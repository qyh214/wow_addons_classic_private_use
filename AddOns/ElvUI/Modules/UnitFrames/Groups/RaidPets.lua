local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

function UF:Construct_RaidpetFrames()
	self:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	self:SetScript('OnLeave', _G.UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Name = UF:Construct_NameText(self)

	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)

	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.customTexts = {}
	self.Cutaway = UF:Construct_Cutaway(self)
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
	self.Fader = UF:Construct_Fader()
	self.HealthPrediction = UF:Construct_HealComm(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.Portrait2D = UF:Construct_Portrait(self, 'texture')
	self.Portrait3D = UF:Construct_Portrait(self, 'model')
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.ThreatIndicator = UF:Construct_Threat(self)

	self.unitframeType = "raidpet"

	return self
end

function UF:Update_RaidpetHeader(header, db)
	header.db = db

	local headerHolder = header:GetParent()
	headerHolder.db = db

	if not headerHolder.positioned then
		headerHolder:ClearAllPoints()
		headerHolder:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 574)
		E:CreateMover(headerHolder, headerHolder:GetName()..'Mover', L["Raid Pet Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,raidpet,generalGroup')

		headerHolder.positioned = true;
	end

	if not header.forceShow and db.enable then
		RegisterStateDriver(headerHolder, "visibility", headerHolder.db.visibility)
	end
end

function UF:Update_RaidpetFrames(frame, db)
	frame.db = db

	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		if(self.thinBorders) then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end

		frame.SHADOW_SPACING = 3
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.height
		frame.USE_POWERBAR = false
		frame.POWERBAR_DETACHED = false
		frame.USE_INSET_POWERBAR = false
		frame.USE_MINI_POWERBAR = false
		frame.USE_POWERBAR_OFFSET = false
		frame.POWERBAR_OFFSET = 0
		frame.POWERBAR_HEIGHT = 0
		frame.POWERBAR_WIDTH = 0
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CLASSBAR_YOFFSET = 0
		frame.BOTTOM_OFFSET = 0
	end

	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

	UF:Configure_HealthBar(frame)
	UF:UpdateNameSettings(frame)

	UF:EnableDisable_Auras(frame)
	UF:Configure_AllAuras(frame)

	UF:Configure_AuraWatch(frame, true)
	UF:Configure_CustomTexts(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_DebuffHighlight(frame)
	UF:Configure_Fader(frame)
	UF:Configure_HealComm(frame)
	UF:Configure_Portrait(frame)
	UF:Configure_RaidDebuffs(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Threat(frame)

	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

--Added an additional argument at the end, specifying the header Template we want to use
UF.headerstoload.raidpet = {nil, nil, 'SecureGroupPetHeaderTemplate'}
