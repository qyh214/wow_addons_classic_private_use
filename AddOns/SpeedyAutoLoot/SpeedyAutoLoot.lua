local AutoLoot = CreateFrame('Frame')

SpeedyAutoLootDB = SpeedyAutoLootDB or {}
SpeedyAutoLootDB.global = SpeedyAutoLootDB.global or {}

local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local LOOT_SLOT_CURRENCY = LOOT_SLOT_CURRENCY
local LOOT_SLOT_ITEM = LOOT_SLOT_ITEM
local LOOT_SLOT_MONEY = LOOT_SLOT_MONEY
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetCVarBool = GetCVarBool
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetLootSlotType = GetLootSlotType
local GetNumLootItems = GetNumLootItems
local GetCursorPosition = GetCursorPosition
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot
local PlaySound = PlaySound
local SetCVar = SetCVar
local find = string.find
local select = select
local tContains = tContains
local errorList = { ERR_INV_FULL, ERR_ITEM_MAX_COUNT }
local fishingChannel = 'Master'

function AutoLoot:PlayFishingSound()
	if IsFishingLoot() then
		return (fishingChannel and PlaySound(SOUNDKIT.FISHING_REEL_IN, fishingChannel)) or PlaySound(SOUNDKIT.FISHING_REEL_IN)
	end
end

function AutoLoot:PlayInventoryFullSound()
	if SpeedyAutoLootDB.global.enableSound and not self.isItemLocked then
		PlaySound(SpeedyAutoLootDB.global.InventoryFullSound, 'Master')
	end
end

function AutoLoot:LootUnderMouse(self, parent)
	if(GetCVar('lootUnderMouse') == '1') then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x - 40, y + 20)
		self:GetCenter()
		self:Raise()
	else
		self:ClearAllPoints()
		self:SetPoint('TOPLEFT', parent, 'TOPLEFT')
	end
end

function AutoLoot:CalculateFreeSlots()
	local numTotalFree, numFreeSlots, bagFamily = 0
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		numFreeSlots, bagFamily = GetContainerNumFreeSlots(i)
		if bagFamily == 0 then
			numTotalFree = numTotalFree + numFreeSlots
		end
	end
	return numTotalFree
end

function AutoLoot:ProcessLoot(itemLink, quantity, slotType)
	if slotType == LOOT_SLOT_MONEY then
		return true
	elseif slotType == LOOT_SLOT_CURRENCY then
		return true
	elseif slotType == LOOT_SLOT_ITEM then
		if self:CalculateFreeSlots() > 0 then
			return true
		end
		local have = (GetItemCount(itemLink) or 0)
		if have > 0 then
			local itemStackCount = (select(8,GetItemInfo(itemLink)) or 0)
			if itemStackCount > 1 then
				while have > itemStackCount do
					have = have - itemStackCount
				end
				local remain = itemStackCount - have
				if remain >= quantity then
					return true
				end
			end
		end
	end
end

function AutoLoot:ShowLootFrame(show)
	if self.XLoot then
		if show then
			self:LootUnderMouse(XLootFrame, UIParent)
			XLootFrame:SetParent(UIParent)
			XLootFrame:SetFrameStrata('DIALOG')
			self.isHidden = false
		else
			XLootFrame:SetParent(self)
			self.isHidden = true
		end
	elseif self.ElvUI then
		if show then
			self:LootUnderMouse(ElvLootFrame, ElvLootFrameHolder)
			ElvLootFrame:SetParent(ElvLootFrameHolder)
			ElvLootFrame:SetFrameStrata('HIGH')
			self.isHidden = false
		else
			ElvLootFrame:SetParent(self)
			self.isHidden = true
		end
	elseif LootFrame:IsEventRegistered('LOOT_SLOT_CLEARED') then
		LootFrame.page = 1;
		if show then
			self:LootUnderMouse(LootFrame, UIParent)
			LootFrame_Show(LootFrame)
			self.isHidden = false
		else
			self.isHidden = true
		end
	end
	self:PlayFishingSound()
end

function AutoLoot:LootItems()
	local numItems = GetNumLootItems() or 0
	if numItems > 0 then
		for i = numItems, 1, -1 do
			local itemLink = GetLootSlotLink(i)
			local slotType = GetLootSlotType(i)
			local quantity, _, _, locked, isQuestItem = select(3, GetLootSlotInfo(i))
			if locked then
				self.isItemLocked = locked
			elseif isQuestItem or self:ProcessLoot(itemLink, quantity, slotType) then
				numItems = numItems - 1
				LootSlot(i)
			end
		end
		if numItems > 0 then
			self:ShowLootFrame(true)
			self:PlayInventoryFullSound()
		end
	end
end

function AutoLoot:OnEvent(e, ...)
	if e == 'PLAYER_LOGIN' then
		if XLootFrame then
			self.XLoot = true
		elseif ElvUI and ElvUI[1].private.general.loot then
			self.ElvUI = true
		end

		if SpeedyAutoLootDB.global.alwaysEnableAutoLoot then
			SetCVar('autoLootDefault',1)
		end
		LootFrame:UnregisterEvent('LOOT_OPENED')
		self:ShowLootFrame(false)
	elseif (e == 'LOOT_READY' or e == 'LOOT_OPENED') and not self.isLooting then
		self.isLooting = true

		local autoLoot = ...
		if autoLoot or GetCVarBool('autoLootDefault') ~= IsModifiedClick('AUTOLOOTTOGGLE') then
			self:LootItems()
		else
			self:ShowLootFrame(true)
		end
	elseif e == 'LOOT_CLOSED' then
		self.isLooting = false
		self.isHidden  = false
		self.isItemLocked = nil
		self:ShowLootFrame(false)
	elseif e == 'UI_ERROR_MESSAGE' and tContains(errorList, select(2,...)) then
		if self.isLooting and self.isHidden then
			self:ShowLootFrame(true)
			self:PlayInventoryFullSound()
		end
	end
end

SLASH_SPEEDYAUTOLOOT1, SLASH_SPEEDYAUTOLOOT2, SLASH_SPEEDYAUTOLOOT3  = '/sal', '/speedyloot', '/speedyautoloot'
function SlashCmdList.SPEEDYAUTOLOOT(msg)
	local _, _, cmd, args = find(msg, '%s?(%w+)%s?(.*)')
	if not cmd or cmd == '' or cmd == 'help' then
		print('|cffEEE4AESpeedy AutoLoot:|r |cffEF6D6D/sal /speedyautoloot /speedyloot|r')
		print('  |cffEF6D6D/sal auto              -|r  |cffFAD1D1Enable Auto Looting for new/all characters|r')
		print('  |cffEF6D6D/sal sound            -|r  |cffFAD1D1Play a Sound when Inventory is full while looting|r')
		print('  |cffEF6D6D/sal set (SoundID) -|r  |cffFAD1D1Set a Sound (SoundID), Example: /sal set 139|r')
	elseif cmd == 'auto' then
		if SpeedyAutoLootDB.global.alwaysEnableAutoLoot then
			SpeedyAutoLootDB.global.alwaysEnableAutoLoot = false
			print('|cffEEE4AESpeedy AutoLoot:|r |cffB6B6B6Auto Loot for all Characters disabled.')
		else
			SpeedyAutoLootDB.global.alwaysEnableAutoLoot = true
			print('|cffEEE4AESpeedy AutoLoot:|r |cff37DB33Auto Loot for all Characters enabled.')
		end
	elseif cmd == 'sound' then
		if SpeedyAutoLootDB.global.enableSound then
			SpeedyAutoLootDB.global.enableSound = false
			print('|cffEEE4AESpeedy AutoLoot:|r |cffB6B6B6Don\'t play a sound when inventory is full.')
		else
			if not SpeedyAutoLootDB.global.InventoryFullSound then
				SpeedyAutoLootDB.global.InventoryFullSound = 139
			end
			SpeedyAutoLootDB.global.enableSound = true
			print('|cffEEE4AESpeedy AutoLoot:|r |cff37DB33Play a sound when inventory is full.')
		end
	elseif cmd == 'set' and args ~= '' then
		local SoundID = tonumber(args:match('%d+'))
		if SoundID then
			SpeedyAutoLootDB.global.InventoryFullSound = tonumber(args:match('%d+'))
			PlaySound(SoundID, 'Master')
			print('|cffEEE4AESpeedy AutoLoot: Set Sound|r |cff37DB33'..SoundID..'|r')
		end
	end
end

function AutoLoot:OnLoad()
	self:SetToplevel(true)
	self:Hide()
	self:SetScript('OnEvent', function(_, ...)
		self:OnEvent(...)
	end)

	for _,e in next, ({	'PLAYER_LOGIN',
						'LOOT_READY',
						'LOOT_OPENED',
						'LOOT_CLOSED',
						'UI_ERROR_MESSAGE' }) do
		self:RegisterEvent(e)
	end
end
AutoLoot:OnLoad()