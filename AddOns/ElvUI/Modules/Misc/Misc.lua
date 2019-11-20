local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local Bags = E:GetModule('Bags')

--Lua functions
local _G = _G
local select = select
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local AcceptGroup = AcceptGroup
local BNGetGameAccountInfoByGUID = BNGetGameAccountInfoByGUID
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetInstanceInfo = GetInstanceInfo
local GetItemInfo = GetItemInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetNumQuestChoices = GetNumQuestChoices
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local InCombatLockdown = InCombatLockdown
local IsGuildMember = IsGuildMember
local IsCharacterFriend = C_FriendList.IsFriend
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsShiftKeyDown = IsShiftKeyDown
local LeaveParty = LeaveParty
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RepairAllItems = RepairAllItems
local SendChatMessage = SendChatMessage
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitInRaid = UnitInRaid
local UnitName = UnitName

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY = LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY
local LE_GAME_ERR_NOT_ENOUGH_MONEY = LE_GAME_ERR_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local UIErrorsFrame = UIErrorsFrame

local INTERRUPT_MSG = INTERRUPTED.." %s's [%s]!"

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end
	if event == 'PLAYER_REGEN_DISABLED' then
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED()
	if E.db.general.interruptAnnounce == 'NONE' then return end
	local inGroup, inRaid = IsInGroup(), IsInRaid()
	if not inGroup then return end -- not in group, exit.

	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	if not (strmatch(event, "_INTERRUPT") and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet'))) then return end -- No announce-able interrupt from player or pet, exit.

	local interruptAnnounce, msg = E.db.general.interruptAnnounce, format(INTERRUPT_MSG, destName or UNKNOWN, spellName or UNKNOWN)
	if interruptAnnounce == "PARTY" then
		SendChatMessage(msg, "PARTY")
	elseif interruptAnnounce == "RAID" then
		SendChatMessage(msg, (inRaid and "RAID" or "PARTY"))
	elseif interruptAnnounce == "RAID_ONLY" and inRaid then
		SendChatMessage(msg, "RAID")
	elseif interruptAnnounce == "SAY" and IsInInstance() then
		SendChatMessage(msg, "SAY")
	elseif interruptAnnounce == "YELL" and IsInInstance() then
		SendChatMessage(msg, "YELL")
	elseif interruptAnnounce == "EMOTE" then
		SendChatMessage(msg, "EMOTE")
	end
end

do -- Auto Repair Functions
	local STATUS, COST, POSS
	function M:AttemptAutoRepair()
		STATUS, COST, POSS = "", GetRepairAllCost()

		if POSS and COST > 0 then
			RepairAllItems()

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			E:Delay(0.5, M.AutoRepairOutput)
		end
	end

	function M:AutoRepairOutput()
		if STATUS == "PLAYER_REPAIR_FAILED" then
			E:Print(L["You don't have enough money to repair."])
		else
			E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
		end
	end

	function M:UI_ERROR_MESSAGE(_, messageType)
		if messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
			STATUS = "PLAYER_REPAIR_FAILED"
		end
	end
end

function M:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then E:Delay(0.5, Bags.VendorGrays, Bags) end

	if E.db.general.autoRepair == 'NONE' or IsShiftKeyDown() or not CanMerchantRepair() then return end

	--Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")

	--Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	M:AttemptAutoRepair()
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' then
		RaidNotice_AddMessage(_G.RaidBossEmoteFrame, msg, _G.ChatTypeInfo.RAID_BOSS_EMOTE);
	end
end

function M:AutoInvite(event, _, _, _, _, _, _, inviterGUID)
	if not E.db.general.autoAcceptInvite then return end

	if event == "PARTY_INVITE_REQUEST" then
		if BNGetGameAccountInfoByGUID(inviterGUID) or IsCharacterFriend(inviterGUID) or IsGuildMember(inviterGUID) then
			AcceptGroup()
			StaticPopupDialogs["PARTY_INVITE"].inviteAccepted = 1
			StaticPopup_Hide("PARTY_INVITE")
		end
	end
end

function M:ForceCVars()
	if not GetCVarBool('lockActionBars') and E.private.actionbar.enable then
		SetCVar('lockActionBars', 1)
	end
end

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
	self:ToggleChatBubbleScript()
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_InspectUI" then
		M:SetupInspectPageInfo()
	end
end

do
	local _
	local bestValue, totalValue, bestItem, itemSellPrice
	local questLink, amount, numQuests

	function M:QUEST_COMPLETE()
		if not E.db.general.questRewardMostValueIcon then return end

		bestValue = 0
		numQuests = GetNumQuestChoices()

		if numQuests <= 0 then
			return -- no choices, quick exit
		end

		if not self.QuestRewardGoldIconFrame then
			local frame = CreateFrame("Frame", nil, _G.QuestInfoRewardsFrameQuestInfoItem1)
			frame:SetFrameStrata("HIGH")
			frame:Size(20)
			frame.Icon = frame:CreateTexture(nil, "OVERLAY")
			frame.Icon:SetAllPoints(frame)
			frame.Icon:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon")
			frame:Hide()
			self.QuestRewardGoldIconFrame = frame
		end

		self.QuestRewardGoldIconFrame:Hide()

		for i = 1, numQuests do
			questLink = GetQuestItemLink('choice', i)
			_,_, amount = GetQuestItemInfo('choice', i)
			itemSellPrice = questLink and select(11, GetItemInfo(questLink))

			totalValue = (itemSellPrice and itemSellPrice * amount) or 0
			if totalValue > bestValue then
				bestValue = totalValue
				bestItem = i
			end
		end

		if bestItem then
			local btn = _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]
			if btn.type == 'choice' then
				self.QuestRewardGoldIconFrame:ClearAllPoints()
				self.QuestRewardGoldIconFrame:Point("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
				self.QuestRewardGoldIconFrame:Show()
			end
		end
	end
end

function M:Initialize()
	self.Initialized = true
	self:LoadRaidMarker()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:LoadLoot()
	--self:ToggleItemLevelInfo(true)
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE', 'PVPMessageEnhancement')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL', 'PVPMessageEnhancement')
	self:RegisterEvent('PARTY_INVITE_REQUEST', 'AutoInvite')
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'AutoInvite')
	self:RegisterEvent('CVAR_UPDATE', 'ForceCVars')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent("QUEST_COMPLETE")
--[[
	if IsAddOnLoaded("Blizzard_InspectUI") then
		M:SetupInspectPageInfo()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
]]
end

E:RegisterModule(M:GetName())
