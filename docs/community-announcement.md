<!--
First community post for the NS8 Counter-Strike 2 module, written in the style
of https://community.nethserver.org/t/ns8-forgejo-testing/28554 (first post).
Paste into a new topic on community.nethserver.org, category "App", tag "ns8".
Fill in the wiki link once the page is published.
-->

# NS8 Counter-Strike 2 (testing)

Hi all,

I've built an NS8 module for a [Counter-Strike 2 dedicated server](https://github.com/joedwards32/CS2) — your own always-on CS2 game server, built on the joedwards32/cs2 image (Steam Runtime + SteamCMD).

It's in my community repository. To try it, add the repo once:

```
api-cli run add-repository --data '{"name":"tebbiworld","url":"https://raw.githubusercontent.com/tebbiworld/ns8-repo/main/ns8/updates/","status":true,"testing":false}'
```

then install **Counter-Strike 2 Server** from the Software Center. (Or straight from the image: `add-module ghcr.io/tebbiworld/cs2:latest 1`.)

What it does:

* Runs a full CS2 dedicated server with game modes Casual, Competitive, Wingman, Arms Race, Demolition, Deathmatch and Custom, map group/start map and Steam Workshop maps or collections
* Bots, server password and CSTV with demo recording, all from the settings page
* Opens the game port (TCP+UDP) and the CSTV port on the node firewall — the ports are yours to choose
* An **RCON console** right on the settings page (and a `run-command` action) plus a live A2S status tile with a `steam://connect` link
* Backs up your settings and cfg overrides in the NS8 backup; the game files are simply re-downloaded on restore

A few things to know:

* **~70 GB of free disk** — SteamCMD preallocates ~58 GB before it will even start and the installed files are ~67 GB; the first download takes 10–30 minutes
* Players outside the LAN need you to set a **Game Server Login Token (GSLT)** for app ID 730 (from steamcommunity.com/dev/managegameservers); with no token the server accepts LAN clients only
* Reckon on 2 CPUs and ~2 GB RAM for the server, plus internet access to Steam at every start
* Players join with the free CS2 client from Steam via `steam://connect/<node>:<port>`
* Still testing — it works on my box, but I'd like more real-world runs

If you fancy hosting a server for your group, give it a go and let me know how it plays — feedback and bug reports very welcome.

Docs: NethServer wiki (tebbiworld repository) · Source: [github.com/tebbiworld/ns8-cs2](https://github.com/tebbiworld/ns8-cs2)

Thanks!

*Category: App · Tags: ns8*
