local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

E.Options.args.skins = {
	type = 'group',
	name = L["Skins"],
	childGroups = "tree",
	order = 2,
	args = {
		intro = {
			order = 0,
			type = 'description',
			name = L["SKINS_DESC"],
		},
		general = {
			order = 1,
			type = 'group',
			name = L["General"],
			guiInline = true,
			args = {
				blizzardEnable = {
					order = 1,
					type = 'toggle',
					name = L["Blizzard"],
					get = function(info) return E.private.skins.blizzard.enable end,
					set = function(info, value) E.private.skins.blizzard.enable = value; E:StaticPopup_Show('PRIVATE_RL') end,
				},
				ace3 = {
					order = 2,
					type = 'toggle',
					name = 'Ace3',
					get = function(info) return E.private.skins.ace3.enable end,
					set = function(info, value) E.private.skins.ace3.enable = value; E:StaticPopup_Show('PRIVATE_RL') end,
				},
				checkBoxSkin = {
					order = 3,
					type = 'toggle',
					name = L["CheckBox Skin"],
					get = function(info) return E.private.skins.checkBoxSkin end,
					set = function(info, value) E.private.skins.checkBoxSkin = value; E:StaticPopup_Show('PRIVATE_RL') end
				},
				--[[
				parchmentRemover = {
					order = 4,
					type = 'toggle',
					name = L["Parchment Remover"],
					get = function(info) return E.private.skins.parchmentRemover.enable end,
					set = function(info, value) E.private.skins.parchmentRemover.enable = value; E:StaticPopup_Show('PRIVATE_RL') end,
				},]]
			},
		},
		blizzard = {
			order = 300,
			type = 'group',
			name = L["Blizzard"],
			get = function(info) return E.private.skins.blizzard[info[#info]] end,
			set = function(info, value) E.private.skins.blizzard[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				auctionhouse = {
					type = 'toggle',
					name = L["Auctions"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bags = {
					type = 'toggle',
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.bags.enable end
				},
				battlefield = {
					type = 'toggle',
					name = L["Battlefield Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bgscore = {
					type = 'toggle',
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"]
				},
				binding = {
					type = 'toggle',
					name = L["Key Binding"],
					desc = L["TOGGLESKIN_DESC"]
				},
				BlizzardOptions = {
					type = 'toggle',
					name = L["Interface Options"],
					desc = L["TOGGLESKIN_DESC"]
				},
				Channels  = {
					type = 'toggle',
					name = L["CHANNELS"],
					desc = L["TOGGLESKIN_DESC"],
				},
				character = {
					type = 'toggle',
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				craft = {
					type = 'toggle',
					name = L["Craft"],
					desc = L["TOGGLESKIN_DESC"]
				},
				debug = {
					type = 'toggle',
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"]
				},
				dressingroom = {
					type = 'toggle',
					name = L["Dressing Room"],
					desc = L["TOGGLESKIN_DESC"]
				},
				friends = {
					type = 'toggle',
					name = L["Friends"],
					desc = L["TOGGLESKIN_DESC"]
				},
				GMChat = {
					type = 'toggle',
					name = L["GM Chat"],
					desc = L["TOGGLESKIN_DESC"],
				},
				gossip = {
					type = 'toggle',
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guildregistrar = {
					type = 'toggle',
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				help = {
					type = 'toggle',
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				inspect = {
					type = 'toggle',
					name = L["Inspect"],
					desc = L["TOGGLESKIN_DESC"]
				},
				loot = {
					type = 'toggle',
					name = L["Loot Frames"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return not E.private.general.loot end
				},
				lootRoll = {
					type = 'toggle',
					name = L["Loot Roll"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return not E.private.general.lootRoll end
				},
				macro = {
					type = 'toggle',
					name = L["Macros"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mail = {
					type = 'toggle',
					name = L["Mail"],
					desc = L["TOGGLESKIN_DESC"]
				},
				merchant = {
					type = 'toggle',
					name = L["Merchant"],
					desc = L["TOGGLESKIN_DESC"]
				},
				misc = {
					type = 'toggle',
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				petition = {
					type = 'toggle',
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				quest = {
					type = 'toggle',
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				questtimers = {
					type = 'toggle',
					name = L["QuestTimers Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				raid = {
					type = 'toggle',
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				spellbook = {
					type = 'toggle',
					name = L["Spellbook"],
					desc = L["TOGGLESKIN_DESC"]
				},
				stable = {
					type = 'toggle',
					name = L["Stable"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tabard = {
					type = 'toggle',
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				talent = {
					type = 'toggle',
					name = L["Talents"],
					desc = L["TOGGLESKIN_DESC"]
				},
				taxi = {
					type = 'toggle',
					name = L["Taxi Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				timemanager = {
					type = 'toggle',
					name = L["TIMEMANAGER_TITLE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tooltip = {
					type = 'toggle',
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"],
				},
				trade = {
					type = 'toggle',
					name = L["Trade"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tradeskill = {
					type = 'toggle',
					name = L["Tradeskills"],
					desc = L["TOGGLESKIN_DESC"]
				},
				trainer = {
					type = 'toggle',
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tutorial = {
					type = 'toggle',
					name = L["Tutorial Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				worldmap = {
					type = 'toggle',
					name = L["World Map"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mirrorTimers = {
					type = 'toggle',
					name = L["Mirror Timers"],
					desc = L["TOGGLESKIN_DESC"]
				}
			}
		}
	}
};
