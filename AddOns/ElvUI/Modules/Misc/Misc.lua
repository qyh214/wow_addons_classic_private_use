local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local Bags = E:GetModule('Bags')

--Lua functions
local _G = _G
local format = format
--WoW API / Variables
local AcceptGroup = AcceptGroup
local BNGetGameAccountInfoByGUID = BNGetGameAccountInfoByGUID
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
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
local IsInGuild = IsInGuild

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
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == E.myguid or sourceGUID == UnitGUID('pet'))) then return end -- No announce-able interrupt from player or pet, exit.

	local interruptAnnounce, msg = E.db.general.interruptAnnounce, format(INTERRUPT_MSG, destName or UNKNOWN, spellName or UNKNOWN)
	if interruptAnnounce == "PARTY" then
		SendChatMessage(msg, "PARTY")
	elseif interruptAnnounce == "RAID" then
		SendChatMessage(msg, (inRaid and "RAID" or "PARTY"))
	elseif interruptAnnounce == "RAID_ONLY" and inRaid then
		SendChatMessage(msg, "RAID")
	elseif interruptAnnounce == "SAY" then
		SendChatMessage(msg, "SAY")
	elseif interruptAnnounce == "EMOTE" then
		SendChatMessage(msg, "EMOTE")
	end
end

do -- Auto Repair Functions
	local STATUS, TYPE, COST, POSS
	function M:AttemptAutoRepair(playerOverride)
		STATUS, TYPE, COST, POSS = "", E.db.general.autoRepair, GetRepairAllCost()

		if POSS and COST > 0 then
			--This check evaluates to true even if the guild bank has 0 gold, so we add an override
			if TYPE == 'GUILD' and (playerOverride or (IsInGuild() and (not CanGuildBankRepair() or COST > GetGuildBankWithdrawMoney()))) then
				TYPE = 'PLAYER'
			end

			RepairAllItems(TYPE == 'GUILD')

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			E:Delay(0.5, M.AutoRepairOutput)
		end
	end

	function M:AutoRepairOutput()
		if TYPE == 'GUILD' then
			if STATUS == "GUILD_REPAIR_FAILED" then
				M:AttemptAutoRepair(true) --Try using player money instead
			else
				E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		elseif TYPE == "PLAYER" then
			if STATUS == "PLAYER_REPAIR_FAILED" then
				E:Print(L["You don't have enough money to repair."])
			else
				E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		end
	end

	function M:UI_ERROR_MESSAGE(_, messageType)
		if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
			STATUS = "GUILD_REPAIR_FAILED"
		elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
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
--[[
	if IsAddOnLoaded("Blizzard_InspectUI") then
		M:SetupInspectPageInfo()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
]]
end

E:RegisterModule(M:GetName())
