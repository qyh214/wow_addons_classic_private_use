local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local mod = E:GetModule('DataBars')

E.Options.args.databars = {
	type = "group",
	name = L["DataBars"],
	childGroups = "tab",
	get = function(info) return E.db.databars[info[#info]] end,
	set = function(info, value) E.db.databars[info[#info]] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["Setup on-screen display of information bars."],
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
		},
		experience = {
			order = 5,
			get = function(info) return mod.db.experience[info[#info]] end,
			set = function(info, value) mod.db.experience[info[#info]] = value; mod:UpdateExperienceDimensions() end,
			type = "group",
			name = L["XPBAR_LABEL"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["XPBAR_LABEL"],
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.experience[info[#info]] = value; mod:EnableDisable_ExperienceBar() end,
				},
				mouseover = {
					order = 2,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideAtMaxLevel = {
					order = 3,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) mod.db.experience[info[#info]] = value; mod:UpdateExperience() end,
				},
				hideInCombat = {
					order = 5,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.experience[info[#info]] = value; mod:UpdateExperience() end,
				},
				reverseFill = {
					order = 6,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 8,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 9,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 10,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 11,
					name = L["FONT_SIZE"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 12,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
				},
				textFormat = {
					order = 13,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["NONE"],
						PERCENT = L["Percent"],
						CUR = L["Current"],
						REM = L["Remaining"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.experience[info[#info]] = value; mod:UpdateExperience() end,
				},
			},
		},
		reputation = {
			order = 6,
			get = function(info) return mod.db.reputation[info[#info]] end,
			set = function(info, value) mod.db.reputation[info[#info]] = value; mod:UpdateReputationDimensions() end,
			type = "group",
			name = L["REPUTATION"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["REPUTATION"],
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.reputation[info[#info]] = value; mod:EnableDisable_ReputationBar() end,
				},
				mouseover = {
					order = 2,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideInCombat = {
					order = 4,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.reputation[info[#info]] = value; mod:UpdateReputation() end,
				},
				reverseFill = {
					order = 5,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				spacer = {
					order = 6,
					type = "description",
					name = " ",
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 8,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 9,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				font = {
					order = 10,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				textSize = {
					order = 11,
					name = L["FONT_SIZE"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 12,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
				},
				textFormat = {
					order = 13,
					type = 'select',
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["NONE"],
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.reputation[info[#info]] = value; mod:UpdateReputation() end,
				},
			},
		},
	},
}
