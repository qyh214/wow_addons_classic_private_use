local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
local _G = _G
local max = math.max
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterAttributeDriver = RegisterAttributeDriver

function UF:Construct_TankFrames()
	self:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	self:SetScript('OnLeave', _G.UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)

	self.Health = UF:Construct_HealthBar(self, true)
	self.Name = UF:Construct_NameText(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	if not self.isChild then
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self)

		self.unitframeType = "tank"
	else
		self.unitframeType = "tanktarget"
	end

	UF:Update_StatusBars()
	UF:Update_FontStrings()

	self.originalParent = self:GetParent()

	return self
end

function UF:Update_TankHeader(header, db)
	header:Hide()
	header.db = db

	UF:ClearChildPoints(header:GetChildren())

	RegisterAttributeDriver(header, 'state-visibility', '[@raid1,exists] show;hide')

	header:SetAttribute('point', 'BOTTOM')
	header:SetAttribute('columnAnchorPoint', 'LEFT')
	header:SetAttribute("yOffset", db.verticalSpacing)

	if not header.positioned then
		local width, height = header:GetSize()
		header.dirtyWidth, header.dirtyHeight = width, max(height, 2*db.height + db.verticalSpacing)
		header:ClearAllPoints()
		header:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -186)
		E:CreateMover(header, header:GetName()..'Mover', L["MT Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,tank,generalGroup')
		header.mover.positionOverride = "TOPLEFT"
		header:SetAttribute('minHeight', header.dirtyHeight)
		header:SetAttribute('minWidth', header.dirtyWidth)
		header.positioned = true;
	end
end

function UF:Update_TankFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?

		if(self.thinBorders) then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end
		frame.SHADOW_SPACING = 3

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

		frame.USE_PORTRAIT = false
		frame.USE_PORTRAIT_OVERLAY = false
		frame.PORTRAIT_WIDTH = 0

		frame.CLASSBAR_YOFFSET = 0
		frame.BOTTOM_OFFSET = 0

		frame.VARIABLES_SET = true
	end

	if frame.isChild and frame.originalParent then
		local childDB = db.targetsGroup
		frame.db = db.targetsGroup
		if not frame.originalParent.childList then
			frame.originalParent.childList = {}
		end
		frame.originalParent.childList[frame] = true;

		if not InCombatLockdown() then
			if childDB.enable then
				frame:SetParent(frame.originalParent)
				frame:Size(childDB.width, childDB.height)
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset)
			else
				frame:SetParent(E.HiddenFrame)
			end
		end
	elseif not InCombatLockdown() then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	end

	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--Fader
	UF:Configure_Fader(frame)

	--Cutaway
	UF:Configure_Cutaway(frame)

	UF:Configure_RaidIcon(frame)

	if not frame.isChild then
		--Auras
		UF:EnableDisable_Auras(frame)
		UF:Configure_Auras(frame, "Buffs")
		UF:Configure_Auras(frame, "Debuffs")

		--RaidDebuffs
		UF:Configure_RaidDebuffs(frame)

		--Debuff Highlight
		UF:Configure_DebuffHighlight(frame)

		--Buff Indicator
		UF:Configure_AuraWatch(frame)
	end

	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

UF.headerstoload.tank = {'MAINTANK', 'ELVUI_UNITTARGET'}
