local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local _G = _G
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

function UF:Construct_PartyFrames()
	self:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	self:SetScript('OnLeave', _G.UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)

	self.BORDER = E.Border
	self.SPACING = E.Spacing
	self.SHADOW_SPACING = 3

	if self.isChild then
		self.Health = UF:Construct_HealthBar(self, true)
		self.Name = UF:Construct_NameText(self)

		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)

		self.originalParent = self:GetParent()

		self.childType = "pet"
		if self == _G[self.originalParent:GetName()..'Target'] then
			self.childType = "target"
		end

		self.unitframeType = "party"..self.childType
	else
		self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
		self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT')
		self.Power.frequentUpdates = false;
		self.InfoPanel = UF:Construct_InfoPanel(self)
		self.Name = UF:Construct_NameText(self)
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)

		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.customTexts = {}
		self.AuraHighlight = UF:Construct_AuraHighlight(self)
		self.HealthPrediction = UF:Construct_HealComm(self)
		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.PhaseIndicator = UF:Construct_PhaseIcon(self)
		self.Portrait2D = UF:Construct_Portrait(self, 'texture')
		self.Portrait3D = UF:Construct_Portrait(self, 'model')
		self.PowerPrediction = UF:Construct_PowerPrediction(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
		self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self)
		self.ResurrectIndicator = UF:Construct_ResurrectionIcon(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.ThreatIndicator = UF:Construct_Threat(self)

		self.Sparkle = CreateFrame("Frame", nil, self)
		self.Sparkle:SetAllPoints(self.Health)

		self.unitframeType = "party"
	end

	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	return self
end

function UF:Update_PartyHeader(header, db)
	local parent = header:GetParent()
	parent.db = db

	if not parent.positioned then
		parent:ClearAllPoints()
		parent:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', 4, 248)
		E:CreateMover(parent, parent:GetName()..'Mover', L["Party Frames"], nil, nil, nil, 'ALL,PARTY,ARENA', nil, 'unitframe,groupUnits,party,generalGroup')
		parent.positioned = true
	end
end

function UF:Update_PartyFrames(frame, db)
	frame.db = db

	frame.colors = ElvUF.colors
	frame:RegisterForClicks(UF.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		if UF.thinBorders then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end

		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CLASSBAR_YOFFSET = 0

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	end

	if frame.isChild then
		frame.USE_PORTAIT = false
		frame.USE_PORTRAIT_OVERLAY = false
		frame.PORTRAIT_WIDTH = 0
		frame.USE_POWERBAR = false
		frame.USE_INSET_POWERBAR = false
		frame.USE_MINI_POWERBAR = false
		frame.USE_POWERBAR_OFFSET = false
		frame.POWERBAR_OFFSET = 0

		frame.POWERBAR_HEIGHT = 0
		frame.POWERBAR_WIDTH = 0

		frame.BOTTOM_OFFSET = 0

		frame.db = frame.childType == "target" and db.targetsGroup or db.petsGroup
		db = frame.db

		if frame.childType == 'pet' then
			frame.Health.colorPetByUnitClass = db.colorPetByUnitClass
		end

		frame:Size(db.width, db.height)

		if not InCombatLockdown() then
			if db.enable then
				frame:Enable()
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[db.anchorPoint], frame.originalParent, db.anchorPoint, db.xOffset, db.yOffset)
			else
				frame:Disable()
			end
		end

		UF:Configure_HealthBar(frame)
	else
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame)
		UF:EnableDisable_Auras(frame)
		UF:Configure_AllAuras(frame)

		UF:Configure_AuraWatch(frame)
		UF:Configure_CustomTexts(frame)
		UF:Configure_AuraHighlight(frame)
		UF:Configure_HealComm(frame)
		UF:Configure_PhaseIcon(frame)
		UF:Configure_Portrait(frame)
		UF:Configure_PowerPrediction(frame)
		UF:Configure_RaidDebuffs(frame)
		UF:Configure_RaidRoleIcons(frame)
		UF:Configure_ReadyCheckIcon(frame)
		UF:Configure_ResurrectionIcon(frame)
		UF:Configure_Threat(frame)
	end

	UF:UpdateNameSettings(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Fader(frame)
	UF:Configure_Cutaway(frame)

	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

UF.headerstoload.party = {nil, 'ELVUI_UNITPET, ELVUI_UNITTARGET'}
