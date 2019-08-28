local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local SetDressUpBackground = SetDressUpBackground

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end

	local DressUpFrame = _G.DressUpFrame
	DressUpFrame:StripTextures()
	DressUpFrame:CreateBackdrop('Transparent')
	DressUpFrame.backdrop:Point('TOPLEFT', 10, -12)
	DressUpFrame.backdrop:Point('BOTTOMRIGHT', -33, 73)

	DressUpFramePortrait:Kill()

	-- SetDressUpBackground()
	DressUpFrameBackgroundTopLeft:SetDesaturated(true)
	DressUpFrameBackgroundTopRight:SetDesaturated(true)
	DressUpFrameBackgroundBot:SetDesaturated(true)

	DressUpFrameDescriptionText:Point('CENTER', DressUpFrameTitleText, 'BOTTOM', -5, -22)

	S:HandleCloseButton(DressUpFrameCloseButton)

	S:HandleRotateButton(DressUpModelFrameRotateLeftButton)
	DressUpModelFrameRotateLeftButton:Point('TOPLEFT', DressUpFrame, 25, -79)
	S:HandleRotateButton(DressUpModelFrameRotateRightButton)
	DressUpModelFrameRotateRightButton:Point('TOPLEFT', DressUpModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	S:HandleButton(DressUpFrameCancelButton)
	DressUpFrameCancelButton:Point('CENTER', DressUpFrame, 'TOPLEFT', 306, -423)
	S:HandleButton(DressUpFrameResetButton)
	DressUpFrameResetButton:Point('RIGHT', DressUpFrameCancelButton, 'LEFT', -3, 0)

	DressUpModelFrame:CreateBackdrop('Default')
	DressUpModelFrame.backdrop:Point('TOPLEFT', -2, 1)
	DressUpModelFrame.backdrop:Point('BOTTOMRIGHT', 0, 19)
end

S:AddCallback('DressingRoom', LoadSkin)