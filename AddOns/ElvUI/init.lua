--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Lua functions
local _G = _G
local unpack, select = unpack, select
local format, gsub, type = format, gsub, type
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnMetadata = GetAddOnMetadata
local GetLocale = GetLocale
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local DisableAddOn = DisableAddOn
local ReloadUI = ReloadUI

local MAINMENU_BUTTON = MAINMENU_BUTTON
local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

_G.BINDING_HEADER_ELVUI = GetAddOnMetadata(..., 'Title')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
E.DF = {profile = {}, global = {}}; E.privateVars = {profile = {}} -- Defaults
E.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree'}
E.callbacks = E.callbacks or CallbackHandler:New(E)

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.ElvUI = Engine

E.oUF = Engine.oUF
E.ActionBars = E:NewModule('ActionBars','AceHook-3.0','AceEvent-3.0')
E.AFK = E:NewModule('AFK','AceEvent-3.0','AceTimer-3.0')
E.Auras = E:NewModule('Auras','AceHook-3.0','AceEvent-3.0')
E.Bags = E:NewModule('Bags','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.Blizzard = E:NewModule('Blizzard','AceEvent-3.0','AceHook-3.0')
E.Chat = E:NewModule('Chat','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.DataBars = E:NewModule('DataBars','AceEvent-3.0')
E.DataTexts = E:NewModule('DataTexts','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.DebugTools = E:NewModule('DebugTools','AceEvent-3.0','AceHook-3.0')
E.Distributor = E:NewModule('Distributor','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
E.Layout = E:NewModule('Layout','AceEvent-3.0')
E.Minimap = E:NewModule('Minimap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.Misc = E:NewModule('Misc','AceEvent-3.0','AceTimer-3.0')
E.ModuleCopy = E:NewModule('ModuleCopy','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
E.NamePlates = E:NewModule('NamePlates','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.PluginInstaller = E:NewModule('PluginInstaller')
E.RaidUtility = E:NewModule('RaidUtility','AceEvent-3.0')
E.Skins = E:NewModule('Skins','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.Threat = E:NewModule('Threat','AceEvent-3.0')
E.Tooltip = E:NewModule('Tooltip','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.TotemBar = E:NewModule('Totems','AceEvent-3.0')
E.UnitFrames = E:NewModule('UnitFrames','AceTimer-3.0','AceEvent-3.0','AceHook-3.0')
E.WorldMap = E:NewModule('WorldMap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')

do
	local locale = GetLocale()
	local convert = {enGB = 'enUS', esES = 'esMX', itIT = 'enUS'}
	local gameLocale = convert[locale] or locale or 'enUS'

	function E:GetLocale()
		return gameLocale
	end
end

do
	E.Libs = {}
	E.LibsMinor = {}
	function E:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == 'table' and type(minor) == 'number' then
			E.Libs[name], E.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			E.Libs[name], E.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	E:AddLib('AceAddon', AceAddon, AceAddonMinor)
	E:AddLib('AceDB', 'AceDB-3.0')
	E:AddLib('EP', 'LibElvUIPlugin-1.0')
	E:AddLib('LSM', 'LibSharedMedia-3.0')
	E:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	E:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	E:AddLib('LDB', 'LibDataBroker-1.1')
	E:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	E:AddLib('ButtonGlow', 'LibButtonGlow-1.0', true)
	E:AddLib('ItemSearch', 'LibItemSearch-1.2-ElvUI')
	E:AddLib('Compress', 'LibCompress')
	E:AddLib('Base64', 'LibBase64-1.0-ElvUI')
	E:AddLib('Masque', 'Masque', true)
	E:AddLib('Translit', 'LibTranslit-1.0')
	E:AddLib('LCD', 'LibClassicDurations')
	E:AddLib('LCC', 'LibClassicCasterino')
	E:AddLib('RC', 'LibRangeCheck-2.0')
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	if E.Libs.LCD then
		E.Libs.LCD:Register("ElvUI")
	end

	-- backwards compatible for plugins
	E.LSM = E.Libs.LSM
	E.Masque = E.Libs.Masque
end

do
	local a1,a2,a3 = '','([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function E:EscapeString(s) return gsub(s,a2,a3) end

	local a4,a5,a6,a7 = '|c[fF][fF]%x%x%x%x%x%x','|r','|[TA].-|[ta]','^%s*'
	function E:StripString(s)
		return gsub(gsub(gsub(gsub(s,a4,a1),a5,a1),a6,a1),a7,a1)
	end
end

do
	DisableAddOn("ElvUI_VisualAuraTimers")
	DisableAddOn("ElvUI_ExtraActionBars")
	DisableAddOn("ElvUI_CastBarOverlay")
	DisableAddOn("ElvUI_EverySecondCounts")
	DisableAddOn("ElvUI_AuraBarsMovers")
	DisableAddOn("ElvUI_CustomTweaks")
	DisableAddOn("ElvUI_DTBars2")
end

function E:OnEnable()
	E:Initialize()
end

function E:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil --Depreciated
	ElvPrivateData = nil --Depreciated
	ElvData = nil --Depreciated

	E.db = E:CopyTable({}, E.DF.profile)
	E.global = E:CopyTable({}, E.DF.global)
	E.private = E:CopyTable({}, E.privateVars.profile)

	if ElvDB then
		if ElvDB.global then
			E:CopyTable(E.global, ElvDB.global)
		end

		local key = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		if key and ElvDB.profiles and ElvDB.profiles[key] then
			E:CopyTable(E.db, ElvDB.profiles[key])
		end
	end

	if ElvPrivateDB then
		local key = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		if key and ElvPrivateDB.profiles and ElvPrivateDB.profiles[key] then
			E:CopyTable(E.private, ElvPrivateDB.profiles[key])
		end
	end

	E.twoPixelsPlease = false
	E.ScanTooltip = CreateFrame('GameTooltip', 'ElvUI_ScanTooltip', _G.UIParent, 'GameTooltipTemplate')
	E.PixelMode = E.twoPixelsPlease or E.private.general.pixelPerfect -- keep this over `UIScale`
	E:UIScale(true)
	E:UpdateMedia()
	E:Contruct_StaticPopups()
	E:InitializeInitialModules()

	if self.private.general.minimap.enable then
		self.Minimap:SetGetMinimapShape()
		_G.Minimap:SetMaskTexture('interface/chatframe/chatframebackground')
	else
		_G.Minimap:SetMaskTexture('textures/minimapmask')
	end

	if GetAddOnEnableState(E.myname, 'Tukui') == 2 then
		E:StaticPopup_Show('TUKUI_ELVUI_INCOMPATIBLE')
	end

	local GameMenuButton = CreateFrame('Button', nil, GameMenuFrame, 'GameMenuButtonTemplate')
	GameMenuButton:SetScript('OnClick', function()
		E:ToggleOptionsUI() --We already prevent it from opening in combat
		if not InCombatLockdown() then
			HideUIPanel(GameMenuFrame)
		end
	end)
	GameMenuFrame[E.name] = GameMenuButton

	if not IsAddOnLoaded('ConsolePortUI_Menu') then -- #390
		GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:Point('TOPLEFT', GameMenuButtonAddons, 'BOTTOMLEFT', 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', E.PositionGameMenuButton)
	end

	E.loadedtime = GetTime()
end

function E:PositionGameMenuButton()
	for i=1, GameMenuFrame:GetNumRegions() do
		local region = select(i, GameMenuFrame:GetRegions())
		if region:IsObjectType('FontString') and region:GetText() == MAINMENU_BUTTON then
			region:SetTextColor(unpack(E.media.rgbvaluecolor))
			break
		end
	end

	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)

	local button = GameMenuFrame[E.name]
	button:SetText(format('%s%s|r', E.media.hexvaluecolor, E.name))

	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= button then
		button:ClearAllPoints()
		button:Point('TOPLEFT', relTo, 'BOTTOMLEFT', 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point('TOPLEFT', button, 'BOTTOMLEFT', 0, offY)
	end
end

function E:ResetProfile()
	E:StaggeredUpdateAll()
end

function E:OnProfileReset()
	E:StaticPopup_Show('RESET_PROFILE_PROMPT')
end

function E:ResetPrivateProfile()
	ReloadUI()
end

function E:OnPrivateProfileReset()
	E:StaticPopup_Show('RESET_PRIVATE_PROFILE_PROMPT')
end
