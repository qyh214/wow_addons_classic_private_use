local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local pairs = pairs
local find = string.find
--WoW API / Variables
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemQuality = GetInventoryItemQuality
local GetNumFactions = GetNumFactions
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	-- Character Frame
	CharacterFrame:StripTextures(true)

	CharacterFrame:CreateBackdrop('Transparent')
	CharacterFrame.backdrop:Point('TOPLEFT', 11, -12)
	CharacterFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)

	S:HandleCloseButton(CharacterFrameCloseButton)

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G['CharacterFrameTab'..i]
		S:HandleTab(tab)
	end

	PaperDollFrame:StripTextures()

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	CharacterModelFrameRotateRightButton:Point('TOPLEFT', CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	CharacterAttributesFrame:StripTextures()

	local function HandleResistanceFrame(frameName)
		for i = 1, 5 do
			local frame = _G[frameName..i]
			frame:Size(24)

			local icon, text = _G[frameName..i]:GetRegions()
			icon:SetInside()
			icon:SetDrawLayer('ARTWORK')
			text:SetDrawLayer('OVERLAY')

			frame:SetTemplate('Default')

			if i ~= 1 then
				frame:ClearAllPoints()
				frame:Point('TOP', _G[frameName..i - 1], 'BOTTOM', 0, -(E.Border + E.Spacing))
			end
		end
	end

	HandleResistanceFrame('MagicResFrame')

	MagicResFrame1:GetRegions():SetTexCoord(0.21875, 0.8125, 0.25, 0.32421875)		--Arcane
	MagicResFrame2:GetRegions():SetTexCoord(0.21875, 0.8125, 0.0234375, 0.09765625)	--Fire
	MagicResFrame3:GetRegions():SetTexCoord(0.21875, 0.8125, 0.13671875, 0.2109375)	--Nature
	MagicResFrame4:GetRegions():SetTexCoord(0.21875, 0.8125, 0.36328125, 0.4375)	--Frost
	MagicResFrame5:GetRegions():SetTexCoord(0.21875, 0.8125, 0.4765625, 0.55078125)	--Shadow

	local slots = {'HeadSlot', 'NeckSlot', 'ShoulderSlot', 'BackSlot', 'ChestSlot', 'ShirtSlot', 'TabardSlot', 'WristSlot',
		'HandsSlot', 'WaistSlot', 'LegsSlot', 'FeetSlot', 'Finger0Slot', 'Finger1Slot', 'Trinket0Slot', 'Trinket1Slot',
		'MainHandSlot', 'SecondaryHandSlot', 'RangedSlot', 'AmmoSlot'
	}

	for _, slot in pairs(slots) do
		local icon = _G['Character'..slot..'IconTexture']
		local cooldown = _G['Character'..slot..'Cooldown']

		slot = _G['Character'..slot]
		slot:StripTextures()
		slot:SetTemplate('Default', true, true)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		slot:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)

		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('PaperDollItemSlotButton_Update', function(self, cooldownOnly)
		if cooldownOnly then return end

		local textureName = GetInventoryItemTexture('player', self:GetID())
		if textureName then
			local rarity = GetInventoryItemQuality('player', self:GetID())
			self:SetBackdropBorderColor(GetItemQualityColor(rarity))
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	-- PetPaperDollFrame
	PetPaperDollFrame:StripTextures()

	S:HandleButton(PetPaperDollCloseButton)

	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	PetModelFrameRotateLeftButton:ClearAllPoints()
	PetModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(PetModelFrameRotateRightButton)
	PetModelFrameRotateRightButton:ClearAllPoints()
	PetModelFrameRotateRightButton:Point('TOPLEFT', PetModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	PetAttributesFrame:StripTextures()

	PetResistanceFrame:CreateBackdrop('Default')
	PetResistanceFrame.backdrop:SetOutside(PetMagicResFrame1, nil, nil, PetMagicResFrame5)

	for i = 1, 5 do
		local frame = _G['PetMagicResFrame'..i]
		frame:Size(24)
	end

	PetMagicResFrame1:GetRegions():SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125)
	PetMagicResFrame2:GetRegions():SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375)
	PetMagicResFrame3:GetRegions():SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125)
	PetMagicResFrame4:GetRegions():SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375)
	PetMagicResFrame5:GetRegions():SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875)

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:CreateBackdrop('Default')

	local function updHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not happiness or not isHunterPet then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end

	PetPaperDollPetInfo:Point('TOPLEFT', PetModelFrameRotateLeftButton, 'BOTTOMLEFT', 9, -3)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:CreateBackdrop('Default')
	PetPaperDollPetInfo:Size(24)

	PetPaperDollPetInfo:RegisterEvent('UNIT_HAPPINESS')
	PetPaperDollPetInfo:SetScript('OnEvent', updHappiness)
	PetPaperDollPetInfo:SetScript('OnShow', updHappiness)

	-- Reputation Frame
	ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionBar = _G['ReputationBar'..i]
		local factionHeader = _G['ReputationHeader'..i]
		local factionName = _G['ReputationBar'..i..'FactionName']
		local factionWar = _G['ReputationBar'..i..'AtWarCheck']

		factionBar:StripTextures()
		factionBar:CreateBackdrop('Default')
		factionBar:SetStatusBarTexture(E.media.normTex)
		factionBar:Size(108, 13)
		E:RegisterStatusBar(factionBar)

		if i == 1 then
			factionBar:Point('TOPLEFT', 190, -86)
		end

		factionName:Width(140)
		factionName:Point('LEFT', factionBar, 'LEFT', -150, 0)
		factionName.SetWidth = E.noop

		factionHeader:GetNormalTexture():Size(14)
		factionHeader:SetHighlightTexture(nil)
		factionHeader:Point('TOPLEFT', factionBar, 'TOPLEFT', -175, 0)

		factionWar:StripTextures()
		factionWar:Point('LEFT', factionBar, 'RIGHT', 0, 0)

		factionWar.Icon = factionWar:CreateTexture(nil, 'OVERLAY')
		factionWar.Icon:Point('LEFT', 6, -8)
		factionWar.Icon:Size(32)
		factionWar.Icon:SetTexture('Interface\\Buttons\\UI-CheckBox-SwordCheck')
	end

	hooksecurefunc('ReputationFrame_Update', function()
		local numFactions = GetNumFactions()
		local factionIndex, factionHeader
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			factionHeader = _G['ReputationHeader'..i]
			factionIndex = factionOffset + i
			if factionIndex <= numFactions then
				if factionHeader.isCollapsed then
					factionHeader:SetNormalTexture(E.Media.Textures.PlusButton)
				else
					factionHeader:SetNormalTexture(E.Media.Textures.MinusButton)
				end
			end
		end
	end)

	ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)

	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate('Transparent')
	ReputationDetailFrame:Point('TOPLEFT', ReputationFrame, 'TOPRIGHT', -31, -12)

	S:HandleCloseButton(ReputationDetailCloseButton)
	ReputationDetailCloseButton:Point('TOPRIGHT', 2, 2)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)

	-- Skill Frame
	SkillFrame:StripTextures()

	SkillFrameExpandButtonFrame:DisableDrawLayer('BACKGROUND')
	SkillFrameCollapseAllButton:GetNormalTexture():Size(15)
	SkillFrameCollapseAllButton:Point('LEFT', SkillFrameExpandTabLeft, 'RIGHT', -40, -3)

	SkillFrameCollapseAllButton:SetHighlightTexture(nil)

	hooksecurefunc('SkillFrame_UpdateSkills', function()
		if strfind(SkillFrameCollapseAllButton:GetNormalTexture():GetTexture(), 'MinusButton') then
			SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		else
			SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		end
	end)

	S:HandleButton(SkillFrameCancelButton)

	for i = 1, SKILLS_TO_DISPLAY do
		local bar = _G['SkillRankFrame'..i]
		local label = _G['SkillTypeLabel'..i]
		local border = _G['SkillRankFrame'..i..'Border']
		local background = _G['SkillRankFrame'..i..'Background']

		bar:CreateBackdrop('Default')
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		border:StripTextures()
		background:SetTexture(nil)

		label:GetNormalTexture():Size(14)
		label:SetHighlightTexture(nil)
	end

	hooksecurefunc('SkillFrame_SetStatusBar', function(statusBarID, skillIndex, numSkills)
		local skillLine = _G["SkillTypeLabel"..statusBarID]
		if strfind(skillLine:GetNormalTexture():GetTexture(), 'MinusButton') then
			skillLine:SetNormalTexture(E.Media.Textures.MinusButton)
		else
			skillLine:SetNormalTexture(E.Media.Textures.PlusButton)
		end
	end)

	SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(SkillListScrollFrameScrollBar)

	SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar)

	SkillDetailStatusBar:StripTextures()
	SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
	SkillDetailStatusBar:CreateBackdrop('Default')
	SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(SkillDetailStatusBar)

	S:HandleNextPrevButton(SkillDetailStatusBarUnlearnButton)
	-- S:SquareButton_SetIcon(SkillDetailStatusBarUnlearnButton, 'DELETE')
	SkillDetailStatusBarUnlearnButton:Size(24)
	SkillDetailStatusBarUnlearnButton:Point('LEFT', SkillDetailStatusBarBorder, 'RIGHT', 5, 0)
	SkillDetailStatusBarUnlearnButton:SetHitRectInsets(0, 0, 0, 0)

	-- Honor Frame
	HonorFrame:StripTextures()

	HonorFrameProgressButton:CreateBackdrop()
	HonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(HonorFrameProgressBar)
end

S:AddCallback('Character', LoadSkin)
