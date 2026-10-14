# Veteran Upgrades for Master of Strategy Sengoku (Total War: Shogun 2)

The [Veteran Upgrades](https://github.com/keanfreeman/shogun2-veteran-upgrades) mod rebuilt for the
**Master of Strategy Sengoku (MoSS)** overhaul: the multiplayer veteran upgrade trees in the Sengoku
campaign, covering the units a MoSS campaign actually recruits, including MoSS's own.

- **Clan points:** 1 per battle your units fight in, win or lose.
- **Stats** (Melee Attack, Melee Defence, Armour, Morale, Accuracy) can be bought up to 10 times;
  each pick costs more, and stronger stats cost more.
- **Abilities:** one "Abilities" upgrade per unit type unlocks all of its abilities at once (Inspire
  Unit, Hold Firm, ...). Each unit has a single "(Upgraded)" version, so the recruitment list grows by
  at most one entry per unit.
- **Retrain** existing units into their Upgraded version (one army, or all armies at once).
- **AI clans** (MoSS's added clans too) earn points the same way and buy stat upgrades.

Needs MoSS's mandatory packs (Database, Files 1-4 and Original Clans; New Clans isn't supported yet). Use it **instead of**
the regular Veteran Upgrades, not together with it: both add their code to the same game file.
Sengoku Jidai only. Start a new campaign after enabling it.

## How it works

The engine can't change one unit's abilities, and copies of ability records are ignored in battle.
So every unit gets one **unit record copy** (`<unit>_VU`, "(Upgraded)") with all of its unlockable
abilities attached. When you buy the Abilities upgrade, the mod switches your clan's recruitment to
the copy (per-faction recruitment locks), and Retrain replaces existing units with it. Stat upgrades are
effect bundles applied to your faction, covering the originals and all copies.

The code is appended to CA's `export_advice.lua`, which every campaign script loads, and starts when
the campaign script calls `SetCampaign`. The mod ships no `scripting.lua`, so it works alongside
overhauls that replace it (such as MoSS).

The data comes from the game's packs with MoSS's Database and Original Clans packs laid over them
(`MOSS_PACKS` in `build.py`), so unit types, recruitment buildings and clan permissions are MoSS's.
Units with the same in-game name and class (MoSS's `_ikko` variants) form one unit type; units
without a multiplayer tree borrow the tree of a multiplayer unit of the same class; unit types that
no clan can recruit under MoSS are left out.

[`docs/ENGINE_NOTES.md`](docs/ENGINE_NOTES.md) lists what we learned about the engine, including
the things that crash it.

## Repository

| Path | What |
|---|---|
| `veteran_upgrades/build.py` | Generates the whole mod from the game's own data |
| `veteran_upgrades/vu.lua` | Campaign script: points, panel UI, recruitment, retraining, AI |
| `tools_*.py` | Pack reader/writer, DB table codec (RPFM schema), `.loc` codec, reference checker |
| `tools/release.py` | Build + test + `dist/` (pack, Workshop thumbnail, description) |
| `tools/vu_ui_audit.py` | Leftover-tooltip report from a debug build's log |
| `tests/` | Mock campaign engine and scenarios, run with `tests/run_tests.py` |

Nothing from the game is included. The build reads your own copy of the game and writes the mod pack.

## Building

Needs Python 3.10+, a Steam install of Shogun 2, RPFM's Shogun 2 schema, and MoSS: subscribe to its
mandatory Workshop items and enable them once in the CA launcher, which copies them into the game's
`data` folder as `MoSS_Must_*.pack`.

1. `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`
2. Get the schema: install [RPFM](https://github.com/Frodo45127/rpfm), let it download its schemas,
   then point `RPFM_SCHEMA` at `schema_sho2.ron` (or copy it to `./schemas/`).
3. If the game isn't in a default Steam location, set `SHOGUN2_DATA` to its `data` folder.
4. `.venv/bin/python tools/release.py` builds `veteran_upgrades/veteran_upgrades_moss.pack`, runs the
   tests and fills `dist/`. Add `--install` to copy the pack and thumbnail into the game.

To use a local build, add `mod "veteran_upgrades_moss.pack";` (and MoSS's packs) to `user.script.txt` (UTF-16, in
`%APPDATA%\The Creative Assembly\Shogun2\scripts\`).

### Debug builds

`VU_DEBUG=1 .venv/bin/python veteran_upgrades/build.py` logs every view of the panel with its texts
and tooltips to `vu_log.txt` in the game folder; `tools/vu_ui_audit.py` reports leftovers from it.
The mod always writes a short `vu_log.txt` (purchases, battles, errors).

## Testing

`tests/run_tests.py` loads the built pack's `export_advice.lua` against a mock of the campaign scripting API
(`tests/mock_engine.lua`): the full flows, and a smoke test for a few clans including one of MoSS's. It can't
catch engine crashes, so changes still need a play test, ideally with `PROTON_LOG=1` / a debugger
for native crashes.

## License

MIT, see [LICENSE](LICENSE). Total War: Shogun 2 is © SEGA / The Creative Assembly; this project
contains none of its files.
