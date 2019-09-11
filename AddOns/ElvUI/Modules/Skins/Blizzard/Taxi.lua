local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G.TaxiFrame
	S:HandlePortraitFrame(TaxiFrame, true)
	TaxiFrame.backdrop:Point('TOPLEFT', 11, -12)
	TaxiFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)

	_G.TaxiMap:CreateBackdrop('Default')
	_G.TaxiMap:Point('TOPLEFT', 23, -70)
	_G.TaxiRouteMap:Point('TOPLEFT', 23, -70)

	_G.TaxiPortrait:Kill()

	_G.TaxiMerchant:SetTextColor(1, 1, 1)

	S:HandleCloseButton(_G.TaxiCloseButton, TaxiFrame.backdrop)
	_G.TaxiCloseButton:Point('TOPRIGHT', -28, -9)
end

S:AddCallback('Taxi', LoadSkin)