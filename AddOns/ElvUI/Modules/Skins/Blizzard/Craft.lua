local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local find, match = string.find, string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetCraftItemLink = GetCraftItemLink
local GetCraftReagentInfo = GetCraftReagentInfo
local GetCraftReagentItemLink = GetCraftReagentItemLink
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or not E.private.skins.blizzard.craft ~= true then return end

	CraftFrame:StripTextures(true)
	CraftFrame:CreateBackdrop('Transparent')
	CraftFrame.backdrop:Point('TOPLEFT', 10, -12)
	CraftFrame.backdrop:Point('BOTTOMRIGHT', -34, 0)

	CraftFrame.bg1 = CreateFrame('Frame', nil, CraftFrame)
	CraftFrame.bg1:SetTemplate('Transparent')
	CraftFrame.bg1:Point('TOPLEFT', 14, -92)
	CraftFrame.bg1:Point('BOTTOMRIGHT', -367, 4)
	CraftFrame.bg1:SetFrameLevel(CraftFrame.bg1:GetFrameLevel() - 1)

	CraftFrame.bg2 = CreateFrame('Frame', nil, CraftFrame)
	CraftFrame.bg2:SetTemplate('Transparent')
	CraftFrame.bg2:Point('TOPLEFT', CraftFrame.bg1, 'TOPRIGHT', 3, 0)
	CraftFrame.bg2:Point('BOTTOMRIGHT', CraftFrame, 'BOTTOMRIGHT', -38, 4)
	CraftFrame.bg2:SetFrameLevel(CraftFrame.bg2:GetFrameLevel() - 1)

	CraftRankFrameBorder:StripTextures()

	CraftRankFrame:StripTextures()
	CraftRankFrame:CreateBackdrop()
	CraftRankFrame:Size(420, 18)
	CraftRankFrame:ClearAllPoints()
	CraftRankFrame:Point('TOP', -10, -38)
	CraftRankFrame:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(CraftRankFrame)

	CraftRankFrameSkillName:Hide()
	CraftRankFrameSkillRank:ClearAllPoints()
	CraftRankFrameSkillRank:SetParent(CraftRankFrame)
	CraftRankFrameSkillRank:Point('CENTER', CraftRankFrame, 'CENTER', 58, 0)

	CraftListScrollFrame:StripTextures()
	CraftListScrollFrame:Size(310, 405)
	CraftListScrollFrame:ClearAllPoints()
	CraftListScrollFrame:Point('TOPLEFT', 17, -95)

	CraftDetailScrollFrame:StripTextures()
	CraftDetailScrollFrame:Size(300, 381)
	CraftDetailScrollFrame:ClearAllPoints()
	CraftDetailScrollFrame:Point('TOPRIGHT', CraftFrame, -60, -95)

	CraftDetailScrollChildFrame:StripTextures()
	CraftDetailScrollChildFrame:Size(300, 150)

	S:HandleScrollBar(CraftListScrollFrameScrollBar)
	S:HandleScrollBar(CraftDetailScrollFrameScrollBar)

	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:Point('TOPRIGHT', CraftDetailScrollFrame, 'BOTTOMRIGHT', 19, -3)
	S:HandleButton(CraftCancelButton)

	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:Point('TOPRIGHT', CraftCancelButton, 'TOPLEFT', -3, 0)
	S:HandleButton(CraftCreateButton)

	CraftIcon:StripTextures()
	CraftIcon:SetTemplate('Default')
	CraftIcon:StyleButton(nil, true)
	CraftIcon:Size(47)
	CraftIcon:Point('TOPLEFT', 1, -3)

	CraftName:Point('TOPLEFT', 55, -3)

	CraftRequirements:SetTextColor(1, 0.80, 0.10)

	S:HandleCloseButton(CraftFrameCloseButton, CraftFrame.backdrop)

	CraftExpandButtonFrame:StripTextures()

	CraftCollapseAllButton:Point('LEFT', CraftExpandTabLeft, 'RIGHT', -8, 5)
	CraftCollapseAllButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
	CraftCollapseAllButton.SetNormalTexture = E.noop
	CraftCollapseAllButton:GetNormalTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetNormalTexture():Size(15)

	CraftCollapseAllButton:SetHighlightTexture('')
	CraftCollapseAllButton.SetHighlightTexture = E.noop

	CraftCollapseAllButton:SetDisabledTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
	CraftCollapseAllButton.SetDisabledTexture = E.noop
	CraftCollapseAllButton:GetDisabledTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetDisabledTexture():Size(15)
	CraftCollapseAllButton:GetDisabledTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
	CraftCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(CraftCollapseAllButton, 'SetNormalTexture', function(self, texture)
		if find(texture, 'MinusButton') then
			self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
		else
			self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
		end
	end)

	for i = 9, 25 do
		CreateFrame('Button', 'Craft'..i, CraftFrame, 'CraftButtonTemplate'):Point('TOPLEFT', _G['Craft'..i - 1], 'BOTTOMLEFT')
	end

	for i = 1, CRAFTS_DISPLAYED do
		local button = _G['Craft'..i]
		local highlight = _G['Craft'..i..'Highlight']

		button:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
		button.SetNormalTexture = E.noop
		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():Point('LEFT', 4, 1)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop

		hooksecurefunc(button, 'SetNormalTexture', function(self, texture)
			if find(texture, 'MinusButton') then
				self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
			elseif find(texture, 'PlusButton') then
				self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
			end
		end)
	end

	for i = 1, MAX_CRAFT_REAGENTS do
		local reagent = _G['CraftReagent'..i]
		local icon = _G['CraftReagent'..i..'IconTexture']
		local count = _G['CraftReagent'..i..'Count']
		local name = _G['CraftReagent'..i..'Name']
		local nameFrame = _G['CraftReagent'..i..'NameFrame']

		reagent:SetTemplate('Default')
		reagent:StyleButton(nil, true)
		reagent:Size(143, 40)

		icon.backdrop = CreateFrame('Frame', nil, reagent)
		icon.backdrop:SetTemplate('Default')
		icon.backdrop:Point('TOPLEFT', icon, -1, 1)
		icon.backdrop:Point('BOTTOMRIGHT', icon, 1, -1)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer('OVERLAY')
		icon:Size(E.PixelMode and 38 or 32)
		icon:Point('TOPLEFT', E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		count:SetParent(icon.backdrop)
		count:SetDrawLayer('OVERLAY')

		name:Point('LEFT', nameFrame, 'LEFT', 20, 0)

		nameFrame:Kill()
	end

	CraftReagent1:Point('TOPLEFT', CraftReagentLabel, 'BOTTOMLEFT', -3, -3)
	CraftReagent2:Point('LEFT', CraftReagent1, 'RIGHT', 3, 0)
	CraftReagent4:Point('LEFT', CraftReagent3, 'RIGHT', 3, 0)
	CraftReagent6:Point('LEFT', CraftReagent5, 'RIGHT', 3, 0)
	CraftReagent8:Point('LEFT', CraftReagent7, 'RIGHT', 3, 0)

	hooksecurefunc('CraftFrame_Update', function()
		CraftRankFrame:SetStatusBarColor(0.13, 0.28, 0.85)
	end)

	hooksecurefunc('CraftFrame_SetSelection', function(id)
		CraftReagentLabel:Point('TOPLEFT', CraftDescription, 'BOTTOMLEFT', 0, -10)

		if CraftIcon:GetNormalTexture() then
			CraftReagentLabel:SetAlpha(1)
			CraftIcon:SetAlpha(1)
			CraftIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			CraftIcon:GetNormalTexture():SetInside()
		else
			CraftReagentLabel:SetAlpha(0)
			CraftIcon:SetAlpha(0)
		end

		local skillLink = GetCraftItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality then
				CraftIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				CraftName:SetTextColor(GetItemQualityColor(quality))
			else
				CraftIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				CraftName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetCraftNumReagents(id)
		for i = 1, numReagents, 1 do
			local _, _, reagentCount, playerReagentCount = GetCraftReagentInfo(id, i)
			local reagentLink = GetCraftReagentItemLink(id, i)
			local reagent = _G['CraftReagent'..i]
			local icon = _G['CraftReagent'..i..'IconTexture']
			local name = _G['CraftReagent'..i..'Name']

			if reagentLink then
				local quality = select(3, GetItemInfo(reagentLink))
				if quality then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					reagent:SetBackdropBorderColor(GetItemQualityColor(quality))
					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					reagent:SetBackdropBorderColor(unpack(E.media.bordercolor))
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_CraftUI', 'Craft', LoadSkin)