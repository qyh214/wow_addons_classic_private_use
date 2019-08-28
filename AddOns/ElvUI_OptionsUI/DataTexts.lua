local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Chat = E:GetModule('Chat')
local Minimap = E:GetModule('Minimap')

local datatexts = {}

local _G = _G
local tonumber = tonumber
local pairs = pairs
local type = type

function DT:PanelLayoutOptions()
	for name, data in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = data.localizedName or L[name]
	end
	datatexts[''] = L["NONE"]

	local order
	local table = E.Options.args.datatexts.args.panels.args
	for pointLoc, tab in pairs(P.datatexts.panels) do
		if not _G[pointLoc] then table[pointLoc] = nil; return; end
		if type(tab) == 'table' then
			if pointLoc:find("Chat") then
				order = 15
			else
				order = 20
			end
			table[pointLoc] = {
				type = 'group',
				args = {},
				name = L[pointLoc] or pointLoc,
				order = order,
			}
			for option in pairs(tab) do
				table[pointLoc].args[option] = {
					type = 'select',
					name = L[option] or option:upper(),
					values = datatexts,
					get = function(info) return E.db.datatexts.panels[pointLoc][info[#info]] end,
					set = function(info, value) E.db.datatexts.panels[pointLoc][info[#info]] = value; DT:LoadDataTexts() end,
				}
			end
		elseif type(tab) == 'string' then
			table.smallPanels.args[pointLoc] = {
				type = 'select',
				name = L[pointLoc] or pointLoc,
				values = datatexts,
				get = function(info) return E.db.datatexts.panels[pointLoc] end,
				set = function(info, value) E.db.datatexts.panels[pointLoc] = value; DT:LoadDataTexts() end,
			}
		end
	end
end

local clientTable = {
	['WoW'] = "WoW",
	['D3'] = "D3",
	['WTCG'] = "HS", --Hearthstone
	['Hero'] = "HotS", --Heros of the Storm
	['Pro'] = "OW", --Overwatch
	['S1'] = "SC",
	['S2'] = "SC2",
	['DST2'] = "Dst2",
	['VIPR'] = "VIPR", -- COD
	['BSAp'] = L["Mobile"],
	['App'] = "App", --Launcher
}

local function SetupFriendClient(client, order)
	local hideGroup = E.Options.args.datatexts.args.friends.args.hideGroup.args
	if not (hideGroup and client and order) then return end --safety
	local clientName = 'hide'..client
	hideGroup[clientName] = {
		order = order,
		type = 'toggle',
		name = clientTable[client] or client,
		get = function(info) return E.db.datatexts.friends[clientName] or false end,
		set = function(info, value) E.db.datatexts.friends[clientName] = value; DT:LoadDataTexts() end,
	}
end

local function SetupFriendClients() --this function is used to create the client options in order
	SetupFriendClient('App', 3)
	SetupFriendClient('BSAp', 4)
	SetupFriendClient('WoW', 5)
	SetupFriendClient('D3', 6)
	SetupFriendClient('WTCG', 7)
	SetupFriendClient('Hero', 8)
	SetupFriendClient('Pro', 9)
	SetupFriendClient('S1', 10)
	SetupFriendClient('S2', 11)
	SetupFriendClient('DST2', 12)
	SetupFriendClient('VIPR', 13)
end

E.Options.args.datatexts = {
	type = "group",
	name = L["DataTexts"],
	childGroups = "tab",
	get = function(info) return E.db.datatexts[info[#info]] end,
	set = function(info, value) E.db.datatexts[info[#info]] = value; DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"],
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"],
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					args = {
						battleground = {
							order = 3,
							type = 'toggle',
							name = L["Battleground Texts"],
							desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."],
						},
						panelTransparency = {
							order = 4,
							name = L["Panel Transparency"],
							type = 'toggle',
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end,
						},
						panelBackdrop = {
							order = 5,
							name = L["Backdrop"],
							type = 'toggle',
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end,
						},
						noCombatClick = {
							order = 6,
							type = "toggle",
							name = L["Block Combat Click"],
							desc = L["Blocks all click events while in combat."],
						},
						noCombatHover = {
							order = 7,
							type = "toggle",
							name = L["Block Combat Hover"],
							desc = L["Blocks datatext tooltip from showing in combat."],
						},
					},
				},
				fontGroup = {
					order = 3,
					type = 'group',
					guiInline = true,
					name = L["Fonts"],
					args = {
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 1,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 2,
							name = L["FONT_SIZE"],
							type = "range",
							min = 4, max = 212, step = 1,
						},
						fontOutline = {
							order = 3,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = C.Values.FontFlags,
						},
						wordWrap = {
							order = 4,
							type = "toggle",
							name = L["Word Wrap"],
						},
					},
				},
			},
		},
		panels = {
			type = 'group',
			name = L["Panels"],
			order = 4,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Panels"],
				},
				leftChatPanel = {
					order = 2,
					name = L["Datatext Panel (Left)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.LeftChatPanelFaded then
							E.db.LeftChatPanelFaded = true;
							_G.HideLeftChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end,
				},
				rightChatPanel = {
					order = 3,
					name = L["Datatext Panel (Right)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.RightChatPanelFaded then
							E.db.RightChatPanelFaded = true;
							_G.HideRightChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end,
				},
				minimapPanels = {
					order = 4,
					name = L["Minimap Panels"],
					desc = L["Display minimap panels below the minimap, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTop = {
					order = 5,
					name = L["TopMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTopLeft = {
					order = 6,
					name = L["TopLeftMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTopRight = {
					order = 7,
					name = L["TopRightMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottom = {
					order = 8,
					name = L["BottomMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottomLeft = {
					order = 9,
					name = L["BottomLeftMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottomRight = {
					order = 10,
					name = L["BottomRightMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				spacer = {
					order = 11,
					type = "description",
					name = "\n",
				},
				smallPanels = {
					type = "group",
					name = L["Small Panels"],
					order = 12,
					args = {},
				},
			},
		},
		time = {
			order = 6,
			type = "group",
			name = L["Time"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Time"],
				},
				time24 = {
					order = 2,
					type = 'toggle',
					name = L["24-Hour Time"],
					desc = L["Toggle 24-hour mode for the time datatext."],
					get = function(info) return E.db.datatexts.time24 end,
					set = function(info, value) E.db.datatexts.time24 = value; DT:LoadDataTexts() end,
				},
				localtime = {
					order = 3,
					type = 'toggle',
					name = L["Local Time"],
					desc = L["If not set to true then the server time will be displayed instead."],
					get = function(info) return E.db.datatexts.localtime end,
					set = function(info, value) E.db.datatexts.localtime = value; DT:LoadDataTexts() end,
				},
			},
		},
		friends = {
			order = 7,
			type = "group",
			name = L["FRIENDS"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["FRIENDS"],
				},
				description = {
					order = 1,
					type = "description",
					name = L["Hide specific sections in the datatext tooltip."],
				},
				hideGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["HIDE"],
					args = {
						hideAFK = {
							order = 1,
							type = 'toggle',
							name = L["AFK"],
							get = function(info) return E.db.datatexts.friends.hideAFK end,
							set = function(info, value) E.db.datatexts.friends.hideAFK = value; DT:LoadDataTexts() end,
						},
						hideDND = {
							order = 2,
							type = 'toggle',
							name = L["DND"],
							get = function(info) return E.db.datatexts.friends.hideDND end,
							set = function(info, value) E.db.datatexts.friends.hideDND = value; DT:LoadDataTexts() end,
						},
					},
				},
			},
		},
	},
}

DT:PanelLayoutOptions()
SetupFriendClients()
