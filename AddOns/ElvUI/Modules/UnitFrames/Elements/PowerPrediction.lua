local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_PowerPrediction(frame)
	local power = frame.Power

	local mainBar = CreateFrame('StatusBar', nil, power)
	mainBar.parent = power
	UF.statusbars[mainBar] = true
	mainBar:Hide()

	local PowerPrediction = { mainBar = mainBar, parent = frame }
	local texture = (not power.isTransparent and power:GetStatusBarTexture()) or E.media.blankTex
	UF:Update_StatusBar(mainBar, texture)

	return PowerPrediction
end

function UF:Configure_PowerPrediction(frame)
	local powerPrediction = frame.PowerPrediction
	if frame.db.power.powerPrediction then
		if not frame:IsElementEnabled('PowerPrediction') then
			frame:EnableElement('PowerPrediction')
		end

		local power = frame.Power
		local powerTexture = power:GetStatusBarTexture()
		local mainBar = powerPrediction.mainBar
		local orientation = frame.db.power.orientation or power:GetOrientation()
		local reverseFill = not not frame.db.power.reverseFill

		mainBar:SetReverseFill(not reverseFill)

		if orientation == "HORIZONTAL" then
			local width = power:GetWidth()
			local point = reverseFill and "LEFT" or "RIGHT"

			mainBar:ClearAllPoints()
			mainBar:Point("TOP", power, "TOP")
			mainBar:Point("BOTTOM", power, "BOTTOM")
			mainBar:Point(point, powerTexture, point)
			mainBar:Size(width, 0)
		else
			local height = power:GetHeight()
			local point = reverseFill and "BOTTOM" or "TOP"

			mainBar:ClearAllPoints()
			mainBar:Point("LEFT", power, "LEFT")
			mainBar:Point("RIGHT", power, "RIGHT")
			mainBar:Point(point, powerTexture, point)
			mainBar:Size(0, height)
		end
	elseif frame:IsElementEnabled('PowerPrediction') then
		frame:DisableElement('PowerPrediction')
	end
end
