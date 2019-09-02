local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local strjoin = strjoin
local format = format
--WoW API / Variables
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local ToggleAllBags = ToggleAllBags
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local CURRENCY = CURRENCY
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS

local BAG_TYPES = {
	[0x0001]  = 'Quiver',
	[0x0002]  = 'Ammo Pouch',
	[0x0004]  = 'Soul Bag',
	[0x0008]  = 'Leatherworking Bag',
	[0x0010]  = 'Inscription Bag',
	[0x0020]  = 'Herb Bag',
	[0x0040]  = 'Enchanting Bag',
	[0x0080]  = 'Engineering Bag',
	[0x0100]  = 'Keyring',
	[0x0200]  = 'Gem Bag',
	[0x0400]  = 'Mining Bag',
	[0x0800]  = 'Unused (800)',
	[0x1000]  = 'Vanity Pets',
	[0x2000]  = 'Unused (2000)',
	[0x4000]  = 'Unused (4000)',
	[0x8000]  = 'Tackle Box',
	[0x10000] = 'Cooking Bag'
 }

local displayString, lastPanel = ''

local function OnEvent(self)
	lastPanel = self
	local free, total = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		local bagFreeSlots, bagType = GetContainerNumFreeSlots(i)
		if not bagType or bagType == 0 then
			free, total = free + bagFreeSlots, total + GetContainerNumSlots(i)
		end
	end
	self.text:SetFormattedText(displayString, L["Bags"]..': ', total - free, total)
end

local function OnClick()
	ToggleAllBags()
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 0, NUM_BAG_SLOTS do
		local bagFreeSlots, bagType = GetContainerNumFreeSlots(i)
		local bagTypeName = BAG_TYPES[bagType]

		if bagTypeName then
			local bagSlots = GetContainerNumSlots(i)
			local bagName = GetBagName(i)
			DT.tooltip:AddDoubleLine(bagName, format('%d/%d', bagSlots - bagFreeSlots, GetContainerNumSlots(i)))
		end
		
	 end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%d/%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Bags', {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"])
