# ns8-cs2

[NethServer 8](https://github.com/NethServer/ns8-core) module for a
**Counter-Strike 2 dedicated server**, built on the
[joedwards32/cs2](https://github.com/joedwards32/CS2) image (Steam Runtime +
SteamCMD).

- Game modes Casual, Competitive, Wingman, Arms Race, Demolition, Deathmatch,
  Custom; map group and start map; Steam Workshop maps and collections
- Bots (number, difficulty, quota mode — bots join once the first player is
  connected, `bot_join_after_player`), server password, CSTV with demo
  recording
- Ports chosen in the settings (game port TCP+UDP, CSTV UDP), published on the
  node and opened on the node firewall
- **RCON console** on the settings page (and the `run-command` action); live
  status via A2S query (map, players, version) with a `steam://connect` link
- Free-form additional container variables and cs2 command line arguments
- Settings and cfg overrides in the NS8 backup (the game files are
  re-downloaded); pinned image with automatic upstream-update releases

## Requirements

- **~70 GB free disk** on the node for the module's volume: SteamCMD
  preallocates 58.4 GB before the first download and refuses to install
  with less ("Not enough disk space", app state 0x202); the installed game
  files take **~67 GB** (71 GB download), updates need headroom on top
- 2 CPUs, ~2 GB RAM for the server itself
- Internet access to Steam at every start
- Players use the **free CS2 client from Steam** (Steam account required).
  For players outside the LAN the server needs a **Game Server Login Token**
  (GSLT) for app ID 730, created at
  https://steamcommunity.com/dev/managegameservers and entered in the
  settings; without a token the server accepts LAN clients only.

## Install

Add the repository `https://raw.githubusercontent.com/tebbiworld/ns8-repo/main/ns8/updates/`
in Software Center → Repositories, then install *Counter-Strike 2 Server*. Or
from the leader node:

    add-module ghcr.io/tebbiworld/cs2:latest 1

## Configure

Open the instance settings: server name, optional password, GSLT token,
maximum players, game port, game mode, maps, bots, CSTV, and save. The first
start downloads the game files — expect 10–30 minutes depending on the
connection; the settings page shows the state (container running / SteamCMD
still installing / server online with map and players).

| Setting | Notes |
| --- | --- |
| Game port | Published on all node addresses (TCP+UDP) and opened on the node firewall as public service `<instance>`; RCON listens on the TCP side. Default 27015. |
| GSLT token | Stored in the module environment; the field is never echoed back. Leave empty to keep it, tick *remove* to delete it. |
| LAN mode | `sv_lan 1`: no Steam authentication, LAN clients only. Otherwise the token decides (see above). |
| Game mode | Mapped to `game_type`/`game_mode` (Casual 0/0, Competitive 0/1, Wingman 0/2, Arms Race 1/0, Demolition 1/1, Deathmatch 1/2, Custom 3/0). |
| Workshop | A collection ID downloads the collection (choose maps with `ds_workshop_changelevel` in the console); a map ID loads that map at start. Both override map group/start map. |
| Validate files | `STEAMAPPVALIDATE=1`: SteamCMD verifies every file at start (slow) — for repairing a broken customisation. |
| Additional variables | `KEY=VALUE` lines passed to the image after the generated ones, e.g. `CS2_CFG_URL=…` (customisation bundle), `CS2_LOG_*`, `DEBUG=…`. Variables managed by the page are refused. |

Game mode defaults live in `game/csgo/cfg/gamemode_*.cfg` inside the
`cs2-data` volume; override them in `gamemode_<mode>_server.cfg` (see the
image README). The container runs the server as uid 1000; the volume is
owned accordingly.

### Console

The settings page sends console commands through RCON: `status`,
`changelevel de_dust2`, `bot_add`, `bot_kick`, `mp_restartgame 1`,
`say …`, `ds_workshop_listmaps`, … From the leader node:

    api-cli run module/cs21/run-command --data '{"command":"status"}'

## Connecting

Players install CS2 from Steam (free) and join via
`steam://connect/<node IP or name>:<port>` (link on the settings page) or
`connect <address>` in the game console. For players outside the LAN forward
the game port (TCP+UDP) — and the CSTV port if enabled — on the router to the
node, and enter a GSLT token.

## Backup and restore

The NS8 backup contains the module settings (incl. token and RCON password),
the server cfg directory (`game/csgo/cfg`: game mode overrides, custom
configs) and the `pre.sh`/`post.sh` hooks — **not** the ~67 GB of game files.
A restore recreates the instance, restores the cfg files into a fresh
volume, re-applies settings and firewall service and starts the server,
which downloads the game files again.

## Updates

The module pins the `joedwards32/cs2` image. A weekly GitHub Action checks
Docker Hub for a newer release tag that is at least six weeks old and
releases a new module version; the Software Center update restarts the
server. The **game files** are updated by SteamCMD at every container start
independently of that — restart the instance after a CS2 update.

## Development

    IMAGETAG=1.0.0 bash ./build-images.sh

## License

GPL-3.0-or-later. Counter-Strike is a trademark of Valve Corporation; the
server files are downloaded from Steam at runtime under Valve's terms and are
not redistributed.
