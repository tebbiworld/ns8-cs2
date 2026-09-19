# Changelog

## 1.1.0 — 2026-09-19

Alignment with the NethServer module conventions (NethServer/agents skills).

### Changed

- **Secrets moved out of the module environment.** The RCON password, the join password, the GSLT token and the CSTV password are now kept in `state/passwords.env` (mode 0600) instead of `state/environment`, which NS8 mirrors to Redis in plain text. Existing installations are migrated on update; the values do not change. The RCON password is no longer passed on a command line.
- The module backup includes `state/passwords.env`; restore reads the secrets from it (backups taken with 1.0.0 are still restorable).

### Added

- Robot Framework tests (install, update from the previous release, secrets) run on real NS8 nodes through `stephdl/ns8-ci-actions`. The game server itself is not started in CI (70 GB download).

### Platform integration

- **Clone and move.** New `clone-module` step (a link to the restore step): a cloned or moved instance gets its route and settings back instead of coming up unconfigured.
- `org.nethserver.volumes`: the bulk-data volume(s) `cs2-data` can be placed on an additional disk when the module is installed.
- The software centre shows the upstream terms before installation (`terms_url`); release notes are linked (`relnotes_url`).

## 1.0.0 — 2026-09-15

- Initial release: joedwards32/cs2 (pinned) with game modes, maps and
  workshop, bots, CSTV, GSLT token, firewall service, A2S status, RCON
  console action, backup of settings and cfg overrides, restore, settings UI
  (EN/DE), automatic upstream-update releases.
