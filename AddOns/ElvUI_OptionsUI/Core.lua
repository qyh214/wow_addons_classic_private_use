local E = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor")

local Engine = select(2, ...)
Engine[1] = {}
Engine[2] = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale)
local C, L = Engine[1], Engine[2]

local _G, format, sort, tinsert = _G, format, sort, tinsert

C.Values = {
	FontFlags = { NONE = L["NONE"], OUTLINE = "OUTLINE", MONOCHROMEOUTLINE = "MONOCROMEOUTLINE", THICKOUTLINE = "THICKOUTLINE" },
	FontSize = { min = 8, max = 64, step = 1 },
	Strata = { BACKGROUND = "BACKGROUND", LOW = "LOW", MEDIUM = "MEDIUM", HIGH = "HIGH", DIALOG = "DIALOG", TOOLTIP = "TOOLTIP" }
}

E:AddLib('AceGUI', 'AceGUI-3.0')
E:AddLib('AceConfig', 'AceConfig-3.0-ElvUI')
E:AddLib('AceConfigDialog', 'AceConfigDialog-3.0-ElvUI')
E:AddLib('AceConfigRegistry', 'AceConfigRegistry-3.0-ElvUI')
E:AddLib('AceDBOptions', 'AceDBOptions-3.0')
E:AddLib('ACH', 'LibAceConfigHelper')

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local GameTooltip_Hide = GameTooltip_Hide
local GameFontHighlightSmall = _G.GameFontHighlightSmall
local ACH = E.Libs.ACH

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	E:RefreshCustomTextsConfigs()
	E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
end

E.Libs.AceConfig:RegisterOptionsTable("ElvUI", E.Options)
E.Libs.AceConfigDialog:SetDefaultSize("ElvUI", E:Config_GetDefaultSize())
E.Options.name = format("%s: |cff99ff33%s|r", L["Version"], E.version)

local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee",
	"Portable",
	"Ithilyn"
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine",
	"Blazeflack",
	"|cff0070DEAzilroka|r",
	"|cff9482c9Darth Predator|r",
	"|TInterface\\Icons\\INV_Misc_MonsterClaw_04:15:15:0:0:64:64:5:59:5:59|t |cffff7d0aMerathilis|r",
	"|cffff2020NihilisticPandemonium|r",
	E:TextGradient("Simpy but my name needs to be longer.", 1.0,0.6,0.4, 1.0,0.4,0.6, 0.6,0.4,1.0, 0.4,0.6,1.0, 0.4,1.0,0.6).."|r",
	"Crum",
}

local TESTERS = {
	"Tukui Community",
	"Affinity",
	"Modarch",
	"Tirain",
	"Phima",
	"Veiled",
	"Repooc",
	"Alex",
	"Nidra",
	"Kurhyus",
	"Shrom",
	"BuG",
	"Kringel",
	"Botanica",
	"|cff00c0faBenik|r",
	"|cff006fdcRubgrsch|r",
	"|TInterface\\AddOns\\ElvUI\\Media\\ChatLogos\\Clover:15:15:0:0:64:64:5:59:5:59|t Luckyone",
	"Yachanay",
	"AcidWeb",
	"Catok",
	"Catskull",
	"Thurin",
	"|TInterface\\Icons\\INV_Staff_30:15:15:0:0:64:64:5:59:5:59|t Loon - For being right",
	"|TInterface\\Icons\\INV_Misc_MonsterClaw_04:15:15:0:0:64:64:5:59:5:59|t |cffFF7D0ABladesdruid|r - AKA SUPERBEAR",
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(DONATORS, SortList)
sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

for _, name in pairs(DONATORS) do
	tinsert(E.CreditsList, name)
end
local DONATOR_STRING = table.concat(DONATORS, "\n")
for _, name in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, name)
end
local DEVELOPER_STRING = table.concat(DEVELOPERS, "\n")
for _, name in pairs(TESTERS) do
	tinsert(E.CreditsList, name)
end
local TESTER_STRING = table.concat(TESTERS, "\n")

E.Options.args.info = {
	order = 4,
	type = "group",
	name = L["Information"],
	args = {
		header = ACH:Description(L["ELVUI_DESC"], 1, "medium"),
		spacer = ACH:Spacer(2),
		support = {
			order = 3,
			type = "group",
			name = L["Support & Download"],
			guiInline = true,
			args = {
				homepage = {
					order = 1,
					type = "execute",
					name = L["Support Forum"],
					customWidth = 140,
					func = function() E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, "https://www.tukui.org/forum/viewforum.php?f=4") end,
				},
				git = {
					order = 2,
					type = "execute",
					name = L["Ticket Tracker"],
					customWidth = 140,
					func = function() E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, "https://git.tukui.org/elvui/elvui/issues") end,
				},
				discord = {
					order = 3,
					type = "execute",
					name = L["Discord"],
					customWidth = 140,
					func = function() E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, "https://discordapp.com/invite/xFWcfgE") end,
				},
				changelog = {
					order = 4,
					type = "execute",
					name = L["Changelog"],
					customWidth = 140,
					func = function() E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, "https://www.tukui.org/download.php?ui=elvui#changelog") end,
				},
				development = {
					order = 5,
					type = 'execute',
					name = L["Development Version"],
					desc = L["Link to the latest development version."],
					customWidth = 140,
					func = function() E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, "https://git.tukui.org/elvui/elvui-classic/-/archive/development/elvui-classic-development.zip") end,
				},
			},
		},
		credits = {
			order = 4,
			type = "group",
			name = L["Credits"],
			guiInline = true,
			args = {
				string = ACH:Description(L["ELVUI_CREDITS"], 1, "medium"),
			},
		},
		coding = {
			order = 5,
			type = "group",
			name = L["Coding:"],
			guiInline = true,
			args = {
				string = ACH:Description(DEVELOPER_STRING, 1, "medium"),
			},
		},
		testers = {
			order = 6,
			type = "group",
			name = L["Testing:"],
			guiInline = true,
			args = {
				string = ACH:Description(TESTER_STRING, 1, "medium"),
			},
		},
		donators = {
			order = 7,
			type = "group",
			name = L["Donations:"],
			guiInline = true,
			args = {
				string = ACH:Description(DONATOR_STRING, 1, "medium"),
			},
		},
	}
}

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filters"] = L["Aura Filters"],
	["styleFilters"] = L["NamePlate Style Filters"]
}
local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filters",
	"styleFilters"
}
local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"]
}
local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin"
}

local exportString = ""
local function ExportImport_Open(mode)
	local Frame = E.Libs.AceGUI:Create("Frame")
	Frame:SetTitle("")
	Frame:EnableResize(false)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	Frame:SetLayout("flow")

	local Box = E.Libs.AceGUI:Create("MultiLineEditBox-ElvUI")
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel("")
	Frame:AddChild(Box)
	--Save original script so we can restore it later
	Box.editBox.OnTextChangedOrig = Box.editBox:GetScript("OnTextChanged")
	Box.editBox.OnCursorChangedOrig = Box.editBox:GetScript("OnCursorChanged")
	--Remove OnCursorChanged script as it causes weird behaviour with long text
	Box.editBox:SetScript("OnCursorChanged", nil)
	Box.scrollFrame:UpdateScrollChildRect()

	local Label1 = E.Libs.AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label1:SetFont(font, 14)
	Label1:SetText(".") --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	Frame:AddChild(Label1)

	local Label2 = E.Libs.AceGUI:Create("Label")
	font = GameFontHighlightSmall:GetFont()
	Label2:SetFont(font, 14)
	Label2:SetText(".\n.")
	Label2:SetWidth(800)
	Frame:AddChild(Label2)

	if mode == "export" then
		Frame:SetTitle(L["Export Profile"])

		local ProfileTypeDropdown = E.Libs.AceGUI:Create("Dropdown")
		ProfileTypeDropdown:SetMultiselect(false)
		ProfileTypeDropdown:SetLabel(L["Choose What To Export"])
		ProfileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder)
		ProfileTypeDropdown:SetValue("profile") --Default export
		Frame:AddChild(ProfileTypeDropdown)

		local ExportFormatDropdown = E.Libs.AceGUI:Create("Dropdown")
		ExportFormatDropdown:SetMultiselect(false)
		ExportFormatDropdown:SetLabel(L["Choose Export Format"])
		ExportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder)
		ExportFormatDropdown:SetValue("text") --Default format
		ExportFormatDropdown:SetWidth(150)
		Frame:AddChild(ExportFormatDropdown)

		local exportButton = E.Libs.AceGUI:Create("Button-ElvUI")
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		exportButton:SetCallback("OnClick", function()
			Label1:SetText("")
			Label2:SetText("")

			local profileType, exportFormat = ProfileTypeDropdown:GetValue(), ExportFormatDropdown:GetValue()
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
			if not profileKey or not profileExport then
				Label1:SetText(L["Error exporting profile!"])
			else
				Label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]))

				if profileType == "profile" then
					Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
				end
			end

			Box:SetText(profileExport)
			Box.editBox:HighlightText()
			Box:SetFocus()

			exportString = profileExport
		end)
		Frame:AddChild(exportButton)

		--Set scripts
		Box.editBox:SetScript("OnChar", function()
			Box:SetText(exportString)
			Box.editBox:HighlightText()
		end)
		Box.editBox:SetScript("OnTextChanged", function(_, userInput)
			if userInput then
				--Prevent user from changing export string
				Box:SetText(exportString)
				Box.editBox:HighlightText()
			else
				--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
				Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())
			end
		end)
	elseif mode == "import" then
		Frame:SetTitle(L["Import Profile"])
		local importButton = E.Libs.AceGUI:Create("Button-ElvUI") --This version changes text color on SetDisabled
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback("OnClick", function()
			Label1:SetText("")
			Label2:SetText("")

			local success = D:ImportProfile(Box:GetText())
			Label1:SetText((success and L["Profile imported successfully!"]) or L["Error decoding data. Import string may be corrupted!"])
		end)
		Frame:AddChild(importButton)

		local decodeButton = E.Libs.AceGUI:Create("Button-ElvUI")
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback("OnClick", function()
			Label1:SetText("")
			Label2:SetText("")

			local profileType, profileKey, profileData = D:Decode(Box:GetText())
			local decodedText = (profileData and E:TableToLuaString(profileData)) or nil
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
			Box:SetText(importText)
		end)
		Frame:AddChild(decodeButton)

		local oldText = ""
		local function OnTextChanged()
			local text = Box:GetText()
			if text == "" then
				Label1:SetText("")
				Label2:SetText("")
				importButton:SetDisabled(true)
				decodeButton:SetDisabled(true)
			elseif oldText ~= text then
				local stringType = D:GetImportStringType(text)
				if stringType == "Base64" then
					decodeButton:SetDisabled(false)
				else
					decodeButton:SetDisabled(true)
				end

				local profileType, profileKey = D:Decode(text)
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
					Label2:SetText("")
					importButton:SetDisabled(true)
					decodeButton:SetDisabled(true)
				else
					Label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""))
					if profileType == "profile" then
						Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
					end

					--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
					Box.scrollFrame:UpdateScrollChildRect()
					Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())

					importButton:SetDisabled(false)
				end

				oldText = text
			end
		end

		Box.editBox:SetFocus()
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", OnTextChanged)
	end

	Frame:SetCallback("OnClose", function(widget)
		--Restore changed scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", Box.editBox.OnTextChangedOrig)
		Box.editBox:SetScript("OnCursorChanged", Box.editBox.OnCursorChangedOrig)
		Box.editBox.OnTextChangedOrig = nil
		Box.editBox.OnCursorChangedOrig = nil

		--Clear stored export string
		exportString = ""

		E.Libs.AceGUI:Release(widget)
		E:Config_OpenWindow()
	end)

	--Clear default text
	Label1:SetText("")
	Label2:SetText("")

	--Close ElvUI OptionsUI
	E.Libs.AceConfigDialog:Close("ElvUI")

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = ACH:Group(L["Profiles"], nil, 5, 'tab')
E.Options.args.profiles.args.desc = ACH:Description(L["This feature will allow you to transfer settings to other characters."], 0)
E.Options.args.profiles.args.distributeProfile = ACH:Execute(L["Share Current Profile"], L["Sends your current profile to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name) elseif server then D:Distribute(name, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.distributeGlobal = ACH:Execute(L["Share Filters"], L["Sends your filter settings to your target."], 1, function() if not UnitExists('target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') or UnitIsUnit('player', 'target') then E:Print(L["You must be targeting a player."]) return end local name, server = UnitName('target') if name and (not server or server == '') then D:Distribute(name, false, true) elseif server then D:Distribute(name, true, true) end end, nil, nil, nil, nil, nil, function() return not E.global.general.allowDistributor end)
E.Options.args.profiles.args.exportProfile = ACH:Execute(L["Export Profile"], nil, 4, function() ExportImport_Open('export') end)
E.Options.args.profiles.args.importProfile = ACH:Execute(L["Import Profile"], nil, 5, function() ExportImport_Open('import') end)
E.Options.args.profiles.args.allowDistributor = ACH:Toggle(L["Allow Sharing"], L["Both users will need this option enabled."], 6, nil, nil, nil, function() return E.global.general.allowDistributor end, function(_, value) E.global.general.allowDistributor = value; D:UpdateSettings() end)
E.Options.args.profiles.args.spacer = ACH:Spacer(6)

E.Options.args.profiles.args.profile = E.Libs.AceDBOptions:GetOptionsTable(E.data)
E.Options.args.profiles.args.private = E.Libs.AceDBOptions:GetOptionsTable(E.charSettings)

E.Options.args.profiles.args.profile.name = L["Profile"]
E.Options.args.profiles.args.profile.order = 1
E.Options.args.profiles.args.private.name = L["Private"]
E.Options.args.profiles.args.private.order = 2

E.Libs.AceConfig:RegisterOptionsTable('ElvProfiles', E.Options.args.profiles.args.profile)
E.Libs.AceConfig:RegisterOptionsTable('ElvPrivates', E.Options.args.profiles.args.private)

E.Options.args.profiles.args.private.args.choose.confirm = function(info, value)
	if info[#info-1] == 'private' then
		return format(L["Choosing Settings %s. This will reload the UI.\n\n Are you sure?"], value)
	else
		return false
	end
end

E.Options.args.profiles.args.private.args.copyfrom.confirm = function(info, value)
	return format(L["Copy Settings from %s. This will overwrite %s profile.\n\n Are you sure?"], value, info.handler:GetCurrentProfile())
end

if GetAddOnEnableState(nil, 'ElvUI_Config') ~= 0 then
	E:StaticPopup_Show('ELVUI_CONFIG_FOUND')
end
