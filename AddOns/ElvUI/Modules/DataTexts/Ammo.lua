local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local strjoin = strjoin
--WoW API / Variables
local GetContainerNumSlots = GetContainerNumSlots
local ToggleAllBags = ToggleAllBags
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo


local Ammos = {
	"Accurate Slugs",
	"Doomshot",
	"Exploding Shot",
	"Feathered Arrow",
	"Flash Pellet",
	"Heavy Shot",
	"Hi-Impact Mithril Slugs",
	"Ice Threaded Arrow",
	"Ice Threaded Bullet",
	"Impact Shot",
	"Jagged Arrow",
	"Light Shot",
	"Miniature Cannon Balls",
	"Mithril Gyro-Shot",
	"Precision Arrow",
	"Razor Arrow",
	"Rockshard Pellets",
	"Rough Arrow",
	"Sharp Arrow",
	"Smooth Pebble",
	"Solid Shot",
	"Thorium Headed Arrow",
	"Thorium Shells",
	"Wicked Arrow"
}

local Quivers = {
	"Ancient Sinew Wrapped Lamina",
  "Bandolier of the Night Watch",
  "Gnoll Skin Bandolier",
  "Harpy Hide Quiver",
  "Heavy Leather Ammo Pouch",
  "Heavy Quiver",
  "Hunting Ammo Sack",
  "Hunting Quiver",
  "Light Quiver",
  "Light Leather Quiver",
  "Medium Shot Pouch",
  "Medium Quiver",
  "Quickdraw Quiver",
  "Quiver of the Night Watch",
  "Ribbly's Quiver",
  "Ribbly's Bandolier",
  "Small Ammo Pouch",
  "Small Leather Ammo Pouch",
  "Small Quiver",
  "Thick Leather Ammo Pouch"
}

local statusColors = {
	"|cff0CD809",
	"|cffE8DA0F",
	"|cffFF9000",
	"|cffD80909"
}

local greenThresholdPct = .66 --Show green when above this % of max ammo
local yellowThresholdPct = .4 --Show yellow when above this % of max ammo
local orangeThresholdPct = .2 --Show orange when above this % of max ammo

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local displayString, lastPanel = ''
local maxAmmoCount = 0


-- ******************MAIN FUNCTION*********************
local function OnEvent(self)
	lastPanel = self
	local ammoCount = 0


	local tex,icount
	for i=0, 4, 1 do
		for j=1, GetContainerNumSlots(i), 1 do
			name = GetBagName(i)
			numSlots = GetContainerNumSlots(i)
			if name ~= nil then
				for amf = 1,table.getn(Quivers) do
					if (string.find(name, Quivers[amf])) then
						maxAmmoCount = numSlots * 200;
					end
				end
			end

			link = GetContainerItemLink(i, j);
			if link ~= nil then
				for amf = 1,table.getn(Ammos) do
					if (string.find(link, Ammos[amf])) then
						tex,icount = GetContainerItemInfo(i, j);
						ammoCount = ammoCount + icount;
					end
				end
			end
		end
	end

	local ammoPct = 0
	if maxAmmoCount ~= 0 then --catch div/0 errors
		ammoPct = ammoCount/maxAmmoCount;
	end

	local colorStr = statusColors[(maxAmmoCount == 0 or ammoPct >= greenThresholdPct) and 1
									or (ammoPct < greenThresholdPct and ammoPct >= yellowThresholdPct) and 2
									or (ammoPct < yellowThresholdPct and ammoPct >= orangeThresholdPct) and 3
									or 4]
	self.text:SetFormattedText("Ammo: %s%d/%d|r", colorStr, ammoCount, maxAmmoCount)
end

local function OnClick()
	ToggleAllBags()
end


local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%d/%d|r")
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Ammo', {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"}, OnEvent, nil, OnClick, nil, nil, L["Ammo"])

--[[
local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local select = select
local format, join = string.format, string.join

local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetAuctionItemSubClasses = GetAuctionItemSubClasses
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount
local GetInventorySlotInfo = GetInventorySlotInfo
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemQualityColor = GetItemQualityColor
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local INVTYPE_AMMO = INVTYPE_AMMO

local quiver = select(1, GetAuctionItemSubClasses(8))
local pouch = select(2, GetAuctionItemSubClasses(8))
local soulBag = select(2, GetAuctionItemSubClasses(3))

local iconString = "|T%s:16:16:0:0:64:64:4:55:4:55|t"
local displayString = ""

local lastPanel

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local function OnEvent(self)
	local name, count, link
for i = 0, NUM_BAG_FRAMES do
		for j = 1, GetContainerNumSlots(i) do
			item = GetContainerItemID(i, j)
			if item then
				link = GetContainerItemLink(i, j)
				name, _, quality, _, _, _, _, _, equipLoc, texture = GetItemInfo(link)
				count = GetItemCount(link)

				if equipLoc == "INVTYPE_AMMO" then
					self.text:SetFormattedText(displayString, name, count)
				end
			end
		end
	end
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext(INVTYPE_AMMO, {"PLAYER_ENTERING_WORLD", "BAG_UPDATE", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, ColorizeSettingName(L["Ammo/Shard Counter"]))
]]
