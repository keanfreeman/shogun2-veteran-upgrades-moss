# Changelog

## 1.2.0 (2026-10-15)
- Multiplayer campaigns: every player's upgrades now stick. Up to 1.1.0 a purchase changed only the
  buyer's game, the game resynced from the host at the end of the turn, and a guest's upgrades
  vanished. Purchases are now sent to every player (in the names of a few of the buyer's units) and
  take effect for everyone when the buyer ends the turn; the names are put back at the next turn.
  Each clan has its own points, from its own battles.
- Multiplayer campaigns saved with 1.1.0 or older: the upgrades in the save can't be assigned to a
  player, so they are refunded as points to every player.
- Single-player saves are unchanged.
- Debug builds in multiplayer: 100 points for every human clan per session.

## 1.1.0
- Every unit type can buy Melee Attack, Melee Defence, Armour and Morale, Accuracy if it shoots, and
  Scare Enemies unless it already frightens, whether or not its multiplayer tree has them. Artillery
  gets Armour, Morale and Accuracy only. (Charge, speed, fatigue and ammunition were tried per unit
  type and did nothing in game; VU_EXPERIMENTAL=all builds them for further tests.)
- The upgrade tree shows one line per row under each heading.
- AI clans' upgrade levels are saved in chunks of 6 lines, so every saved number stays exact.
- Debug builds log the unit cards' numbers when they change.

## 1.0.0 (2026-10-14)
First release for Master of Strategy Sengoku, based on Veteran Upgrades 1.1.0.
- Unit types, recruitment and clan permissions generated from MoSS's data (Original Clans); MoSS's own
  units are covered (units without a multiplayer tree borrow one of the same class), and same-name
  variants such as the Ikko Ikki ones form one unit type.
- One "(Upgraded)" copy per unit with all of its abilities, bought as a single Abilities upgrade.
- Abilities are only offered where they work under MoSS: not when the unit already has one of the
  same name (MoSS renames abilities), not when nothing in MoSS enables a gated ability (Rapid
  Volley), arrow/grenade abilities only for bow/sling units (MoSS's range_effect fires flaming
  arrows), and only to the kinds of unit that carry the ability natively in MoSS. Tooltips name the
  research a gated ability needs.
- Accuracy is not offered to units without a missile weapon or artillery.
- The list sorts each column by recruitment building tier, then cost; mounted units are under Cavalry.
- Sengoku Jidai only. Not supported yet: MoSS's New Clans pack.
