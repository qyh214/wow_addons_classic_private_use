local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local match = string.match
--WoW API / Variables
local GetItemQualityColor = GetItemQualityColor
local GetContainerItemLink = GetContainerItemLink
local BANK_CONTAINER = BANK_CONTAINER
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

function S:ContainerFrame_Update(self)
	local id = self:GetID()
	local name = self:GetName()
	local _, itemButton, itemLink, quality

	for i = 1, self.size, 1 do
		itemButton = _G[name..'Item'..i]

		itemLink = GetContainerItemLink(id, itemButton:GetID())
		if itemLink then
			quality = select(3, GetItemInfo(itemLink))
			if quality and quality > 1 then
				itemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
				itemButton.ignoreBorderColors = true
			else
				itemButton:SetBackdropBorderColor(unpack(E['media'].bordercolor))
				itemButton.ignoreBorderColors = true
			end
		else
			itemButton:SetBackdropBorderColor(unpack(E['media'].bordercolor))
			itemButton.ignoreBorderColors = true
		end
	end
end

function S:BankFrameItemButton_Update(self)
	if not self.isBag then
		local itemLink = GetContainerItemLink(BANK_CONTAINER, self:GetID())
		if itemLink then
			local quality = select(3, GetItemInfo(itemLink))
			if quality and quality > 1 then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
				self.ignoreBorderColors = true
			else
				self:SetBackdropBorderColor(unpack(E['media'].bordercolor))
				self.ignoreBorderColors = true
			end
		else
			self:SetBackdropBorderColor(unpack(E['media'].bordercolor))
			self.ignoreBorderColors = true
		end
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	-- ContainerFrame
	local containerFrame, containerFrameClose
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		containerFrame = _G['ContainerFrame'..i]
		containerFrameClose = _G['ContainerFrame'..i..'CloseButton']

		containerFrame:StripTextures(true)
		containerFrame:CreateBackdrop('Transparent')
		containerFrame.backdrop:Point('TOPLEFT', 9, -4)
		containerFrame.backdrop:Point('BOTTOMRIGHT', -4, 2)

		S:HandleCloseButton(containerFrameClose)

		S:SecureHookScript(containerFrame, 'OnShow', 'ContainerFrame_Update')

		local itemButton, itemButtonIcon, itemButtonCooldown
		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			itemButton = _G['ContainerFrame'..i..'Item'..k]
			itemButtonIcon = _G['ContainerFrame'..i..'Item'..k..'IconTexture']
			itemButtonCooldown = _G['ContainerFrame'..i..'Item'..k..'Cooldown']

			itemButton:SetNormalTexture('')

			itemButton:SetTemplate('Default', true)
			itemButton:StyleButton()

			itemButtonIcon:SetInside()
			itemButtonIcon:SetTexCoord(unpack(E.TexCoords))

			if itemButtonCooldown then
				E:RegisterCooldown(itemButtonCooldown)
			end
		end
	end

	S:SecureHook('ContainerFrame_Update')

	-- BankFrame
	BankFrame:CreateBackdrop('Transparent')
	BankFrame.backdrop:Point('TOPLEFT', 10, -11)
	BankFrame.backdrop:Point('BOTTOMRIGHT', -26, 93)

	BankFrame:StripTextures(true)

	S:HandleCloseButton(BankCloseButton, BankFrame.backdrop)

	local button, buttonIcon
	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		button = _G['BankFrameItem'..i]
		buttonIcon = _G['BankFrameItem'..i..'IconTexture']

		button:SetNormalTexture('')

		button:SetTemplate('Default', true)
		button:StyleButton()

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))
	end

	BankFrame.itemBackdrop = CreateFrame('Frame', 'BankFrameItemBackdrop', BankFrame)
	BankFrame.itemBackdrop:SetTemplate('Default')
	BankFrame.itemBackdrop:Point('TOPLEFT', BankFrameItem1, 'TOPLEFT', -6, 6)
	BankFrame.itemBackdrop:Point('BOTTOMRIGHT', BankFrameItem24, 'BOTTOMRIGHT', 6, -6)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		button = _G['BankFrameItem'..i]
		buttonIcon = _G['BankFrameItem'..i..'IconTexture']

		button:SetNormalTexture('')

		button:SetTemplate('Default', true)
		button:StyleButton()

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))

		-- _G['BankFrameItem'..i..'HighlightFrameTexture']:SetInside()
		-- _G['BankFrameItem'..i..'HighlightFrameTexture']:SetTexture(unpack(E['media'].rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame('Frame', 'BankFrameBagBackdrop', BankFrame)
	BankFrame.bagBackdrop:SetTemplate('Default')
	BankFrame.bagBackdrop:Point('TOPLEFT', BankFrameBag1, 'TOPLEFT', -6, 6)
	BankFrame.bagBackdrop:Point('BOTTOMRIGHT', BankFrameBag6, 'BOTTOMRIGHT', 6, -6)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	S:SecureHook('BankFrameItemButton_Update')
end

S:AddCallback('SkinBags', LoadSkin)
