local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G.TaxiFrame
	S:HandlePortraitFrame(TaxiFrame, true)
	TaxiFrame.backdrop:Point('TOPLEFT', 15, -11)
	TaxiFrame.backdrop:Point('BOTTOMRIGHT', -30, 76)

	_G.TaxiMap:CreateBackdrop('Default')
	_G.TaxiMap:Point('TOPLEFT', TaxiFrame, 'TOPLEFT', 27, -73)
	_G.TaxiRouteMap:Point('TOPLEFT', TaxiFrame, 'TOPLEFT', 27, -73)

	_G.TaxiPortrait:Kill()

	S:HandleCloseButton(_G.TaxiCloseButton, TaxiFrame.backdrop)
end

S:AddCallback('Taxi', LoadSkin)