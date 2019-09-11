local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:CreateBackdrop('Transparent')

	S:HandleDropDownBox(_G.WorldMapContinentDropDown)
	S:HandleDropDownBox(_G.WorldMapZoneDropDown)

	_G.WorldMapContinentDropDown:Point('TOPLEFT', WorldMapFrame, 'TOPLEFT', 289, -40)
	_G.WorldMapZoneDropDown:Point('LEFT', _G.WorldMapContinentDropDown, 'RIGHT', -32, 0)

	_G.WorldMapZoomOutButton:Point('LEFT', _G.WorldMapZoneDropDown, 'RIGHT', -12, 2)
	_G.WorldMapZoomOutButton:Height(20)

	S:HandleButton(_G.WorldMapZoomOutButton)

	S:HandleCloseButton(_G.WorldMapFrameCloseButton, WorldMapFrame.backdrop)
	_G.WorldMapFrameCloseButton:SetFrameLevel(_G.WorldMapFrameCloseButton:GetFrameLevel() + 2)
end

S:AddCallback('SkinWorldMap', LoadSkin)
