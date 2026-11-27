# SimScore

A World of Warcraft addon for **Forever** that adds a player's SimScore to their tooltip:

> SimScore **91.3** [Warrior][Fury]

The score is how the character's own gear and talents sim against every other character of the same spec: 100 is
the best, 0 the worst, coloured like Warcraft Logs' percentiles. A character scored in more than one spec shows
each, best first. Each spec keeps the character's best score ever, so a respec or a weaker set of gear doesn't
lower it.

Every character is simmed by [Instasims](https://instasims.org) with the same raid buffs, consumables and fight, so
the score only moves when the character changes. Level-60 Fury warriors for now; more specs to come.

## Install

Install the package for your server (region and ruleset), e.g. **SimScore EU PvP**, from CurseForge, Wago or
WowUp. Each package holds the tooltip addon (`SimScore`) and that server's scores (`SimScore_DB_EU_PvP`), updated
daily.

## Repository

- `SimScore/`: the tooltip addon. `Core.lua` is the logic without the game's API (tested in the Instasims repo).
- `SimScore_DB_<REGION>_<Ruleset>/`: one server's scores, `Data.lua` written by the release job.
- `pkgmeta/`: one package per server for the BigWigs packager: the tooltip addon and that server's data addon, nothing
  else (the other servers' folders are ignored, so the package's own folder is left empty and dropped).
- `CHANGELOG.md`: the release notes on CurseForge and Wago; not in the zip.
- `.github/workflows/release.yml`: downloads every server's scores from Instasims
  (`/api/simscores/forever/<region>/<ruleset>.lua`), commits and tags `vYYYYMMDD`, and packages each server to
  CurseForge, Wago and GitHub Releases.

### Before the first release

1. Create one CurseForge and one Wago project per server (`SimScore EU PvP`, …). CurseForge reviews the first file
   by hand.
2. Repo secrets: `CF_API_KEY` (CurseForge's API tokens page), `WAGO_API_TOKEN` (Wago's developer dashboard).
3. Repo variables: `CF_PROJECT_EU_PVP`, `WAGO_PROJECT_EU_PVP`, … for each of the eight servers.
4. Actions → release → Run workflow, and check one package's zip: `SimScore/` and `SimScore_DB_<server>/`.
5. Turn on the daily `schedule` in the workflow.
