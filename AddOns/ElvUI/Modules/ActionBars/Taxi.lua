local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local LAB = E.Libs.LAB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group("ElvUI", "ActionBars")
local TaxiButtonHolder
--[[
AB.customTaxiButton = {
	func = TaxiRequestEarlyLanding,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = _G.LEAVE_VEHICLE,
}
]]

function AB:MoveTaxiButton()
	TaxiButtonHolder = CreateFrame('Frame', nil, E.UIParent)
	TaxiButtonHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 300)
	TaxiButtonHolder:Size(_G.MainMenuBarVehicleLeaveButton:GetSize())

	local Button = _G.MainMenuBarVehicleLeaveButton

	if (MasqueGroup and E.private.actionbar.masque.actionbars and true) then
		Button:StyleButton(true, true, true)
	else
		Button:CreateBackdrop(nil, true)
		Button:GetNormalTexture():SetTexCoord(0.140625 + .08, 0.859375 - .06, 0.140625 + .08, 0.859375 - .08)
		Button:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		Button:StyleButton(nil, true, true)
	end

	Button:ClearAllPoints()
	Button:SetParent(_G.UIParent)
	Button:SetPoint('CENTER', TaxiButtonHolder, 'CENTER')

	E:CreateMover(TaxiButtonHolder, 'TaxiButtonMover', L["Taxi Button"], nil, nil, nil, nil, nil, 'all,general')

	hooksecurefunc(Button, 'SetPoint', function(_, _, parent)
		if parent ~= TaxiButtonHolder then
			Button:ClearAllPoints()
			Button:SetParent(_G.UIParent)
			Button:SetPoint('CENTER', TaxiButtonHolder, 'CENTER')
		end
	end)

	hooksecurefunc(Button, 'SetHighlightTexture', function(_, tex)
		if tex ~= self.hover then
			Button:SetHighlightTexture(self.hover)
		end
	end)
end
