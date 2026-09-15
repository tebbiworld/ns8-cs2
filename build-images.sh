#!/bin/bash

#
# Copyright (C) 2026 tebbi
# SPDX-License-Identifier: GPL-3.0-or-later
#

set -e

images=()
repobase="${REPOBASE:-ghcr.io/tebbiworld}"
reponame="cs2"

# joedwards32/cs2: Counter-Strike 2 dedicated server on the Steam Runtime
# ("sniper"), pinned. Exposed to the unit as ${CS2_IMAGE} through the
# org.nethserver.images label. The image installs/updates the server files
# with SteamCMD (anonymous login) into /home/steam/cs2-dedicated at every
# start and is configured through environment variables.
cs2_image="docker.io/joedwards32/cs2:4.0.1"

runtime_images=(
    "${cs2_image}"
)

container=$(buildah from scratch)

if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-cs2; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-cs2 -v "${PWD}:/usr/src:Z" docker.io/library/node:24.16.0-slim
fi

echo "Build static UI files with node..."
buildah run \
    --workingdir=/usr/src/ui \
    --env="NODE_OPTIONS=--openssl-legacy-provider" \
    nodebuilder-cs2 \
    sh -c "yarn install && yarn build"

buildah add "${container}" imageroot /imageroot
buildah add "${container}" ui/dist /ui
# node:fwadm: the game port (tcp+udp) and the CSTV port are opened on the node
# firewall as a public service named after the instance. No Traefik route.
buildah config --entrypoint=/ \
    --label="org.nethserver.authorizations=node:fwadm" \
    --label="org.nethserver.rootfull=0" \
    --label="org.nethserver.images=${runtime_images[*]}" \
    "${container}"
buildah commit "${container}" "${repobase}/${reponame}"

images+=("${repobase}/${reponame}")

if [[ -n "${CI}" ]]; then
    printf "images=%s\n" "${images[*],,}" >> "${GITHUB_OUTPUT}"
else
    printf "Publish the images with:\n\n"
    for image in "${images[@],,}"; do printf "  buildah push %s docker://%s:%s\n" "${image}" "${image}" "${IMAGETAG:-latest}" ; done
    printf "\n"
fi
