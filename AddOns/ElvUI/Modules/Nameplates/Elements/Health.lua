local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

-- Cache global variables
-- Lua functions
local pairs = pairs
local unpack = unpack
-- WoW API / Variables
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local CreateFrame = CreateFrame

function NP:Health_UpdateColor(event, unit)
	if(not unit or self.unit ~= unit) then return end
	local element = self.Health

	local r, g, b, t
	if(element.colorDead and element.dead) then
		t = self.colors.dead
	elseif(element.colorDisconnected and element.disconnected) then
		t = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = NP.db.colors.tapped
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		local reaction = UnitReaction(unit, 'player')
		if reaction <= 3 then reaction = 'bad' elseif reaction == 4 then reaction = 'neutral' else reaction = 'good' end
		t = NP.db.colors.reactions[reaction]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	elseif(element.colorHealth) then
		t = NP.db.colors.health
	end

	if t then
		r, g, b = t[1] or t.r, t[2] or t.g, t[3] or t.b
		element.r, element.g, element.b = r, g, b -- save these for the style filter to switch back
	end

	local SF_HealthColor = NP:StyleFilterCheckChanges(self, 'HealthColor')
	if SF_HealthColor then
		r, g, b = SF_HealthColor.r, SF_HealthColor.g, SF_HealthColor.b
	end

	if b then
		element:SetStatusBarColor(r, g, b)

		if element.bg then
			element.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
		end
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, r, g, b)
	end
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate:GetDebugName()..'Health', nameplate)
	Health:SetFrameStrata(nameplate:GetFrameStrata())
	Health:SetFrameLevel(5)
	Health:CreateBackdrop('Transparent')
	Health:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))

	local clipFrame = CreateFrame('Frame', nil, Health)
	clipFrame:SetClipsChildren(true)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	Health.ClipFrame = clipFrame

	--[[Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints()
	Health.bg:SetTexture(E.media.blankTex)
	Health.bg.multiplier = 0.2]]

	NP.StatusBars[Health] = true

	local statusBarTexture = Health:GetStatusBarTexture()
	local healthFlashTexture = Health:CreateTexture(nameplate:GetDebugName()..'FlashTexture', "OVERLAY")
	healthFlashTexture:SetTexture(E.Libs.LSM:Fetch("background", "ElvUI Blank"))
	healthFlashTexture:Point("BOTTOMLEFT", statusBarTexture, "BOTTOMLEFT")
	healthFlashTexture:Point("TOPRIGHT", statusBarTexture, "TOPRIGHT")
	healthFlashTexture:Hide()
	nameplate.HealthFlashTexture = healthFlashTexture

	Health.colorTapping = true
	Health.colorReaction = true
	Health.frequentUpdates = true --Azil, keep this for now. It seems it may prevent event bugs
	Health.UpdateColor = NP.Health_UpdateColor

	return Health
end

function NP:Update_Health(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate.Health.colorTapping = true
	nameplate.Health.colorClass = db.health.useClassColor
	nameplate.Health.colorReaction = true

	if db.health.enable then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:Point('CENTER')
		nameplate.Health:Point('LEFT')
		nameplate.Health:Point('RIGHT')

		nameplate:SetHealthUpdateMethod(E.global.nameplate.effectiveHealth)
		nameplate:SetHealthUpdateSpeed(E.global.nameplate.effectiveHealthSpeed)

		E:SetSmoothing(nameplate.Health, NP.db.smoothbars)
	else
		if nameplate:IsElementEnabled('Health') then
			nameplate:DisableElement('Health')
		end
	end

	if db.health.text.enable then
		nameplate.Health.Text:ClearAllPoints()
		nameplate.Health.Text:Point(E.InversePoints[db.health.text.position], db.health.text.parent == 'Nameplate' and nameplate or nameplate[db.health.text.parent], db.health.text.position, db.health.text.xOffset, db.health.text.yOffset)
		nameplate.Health.Text:FontTemplate(E.LSM:Fetch('font', db.health.text.font), db.health.text.fontSize, db.health.text.fontOutline)
		nameplate.Health.Text:Show()
	else
		nameplate.Health.Text:Hide()
	end

	nameplate:Tag(nameplate.Health.Text, db.health.text.format)
	nameplate.Health.Text.frequentUpdates = .1

	nameplate.Health.width = db.health.width
	nameplate.Health.height = db.health.height
	nameplate.Health:Height(db.health.height)
end

function NP:Construct_HealthPrediction(nameplate)
	local HealthPrediction = CreateFrame('Frame', nameplate:GetDebugName()..'HealthPrediction', nameplate)
	local healthTexture = nameplate.Health:GetStatusBarTexture()
	local healthFrameLevel = nameplate.Health:GetFrameLevel()

	HealthPrediction.myBar = CreateFrame('StatusBar', nil, nameplate.Health.ClipFrame)
	HealthPrediction.myBar:SetFrameStrata(nameplate:GetFrameStrata())
	HealthPrediction.myBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	HealthPrediction.myBar:SetFrameLevel(healthFrameLevel + 2)
	HealthPrediction.myBar:SetMinMaxValues(0, 1)
	HealthPrediction.myBar:SetWidth(150)
	HealthPrediction.myBar:SetPoint('TOP')
	HealthPrediction.myBar:SetPoint('BOTTOM')
	HealthPrediction.myBar:SetPoint('LEFT', healthTexture, 'RIGHT')

	HealthPrediction.otherBar = CreateFrame('StatusBar', nil, nameplate.Health.ClipFrame)
	HealthPrediction.otherBar:SetFrameStrata(nameplate:GetFrameStrata())
	HealthPrediction.otherBar:SetFrameLevel(healthFrameLevel + 3)
	HealthPrediction.otherBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	HealthPrediction.otherBar:SetPoint('TOP')
	HealthPrediction.otherBar:SetPoint('BOTTOM')
	HealthPrediction.otherBar:SetPoint('LEFT', healthTexture, 'RIGHT')
	HealthPrediction.otherBar:SetWidth(150)

	NP.StatusBars[HealthPrediction.myBar] = true
	NP.StatusBars[HealthPrediction.otherBar] = true

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	return HealthPrediction
end

function NP:Update_HealthPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.health.enable and db.health.healPrediction then
		if not nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:EnableElement('HealthPrediction')
		end

		nameplate.HealthPrediction.myBar:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
		nameplate.HealthPrediction.otherBar:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)
	else
		if nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:DisableElement('HealthPrediction')
		end
	end
end
