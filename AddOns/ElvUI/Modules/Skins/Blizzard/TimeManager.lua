local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
local select = select
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.timemanager then return end

	local TimeManagerFrame = _G.TimeManagerFrame
	S:HandleFrame(TimeManagerFrame, true)
	TimeManagerFrame:Size(190, 240)

	E:CreateMover(TimeManagerFrame, 'TimeManagerFrameMover', _G.TIMEMANAGER_TITLE)
	TimeManagerFrame.mover:SetFrameLevel(TimeManagerFrame:GetFrameLevel() + 4)

	select(7, TimeManagerFrame:GetRegions()):Point('TOP', 0, -5)

	_G.TimeManagerFrameCloseButton:Point('TOPRIGHT', 4, 5)

	_G.TimeManagerStopwatchFrame:Point('TOPRIGHT', 10, -12)

	_G.TimeManagerStopwatchCheck:SetTemplate('Default')
	_G.TimeManagerStopwatchCheck:StyleButton(nil, true)

	_G.TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	_G.TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

	_G.TimeManagerAlarmTimeFrame:Point('TOPLEFT', 12, -65)

	S:HandleDropDownBox(_G.TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(_G.TimeManagerAlarmMessageEditBox)

	_G.TimeManagerAlarmEnabledButton:Point('LEFT', 16, -45)
	_G.TimeManagerAlarmEnabledButton:SetNormalTexture(nil)
	_G.TimeManagerAlarmEnabledButton.SetNormalTexture = E.noop
	_G.TimeManagerAlarmEnabledButton:SetPushedTexture(nil)
	_G.TimeManagerAlarmEnabledButton.SetPushedTexture = E.noop
	S:HandleButton(_G.TimeManagerAlarmEnabledButton)

	_G.TimeManagerMilitaryTimeCheck:Point('TOPLEFT', 155, -190)
	S:HandleCheckBox(_G.TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(_G.TimeManagerLocalTimeCheck)

	_G.StopwatchFrame:CreateBackdrop('Transparent')
	_G.StopwatchFrame.backdrop:Point('TOPLEFT', 0, -16)
	_G.StopwatchFrame.backdrop:Point('BOTTOMRIGHT', 0, 2)

	_G.StopwatchFrame:StripTextures()

	_G.StopwatchTabFrame:StripTextures()

	S:HandleCloseButton(_G.StopwatchCloseButton)

	_G.StopwatchPlayPauseButton:CreateBackdrop('Default', true)
	_G.StopwatchPlayPauseButton:SetSize(12, 12)
	_G.StopwatchPlayPauseButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\play')
	_G.StopwatchPlayPauseButton:SetHighlightTexture('')
	_G.StopwatchPlayPauseButton.backdrop:SetOutside(_G.StopwatchPlayPauseButton, 2, 2)
	_G.StopwatchPlayPauseButton:HookScript('OnEnter', S.SetModifiedBackdrop)
	_G.StopwatchPlayPauseButton:HookScript('OnLeave', S.SetOriginalBackdrop)
	_G.StopwatchPlayPauseButton:Point('RIGHT', _G.StopwatchResetButton, 'LEFT', -4, 0)
	S:HandleButton(_G.StopwatchResetButton)
	_G.StopwatchResetButton:SetSize(16,16)
	_G.StopwatchResetButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\reset')
	_G.StopwatchResetButton:Point('BOTTOMRIGHT', _G.StopwatchFrame, 'BOTTOMRIGHT', -4, 6)

	local function SetPlayTexture()
		_G.StopwatchPlayPauseButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\play')
	end
	local function SetPauseTexture()
		_G.StopwatchPlayPauseButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\pause')
	end

	hooksecurefunc('Stopwatch_Play', SetPauseTexture)
	hooksecurefunc('Stopwatch_Pause', SetPlayTexture)
	hooksecurefunc('Stopwatch_Clear', SetPlayTexture)
end

S:AddCallbackForAddon('Blizzard_TimeManager', 'Skin_Blizzard_TimeManager', LoadSkin)