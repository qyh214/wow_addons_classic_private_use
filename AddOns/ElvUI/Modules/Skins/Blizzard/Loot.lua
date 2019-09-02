local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack, select = unpack, select
--WoW API / Variables
local UnitName = UnitName
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local IsFishingLoot = IsFishingLoot
local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetLootSlotInfo = GetLootSlotInfo
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local LOOT, ITEMS = LOOT, ITEMS
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.general.loot or E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true then return end

	local LootFrame = _G.LootFrame
	LootFrame:StripTextures()
	LootFrame:CreateBackdrop('Transparent')

	_G.LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	S:HandleNextPrevButton(_G.LootFrameUpButton)
	_G.LootFrameUpButton:Point('BOTTOMLEFT', 25, 20)
	_G.LootFrameUpButton:Size(24)

	S:HandleNextPrevButton(_G.LootFrameDownButton)
	_G.LootFrameDownButton:Point('BOTTOMLEFT', 145, 20)
	_G.LootFrameDownButton:Size(24)

	LootFrame:EnableMouseWheel(true)
	LootFrame:SetScript('OnMouseWheel', function(_, value)
		if value > 0 then
			if _G.LootFrameUpButton:IsShown() and _G.LootFrameUpButton:IsEnabled() == 1 then
				LootFrame_PageUp()
			end
		else
			if _G.LootFrameDownButton:IsShown() and _G.LootFrameDownButton:IsEnabled() == 1 then
				LootFrame_PageDown()
			end
		end
	end)

	S:HandleCloseButton(_G.LootFrameCloseButton)
	_G.LootFrameCloseButton:Point('CENTER', LootFrame, 'TOPRIGHT', -87, -26)

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:GetObjectType() == 'FontString' then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point('TOPLEFT', LootFrame.backdrop, 'TOPLEFT', 4, -4)
	LootFrame.Title:SetJustifyH('LEFT')

	LootFrame:HookScript('OnShow', function(self)
		if IsFishingLoot() then
			self.Title:SetText(L['Fishy Loot'])
		elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
			self.Title:SetText(UnitName('target'))
		else
			self.Title:SetText(LOOT)
		end
	end)

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G['LootButton'..i]
		local nameFrame = _G['LootButton'..i..'NameFrame']
		-- local questTexture = _G['LootButton'..i..'IconQuestTexture']

		S:HandleItemButton(button, true)

		button.bg = CreateFrame('Frame', nil, button)
		button.bg:SetTemplate('Default')
		button.bg:Point('TOPLEFT', 40, 0)
		button.bg:Point('BOTTOMRIGHT', 110, 0)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 1)

		-- questTexture:SetTexture(E.Media.Textures.BagQuestIcon)
		-- questTexture.SetTexture = E.noop
		-- questTexture:SetTexCoord(0, 1, 0, 1)
		-- questTexture:SetInside()

		nameFrame:Hide()
	end

	hooksecurefunc('LootFrame_UpdateButton', function(index)
		local numLootItems = LootFrame.numLootItems
		local numLootToShow = LOOTFRAME_NUMBUTTONS
		if numLootItems > LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1
		end

		local button = _G['LootButton'..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index

		if slot <= numLootItems then
			if (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow then
				local texture, _, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
				if texture then
					local questTexture = _G['LootButton'..index..'IconQuestTexture']

					questTexture:Hide()

					if questId and not isActive then
						button.backdrop:SetBackdropBorderColor(1.0, 1.0, 0.0)
						questTexture:Show()
					elseif questId or isQuestItem then
						button.backdrop:SetBackdropBorderColor(1.0, 0.3, 0.3)
					elseif quality then
						button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					else
						button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end
			end
		end
	end)
end

local function LoadRollSkin()
	if E.private.general.lootRoll then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll then return end

	local function OnShow(self)
		local cornerTexture = _G[self:GetName()..'Corner']
		local iconFrame = _G[self:GetName()..'IconFrame']
		local statusBar = _G[self:GetName()..'Timer']
		local _, _, _, quality = GetLootRollItemInfo(self.rollID)

		self:SetTemplate('Transparent')

		cornerTexture:SetTexture()

		iconFrame:SetBackdropBorderColor(GetItemQualityColor(quality))
		statusBar:SetStatusBarColor(GetItemQualityColor(quality))
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G['GroupLootFrame'..i]
		frame:StripTextures()
		frame:ClearAllPoints()

		if i == 1 then
			frame:Point('TOP', _G.AlertFrameHolder, 'BOTTOM', 0, -4)
		else
			frame:Point('TOP', _G['GroupLootFrame'..i - 1], 'BOTTOM', 0, -4)
		end

		local frameName = frame:GetName()

		local iconFrame = _G[frameName..'IconFrame']
		iconFrame:SetTemplate('Default')
		iconFrame:StyleButton()

		local icon = _G[frameName..'IconFrameIcon']
		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		local statusBar = _G[frameName..'Timer']
		statusBar:StripTextures()
		statusBar:CreateBackdrop('Default')
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)

		local decoration = _G[frameName..'Decoration']
		decoration:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon')
		decoration:Size(130)
		decoration:Point('TOPLEFT', -37, 20)

		local pass = _G[frameName..'PassButton']
		S:HandleCloseButton(pass, frame)

		_G['GroupLootFrame'..i]:HookScript('OnShow', OnShow)
	end
end

S:AddCallback('Loot', LoadSkin)
S:AddCallback('LootRoll', LoadRollSkin)
