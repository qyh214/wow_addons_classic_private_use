local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame:CreateBackdrop('Transparent')

	S:HandleDropDownBox(WorldMapContinentDropDown, 170)
	S:HandleDropDownBox(WorldMapZoneDropDown, 170)

	WorldMapZoneDropDown:Point('LEFT', WorldMapContinentDropDown, 'RIGHT', -24, 0)
	WorldMapZoomOutButton:Point('LEFT', WorldMapZoneDropDown, 'RIGHT', -4, 3)

	S:HandleButton(WorldMapZoomOutButton)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	WorldMapFrame.ScrollContainer:CreateBackdrop('Default')
end

S:AddCallback('SkinWorldMap', LoadSkin)