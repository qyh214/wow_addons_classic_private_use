local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function UF.HealthClipFrame_HealComm(frame)
	local pred = frame.HealthPrediction
	if pred then
		UF:SetAlpha_HealComm(pred, true)
		UF:SetVisibility_HealComm(pred)
	end
end

function UF:SetAlpha_HealComm(obj, show)
	obj.myBar:SetAlpha(show and 1 or 0)
end

function UF:SetVisibility_HealComm(obj)
	-- the first update is from `HealthClipFrame_HealComm`
	-- we set this variable to allow `Configure_HealComm` to
	-- update the elements overflow lock later on by option
	if not obj.allowClippingUpdate then
		obj.allowClippingUpdate = true
	end

	if obj.maxOverflow > 1 then
		obj.myBar:SetParent(obj.health)
	else
		obj.myBar:SetParent(obj.parent)
	end
end

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local myBar = CreateFrame('StatusBar', nil, parent)

	myBar:SetFrameLevel(11)

	UF.statusbars[myBar] = true

	local texture = (not health.isTransparent and health:GetStatusBarTexture()) or E.media.blankTex
	UF:Update_StatusBar(myBar, texture)

	local healPrediction = {
		myBar = myBar,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	UF:SetAlpha_HealComm(healPrediction)

	return healPrediction
end

function UF:Configure_HealComm(frame)
	if frame.db.healPrediction and frame.db.healPrediction.enable then
		local healPrediction = frame.HealthPrediction
		local myBar = healPrediction.myBar
		local c = self.db.colors.healPrediction
		healPrediction.maxOverflow = 1 + (c.maxOverflow or 0)

		if healPrediction.allowClippingUpdate then
			UF:SetVisibility_HealComm(healPrediction)
		end

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		if frame.db.health then
			local health = frame.Health
			local orientation = frame.db.health.orientation or health:GetOrientation()
			local reverseFill = not not frame.db.health.reverseFill
			local showAbsorbAmount = frame.db.healPrediction.showAbsorbAmount

			myBar:SetOrientation(orientation)

			if orientation == "HORIZONTAL" then
				local width = health:GetWidth()
				width = (width > 0 and width) or health.WIDTH
				local p1 = reverseFill and "RIGHT" or "LEFT"
				local p2 = reverseFill and "LEFT" or "RIGHT"
				local healthTexture = health:GetStatusBarTexture()

				myBar:Size(width, 0)
				myBar:ClearAllPoints()
				myBar:Point("TOP", health, "TOP")
				myBar:Point("BOTTOM", health, "BOTTOM")
				myBar:Point(p1, healthTexture, p2)
			else
				local height = health:GetHeight()
				height = (height > 0 and height) or health.HEIGHT
				local p1 = reverseFill and "TOP" or "BOTTOM"
				local p2 = reverseFill and "BOTTOM" or "TOP"
				local healthTexture = health:GetStatusBarTexture()

				myBar:Size(0, height)
				myBar:ClearAllPoints()
				myBar:Point("LEFT", health, "LEFT")
				myBar:Point("RIGHT", health, "RIGHT")
				myBar:Point(p1, healthTexture, p2)
			end

			myBar:SetReverseFill(reverseFill)
		end

		myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end
