local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G.TaxiFrame
	TaxiFrame:CreateBackdrop('Transparent')
	TaxiFrame.backdrop:Point('TOPLEFT', 11, -12)
	TaxiFrame.backdrop:Point('BOTTOMRIGHT', -34, 75)

	TaxiFrame:StripTextures()

	_G.TaxiPortrait:Kill()

	S:HandleCloseButton(_G.TaxiCloseButton)

	_G.TaxiRouteMap:CreateBackdrop('Default')
end

S:AddCallback('Taxi', LoadSkin)