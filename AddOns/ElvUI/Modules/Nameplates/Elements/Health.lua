local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local ipairs = ipairs
local unpack = unpack
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame

function NP:Health_UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end
	local element = self.Health

	local r, g, b, t
	if element.colorDisconnected and not UnitIsConnected(unit) then
		t = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		t = NP.db.colors.tapped
	elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and UnitPlayerControlled(unit) and not self.isPlayer) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		local reaction = UnitReaction(unit, 'player')
		if reaction <= 3 then reaction = 'bad' elseif reaction == 4 then reaction = 'neutral' else reaction = 'good' end
		t = NP.db.colors.reactions[reaction]
	elseif element.colorSmooth then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	elseif element.colorHealth then
		t = NP.db.colors.health
	end

	if t then
		r, g, b = t[1] or t.r, t[2] or t.g, t[3] or t.b
		element.r, element.g, element.b = r, g, b -- save these for the style filter to switch back
	end

	local sf = NP:StyleFilterChanges(self)
	if sf.HealthColor then
		r, g, b = sf.HealthColor.r, sf.HealthColor.g, sf.HealthColor.b
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
	local Health = CreateFrame('StatusBar', nameplate:GetName()..'Health', nameplate)
	Health:SetFrameStrata(nameplate:GetFrameStrata())
	Health:SetFrameLevel(5)
	Health:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	Health:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))

	local clipFrame = CreateFrame('Frame', nil, Health)
	clipFrame:SetClipsChildren(true)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	Health.ClipFrame = clipFrame

	NP.StatusBars[Health] = true

	local statusBarTexture = Health:GetStatusBarTexture()
	local healthFlashTexture = Health:CreateTexture(nameplate:GetName()..'FlashTexture', 'OVERLAY')
	healthFlashTexture:SetTexture(LSM:Fetch('background', 'ElvUI Blank'))
	healthFlashTexture:Point('BOTTOMLEFT', statusBarTexture, 'BOTTOMLEFT')
	healthFlashTexture:Point('TOPRIGHT', statusBarTexture, 'TOPRIGHT')
	healthFlashTexture:Hide()
	nameplate.HealthFlashTexture = healthFlashTexture

	Health.colorTapping = true
	Health.colorReaction = true
	Health.UpdateColor = NP.Health_UpdateColor

	return Health
end

function NP:Update_Health(nameplate, skipUpdate)
	local db = NP:PlateDB(nameplate)

	nameplate.Health.colorTapping = true
	nameplate.Health.colorReaction = true
	nameplate.Health.colorClass = db.health.useClassColor
	if skipUpdate then return end

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
	elseif nameplate:IsElementEnabled('Health') then
		nameplate:DisableElement('Health')
	end

	nameplate.Health.width = db.health.width
	nameplate.Health.height = db.health.height
	nameplate.Health:Height(db.health.height)
end

local bars = { 'myBar', 'otherBar' }
function NP:Construct_HealthPrediction(nameplate)
	if nameplate then return end

	local HealthPrediction = CreateFrame('Frame', nameplate:GetName()..'HealthPrediction', nameplate)

	for _, name in ipairs(bars) do
		local bar = CreateFrame('StatusBar', nil, nameplate.Health.ClipFrame)
		bar:SetFrameStrata(nameplate:GetFrameStrata())
		bar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		bar:Point('TOP')
		bar:Point('BOTTOM')
		bar:Width(150)
		HealthPrediction[name] = bar
		NP.StatusBars[bar] = true
	end

	local healthTexture = nameplate.Health:GetStatusBarTexture()
	local healthFrameLevel = nameplate.Health:GetFrameLevel()
	HealthPrediction.myBar:Point('LEFT', healthTexture, 'RIGHT')
	HealthPrediction.myBar:SetFrameLevel(healthFrameLevel + 2)
	HealthPrediction.myBar:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
	HealthPrediction.myBar:SetMinMaxValues(0, 1)

	HealthPrediction.otherBar:Point('LEFT', HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.otherBar:SetFrameLevel(healthFrameLevel + 1)
	HealthPrediction.otherBar:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	return HealthPrediction
end

function NP:Update_HealthPrediction(nameplate)
	if nameplate then return end

	local db = NP:PlateDB(nameplate)

	if db.health.enable and db.health.healPrediction then
		if not nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:EnableElement('HealthPrediction')
		end

		nameplate.HealthPrediction.myBar:SetStatusBarColor(NP.db.colors.healPrediction.personal.r, NP.db.colors.healPrediction.personal.g, NP.db.colors.healPrediction.personal.b)
		nameplate.HealthPrediction.otherBar:SetStatusBarColor(NP.db.colors.healPrediction.others.r, NP.db.colors.healPrediction.others.g, NP.db.colors.healPrediction.others.b)
	elseif nameplate:IsElementEnabled('HealthPrediction') then
		nameplate:DisableElement('HealthPrediction')
	end
end
