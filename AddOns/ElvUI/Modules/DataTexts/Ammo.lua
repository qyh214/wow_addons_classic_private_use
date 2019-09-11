local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local _G = _G
local select = select
local format, join = string.format, string.join

local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount
local GetInventoryItemID = GetInventoryItemID
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemQualityColor = GetItemQualityColor
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local INVTYPE_AMMO = INVTYPE_AMMO

local iconString = "|T%s:16:16:0:0:64:64:4:55:4:55|t"
local displayString = ""

local lastPanel

local function OnEvent(self)
	local name, count, itemID
	if E.myclass == "WARLOCK" then
		name, count = GetItemInfo(6265), GetItemCount(6265)
		self.text:SetFormattedText(displayString, name or 'Soul Shard', count or 0) -- Does not need localized. It gets updated.
	else
		itemID, count = GetInventoryItemID("player", INVSLOT_AMMO), GetInventoryItemCount("player", INVSLOT_AMMO)
		if itemID and (count > 0) then
			name = GetItemInfo(itemID)
			self.text:SetFormattedText(displayString, name or 'Arrow', count) -- Does not need localized. It gets updated.
		else
			self.text:SetFormattedText(displayString, INVTYPE_AMMO, 0)
		end
	end

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local r, g, b
	local item, link, count
	local _, name, quality, itemSubType, equipLoc, texture, itemClassID, itemSubClassID
	local free, total, used

	if E.myclass == 'HUNTER' then
		DT.tooltip:AddLine(INVTYPE_AMMO)

		for i = 0, NUM_BAG_FRAMES do
			for j = 1, GetContainerNumSlots(i) do
				item = GetContainerItemID(i, j)
				if item then
					link = GetContainerItemLink(i, j)
					name, _, quality, _, _, _, _, _, equipLoc, texture = GetItemInfo(link)
					count = GetItemCount(link)

					if equipLoc == "INVTYPE_AMMO" then
						r, g, b = GetItemQualityColor(quality)
						DT.tooltip:AddDoubleLine(join("", format(iconString, texture), " ", name), count, r, g, b)
					end
				end
			end
		end

		DT.tooltip:AddLine(" ")
	end

	for i = 1, NUM_BAG_SLOTS do
		link = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
		if link then
			name, _, quality, _, _, _, itemSubType, _, _, texture, itemClassID, itemSubClassID = GetItemInfo(link)
			if itemSubClassID == LE_ITEM_CLASS_QUIVER or itemClassID == LE_ITEM_CLASS_CONTAINER and itemSubClassID == 1 then
				r, g, b = GetItemQualityColor(quality)

				free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
				used = total - free

				DT.tooltip:AddLine(itemSubType)
				DT.tooltip:AddDoubleLine(join("", format(iconString, texture), "  ", name), format("%d / %d", used, total), r, g, b)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, btn)
	if btn == "LeftButton" then
		if not E.private.bags.enable then
			for i = 1, NUM_BAG_SLOTS do
				local link = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
				if link then
					local itemClassID, itemSubClassID = select(11, GetItemInfo(link))
					if itemSubClassID == LE_ITEM_CLASS_QUIVER or itemClassID == LE_ITEM_CLASS_CONTAINER and itemSubClassID == 1 then
						_G.ToggleBag(i)
					end
				end
			end
		else
			ToggleAllBags()
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext(INVTYPE_AMMO, {"PLAYER_ENTERING_WORLD", "BAG_UPDATE", "UNIT_INVENTORY_CHANGED", "GET_ITEM_INFO_RECEIVED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Ammo/Shard Counter"])
