local E, L, V, P, G = unpack(select(2, ...)); --Engine

--Lua functions
local unpack = unpack
local strlower = strlower
--WoW API / Variables
local IsPlayerSpell = IsPlayerSpell

local function Defaults(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0
	}
end

G.unitframe.aurafilters = {};

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
	[339] = Defaults(1), --Entangling Roots(Rank 1)
	[1062] = Defaults(1), --Entangling Roots(Rank 2)
	[5195] = Defaults(1), --Entangling Roots(Rank 3)
	[5196] = Defaults(1), --Entangling Roots(Rank 4)
	[9852] = Defaults(1), --Entangling Roots(Rank 5)
	[9853] = Defaults(1), --Entangling Roots(Rank 6)
	[2637] = Defaults(1), --Hibernate(Rank 1)
	[18657] = Defaults(1), --Hibernate(Rank 2)
	[18658] = Defaults(1), --Hibernate(Rank 3)
	[19675] = Defaults(2), --Feral Charge Effect
	[5211] = Defaults(4), --Bash(Rank 1)
	[6798] = Defaults(4), --Bash(Rank 2)
	[8983] = Defaults(4), --Bash(Rank 3)
	[16922] = Defaults(2), --Starfire Stun
	[9005] = Defaults(2), --Pounce(Rank 1)
	[9823] = Defaults(2), --Pounce(Rank 2)
	[9827] = Defaults(2), --Pounce(Rank 3)
	--Hunter
	[1499] = Defaults(3), --Freezing Trap(Rank 1)
	[14310] = Defaults(3), --Freezing Trap(Rank 2)
	[14311] = Defaults(3), --Freezing Trap(Rank 3)
	[13809] = Defaults(1), --Frost Trap
	[19503] = Defaults(4), --Scatter Shot
	[5116] = Defaults(2), --Concussive Shot
	[297] = Defaults(2), --Wing Clip(Rank 1)
	[14267] = Defaults(2), --Wing Clip(Rank 2)
	[14268] = Defaults(2), --Wing Clip(Rank 3)
	[1513] = Defaults(2), --Scare Beast(Rank 1)
	[14326] = Defaults(2), --Scare Beast(Rank 2)
	[14327] = Defaults(2), --Scare Beast(Rank 3)
	[19577] = Defaults(2), --Intimidation
	[19386] = Defaults(2), --Wyvern Sting(Rank 1)
	[24132] = Defaults(2), --Wyvern Sting(Rank 2)
	[24133] = Defaults(2), --Wyvern Sting(Rank 3)
	[19229] = Defaults(2), --Improved Wing Clip
	[19306] = Defaults(2), --Counterattack(Rank 1)
	[20909] = Defaults(2), --Counterattack(Rank 2)
	[20910] = Defaults(2), --Counterattack(Rank 3)
	--Mage
	[118] = Defaults(3), --Polymorph(Rank 1)
	[12824] = Defaults(3), --Polymorph(Rank 2)
	[12825] = Defaults(3), --Polymorph(Rank 3)
	[12826] = Defaults(3), --Polymorph(Rank 4)
	[122] = Defaults(1), --Frost Nova(Rank 1)
	[865] = Defaults(1), --Frost Nova(Rank 2)
	[6131] = Defaults(1), --Frost Nova(Rank 3)
	[10230] = Defaults(1), --Frost Nova(Rank 4)
	[12494] = Defaults(2), --Frostbite
	[116] = Defaults(2), -- Frostbolt(Rank 1)
	[205] = Defaults(2), -- Frostbolt(Rank 2)
	[837] = Defaults(2), -- Frostbolt(Rank 3)
	[7322] = Defaults(2), -- Frostbolt(Rank 4)
	[8406] = Defaults(2), -- Frostbolt(Rank 5)
	[8407] = Defaults(2), -- Frostbolt(Rank 6)
	[8408] = Defaults(2), -- Frostbolt(Rank 7)
	[10179] = Defaults(2), -- Frostbolt(Rank 8)
	[10180] = Defaults(2), -- Frostbolt(Rank 9)
	[10181] = Defaults(2), -- Frostbolt(Rank 10)
	[25304] = Defaults(2), -- Frostbolt(Rank 11)
	[12355] = Defaults(2), --Impact
	--Paladin
	[853] = Defaults(3), --Hammer of Justice(Rank 1)
	[5588] = Defaults(3), --Hammer of Justice(Rank 2)
	[5589] = Defaults(3), --Hammer of Justice(Rank 3)
	[10308] = Defaults(3), --Hammer of Justice(Rank 4)
	[20066] = Defaults(3), --Repentance
	--Priest
	[8122] = Defaults(3), --Psychic Scream(Rank 1)
	[8124] = Defaults(3), --Psychic Scream(Rank 2)
	[10888] = Defaults(3), --Psychic Scream(Rank 3)
	[10890] = Defaults(3), --Psychic Scream(Rank 4)
	[605] = Defaults(5), --Mind Control(Rank 1)
	[10911] = Defaults(5), --Mind Control(Rank 2)
	[10912] = Defaults(5), --Mind Control(Rank 3)
	[15269] = Defaults(2), --Blackout
	[15407] = Defaults(2), --Mind Flay(Rank 1)
	[17311] = Defaults(2), --Mind Flay(Rank 2)
	[17312] = Defaults(2), --Mind Flay(Rank 3)
	[17313] = Defaults(2), --Mind Flay(Rank 4)
	[17314] = Defaults(2), --Mind Flay(Rank 5)
	[18807] = Defaults(2), --Mind Flay(Rank 6)
	--Rogue
	[6770] = Defaults(4), --Sap(Rank 1)
	[2070] = Defaults(4), --Sap(Rank 2)
	[11297] = Defaults(4), --Sap(Rank 3)
	[2094] = Defaults(5), --Blind
	[408] = Defaults(4), --Kidney Shot(Rank 1)
	[8643] = Defaults(4), --Kidney Shot(Rank 2)
	[1833] = Defaults(2), --Cheap Shot
	[1776] = Defaults(2), --Gouge(Rank 1)
	[1777] = Defaults(2), --Gouge(Rank 2)
	[8629] = Defaults(2), --Gouge(Rank 3)
	[11285] = Defaults(2), --Gouge(Rank 4)
	[11286] = Defaults(2), --Gouge(Rank 5)
	[5530] = Defaults(2), -- Mace Stun Effect
	--Shaman
	[2484] = Defaults(1), --Earthbind Totem
	[8056] = Defaults(2), --Frost Shock(Rank 1)
	[8058] = Defaults(2), --Frost Shock(Rank 2)
	[10472] = Defaults(2), --Frost Shock(Rank 3)
	[10473] = Defaults(2), --Frost Shock(Rank 4)
	--Warlock
	[5782] = Defaults(3), --Fear(Rank 1)
	[6213] = Defaults(3), --Fear(Rank 2)
	[6215] = Defaults(3), --Fear(Rank 3)
	[18223] = Defaults(2), --Curse of Exhaustion
	[18093] = Defaults(2), --Pyroclasm
	[710] = Defaults(2), --Banish(Rank 1)
	[18647] = Defaults(2), --Banish(Rank 2)
	--Warrior
	[5246] = Defaults(4), --Intimidating Shout
	[1715] = Defaults(2), --Hamstring(Rank 1)
	[7372] = Defaults(2), --Hamstring(Rank 2)
	[7373] = Defaults(2), --Hamstring(Rank 3)
	[12809] = Defaults(2), --Concussion Blow
	[20252] = Defaults(2), --Intercept(Rank 1)
	[20616] = Defaults(2), --Intercept(Rank 2)
	[20617] = Defaults(2), --Intercept(Rank 3)
	--Racial
	[20549] = Defaults(2), --War Stomp
	},
}

-- These are buffs that can be considered "protection" buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
	--Hunter
	--Mage
	[11958] = Defaults(2), --Ice Block A
	[27619] = Defaults(2), --Ice Block B
	--Paladin
	[498] = Defaults(2), --Divine Protection(Rank 1)
	[5573] = Defaults(2), --Divine Protection(Rank 2)
	[642] = Defaults(2), --Divine Shield(Rank 1)
	[1020] = Defaults(2), --Divine Shield(Rank 2)
	[1022] = Defaults(2), --Blessing of Protection(Rank 1)
	[5599] = Defaults(2), --Blessing of Protection(Rank 2)
	[10278] = Defaults(2), --Blessing of Protection(Rank 3)
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Consumables
	[3169] = Defaults(2), --Limited Invulnerability Potion
	--Racial
	--All Classes
	[19753] = Defaults(2), --Divine Intervention
	},
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
	--Hunter
	--Mage
	--Paladin
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Racial
	},
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	--Druid
	--Hunter
	--Mage
	--Paladin
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Racial
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	--Druid
	--Hunter
	--Mage
	--Paladin
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Racial
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Onyxia's Lair
		[18431] = Defaults(2), --Bellowing Roar
	-- Molten Core
		[19703] = Defaults(2), --Lucifron's Curse
		[19408] = Defaults(2), --Panic
		[19716] = Defaults(2), --Gehennas' Curse
		[20277] = Defaults(2), --Fist of Ragnaros
		[20475] = Defaults(6), --Living Bomb
		[19695] = Defaults(6), --Inferno
		[19659] = Defaults(2), --Ignite Mana
		[19714] = Defaults(2), --Deaden Magic
		[19713] = Defaults(2), --Shazzrah's Curse
	-- Blackwing's Lair
		[23023] = Defaults(2), --Conflagration
		[18173] = Defaults(2), --Burning Adrenaline
		[24573] = Defaults(2), --Mortal Strike
		[23340] = Defaults(2), --Shadow of Ebonroc
		[23170] = Defaults(2), --Brood Affliction: Bronze
		[22687] = Defaults(2), --Veil of Shadow
	-- Zul'Gurub
		[23860] = Defaults(2), --Holy Fire
		[22884] = Defaults(2), --Psychic Scream
		[23918] = Defaults(2), --Sonic Burst
		[24111] = Defaults(2), --Corrosive Poison
		[21060] = Defaults(2), --Blind
		[24328] = Defaults(2), --Corrupted Blood
		[16856] = Defaults(2), --Mortal Strike
		[24664] = Defaults(2), --Sleep
		[17172] = Defaults(2), --Hex
		[24306] = Defaults(2), --Delusions of Jin'do
	-- Ahn'Qiraj Ruins
		[25646] = Defaults(2), --Mortal Wound
		[25471] = Defaults(2), --Attack Order
		[96] = Defaults(2), --Dismember
		[25725] = Defaults(2), --Paralyze
		[25189] = Defaults(2), --Enveloping Winds
	-- Ahn'Qiraj Temple
		[785] = Defaults(2), --True Fulfillment
		[26580] = Defaults(2), --Fear
		[26050] = Defaults(2), --Acid Spit
		[26180] = Defaults(2), --Wyvern Sting
		[26053] = Defaults(2), --Noxious Poison
		[26613] = Defaults(2), --Unbalancing Strike
		[26029] = Defaults(2), --Dark Glare
	-- Naxxramas
		[28732] = Defaults(2), --Widow's Embrace
		[28622] = Defaults(2), --Web Wrap
		[28169] = Defaults(2), --Mutating Injection
		[29213] = Defaults(2), --Curse of the Plaguebringer
		[28835] = Defaults(2), --Mark of Zeliek
		[27808] = Defaults(2), --Frost Blast
		[28410] = Defaults(2), --Chains of Kel'Thuzad
		[27819] = Defaults(2), --Detonate Mana
	},
}

G.unitframe.aurafilters.DungeonDebuffs = {
	type = 'Whitelist',
	spells = {
		[246] = Defaults(2), --Slow
		[6533] = Defaults(2), --Net
		[8399] = Defaults(2), --Sleep
	-- Blackrock Depths
		[13704] = Defaults(2), --Psychic Scream
	-- Deadmines
		[6304] = Defaults(2), --Rhahk'Zor Slam
		[12097] = Defaults(2), --Pierce Armor
		[7399] = Defaults(2), --Terrify
		[6713] = Defaults(2), --Disarm
		[5213] = Defaults(2), --Molten Metal
		[5208] = Defaults(2), --Poisoned Harpoon
	-- Maraudon
		[7964] = Defaults(2), --Smoke Bomb
		[21869] = Defaults(2), --Repulsive Gaze
	--
		[744] = Defaults(2), --Poison
		[18267] = Defaults(2), --Curse of Weakness
		[20800] = Defaults(2), --Immolate
	-- Razorfen Downs
		[12255] = Defaults(2), --Curse of Tuten'kash
		[12252] = Defaults(2), --Web Spray
		[7645] = Defaults(2), --Dominate Mind
		[12946] = Defaults(2), --Putrid Stench
	-- Razorfen Kraul
		[14515] = Defaults(2), --Dominate Mind
	-- Scarlet Monastry
		[9034] = Defaults(2), --Immolate
		[8814] = Defaults(2), --Flame Spike
		[8988] = Defaults(2), --Silence
		[9256] = Defaults(2), --Deep Sleep
		[8282] = Defaults(2), --Curse of Blood
	-- Shadowfang Keep
		[7068] = Defaults(2), --Veil of Shadow
		[7125] = Defaults(2), --Toxic Saliva
		[7621] = Defaults(2), --Arugal's Curse
	--Stratholme
		[16798] = Defaults(2), --Enchanting Lullaby
		[12734] = Defaults(2), --Ground Smash
		[17293] = Defaults(2), --Burning Winds
		[17405] = Defaults(2), --Domination
		[16867] = Defaults(2), --Banshee Curse
		[6016] = Defaults(2), --Pierce Armor
		[16869] = Defaults(2), --Ice Tomb
		[17307] = Defaults(2), --Knockout
	-- Sunken Temple
		[12889] = Defaults(2), --Curse of Tongues
		[12888] = Defaults(2), --Cause Insanity
		[12479] = Defaults(2), --Hex of Jammal'an
		[12493] = Defaults(2), --Curse of Weakness
		[12890] = Defaults(2), --Deep Slumber
		[24375] = Defaults(2), --War Stomp
	-- Uldaman
		[3356] = Defaults(2), --Flame Lash
		[6524] = Defaults(2), --Ground Tremor
	-- Wailing Caverns
		[8040] = Defaults(2), --Druid's Slumber
		[8142] = Defaults(2), --Grasping Vines
		[7967] = Defaults(2), --Naralex's Nightmare
		[8150] = Defaults(2), --Thundercrack
	-- Zul'Farrak
		[11836] = Defaults(2), --Freeze Solid
	-- World Bosses
		[21056] = Defaults(2), --Mark of Kazzak
		[24814] = Defaults(2), --Seeping Fog
	},
}

--[[
	RAID BUFFS:
	Buffs that are provided by NPCs in raid or other PvE content.
	This can be buffs put on other enemies or on players.
]]
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	spells = {
		--Mythic/Mythic+
		--Raids
	},
}

-- Spells that we want to show the duration backwards
E.ReverseTimer = {}

-- BuffWatch: List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local name = GetSpellInfo(id)
	if not name then return end

	local r, g, b = 1, 1, 1
	if color then r, g, b = unpack(color) end

	local r2, g2, b2 = 1, 1, 1
	if textColor then r2, g2, b2 = unpack(textColor) end

	local rankText = GetSpellSubtext(id)
	local spellRank = rankText and strfind(rankText, '%d') and GetSpellSubtext(id) or nil

	return {
		enabled = true,
		id = id,
		name = name,
		rank = spellRank,
		point = point or 'TOPLEFT',
		color = {r = r, g = g, b = b},
		anyUnit = anyUnit,
		onlyShowMissing = onlyShowMissing,
		style = style or 'coloredIcon',
		displayText = displayText or false,
		decimalThreshold = decimalThreshold or 5,
		textColor = {r = r2, g = g2, b = b2},
		textThreshold = textThreshold or -1,
		xOffset = xOffset or 0,
		yOffset = yOffset or 0,
		sizeOverride = sizeOverride or 0
	}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[1243] = ClassBuff(1243, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 1)
		[1244] = ClassBuff(1244, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 2)
		[1245] = ClassBuff(1245, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 3)
		[2791] = ClassBuff(2791, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 4)
		[10937] = ClassBuff(10937, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 5)
		[10938] = ClassBuff(10938, "TOPLEFT", {1, 1, 0.66}, true), --Power Word: Fortitude (Rank 6)
		[21562] = ClassBuff(21562, "TOPLEFT", {1, 1, 0.66}, true), --Prayer of Fortitude (Rank 1)
		[21564] = ClassBuff(21564, "TOPLEFT", {1, 1, 0.66}, true), --Prayer of Fortitude (Rank 2)
		[14752] = ClassBuff(14752, "TOPRIGHT", {0.2, 0.7, 0.2}, true), --Divine Spirit (Rank 1)
		[14818] = ClassBuff(14818, "TOPRIGHT", {0.2, 0.7, 0.2}, true), --Divine Spirit (Rank 2)
		[14819] = ClassBuff(14819, "TOPRIGHT", {0.2, 0.7, 0.2}, true), --Divine Spirit (Rank 3)
		[27841] = ClassBuff(27841, "TOPRIGHT", {0.2, 0.7, 0.2}, true), --Divine Spirit (Rank 4)
		[27581] = ClassBuff(27581, "TOPRIGHT", {0.2, 0.7, 0.2}, true), --Prayer of Spirit (Rank 1)
		[976] = ClassBuff(976, "BOTTOMLEFT", {0.7, 0.7, 0.7}, true), --Shadow Protection (Rank 1)
		[10957] = ClassBuff(10957, "BOTTOMLEFT", {0.7, 0.7, 0.7}, true), --Shadow Protection (Rank 2)
		[10958] = ClassBuff(10958, "BOTTOMLEFT", {0.7, 0.7, 0.7}, true), --Shadow Protection (Rank 3)
		[27683] = ClassBuff(27683, "BOTTOMLEFT", {0.7, 0.7, 0.7}, true), --Prayer of Shadow Protection (Rank 1)
		[17] = ClassBuff(17, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 1)
		[592] = ClassBuff(592, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 2)
		[600] = ClassBuff(600, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 3), true
		[3747] = ClassBuff(3747, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 4)
		[6065] = ClassBuff(6065, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 5)
		[6066] = ClassBuff(6066, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 6)
		[10898] = ClassBuff(10898, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 7)
		[10899] = ClassBuff(10899, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 8)
		[10900] = ClassBuff(10900, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 9)
		[10901] = ClassBuff(10901, "BOTTOM", {0.00, 0.00, 1.00}), --Power Word: Shield (Rank 10)
		[139] = ClassBuff(139, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 1)
		[6074] = ClassBuff(6074, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 2)
		[6075] = ClassBuff(6075, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 3)
		[6076] = ClassBuff(6076, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 4)
		[6077] = ClassBuff(6077, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 5)
		[6078] = ClassBuff(6078, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 6)
		[10927] = ClassBuff(10927, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 7)
		[10928] = ClassBuff(10928, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 8)
		[10929] = ClassBuff(10929, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 9)
		[25315] = ClassBuff(25315, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Renew (Rank 10)
	},
	DRUID = {
		[1126] = ClassBuff(1126, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 1)
		[5232] = ClassBuff(5232, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 2)
		[6756] = ClassBuff(6756, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 3)
		[5234] = ClassBuff(5234, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 4)
		[8907] = ClassBuff(8907, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 5)
		[9884] = ClassBuff(9884, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 6)
		[16878] = ClassBuff(16878, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Mark of the Wild (Rank 7)
		[21849] = ClassBuff(21849, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Gift of the Wild (Rank 1)
		[21850] = ClassBuff(21850, "TOPLEFT", {0.2, 0.8, 0.8}, true), --Gift of the Wild (Rank 2)
		[467] = ClassBuff(467, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 1)
		[782] = ClassBuff(782, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 2)
		[1075] = ClassBuff(1075, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 3)
		[8914] = ClassBuff(8914, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 4)
		[9756] = ClassBuff(9756, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 5)
		[9910] = ClassBuff(9910, "TOPRIGHT", {0.4, 0.2, 0.8}, true), --Thorns (Rank 6)
		[774] = ClassBuff(774, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 1)
		[1058] = ClassBuff(1058, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 2)
		[1430] = ClassBuff(1430, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 3)
		[2090] = ClassBuff(2090, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 4)
		[2091] = ClassBuff(2091, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 5)
		[3627] = ClassBuff(3627, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 6)
		[8910] = ClassBuff(8910, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 7)
		[9839] = ClassBuff(9839, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 8)
		[9840] = ClassBuff(9840, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 9)
		[9841] = ClassBuff(9841, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 10)
		[25299] = ClassBuff(25299, "BOTTOMLEFT", {0.83, 1.00, 0.25}), --Rejuvenation (Rank 11)
		[8936] = ClassBuff(8936, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 1)
		[8938] = ClassBuff(8938, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 2)
		[8939] = ClassBuff(8939, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 3)
		[8940] = ClassBuff(8940, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 4)
		[8941] = ClassBuff(8941, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 5)
		[9750] = ClassBuff(9750, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 6)
		[9856] = ClassBuff(9856, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 7)
		[9857] = ClassBuff(9857, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 8)
		[9858] = ClassBuff(9858, "BOTTOMRIGHT", {0.33, 0.73, 0.75}), --Regrowth (Rank 9)
		[29166] = ClassBuff(29166, "CENTER", {0.49, 0.60, 0.55}, true), --Innervate
	},
	PALADIN = {
		[1044] = ClassBuff(1044, "CENTER", {0.89, 0.45, 0}), --Blessing of Freedom
		[6940] = ClassBuff(6940, "CENTER", {0.89, 0.1, 0.1}), --Blessing Sacrifice (Rank 1)
		[20729] = ClassBuff(20729, "CENTER", {0.89, 0.1, 0.1}), --Blessing Sacrifice (Rank 2)
		[19740] = ClassBuff(19740, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 1)
		[19834] = ClassBuff(19834, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 2)
		[19835] = ClassBuff(19835, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 3)
		[19836] = ClassBuff(19836, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 4)
		[19837] = ClassBuff(19837, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 5)
		[19838] = ClassBuff(19838, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 6)
		[25291] = ClassBuff(25291, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Might (Rank 7)
		[19742] = ClassBuff(19742, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 1)
		[19850] = ClassBuff(19850, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 2)
		[19852] = ClassBuff(19852, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 3)
		[19853] = ClassBuff(19853, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 4)
		[19854] = ClassBuff(19854, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 5)
		[25290] = ClassBuff(25290, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Blessing of Wisdom (Rank 6)
		[25782] = ClassBuff(25782, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Greater Blessing of Might (Rank 1)
		[25916] = ClassBuff(25916, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Greater Blessing of Might (Rank 2)
		[25894] = ClassBuff(25894, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Greater Blessing of Wisdom (Rank 1)
		[25918] = ClassBuff(25918, "TOPLEFT", {0.2, 0.8, 0.2}, true), --Greater Blessing of Wisdom (Rank 2)
		[465] = ClassBuff(465, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 1)
		[10290] = ClassBuff(10290, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 2)
		[643] = ClassBuff(643, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 3)
		[10291] = ClassBuff(10291, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 4)
		[1032] = ClassBuff(1032, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 5)
		[10292] = ClassBuff(10292, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 6)
		[10293] = ClassBuff(10293, "BOTTOMLEFT", {0.58, 1.00, 0.50}), --Devotion Aura (Rank 7)
		[19977] = ClassBuff(19977, "BOTTOMRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Light (Rank 1)
		[19978] = ClassBuff(19978, "BOTTOMRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Light (Rank 2)
		[19979] = ClassBuff(19979, "BOTTOMRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Light (Rank 3)
		[1022] = ClassBuff(1022, "TOPRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Protection (Rank 1)
		[5599] = ClassBuff(5599, "TOPRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Protection (Rank 2)
		[10278] = ClassBuff(10278, "TOPRIGHT", {0.17, 1.00, 0.75}, true), --Blessing of Protection (Rank 3)
		[19746] = ClassBuff(19746, "BOTTOMLEFT", {0.83, 1.00, 0.07}), --Concentration Aura
	},
	SHAMAN = {
		[29203] = ClassBuff(29203, "TOPRIGHT", {0.7, 0.3, 0.7}), --Healing Way
		[16237] = ClassBuff(16237, "RIGHT", {0.2, 0.2, 1}), --Ancestral Fortitude
		[25909] = ClassBuff(25909, "TOP", {0.00, 0.00, 0.50}), --Tranquil Air
		[8185] = ClassBuff(8185, "TOPLEFT", {0.05, 1.00, 0.50}), --Fire Resistance Totem (Rank 1)
		[10534] = ClassBuff(10534, "TOPLEFT", {0.05, 1.00, 0.50}), --Fire Resistance Totem (Rank 2)
		[10535] = ClassBuff(10535, "TOPLEFT", {0.05, 1.00, 0.50}), --Fire Resistance Totem (Rank 3)
		[8182] = ClassBuff(8182, "TOPLEFT", {0.54, 0.53, 0.79}), --Frost Resistance Totem (Rank 1)
		[10476] = ClassBuff(10476, "TOPLEFT", {0.54, 0.53, 0.79}), --Frost Resistance Totem (Rank 2)
		[10477] = ClassBuff(10477, "TOPLEFT", {0.54, 0.53, 0.79}), --Frost Resistance Totem (Rank 3)
		[10596] = ClassBuff(10596, "TOPLEFT", {0.33, 1.00, 0.20}), --Nature Resistance Totem (Rank 1)
		[10598] = ClassBuff(10598, "TOPLEFT", {0.33, 1.00, 0.20}), --Nature Resistance Totem (Rank 2)
		[10599] = ClassBuff(10599, "TOPLEFT", {0.33, 1.00, 0.20}), --Nature Resistance Totem (Rank 3)
		[5672] = ClassBuff(5672, "BOTTOM", {0.67, 1.00, 0.50}), --Healing Stream Totem (Rank 1)
		[6371] = ClassBuff(6371, "BOTTOM", {0.67, 1.00, 0.50}), --Healing Stream Totem (Rank 2)
		[6372] = ClassBuff(6372, "BOTTOM", {0.67, 1.00, 0.50}), --Healing Stream Totem (Rank 3)
		[10460] = ClassBuff(10460, "BOTTOM", {0.67, 1.00, 0.50}), --Healing Stream Totem (Rank 4)
		[10461] = ClassBuff(10461, "BOTTOM", {0.67, 1.00, 0.50}), --Healing Stream Totem (Rank 5)
		[16191] = ClassBuff(16191, "BOTTOMLEFT", {0.67, 1.00, 0.80}), --Mana Tide Totem (Rank 1)
		[17355] = ClassBuff(17355, "BOTTOMLEFT", {0.67, 1.00, 0.80}), --Mana Tide Totem (Rank 2)
		[17360] = ClassBuff(17360, "BOTTOMLEFT", {0.67, 1.00, 0.80}), --Mana Tide Totem (Rank 3)
		[5677] = ClassBuff(5677, "LEFT", {0.67, 1.00, 0.80}), --Mana Spring Totem (Rank 1)
		[10491] = ClassBuff(10491, "LEFT", {0.67, 1.00, 0.80}), --Mana Spring Totem (Rank 2)
		[10493] = ClassBuff(10493, "LEFT", {0.67, 1.00, 0.80}), --Mana Spring Totem (Rank 3)
		[10494] = ClassBuff(10494, "LEFT", {0.67, 1.00, 0.80}), --Mana Spring Totem (Rank 4)
		[8072] = ClassBuff(8072, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 1)
		[8156] = ClassBuff(8156, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 2)
		[8157] = ClassBuff(8157, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 3)
		[10403] = ClassBuff(10403, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 4)
		[10404] = ClassBuff(10404, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 5)
		[10405] = ClassBuff(10405, "BOTTOMRIGHT", {0.00, 0.00, 0.26}), --Stoneskin Totem (Rank 6)
	},
	WARRIOR = {
		[6673] = ClassBuff(6673, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 1)
		[5242] = ClassBuff(5242, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 2)
		[6192] = ClassBuff(6192, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 3)
		[11549] = ClassBuff(11549, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 4)
		[11550] = ClassBuff(11550, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 5)
		[11551] = ClassBuff(11551, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 6)
		[25289] = ClassBuff(25289, "TOPLEFT", {0.2, 0.2, 1}, true), --Battle Shout (Rank 7)
	},
	MAGE = {
		[1459] = ClassBuff(1459, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Intellect (Rank 1)
		[1460] = ClassBuff(1460, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Intellect (Rank 2)
		[1461] = ClassBuff(1461, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Intellect (Rank 3)
		[10156] = ClassBuff(10156, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Intellect (Rank 4)
		[10157] = ClassBuff(10157, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Intellect (Rank 5)
		[23028] = ClassBuff(23028, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Brilliance (Rank 1)
		[27127] = ClassBuff(27127, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Arcane Brilliance (Rank 2)
		[604] = ClassBuff(604, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Dampen Magic (Rank 1)
		[8450] = ClassBuff(8450, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Dampen Magic (Rank 2)
		[8451] = ClassBuff(8451, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Dampen Magic (Rank 3)
		[10173] = ClassBuff(10173, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Dampen Magic (Rank 4)
		[10174] = ClassBuff(10174, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Dampen Magic (Rank 5)
		[1008] = ClassBuff(1008, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Amplify Magic (Rank 1)
		[8455] = ClassBuff(8455, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Amplify Magic (Rank 2)
		[10169] = ClassBuff(10169, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Amplify Magic (Rank 3)
		[10170] = ClassBuff(10170, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Amplify Magic (Rank 4)
		[12438] = ClassBuff(12438, "CENTER", {0.00, 0.00, 0.50}, true), --Slow Fall
	},
	HUNTER = {
		[19506] = ClassBuff(19506, "TOPLEFT", {0.89, 0.09, 0.05}), --Trueshot Aura (Rank 1)
		[20905] = ClassBuff(20905, "TOPLEFT", {0.89, 0.09, 0.05}), --Trueshot Aura (Rank 2)
		[20906] = ClassBuff(20906, "TOPLEFT", {0.89, 0.09, 0.05}), --Trueshot Aura (Rank 3)
	},
	WARLOCK = {
		[5597] = ClassBuff(5597, "TOPLEFT", {0.89, 0.09, 0.05}, true), --Unending Breath
		[6512] = ClassBuff(6512, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Detect Lesser Invisibility
		[2970] = ClassBuff(2970, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Detect Invisibility
		[11743] = ClassBuff(11743, "TOPRIGHT", {0.2, 0.8, 0.2}, true), --Detect Greater Invisibility
	},
	PET = {
	--Warlock Imp
		[6307] = ClassBuff(6307, "BOTTOMLEFT", {0.89, 0.09, 0.05}), --Blood Pact (Rank 1)
		[7804] = ClassBuff(7804, "BOTTOMLEFT", {0.89, 0.09, 0.05}), --Blood Pact (Rank 2)
		[7805] = ClassBuff(7805, "BOTTOMLEFT", {0.89, 0.09, 0.05}), --Blood Pact (Rank 3)
		[11766] = ClassBuff(11766, "BOTTOMLEFT", {0.89, 0.09, 0.05}), --Blood Pact (Rank 4)
		[11767] = ClassBuff(11767, "BOTTOMLEFT", {0.89, 0.09, 0.05}), --Blood Pact (Rank 5)
	--Warlock Felhunter
		[19480] = ClassBuff(19480, "BOTTOMLEFT", {0.2, 0.8, 0.2}), --Paranoia
	--Hunter Pets
		[24604] = ClassBuff(24604, "TOPRIGHT", {0.08, 0.59, 0.41}), --Furious Howl (Rank 1)
		[24605] = ClassBuff(24605, "TOPRIGHT", {0.08, 0.59, 0.41}), --Furious Howl (Rank 2)
		[24603] = ClassBuff(24603, "TOPRIGHT", {0.08, 0.59, 0.41}), --Furious Howl (Rank 3)
		[24597] = ClassBuff(24597, "TOPRIGHT", {0.08, 0.59, 0.41}), --Furious Howl (Rank 4)
	},
	ROGUE = {}, --No buffs
}

-- Profile specific BuffIndicator
P.unitframe.filters = {
	buffwatch = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[198590] = 6, -- Drain Soul
	[755]    = 6, -- Health Funnel
	[234153] = 6, -- Drain Life
	-- Priest
	[64843]  = 4, -- Divine Hymn
	[15407]  = 4, -- Mind Flay
	[48045] = 5, -- Mind Sear
	-- Mage
	[5143]   = 5,  -- Arcane Missiles
	[12051]  = 3,  -- Evocation
	[205021] = 10, -- Ray of Frost
	--Druid
	[740]    = 4, -- Tranquility
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	if strlower(E.myclass) ~= "priest" then return end

	local penanceTicks = IsPlayerSpell(193134) and 4 or 3
	E.global.unitframe.ChannelTicks[47540] = penanceTicks --Penance
end)

G.unitframe.ChannelTicksSize = {
	-- Warlock
	[198590] = 1, -- Drain Soul
}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[205021] = true, -- Ray of Frost
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]  = {r = 0.98, g = 0.57, b = 0.10}, -- Bloodlust
	[32182] = {r = 0.98, g = 0.57, b = 0.10}, -- Heroism
	[80353] = {r = 0.98, g = 0.57, b = 0.10}, -- Time Warp
	[90355] = {r = 0.98, g = 0.57, b = 0.10}, -- Ancient Hysteria
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}

G.unitframe.specialFilters = {
	-- Whitelists
	Boss = true,
	Personal = true,
	nonPersonal = true,
	CastByUnit = true,
	notCastByUnit = true,
	Dispellable = true,
	notDispellable = true,
	CastByNPC = true,
	CastByPlayers = true,

	-- Blacklists
	blockNonPersonal = true,
	blockCastByPlayers = true,
	blockNoDuration = true,
	blockDispellable = true,
	blockNotDispellable = true,
};
