local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

function UF:Construct_Cutaway(frame)
	local cutaway = {}
	local frameName = frame:GetDebugName()

	if frame.Power then
		local powerTexture = frame.Power:GetStatusBarTexture()
		local cutawayPower = frame.Power.ClipFrame:CreateTexture(frameName .. "CutawayPower")
		cutawayPower:SetPoint("TOPLEFT", powerTexture, "TOPRIGHT")
		cutawayPower:SetPoint("BOTTOMLEFT", powerTexture, "BOTTOMRIGHT")
		cutawayPower:SetTexture(E.media.blankTex)
		cutaway.Power = cutawayPower
	end

	local healthTexture = frame.Health:GetStatusBarTexture()
	local cutawayHealth = frame.Health.ClipFrame:CreateTexture(frameName .. "CutawayHealth")
	cutawayHealth:SetPoint("TOPLEFT", healthTexture, "TOPRIGHT")
	cutawayHealth:SetPoint("BOTTOMLEFT", healthTexture, "BOTTOMRIGHT")
	cutawayHealth:SetTexture(E.media.blankTex)
	cutaway.Health = cutawayHealth

	return cutaway
end

local cutawayPoints = {
	[-4] = {"TOPLEFT", "BOTTOMLEFT"},
	[-3] = {"TOPRIGHT", "BOTTOMRIGHT"},
	[-2] = {"TOPRIGHT", "TOPLEFT"},
	[-1] = {"BOTTOMRIGHT", "BOTTOMLEFT"},
	[1] = {"TOPLEFT", "TOPRIGHT"},
	[2] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[3] = {"BOTTOMLEFT", "TOPLEFT"},
	[4] = {"BOTTOMRIGHT", "TOPRIGHT"}
}

local DEFAULT_INDEX, VERT_INDEX = 1, 3
function UF:GetPoints_Cutaway(db)
	local index = (db.orientation == "VERTICAL" and VERT_INDEX) or DEFAULT_INDEX
	local p1 = (db.reverseFill and -index) or index
	local p2 = p1 + (db.reverseFill and -1 or 1)
	return cutawayPoints[p1], cutawayPoints[p2]
end

function UF:Configure_Cutaway(frame)
	local db = frame.db and frame.db.cutaway
	local healthDB, powerDB = db and db.health, db and db.power
	local healthEnabled = healthDB and healthDB.enabled
	local powerEnabled = powerDB and powerDB.enabled
	if healthEnabled or powerEnabled then
		if not frame:IsElementEnabled("Cutaway") then
			frame:EnableElement("Cutaway")
		end

		frame.Cutaway:UpdateConfigurationValues(db)
		local health = frame.Cutaway.Health
		if health and healthEnabled then
			local point1, point2 = UF:GetPoints_Cutaway(healthDB)
			local barTexture = frame.Health:GetStatusBarTexture()

			health:ClearAllPoints()
			health:SetPoint(point1[1], barTexture, point1[2])
			health:SetPoint(point2[1], barTexture, point2[2])

			frame.Health:PostUpdateColor(frame.unit)
		end

		local power = frame.Cutaway.Power
		local powerUsable = powerEnabled and frame.USE_POWERBAR
		if power and powerUsable then
			local point1, point2 = UF:GetPoints_Cutaway(powerDB)
			local barTexture = frame.Power:GetStatusBarTexture()

			power:ClearAllPoints()
			power:SetPoint(point1[1], barTexture, point1[2])
			power:SetPoint(point2[1], barTexture, point2[2])

			frame.Power:PostUpdateColor()
		end
	elseif frame:IsElementEnabled("Cutaway") then
		frame:DisableElement("Cutaway")
	end
end
