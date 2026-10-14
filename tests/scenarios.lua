-- End-to-end scenarios against tests/mock_engine.lua. Each check() failure is collected and reported.
local failures, passed = {}, 0
local function check(cond, what)
	if cond then passed = passed + 1 else failures[#failures + 1] = what end
end
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local function pool_text() return MOCK.find("dy_points_to_spend").text end
local F = MOCK.fire
-- MoSS's Yari Ashigaru (aaas_melee_yari, plus its Ikko Ikki variant): one copy with all its abilities.
local YARI, COPY, YARI_FAM = "aaas_melee_yari", "aaas_melee_yari_VU", nil
for _, f in ipairs(VU_UNDER_TEST.families) do if f.id == YARI then YARI_FAM = f end end
local ABILITY_COST
for _, l in ipairs(YARI_FAM.lines) do if l.key == "ab_all" then ABILITY_COST = l.levels[1].cost end end
check(ABILITY_COST ~= nil, "Yari Ashigaru has the single Abilities upgrade")
check(#YARI_FAM.copies == 2 and #YARI_FAM.copies[1].keys == 1, "one copy per unit key (" .. #YARI_FAM.copies .. " keys)")

-- Campaign start ----------------------------------------------------------------
F("LoadingGame", {})
F("NewCampaignStarted", {})
local n_copies = 0
for _, f in ipairs(VU_UNDER_TEST.families) do for _, c in ipairs(f.copies) do n_copies = n_copies + #c.keys end end
check(count(MOCK.locks) == n_copies * #VU_UNDER_TEST.factions,
	"every copy prelocked for every clan at NewCampaignStarted (" .. count(MOCK.locks) .. " = " .. n_copies .. " x " .. #VU_UNDER_TEST.factions .. ")")
check(MOCK.locks["oda/" .. COPY], "AI clans can't recruit copies")
check(not MOCK.locks["shimazu/" .. YARI], "plain units are not locked at start")
F("UICreated", { string = "Campaign UI", component = MOCK.root })
F("FactionTurnStart", { string = "shimazu" })
check(MOCK.find("vu_button") ~= nil, "Veterans HUD button created")

-- Army for retraining: general + 2 plain Yari Ashigaru
MOCK.add_card("Gen_Taisho", 0, true)
MOCK.add_card(YARI, 2)
MOCK.add_card(YARI, 0)

-- Points: 1 per battle the clan fights in, however many units/types --------------
MOCK.battle({ YARI, YARI, "aaas_range_bow" })
MOCK.click(MOCK.find("vu_button"))
check(pool_text() == "1", "one battle = 1 clan point (shows " .. tostring(pool_text()) .. ")")
MOCK.click(MOCK.find("button_cancel"))
MOCK.now = MOCK.now + 10
MOCK.fire("UnitCompletedBattle", { human = true, unit = "aaas_range_bow", fought = false })
for i = 1, 11 do MOCK.battle({ YARI }) end   -- 12 points total

-- List: only unit types the player's clan can recruit -------------------------------
MOCK.click(MOCK.find("vu_button"))
check(pool_text() == "12", "pool after 12 battles (shows " .. tostring(pool_text()) .. ")")
check(MOCK.node_labelled("Yari Ashigaru") ~= nil, "Yari Ashigaru listed")
check(MOCK.node_labelled("Portuguese Tercos") == nil, "Otomo-only units hidden for Shimazu")
local others = 0
for _, f in ipairs(VU_UNDER_TEST.families) do
	local mine = false
	for _, c in ipairs(f.factions) do if c == "shimazu" then mine = true end end
	if not mine then others = others + 1 end
end
check(others > 0, "some unit types are for other clans only (" .. others .. ")")
check(MOCK.find("button_reset").visible == false, "Reset hidden in the list")

-- Tree: buy an ability, retrain the selected army ----------------------------------
MOCK.click(MOCK.node_labelled("Yari Ashigaru"))
check(MOCK.find("vu_title").visible, "tree title shown")
local abilities = MOCK.node_labelled("Abilities")
check(abilities ~= nil, "Abilities node present")
MOCK.click(abilities)
check(pool_text() == tostring(12 - ABILITY_COST), "Abilities cost " .. ABILITY_COST .. " (pool " .. tostring(pool_text()) .. ")")
local retrain = MOCK.find("vu_retrain")
check(retrain and retrain.visible and string.find(MOCK.label_of(retrain), "Retrain (2)", 1, true),
	"Retrain (2) offered for the 2 plain Yari Ashigaru (" .. tostring(retrain and MOCK.label_of(retrain)) .. ")")
MOCK.click(retrain)
check(string.find(MOCK.label_of(retrain), "Confirm", 1, true), "first Retrain click asks to confirm")
check(string.find(retrain.tip, "LOSE", 1, true), "confirmation warns about lost experience")
MOCK.click(retrain)
local made = MOCK.created[#MOCK.created]
check(made and made.units == COPY .. "," .. COPY, "copies spawned beside the army (" .. tostring(made and made.units) .. ")")
check(made and made.x == -246 + 1.0 and made.y == -161, "spawned at the army's position")
check(#MOCK.disbanded == 2, "both originals disbanded (" .. #MOCK.disbanded .. ")")
check(MOCK.locks["shimazu/" .. YARI], "plain Yari Ashigaru locked for the player after the purchase")
check(not MOCK.locks["shimazu/" .. COPY], "the Yari copy is unlocked for the player")
check(MOCK.locks["oda/" .. COPY], "AI still locked out of copies")

-- Escalating stat costs ---------------------------------------------------------------
local before = tonumber(pool_text())
local ma = MOCK.node_labelled("Melee Attack")
MOCK.click(ma) MOCK.click(ma)
local spent = before - tonumber(pool_text())
check(spent >= 2 and MOCK.label_of(ma) == "Melee Attack 2/10", "two Melee Attack picks (spent " .. spent .. ", " .. tostring(MOCK.label_of(ma)) .. ")")
MOCK.click(MOCK.find("button_ok"))
check(MOCK.bundles["shimazu/vu_aaas_melee_yari__stat_melee_attack_mod_2"], "level-2 melee attack bundle applied")

-- Respec: refund minus a 2-point fee, charged on OK --------------------------------------
MOCK.click(MOCK.find("button_ok"))   -- close the list
MOCK.click(MOCK.find("vu_button"))
local p0 = tonumber(pool_text())
MOCK.click(MOCK.node_labelled("Yari Ashigaru"))
MOCK.click(MOCK.find("button_reset"))
local p1 = tonumber(pool_text())
check(p1 == p0 + ABILITY_COST + spent - 2, "respec refunds everything minus 2 (" .. p0 .. " -> " .. p1 .. ")")
MOCK.click(MOCK.find("button_reset"))
check(tonumber(pool_text()) == p1, "a second Reset charges nothing more")
MOCK.click(MOCK.find("button_ok"))
check(not MOCK.bundles["shimazu/vu_aaas_melee_yari__stat_melee_attack_mod_2"], "respec removed the stat bundle")
MOCK.click(MOCK.find("button_ok"))

-- Retrain all armies when no army is selected ---------------------------------------------
MOCK.cards.visible = false
MOCK.click(MOCK.find("vu_button"))
MOCK.click(MOCK.node_labelled("Yari Ashigaru"))
MOCK.click(MOCK.node_labelled("Abilities"))
retrain = MOCK.find("vu_retrain")
check(retrain.visible and string.find(MOCK.label_of(retrain), "Retrain all", 1, true), "Retrain all offered with no army selected")
local n_created = #MOCK.created
MOCK.click(retrain) MOCK.click(retrain)
check(#MOCK.created == n_created + 2, "one new stack per army (" .. (#MOCK.created - n_created) .. ")")
MOCK.click(MOCK.find("button_ok"))
MOCK.cards.visible = true

-- AI: earns per battle, spends on unit types it fought with -------------------------------
MOCK.battle({ YARI }, "oda")
MOCK.battle({ YARI }, "oda")
F("FactionTurnStart", { string = "oda" })
local oda_bundles = 0
for k in pairs(MOCK.bundles) do if string.sub(k, 1, 4) == "oda/" then oda_bundles = oda_bundles + 1 end end
check(oda_bundles >= 1, "AI clan bought stat upgrades (" .. oda_bundles .. " bundles)")

-- Save / load round trip ------------------------------------------------------------------
F("SavingGame", {})
check(MOCK.saved.VU_POOL ~= nil and MOCK.saved.VU_AF_oda == 1, "pool and AI state saved")
local saved_pool = MOCK.saved.VU_POOL
F("LoadingGame", {})
F("UICreated", { string = "Campaign UI", component = MOCK.root })
MOCK.click(MOCK.find("vu_button"))
check(tonumber(pool_text()) == saved_pool, "pool restored after load")
-- AI levels: every packed value fits 24 bits, and save -> load -> save gives the same values
local before, big = {}, 0
for k, v in pairs(MOCK.saved) do
	if string.sub(k, 1, 5) == "VU_AL" then before[k] = v if v >= 2 ^ 24 then big = big + 1 end end
end
check(next(before) ~= nil and big == 0, "AI levels saved, all below 2^24 (" .. big .. " too big)")
F("SavingGame", {})
local same = true
for k, v in pairs(before) do if MOCK.saved[k] ~= v then same = false end end
check(same, "AI levels survive a save/load round trip")

-- Report ---------------------------------------------------------------------------------
RESULT = { passed = passed, failures = failures }
