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
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.craft ~= true then return end

	CraftFrame:StripTextures(true)
	CraftFrame:CreateBackdrop('Transparent')
	CraftFrame.backdrop:Point('TOPLEFT', 10, -12)
	CraftFrame.backdrop:Point('BOTTOMRIGHT', -34, 70)

	CraftRankFrameBorder:StripTextures()

	CraftRankFrame:StripTextures()
	CraftRankFrame:CreateBackdrop()
	CraftRankFrame:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(CraftRankFrame)

	--CraftRankFrameSkillName:Hide()
	--CraftRankFrameSkillRank:ClearAllPoints()
	--CraftRankFrameSkillRank:SetParent(CraftRankFrame)
	--CraftRankFrameSkillRank:Point('CENTER', CraftRankFrame, 'CENTER', 58, 0)

	CraftListScrollFrame:StripTextures()

	CraftDetailScrollFrame:StripTextures()

	CraftDetailScrollChildFrame:StripTextures()

	S:HandleScrollBar(CraftListScrollFrameScrollBar)
	S:HandleScrollBar(CraftDetailScrollFrameScrollBar)

	S:HandleButton(CraftCancelButton)

	S:HandleButton(CraftCreateButton)

	CraftIcon:StripTextures()
	CraftIcon:SetTemplate('Default')
	CraftIcon:StyleButton(nil, true)

	CraftRequirements:SetTextColor(1, 0.80, 0.10)

	S:HandleCloseButton(CraftFrameCloseButton, CraftFrame.backdrop)

	CraftExpandButtonFrame:StripTextures()

	CraftCollapseAllButton:Point('LEFT', CraftExpandTabLeft, 'RIGHT', -8, 5)
	CraftCollapseAllButton:GetNormalTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetNormalTexture():Size(15)

	CraftCollapseAllButton:SetHighlightTexture('')
	CraftCollapseAllButton.SetHighlightTexture = E.noop

	CraftCollapseAllButton:SetDisabledTexture(E.Media.Textures.MinusButton)
	CraftCollapseAllButton.SetDisabledTexture = E.noop
	CraftCollapseAllButton:GetDisabledTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetDisabledTexture():Size(15)
	CraftCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	for i = 1, CRAFTS_DISPLAYED do
		local button = _G['Craft'..i]
		local highlight = _G['Craft'..i..'Highlight']

		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():Point('LEFT', 4, 1)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop
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

		for i = 1, CRAFTS_DISPLAYED do
			local button = _G['Craft'..i]
			local texture = button:GetNormalTexture():GetTexture()
			if texture then
				if strfind(texture, 'MinusButton') then
					button:SetNormalTexture(E.Media.Textures.MinusButton)
				elseif strfind(texture, 'PlusButton') then
					button:SetNormalTexture(E.Media.Textures.PlusButton)
				end
			end
		end

		if CraftCollapseAllButton.collapsed then
			CraftCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		else
			CraftCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		end
	end)

	hooksecurefunc('CraftFrame_SetSelection', function(id)
		if ( not id ) then
			return;
		end

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
			if quality and quality > 1 then
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
				if quality and quality > 1 then
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

		if (numReagents < 4) then
			CraftDetailScrollFrameScrollBar:Hide();
			CraftDetailScrollFrameTop:Hide();
			CraftDetailScrollFrameBottom:Hide();
		else
			CraftDetailScrollFrameScrollBar:Show();
			CraftDetailScrollFrameTop:Show();
			CraftDetailScrollFrameBottom:Show();
		end
	end)
end

S:AddCallbackForAddon('Blizzard_CraftUI', 'Craft', LoadSkin)
