local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local Misc = E:GetModule('Misc')
local Layout = E:GetModule('Layout')
local Totems = E:GetModule('Totems')
local Blizzard = E:GetModule('Blizzard')
local Threat = E:GetModule('Threat')
local AFK = E:GetModule('AFK')

local _G = _G
local IsAddOnLoaded = IsAddOnLoaded
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
	end
	return ChatTabInfo
end

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	childGroups = "tab",
	get = function(info) return E.db.general[info[#info]] end,
	set = function(info, value) E.db.general[info[#info]] = value end,
	args = {
		intro = {
			order = 3,
			type = "description",
			name = L["ELVUI_DESC"],
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 0,
					type = "header",
					name = L["General"],
				},
				messageRedirect = {
					order = 1,
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					type = 'select',
					values = GetChatWindowInfo()
				},
				AutoScale = {
					order = 2,
					type = 'execute',
					name = L["Auto Scale"],
					func = function()
						E.global.general.UIScale = E:PixelClip(E:PixelBestSize())
						E:StaticPopup_Show("UISCALE_CHANGE")
					end,
				},
				UIScale = {
					order = 3,
					type = "range",
					name = L["UI_SCALE"],
					min = 0.1, max = 1.25, step = 0.00001,
					softMin = 0.40, softMax = 1.15, bigStep = 0.01,
					get = function(info) return E.global.general.UIScale end,
					set = function(info, value)
						E.global.general.UIScale = value
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				ignoreScalePopup = {
					order = 4,
					type = 'toggle',
					name = L["Ignore UI Scale Popup"],
					desc = L["This will prevent the UI Scale Popup from being shown when changing the game window size."],
					get = function(info) return E.global.general.ignoreScalePopup end,
					set = function(info, value) E.global.general.ignoreScalePopup = value end
				},
				pixelPerfect = {
					order = 5,
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				eyefinity = {
					order = 6,
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general.eyefinity = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				taintLog = {
					order = 7,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				bottomPanel = {
					order = 8,
					type = 'toggle',
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.bottomPanel = value; Layout:BottomPanelVisibility() end
				},
				topPanel = {
					order = 9,
					type = 'toggle',
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.topPanel = value; Layout:TopPanelVisibility() end
				},
				afk = {
					order = 10,
					type = 'toggle',
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					set = function(info, value) E.db.general.afk = value; AFK:Toggle() end
				},
				decimalLength = {
					order = 11,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					set = function(info, value)
						E.db.general.decimalLength = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				numberPrefixStyle = {
					order = 12,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					set = function(info, value)
						E.db.general.numberPrefixStyle = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["CHINESE"] = "Chinese (W, Y)",
						["ENGLISH"] = "English (K, M, B)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["METRIC"] = "Metric (k, M, G)"
					},
				},
				smoothingAmount = {
					order = 13,
					type = "range",
					isPercent = true,
					name = L["Smoothing Amount"],
					desc = L["Controls the speed at which smoothed bars will be updated."],
					min = 0.2, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01,
					set = function(info, value)
						E.db.general.smoothingAmount = value
						E:SetSmoothingAmount(value)
					end,
				},
				locale = {
					order = 14,
					type = "select",
					name = L["LANGUAGE"],
					get = function(info) return E.global.general.locale end,
					set = function(info, value)
						E.global.general.locale = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["deDE"] = "Deutsch",
						["enUS"] = "English",
						["esMX"] = "Español",
						["frFR"] = "Français",
						["ptBR"] = "Português",
						["ruRU"] = "Русский",
						["zhCN"] = "简体中文",
						["zhTW"] = "正體中文",
						["koKR"] = "한국어",
					},
				}
			},
		},
		media = {
			order = 5,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Media"],
				},
				fontGroup = {
					order = 1,
					name = L["Font"],
					type = 'group',
					guiInline = true,
					args = {
						fontSize = {
							order = 1,
							name = L["FONT_SIZE"],
							desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
							type = "range",
							min = 4, max = 32, step = 1,
							set = function(info, value) E.db.general[info[#info]] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 2,
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general[info[#info]] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						fontStyle = {
							type = "select",
							order = 3,
							name = L["Font Outline"],
							values = C.Values.FontFlags,
							set = function(info, value) E.db.general[info[#info]] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						applyFontToAll = {
							order = 4,
							type = 'execute',
							name = L["Apply Font To All"],
							desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
							func = function() E:StaticPopup_Show("APPLY_FONT_WARNING"); end,
						},
						dmgfont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 5,
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
						},
						namefont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 6,
							name = L["Name Font"],
							desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
						},
						replaceBlizzFonts = {
							order = 7,
							type = 'toggle',
							name = L["Replace Blizzard Fonts"],
							desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						},
					},
				},
				textureGroup = {
					order = 2,
					name = L["Textures"],
					type = 'group',
					guiInline = true,
					get = function(info) return E.private.general[info[#info]] end,
					args = {
						normTex = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 1,
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								local previousValue = E.private.general[info[#info]]
								E.private.general[info[#info]] = value;

								if(E.db.unitframe.statusbar == previousValue) then
									E.db.unitframe.statusbar = value
									E:StaggeredUpdateAll(nil, true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end

							end
						},
						glossTex = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 2,
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								E.private.general[info[#info]] = value;
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyTextureToAll = {
							order = 3,
							type = 'execute',
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E.db.nameplates.statusbar = texture
								E:StaggeredUpdateAll(nil, true)
							end,
						},
					},
				},
				colorsGroup = {
					order = 3,
					name = L["Colors"],
					type = 'group',
					guiInline = true,
					get = function(info)
						local t = E.db.general[info[#info]]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local setting = info[#info]
						local t = E.db.general[setting]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						if setting == 'bordercolor' then
							E:UpdateBorderColors()
						elseif setting == 'backdropcolor' or setting == 'backdropfadecolor' then
							E:UpdateBackdropColors()
						end
					end,
					args = {
						bordercolor = {
							type = "color",
							order = 6,
							name = L["Border Color"],
							desc = L["Main border color of the UI."],
							hasAlpha = false,
						},
						backdropcolor = {
							type = "color",
							order = 7,
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false,
						},
						backdropfadecolor = {
							type = "color",
							order = 8,
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true,
						},
						valuecolor = {
							type = "color",
							order = 9,
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false,
						},
						cropIcon = {
							order = 10,
							type = 'toggle',
							tristate = true,
							name = L["Crop Icons"],
							desc = L["This is for Customized Icons in your Interface/Icons folder."],
							get = function(info)
								local value = E.db.general[info[#info]]
								if value == 2 then return true
								elseif value == 1 then return nil
								else return false end
							end,
							set = function(info, value)
								E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0
								E:StaticPopup_Show("PRIVATE_RL")
							end,
						},
					},
				},
			},
		},
		chatBubblesGroup = {
			order = 7,
			type = "group",
			name = L["Chat Bubbles"],
			get = function(info) return E.private.general[info[#info]] end,
			set = function(info, value) E.private.general[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"],
				},
				chatBubbles = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					values = {
						['backdrop'] = L["Skin Backdrop"],
						['nobackdrop'] = L["Remove Backdrop"],
						['backdrop_noborder'] = L["Skin Backdrop (No Borders)"],
						['disabled'] = L["DISABLE"],
					}
				},
				chatBubbleFont = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
				},
				chatBubbleFontSize = {
					order = 4,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 212, step = 1,
				},
				chatBubbleFontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
				},
				chatBubbleName = {
					order = 6,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble. This will not work if backdrop is disabled or when you are in an instance."],
				},
			},
		},
--[=[
		objectiveFrameGroup = {
			order = 8,
			type = "group",
			name = L["Objective Frame"],
			get = function(info) return E.db.general[info[#info]] end,
			args = {
				objectiveFrameHeader = {
					order = 30,
					type = "header",
					name = L["Objective Frame"],
				},
				--objectiveFrameAutoHide = {
					--order = 31,
					--type = "toggle",
					--name = L["Auto Hide"],
					--desc = L["Automatically hide the objetive frame during boss or arena fights."],
					--disabled = function() return IsAddOnLoaded("!KalielsTracker") end,
					--set = function(info, value) E.db.general.objectiveFrameAutoHide = value; Blizzard:SetObjectiveFrameAutoHide(); end,
				--},
				objectiveFrameHeight = {
					order = 32,
					type = 'range',
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.objectiveFrameHeight = value; Blizzard:SetQuestWatchFrameHeight(); end,
				},
				--bonusObjectivePosition = {
					--order = 33,
					--type = 'select',
					--name = L["Bonus Reward Position"],
					--desc = L["Position of bonus quest reward frame relative to the objective tracker."],
					--values = {
						--['RIGHT'] = L["Right"],
						--['LEFT'] = L["Left"],
						--['AUTO'] = L["Automatic"],
					--},
				--},
			},
		},
]=]
		blizzUIImprovements = {
			order = 11,
			type = "group",
			name = L["BlizzUI Improvements"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["BlizzUI Improvements"],
				},
				loot = {
					order = 1,
					type = "toggle",
					name = L["Loot"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 2,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				hideErrorFrame = {
					order = 3,
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					type = "toggle"
				},
				enhancedPvpMessages = {
					order = 4,
					type = 'toggle',
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				raidUtility = {
					order = 6,
					type = "toggle",
					name = L["RAID_CONTROL"],
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general.raidUtility end,
					set = function(info, value) E.private.general.raidUtility = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				itemLevelInfo = {
					order = 11,
					name = L["Item Level"],
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.general.itemLevel[info[#info]] end,
					args = {
						displayCharacterInfo = {
							order = 1,
							type = "toggle",
							name = L["Display Character Info"],
							desc = L["Shows item level of each item, enchants, and gems on the character page."],
							set = function(info, value)
								E.db.general.itemLevel.displayCharacterInfo = value;
								Misc:ToggleItemLevelInfo()
							end
						},
						displayInspectInfo = {
							order = 2,
							type = "toggle",
							name = L["Display Inspect Info"],
							desc = L["Shows item level of each item, enchants, and gems when inspecting another player."],
							set = function(info, value)
								E.db.general.itemLevel.displayInspectInfo = value;
								Misc:ToggleItemLevelInfo()
							end
						},
						fontGroup = {
							order = 3,
							type = 'group',
							name = L["Fonts"],
							disabled = function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end,
							get = function(info) return E.db.general.itemLevel[info[#info]] end,
							set = function(info, value)
								E.db.general.itemLevel[info[#info]] = value
								Misc:UpdateInspectPageFonts("Character")
								Misc:UpdateInspectPageFonts("Inspect")
							end,
							args = {
								itemLevelFont = {
									order = 1,
									type = "select",
									name = L["Font"],
									dialogControl = 'LSM30_Font',
									values = AceGUIWidgetLSMlists.font,
								},
								itemLevelFontSize = {
									order = 2,
									type = "range",
									name = L["FONT_SIZE"],
									min = 4, max = 40, step = 1,
								},
								itemLevelFontOutline = {
									order = 3,
									type = "select",
									name = L["Font Outline"],
									values = C.Values.FontFlags,
								},
							},
						},
					},
				},
			},
		},
		misc = {
			order = 12,
			type = "group",
			name = L["Miscellaneous"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Miscellaneous"],
				},
				interruptAnnounce = {
					order = 1,
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					type = 'select',
					values = {
						['NONE'] = L["NONE"],
						['SAY'] = L["SAY"],
						['PARTY'] = L["Party Only"],
						['RAID'] = L["Party / Raid"],
						['RAID_ONLY'] = L["Raid Only"],
						["EMOTE"] = L["CHAT_MSG_EMOTE"],
					},
					set = function(info, value)
						E.db.general[info[#info]] = value
						if value == 'NONE' then
							Misc:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
						else
							Misc:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
						end
					end,
				},
				autoRepair = {
					order = 2,
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					type = 'select',
					values = {
						['NONE'] = L["NONE"],
						['GUILD'] = L["GUILD"],
						['PLAYER'] = L["PLAYER"],
					},
				},
				autoAcceptInvite = {
					order = 3,
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."],
					type = 'toggle',
				},
				autoRoll = {
					order = 4,
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					type = 'toggle',
					disabled = function() return not E.private.general.lootRoll end
				},
			},
		},
	},
}
