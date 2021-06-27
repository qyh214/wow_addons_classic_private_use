local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local B = E:GetModule('Blizzard')
local ACH = E.Libs.ACH

local pairs = pairs

E.Options.args.skins = ACH:Group(L["Skins"], nil, 2, 'tab')
E.Options.args.skins.args.intro = ACH:Description(L["SKINS_DESC"], 0)
E.Options.args.skins.args.general = ACH:MultiSelect(L["General"], nil, 1, nil, nil, nil, function(_, key) if key == 'blizzardEnable' then return E.private.skins.blizzard.enable else return E.private.skins[key] end end, function(_, key, value) if key == 'blizzardEnable' then E.private.skins.blizzard.enable = value else E.private.skins[key] = value end E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.general.sortByValue = true
E.Options.args.skins.args.general.values = { ace3Enable = 'Ace3', blizzardEnable = L["Blizzard"], checkBoxSkin = L["CheckBox Skin"], parchmentRemoverEnable = L["Parchment Remover"] }

local function ToggleSkins(value)
	for key in pairs(E.private.skins.blizzard) do
		if key ~= 'enable' then
			E.private.skins.blizzard[key] = value
		end
	end
end

E.Options.args.skins.args.disableBlizzardSkins = ACH:Execute(L["Disable Blizzard Skins"], nil, 3, function() ToggleSkins(false); E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.enableBlizzardSkins = ACH:Execute(L["Enable Blizzard Skins"], nil, 4, function() ToggleSkins(true); E:StaticPopup_Show('PRIVATE_RL') end)
E.Options.args.skins.args.blizzard = ACH:MultiSelect(L["Blizzard"], L["TOGGLESKIN_DESC"], -1, nil, nil, nil, function(_, key) return E.private.skins.blizzard[key] end, function(_, key, value) E.private.skins.blizzard[key] = value; E:StaticPopup_Show('PRIVATE_RL') end, function() return not E.private.skins.blizzard.enable end)
E.Options.args.skins.args.blizzard.sortByValue = true
E.Options.args.skins.args.blizzard.values = {
	addonManager = L["AddOn Manager"],
	arena = L["Arena"],
	arenaRegistrar = L["Arena Registrar"],
	auctionhouse = L["AUCTIONS"],
	bags = L["Bags"],
	battlefield = L["Battlefield"],
	bgmap = L["BG Map"],
	bgscore = L["BG Score"],
	binding = L["KEY_BINDINGS"],
	blizzardOptions = L["INTERFACE_OPTIONS"],
	channels = L["CHANNELS"],
	character = L["Character Frame"],
	communities = L["COMMUNITIES"],
	craft = L["Craft"],
	debug = L["Debug Tools"],
	dressingroom = L["DRESSUP_FRAME"],
	eventLog = L["Event Log"],
	friends = L["FRIENDS"],
	gossip = L["Gossip Frame"],
	guild = L["GUILD"],
	guildcontrol = L["Guild Control Frame"],
	guildregistrar = L["Guild Registrar"],
	help = L["Help Frame"],
	inspect = L["INSPECT"],
	loot = L["Loot Frames"],
	macro = L["MACROS"],
	mail = L["Mail Frame"],
	merchant = L["Merchant Frame"],
	mirrorTimers = L["Mirror Timers"],
	misc = L["Misc Frames"],
	petition = L["Petition Frame"],
	quest = L["Quest Frames"],
	questChoice = L["Quest Choice"],
	raid = L["Raid Frame"],
	socket = L["Socket Frame"],
	spellbook = L["SPELLBOOK"],
	stable = L["Stable"],
	tabard = L["Tabard Frame"],
	talent = L["TALENTS"],
	taxi = L["FLIGHT_MAP"],
	timemanager = L["TIMEMANAGER_TITLE"],
	tooltip = L["Tooltip"],
	trade = L["TRADE"],
	tradeskill = L["TRADESKILLS"],
	trainer = L["Trainer Frame"],
	tutorials = L["Tutorials"],
	worldmap = L["WORLD_MAP"],
}
