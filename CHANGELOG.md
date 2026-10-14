# Changelog

## Unreleased (in testing)
- Every unit type can buy Melee Attack, Melee Defence, Armour and Morale, Accuracy if it shoots,
  and Scare Enemies unless it already frightens, whether or not its multiplayer tree has them.
  Artillery gets Armour, Morale and Accuracy only.
- Charge Bonus, Speed, Fatigue Resistance and Ammunition were tried per unit type and did nothing
  in game; they are off (VU_EXPERIMENTAL=all builds them for further tests).
- The upgrade tree puts one line per row under each heading (side by side, neighbouring headings'
  nodes overlapped); percentage bonuses show as "+5%".
- AI clans' upgrade levels are saved in chunks, so up to 12 lines per unit type stay exact.
- Debug builds log the unit cards' numbers (charge, ammunition, ...) when they change.

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
