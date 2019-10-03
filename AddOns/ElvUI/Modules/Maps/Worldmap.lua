local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('WorldMap')

--Lua functions
local _G = _G
local strfind = strfind
--WoW API / Variables
local CreateFrame = CreateFrame
local SetCVar = SetCVar
local GetCVarBool = GetCVarBool
local InCombatLockdown = InCombatLockdown
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local MOUSE_LABEL = MOUSE_LABEL:gsub('|T.-|t','')
local PLAYER = PLAYER
-- GLOBALS: WORLD_MAP_MIN_ALPHA, CoordsHolder

local INVERTED_POINTS = {
	['TOPLEFT'] = 'BOTTOMLEFT',
	['TOPRIGHT'] = 'BOTTOMRIGHT',
	['BOTTOMLEFT'] = 'TOPLEFT',
	['BOTTOMRIGHT'] = 'TOPRIGHT',
	['TOP'] = 'BOTTOM',
	['BOTTOM'] = 'TOP',
}

-- this will be updated later
local smallerMapScale = 0.8

function M:SetLargeWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame:OnFrameSizeChanged()
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)
end

function M:SetSmallWorldMap(smallerScale)
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:SetScale(smallerScale)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:SetFrameStrata('HIGH')

	_G.WorldMapTooltip:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 110)
end

function M:GetCursorPosition()
	local WorldMapFrame = _G.WorldMapFrame
	local x,y = self.hooks[WorldMapFrame.ScrollContainer].GetCursorPosition(WorldMapFrame.ScrollContainer)
	local s = WorldMapFrame:GetScale()

	return x / s, y / s
end

local inRestrictedArea = false
function M:UpdateRestrictedArea()
	if E.MapInfo.x and E.MapInfo.y then
		inRestrictedArea = false
	else
		inRestrictedArea = true
		CoordsHolder.playerCoords:SetFormattedText('%s:   %s', PLAYER, 'N/A')
	end
end

function M:UpdateCoords(OnShow)
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsShown() then return end

	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
		if x and y and x >= 0 and y >= 0 then
			CoordsHolder.mouseCoords:SetFormattedText('%s:   %.2f, %.2f', MOUSE_LABEL, x * 100, y * 100)
		else
			CoordsHolder.mouseCoords:SetText('')
		end
	else
		CoordsHolder.mouseCoords:SetText('')
	end

	if not inRestrictedArea and (OnShow or E.MapInfo.coordsWatching) then
		if E.MapInfo.x and E.MapInfo.y then
			CoordsHolder.playerCoords:SetFormattedText('%s:   %.2f, %.2f', PLAYER, (E.MapInfo.xText or 0), (E.MapInfo.yText or 0))
		else
			CoordsHolder.playerCoords:SetFormattedText('%s:   %s', PLAYER, 'N/A')
		end
	end
end

function M:PositionCoords()
	local db = E.global.general.WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if strfind(position, 'RIGHT') then	x = -5 end
	if strfind(position, 'TOP') then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:Point(position, _G.WorldMapFrame.ScrollContainer, position, x + xOffset, y + yOffset)

	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:AllowMapFade()
	return GetCVarBool('mapFade') and not _G.WorldMapFrame:IsMouseOver()
end

function M:SetMovementAlpha()
	local WorldMapFrame = _G.WorldMapFrame
	_G.PlayerMovementFrameFader.RemoveFrame(WorldMapFrame)
	_G.PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, E.global.general.mapAlphaWhenMoving, 1, .5, M.AllowMapFade)
end

function M:ToggleMapFix(event)
	local WorldMapFrame = _G.WorldMapFrame
	ShowUIPanel(WorldMapFrame)
	WorldMapFrame:SetAttribute('UIPanelLayout-area', 'center')
	WorldMapFrame:SetAttribute('UIPanelLayout-allowOtherPanels', true)
	HideUIPanel(WorldMapFrame)

	if event then
		self:UnregisterEvent(event)
	end
end

function M:Initialize()
	self.Initialized = true

	if not E.private.general.worldMap then
		return
	end

	local WorldMapFrame = _G.WorldMapFrame
	if E.global.general.WorldMapCoordinates.enable then
		local CoordsHolder = CreateFrame('Frame', 'CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(_G.NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(_G.NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..':   0, 0')
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..':   0, 0')

		WorldMapFrame:HookScript('OnShow', function()
			if not M.CoordsTimer then
				M:UpdateCoords(true)
				M.CoordsTimer = M:ScheduleRepeatingTimer('UpdateCoords', 0.1)
			end
		end)
		WorldMapFrame:HookScript('OnHide', function()
			M:CancelTimer(M.CoordsTimer)
			M.CoordsTimer = nil
		end)

		M:PositionCoords()

		E:RegisterEventForObject('LOADING_SCREEN_DISABLED', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_NEW_AREA', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED_INDOORS', E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject('ZONE_CHANGED', E.MapInfo, M.UpdateRestrictedArea)
	end

	if E.global.general.smallerWorldMap then
		smallerMapScale = E.global.general.smallerWorldMapScale

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleMapFix")
		else
			self:ToggleMapFix()
		end

		self:SecureHookScript(WorldMapFrame, 'OnShow', function()
			self:SetSmallWorldMap(smallerMapScale)

			M:Unhook(WorldMapFrame, 'OnShow', nil)
		end)
	else
		self:SetLargeWorldMap()
	end

	_G.WorldMapMagnifyingGlassButton:Point('TOPLEFT', 60, -120)

	self:RawHook(WorldMapFrame.ScrollContainer, 'GetCursorPosition', 'GetCursorPosition', true)

	--Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = E.global.general.mapAlphaWhenMoving
	SetCVar('mapAnimMinAlpha', E.global.general.mapAlphaWhenMoving)

	--Enable/Disable map fading when moving
	SetCVar('mapFade', (E.global.general.fadeMapWhenMoving == true and 1 or 0))

	self:SetMovementAlpha()
end

E:RegisterInitialModule(M:GetName())
