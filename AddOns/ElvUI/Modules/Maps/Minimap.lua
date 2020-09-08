local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Minimap')

--Lua functions
local _G = _G
local unpack = unpack
local utf8sub = string.utf8sub
--WoW API / Variables
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local PlaySound = PlaySound
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local ToggleChannelFrame = ToggleChannelFrame
local ToggleCharacter = ToggleCharacter
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleTalentFrame = ToggleTalentFrame
-- GLOBALS: GetMinimapShape

--Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent)
local menuList = {
	{text = _G.CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = _G.SPELLBOOK_ABILITIES_BUTTON,
	func = function() ToggleFrame(_G.SpellBookFrame) end},
	{text = _G.TALENTS_BUTTON,
	func = ToggleTalentFrame},
	{text = _G.CHAT_CHANNELS,
	func = ToggleChannelFrame},
	{text = _G.TIMEMANAGER_TITLE,
	func = function() _G.TimeManager_Toggle() end},
	{text = _G.SOCIAL_BUTTON,
	func = ToggleFriendsFrame},
	{text = _G.GUILD,
	func = function()
		if IsInGuild() then
			ToggleFriendsFrame(3)
		else
			ToggleGuildFrame()
		end
	end},
	{text = _G.MAINMENU_BUTTON,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click()
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click()
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click()
			end

			CloseMenus()
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame)
			MainMenuMicroButton_SetNormal()
		end
	end},
	{text = _G.HELP_BUTTON,
	func = ToggleHelpFrame}
}

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		_G.TimeManagerClockButton:Kill()
	end
end

function M:Minimap_OnMouseDown(btn)
	menuFrame:Hide()
	local position = self:GetPoint()
	if btn == "MiddleButton" or btn == "RightButton" then
		if position:match("LEFT") then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	else
		_G.Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' or not E.private.general.minimap.enable then return end
	_G.Minimap.location:SetText(utf8sub(GetMinimapZoneText(),1,46))
	_G.Minimap.location:SetTextColor(M:GetLocTextColor())
	_G.Minimap.location:FontTemplate(E.Libs.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:UpdateSettings()
end

local function PositionTicketButtons()
	local pos = E.db.general.minimap.icons.ticket.position or "TOPRIGHT"
	_G.HelpOpenTicketButton:ClearAllPoints()
	_G.HelpOpenTicketButton:Point(pos, _G.Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
	_G.HelpOpenWebTicketButton:ClearAllPoints()
	_G.HelpOpenWebTicketButton:Point(pos, _G.Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
end

local isResetting
local function ResetZoom()
	_G.Minimap:SetZoom(0)
	_G.MinimapZoomIn:Enable() --Reset enabled state of buttons
	_G.MinimapZoomOut:Disable()
	isResetting = false
end

local function SetupZoomReset()
	if E.db.general.minimap.resetZoom.enable and not isResetting then
		isResetting = true
		E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
	end
end

hooksecurefunc(_G.Minimap, "SetZoom", SetupZoomReset)

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or _G.Minimap:GetWidth() + 10
	E.MinimapWidth, E.MinimapHeight = E.MinimapSize, E.MinimapSize

	_G.Minimap:Size(E.MinimapSize, E.MinimapSize)

	local MinimapPanel = _G.MinimapPanel
	local MMHolder = _G.MMHolder
	local Minimap = _G.Minimap

	MMHolder:Width((Minimap:GetWidth() + E.Border + E.Spacing*3))
	MinimapPanel:SetShown(E.db.datatexts.panels.MinimapPanel.enable)

	if E.db.datatexts.panels.MinimapPanel.enable then
		MMHolder:Height(Minimap:GetHeight() + (MinimapPanel and (MinimapPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
	else
		MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
	end

	Minimap.location:Width(E.MinimapSize)

	if E.db.general.minimap.locationText ~= 'SHOW' then
		Minimap.location:Hide()
	else
		Minimap.location:Show()
	end

	_G.MinimapMover:Size(MMHolder:GetSize())

	local GameTimeFrame = _G.GameTimeFrame
	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	local MiniMapMailFrame = _G.MiniMapMailFrame
	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	local MiniMapBattlefieldFrame = _G.MiniMapBattlefieldFrame
	if MiniMapBattlefieldFrame then
		local pos = E.db.general.minimap.icons.battlefield.position or "BOTTOMLEFT"
		local scale = E.db.general.minimap.icons.battlefield.scale or 1
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.battlefield.xOffset or -2, E.db.general.minimap.icons.battlefield.yOffset or -2)
		MiniMapBattlefieldFrame:SetScale(scale)
		MiniMapBattlefieldFrame:SetParent(Minimap)

		if (_G.BattlegroundShine) then
			_G.BattlegroundShine:Hide()
		end

		if (_G.MiniMapBattlefieldBorder) then
			_G.MiniMapBattlefieldBorder:Hide()
		end

		if (_G.MiniMapBattlefieldIcon) then
			_G.MiniMapBattlefieldIcon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	local MiniMapTrackingFrame = _G.MiniMapTrackingFrame
	if (MiniMapTrackingFrame) then
		if E.private.general.minimap.hideTracking then
			MiniMapTrackingFrame:SetParent(E.HiddenFrame)
		else
			local pos = E.db.general.minimap.icons.tracking.position or "TOPLEFT"
			local scale = E.db.general.minimap.icons.tracking.scale or 1
			local x = E.db.general.minimap.icons.tracking.xOffset or 0
			local y = E.db.general.minimap.icons.tracking.yOffset or 0

			MiniMapTrackingFrame:ClearAllPoints()
			MiniMapTrackingFrame:Point(pos, Minimap, pos, x, y)
			MiniMapTrackingFrame:SetScale(scale)
			MiniMapTrackingFrame:SetParent(Minimap)

			if (_G.MiniMapTrackingBorder) then
				_G.MiniMapTrackingBorder:Hide()
			end

			if (_G.MiniMapTrackingIcon) then
				_G.MiniMapTrackingIcon:SetDrawLayer("ARTWORK")
				_G.MiniMapTrackingIcon:SetTexCoord(unpack(E.TexCoords))
				_G.MiniMapTrackingIcon:SetInside()
				_G.MiniMapTrackingIcon:CreateBackdrop()
			end
		end
	end

	if _G.HelpOpenTicketButton and _G.HelpOpenWebTicketButton then
		local scale = E.db.general.minimap.icons.ticket.scale or 1
		_G.HelpOpenTicketButton:SetScale(scale)
		_G.HelpOpenWebTicketButton:SetScale(scale)

		PositionTicketButtons()
	end
end

local function MinimapPostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(_G.Minimap)
end

local function GetMinimapShape()
	return 'SQUARE'
end

function M:SetGetMinimapShape()
	--This is just to support for other mods
	_G.GetMinimapShape = GetMinimapShape
	_G.Minimap:Size(E.db.general.minimap.size, E.db.general.minimap.size)
end

function M:Initialize()
	self.Initialized = true

	if not E.private.general.minimap.enable then return end

	menuFrame:SetTemplate("Transparent", true)

	local Minimap = _G.Minimap
	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29))
	mmholder:Height(Minimap:GetHeight() + 53)

	Minimap:ClearAllPoints()
	Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)
	Minimap:CreateBackdrop()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript('OnEnter', function(mm)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return end
		mm.location:Show()
	end)

	Minimap:HookScript('OnLeave', function(mm)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return end
		mm.location:Hide()
	end)

	--Fix spellbook taint
	ShowUIPanel(_G.SpellBookFrame)
	HideUIPanel(_G.SpellBookFrame)

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	_G.MinimapBorder:Hide()
	_G.MinimapBorderTop:Hide()
	_G.MinimapZoomIn:Hide()
	_G.MinimapZoomOut:Hide()
	_G.MinimapNorthTag:Kill()
	_G.MinimapZoneTextButton:Hide()
	_G.MiniMapMailBorder:Hide()
	_G.MinimapToggleButton:Hide()
	_G.MiniMapMailIcon:SetTexture(E.Media.Textures.Mail)

	_G.MiniMapWorldMapButton:Hide()

	if _G.TimeManagerClockButton then _G.TimeManagerClockButton:Kill() end
	if _G.FeedbackUIButton then _G.FeedbackUIButton:Kill() end

	E:CreateMover(mmholder, 'MinimapMover', L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, 'maps,minimap')

	_G.MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseDown", M.Minimap_OnMouseDown)
	Minimap:SetScript("OnMouseUp", E.noop)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent('ADDON_LOADED')

	self:UpdateSettings()
end

E:RegisterModule(M:GetName())
