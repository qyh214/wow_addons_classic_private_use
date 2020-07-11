local AutoLoot = CreateFrame("Frame")
SpeedyAutoLootDB = SpeedyAutoLootDB or {}
SpeedyAutoLootDB.global = SpeedyAutoLootDB.global or {}

local SetCVar = SetCVar or C_CVar.SetCVar
local GetCVarBool = GetCVarBool or C_CVar.GetCVarBool
local BACKPACK_CONTAINER, LOOT_SLOT_ITEM, NUM_BAG_SLOTS = BACKPACK_CONTAINER, LOOT_SLOT_ITEM, NUM_BAG_SLOTS
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetCursorPosition = GetCursorPosition
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetLootSlotType = GetLootSlotType
local GetNumLootItems = GetNumLootItems
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot
local PlaySound = PlaySound
local band = bit.band
local select = select
local tContains = tContains

function AutoLoot:ProcessLoot(item, q)
	local total, free, bagFamily = 0
	local itemFamily = GetItemFamily(item)
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		free, bagFamily = GetContainerNumFreeSlots(i)
		if (not bagFamily or bagFamily == 0) or (itemFamily and band(itemFamily, bagFamily) > 0) then
			total = total + free
		end
	end
	if total > 0 then
		return true
	end

	local have = (GetItemCount(item) or 0)
	if have > 0 then
		local itemStackCount = (select(8,GetItemInfo(item)) or 0)
		if itemStackCount > 1 then
			while have > itemStackCount do
				have = have - itemStackCount
			end
			local remain = itemStackCount - have
			if remain >= q then
				return true
			end
		end
	end
	return false
end

function AutoLoot:ShowLootFrame(show)
	if self.ElvUI then
		if show then
			ElvLootFrame:SetParent(ElvLootFrameHolder)
			ElvLootFrame:SetFrameStrata("HIGH")
			self:LootUnderMouse(ElvLootFrame, ElvLootFrameHolder, 20)
			self.isHidden = false
		else
			ElvLootFrame:SetParent(self)
			self.isHidden = true
		end
	elseif LootFrame:IsEventRegistered("LOOT_SLOT_CLEARED") then
		LootFrame.page = 1;
		if show then
			LootFrame_Show(LootFrame)
			self.isHidden = false
		else
			self.isHidden = true
		end
	end
end

function AutoLoot:LootItems(numItems)
	local lootThreshold = (self.isClassic and select(2,GetLootMethod()) == 0) and GetLootThreshold() or 10
	for i = numItems, 1, -1 do
		local itemLink = GetLootSlotLink(i)
		local slotType = GetLootSlotType(i)
		local quantity, _, quality, locked, isQuestItem = select(3, GetLootSlotInfo(i))
		if locked or (quality and quality >= lootThreshold) then
			self.isItemLocked = true
		else
			if slotType ~= LOOT_SLOT_ITEM or (not self.isClassic and isQuestItem) or self:ProcessLoot(itemLink, quantity) then
				numItems = numItems - 1
				LootSlot(i)
			end
		end
	end
	if numItems > 0 then
		self:ShowLootFrame(true)
		self:PlayInventoryFullSound()
	end

	if IsFishingLoot() and not SpeedyAutoLootDB.global.fishingSoundDisabled then
		PlaySound(SOUNDKIT.FISHING_REEL_IN, self.audioChannel)
	end
end

function AutoLoot:OnEvent(e, ...)
    if e == "PLAYER_LOGIN" then
		if SpeedyAutoLootDB.global.alwaysEnableAutoLoot then
			SetCVar("autoLootDefault",1)
		end

		C_Timer.After(1, function()
			self.ElvUI = (ElvUI and ElvUI[1].private.general.loot)
			self:ShowLootFrame(false)
		end)
	elseif (e == "LOOT_READY" or e == "LOOT_OPENED") and not self.isLooting then
		local aL = ...

		local numItems = GetNumLootItems()
		if numItems == 0 then
			return
		end

		self.isLooting = true
		if aL or (aL == nil and GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")) then
			self:LootItems(numItems)
		else
			self:ShowLootFrame(true)
		end
	elseif e == "LOOT_CLOSED" then
		self.isLooting = false
		self.isHidden = false
		self.isItemLocked = false
		self:ShowLootFrame(false)
	elseif (e == "UI_ERROR_MESSAGE" and tContains(({ERR_INV_FULL,ERR_ITEM_MAX_COUNT}), select(2,...))) or e == "LOOT_BIND_CONFIRM" then
		if self.isLooting and self.isHidden then
			self:ShowLootFrame(true)
			if e == "UI_ERROR_MESSAGE" then
				self:PlayInventoryFullSound()
			end
		end
	end
end

function AutoLoot:PlayInventoryFullSound()
	if SpeedyAutoLootDB.global.enableSound and not self.isItemLocked then
		PlaySound(SpeedyAutoLootDB.global.InventoryFullSound, self.audioChannel)
	end
end

function AutoLoot:LootUnderMouse(self, parent, yoffset)
	if GetCVarBool("lootUnderMouse") then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + (yoffset or 20))
		self:GetCenter()
		self:Raise()
	else
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", parent, "TOPLEFT")
	end
end

function AutoLoot:Help(msg)
	local fName = "|cffEEE4AESpeedy AutoLoot:|r "
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if not cmd or cmd == "" or cmd == "help" then
		print(fName.."   |cff58C6FA/sal    /speedyautoloot    /speedyloot|r")
		print("  |cff58C6FA/sal auto              -|r  |cffEEE4AEEnable Auto Looting for all characters|r")
		print("  |cff58C6FA/sal fish              -|r  |cffEEE4AEDisable Fishing reel in sound|r")
		print("  |cff58C6FA/sal sound            -|r  |cffEEE4AEPlay a Sound when Inventory is full while looting|r")
		if self.isClassic then
			print("  |cff58C6FA/sal set (SoundID) -|r  |cffEEE4AESet a Sound (SoundID), Default:  /sal set 139|r")
		else
			print("  |cff58C6FA/sal set (SoundID) -|r  |cffEEE4AESet a Sound (SoundID), Default:  /sal set 44321|r")
		end
	elseif cmd == "fish" then
		if not SpeedyAutoLootDB.global.fishingSoundDisabled then
			SpeedyAutoLootDB.global.fishingSoundDisabled = true
			print(fName.."|cffB6B6B6Fishing reel in sound disabled.")
		else
			SpeedyAutoLootDB.global.fishingSoundDisabled = false
			print(fName.."|cff37DB33Fishing reel in sound enabled.")
		end
	elseif cmd == "auto" then
		if SpeedyAutoLootDB.global.alwaysEnableAutoLoot then
			SpeedyAutoLootDB.global.alwaysEnableAutoLoot = false
			print(fName.."|cffB6B6B6Auto Loot for all Characters disabled.")
			SetCVar("autoLootDefault",0)
		else
			SpeedyAutoLootDB.global.alwaysEnableAutoLoot = true
			print(fName.."|cff37DB33Auto Loot for all Characters enabled.")
			SetCVar("autoLootDefault",1)
		end
	elseif cmd == "sound" then
		if SpeedyAutoLootDB.global.enableSound then
			SpeedyAutoLootDB.global.enableSound = false
			print(fName.."|cffB6B6B6Don't play a sound when inventory is full.")
		else
			if not SpeedyAutoLootDB.global.InventoryFullSound then
				if self.isClassic then
					SpeedyAutoLootDB.global.InventoryFullSound = 139
				else
					SpeedyAutoLootDB.global.InventoryFullSound = 44321
				end
			end
			SpeedyAutoLootDB.global.enableSound = true
			print(fName.."|cff37DB33Play a sound when inventory is full.")
		end
	elseif cmd == "set" and args ~= "" then
		local SoundID = tonumber(args:match("%d+"))
		if SoundID then
			SpeedyAutoLootDB.global.InventoryFullSound = tonumber(args:match("%d+"))
			PlaySound(SoundID, self.audioChannel)
			print(fName.."Set Sound|r |cff37DB33"..SoundID.."|r")
		end
	end
end

function AutoLoot:OnLoad()
	self:SetToplevel(true)
	self:Hide()
	self:SetScript("OnEvent", function(_,...)
		self:OnEvent(...)
	end)

	for _,e in next, ({	"PLAYER_LOGIN", "LOOT_READY", "LOOT_OPENED", "LOOT_CLOSED", "UI_ERROR_MESSAGE" }) do
		self:RegisterEvent(e)
	end

	self.audioChannel = "master"
	self.isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

	if self.isClassic then
        self:RegisterEvent("LOOT_BIND_CONFIRM")
        self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	end

	LootFrame:UnregisterEvent('LOOT_OPENED')
end

SLASH_SPEEDYAUTOLOOT1, SLASH_SPEEDYAUTOLOOT2, SLASH_SPEEDYAUTOLOOT3  = "/sal", "/speedyloot", "/speedyautoloot"
SlashCmdList["SPEEDYAUTOLOOT"] = function(...)
    AutoLoot:Help(...)
end

AutoLoot:OnLoad()