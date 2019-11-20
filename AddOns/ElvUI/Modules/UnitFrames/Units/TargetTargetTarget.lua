local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
local _G = _G
local tinsert = tinsert

function UF:Construct_TargetTargetTargetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.InfoPanel = self:Construct_InfoPanel(frame)
	frame.Name = self:Construct_NameText(frame)
	frame.Buffs = self:Construct_Buffs(frame)
	frame.Debuffs = self:Construct_Debuffs(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.customTexts = {}
	frame.Cutaway = self:Construct_Cutaway(frame)
	frame.Fader = self:Construct_Fader()
	frame.MouseGlow = self:Construct_MouseGlow(frame)
	frame.PowerPrediction = self:Construct_PowerPrediction(frame)
	frame.RaidTargetIndicator = self:Construct_RaidIcon(frame)
	frame.TargetGlow = self:Construct_TargetGlow(frame)
	frame.ThreatIndicator = self:Construct_Threat(frame)

	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 160) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["TargetTargetTarget Frame"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,targettargettarget,generalGroup')

	frame.unitframeType = "targettargettarget"
end

function UF:Update_TargetTargetTargetFrame(frame, db)
	frame.db = db

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	frame.colors = ElvUF.colors
	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	UF:Configure_HealthBar(frame)
	UF:Configure_Power(frame)
	UF:Configure_InfoPanel(frame)
	UF:UpdateNameSettings(frame)
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')

	UF:Configure_CustomTexts(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_Fader(frame)
	UF:Configure_Portrait(frame)
	UF:Configure_PowerPrediction(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Threat(frame)

	E:SetMoverSnapOffset(frame:GetName()..'Mover', -(12 + self.db.units.player.castbar.height))
	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

tinsert(UF.unitstoload, 'targettargettarget')
