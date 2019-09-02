local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooterIndicator = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(24, 12)
	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	frame.MasterLooterIndicator:Size(12)

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooterIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('LeaderIndicator') then
			frame:EnableElement('LeaderIndicator')
			frame:EnableElement('AssistantIndicator')
			frame:EnableElement('MasterLooterIndicator')
		end

		raidRoleFrameAnchor:ClearAllPoints()
		if frame.db.raidRoleIcons.position == 'TOPLEFT' then
			raidRoleFrameAnchor:Point('LEFT', frame, 'TOPLEFT', 2, 0)
		else
			raidRoleFrameAnchor:Point('RIGHT', frame, 'TOPRIGHT', -2, 0)
		end
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
		frame:DisableElement('MasterLooterIndicator')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterlooter = frame.MasterLooterIndicator

	if not leader or not assistant or not masterlooter then return; end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()
	local isMasterLooter = masterlooter:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterlooter:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:Point('LEFT', anchor, 'LEFT')
			masterlooter:Point('LEFT', leader, 'RIGHT')
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:Point('RIGHT', anchor, 'RIGHT')
			masterlooter:Point('RIGHT', leader, 'LEFT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPLEFT' then
			assistant:Point('LEFT', anchor, 'LEFT')
			masterlooter:Point('LEFT', assistant, 'RIGHT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPRIGHT' then
			assistant:Point('RIGHT', anchor, 'RIGHT')
			masterlooter:Point('RIGHT', assistant, 'LEFT')
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT' then
			masterlooter:Point('LEFT', anchor, 'LEFT')
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPRIGHT' then
			masterlooter:Point('RIGHT', anchor, 'RIGHT')
		end
	end
end
