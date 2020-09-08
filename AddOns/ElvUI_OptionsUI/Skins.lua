local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local B = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

E.Options.args.skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
E.Options.args.skins.args.general = ACH:MultiSelect(L["General"], nil, 1, nil, nil, nil, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E:StaticPopup_Show("PRIVATE_RL") end)
E.Options.args.skins.args.general.sortByValue = true
E.Options.args.skins.args.general.values = {
	ace3Enable = "Ace3",
	blizzardEnable = L["Blizzard"],
	checkBoxSkin = L["CheckBox Skin"],
	parchmentRemoverEnable = L["Parchment Remover"],
}

E.Options.args.skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], nil, 3, nil, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E:StaticPopup_Show("PRIVATE_RL") end, function() return not E.private.skins.blizzard.enable end)
E.Options.args.skins.args.blizzard.values = {
	auctionhouse = L["Auctions"],
	addonManager = L["AddOn Manager"],
	bags = L["Bags"],
	battlefield = L["Battlefield Frame"],
	bgscore = L["BG Score"],
	binding = L["Key Binding"],
	BlizzardOptions = L["Interface Options"],
	Channels  = L["CHANNELS"],
	character = L["Character Frame"],
	craft = L["Craft"],
	debug = L["Debug Tools"],
	dressingroom = L["Dressing Room"],
	friends = L["Friends"],
	GMChat = L["GM Chat"],
	gossip = L["Gossip Frame"],
	guildregistrar = L["Guild Registrar"],
	help = L["Help Frame"],
	inspect = L["Inspect"],
	loot = L["Loot Frames"],
	lootRoll = L["Loot Roll"],
	macro = L["Macros"],
	mail = L["Mail"],
	merchant = L["Merchant"],
	misc = L["Misc Frames"],
	petition = L["Petition Frame"],
	quest = L["Quest Frames"],
	questtimers = L["QuestTimers Frame"],
	raid = L["Raid Frame"],
	spellbook = L["Spellbook"],
	stable = L["Stable"],
	tabard = L["Tabard Frame"],
	talent = L["Talents"],
	taxi = L["Taxi Frame"],
	timemanager = L["TIMEMANAGER_TITLE"],
	tooltip = L["Tooltip"],
	trade = L["Trade"],
	tradeskill = L["Tradeskills"],
	trainer = L["Trainer Frame"],
	tutorial = L["Tutorial Frame"],
	worldmap = L["World Map"],
	mirrorTimers = L["Mirror Timers"],
}
