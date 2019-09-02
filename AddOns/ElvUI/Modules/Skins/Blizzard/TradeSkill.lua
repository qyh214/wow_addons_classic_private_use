local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local find, match, split = string.find, string.match, string.split
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end

	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame:CreateBackdrop('Transparent')
	TradeSkillFrame.backdrop:Point('TOPLEFT', 10, -11)
	TradeSkillFrame.backdrop:Point('BOTTOMRIGHT', -32, 74)

	TradeSkillRankFrameBorder:StripTextures()
	TradeSkillRankFrame:Size(322, 16)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:Point('TOP', -10, -45)
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E['media'].normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(TradeSkillRankFrame)

	TradeSkillExpandButtonFrame:StripTextures()

	TradeSkillCollapseAllButton:GetNormalTexture():SetPoint('LEFT', 3, 2)
	TradeSkillCollapseAllButton:GetNormalTexture():Size(15)

	TradeSkillCollapseAllButton:SetHighlightTexture('')
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture(E.Media.Textures.MinusButton)
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop
	TradeSkillCollapseAllButton:GetDisabledTexture():SetPoint('LEFT', 3, 2)
	TradeSkillCollapseAllButton:GetDisabledTexture():Size(15)
	TradeSkillCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	S:HandleDropDownBox(TradeSkillInvSlotDropDown, 140)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:Point('TOPRIGHT', TradeSkillFrame, 'TOPRIGHT', -32, -68)

	S:HandleDropDownBox(TradeSkillSubClassDropDown, 140)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:Point('RIGHT', TradeSkillInvSlotDropDown, 'RIGHT', -120, 0)

	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:Point('TOP', TradeSkillFrame, 'TOP', 0, -18)

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local button = _G['TradeSkillSkill'..i]
		local highlight = _G['TradeSkillSkill'..i..'Highlight']

		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():SetPoint('LEFT', 2, 1)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop
	end

	hooksecurefunc('TradeSkillFrame_Update', function()
		for i = 1, TRADE_SKILLS_DISPLAYED do
			local button = _G['TradeSkillSkill'..i]
			local texture = button:GetNormalTexture():GetTexture()
			if texture then
				if strfind(texture, 'MinusButton') then
					button:SetNormalTexture(E.Media.Textures.MinusButton)
				elseif strfind(texture, 'PlusButton') then
					button:SetNormalTexture(E.Media.Textures.PlusButton)
				end
			end
		end

		if TradeSkillCollapseAllButton.collapsed then
			TradeSkillCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		else
			TradeSkillCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		end
	end)

	TradeSkillDetailScrollFrame:StripTextures()
	TradeSkillListScrollFrame:StripTextures()
	TradeSkillDetailScrollChildFrame:StripTextures()

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)

	TradeSkillSkillIcon:StyleButton(nil, true)
	TradeSkillSkillIcon:SetTemplate('Default')

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G['TradeSkillReagent'..i]
		local icon = _G['TradeSkillReagent'..i..'IconTexture']
		local count = _G['TradeSkillReagent'..i..'Count']
		local nameFrame = _G['TradeSkillReagent'..i..'NameFrame']

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer('OVERLAY')

		icon.backdrop = CreateFrame('Frame', nil, reagent)
		icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1)
		icon.backdrop:SetTemplate('Default')
		icon.backdrop:SetOutside(icon)

		icon:SetParent(icon.backdrop)
		count:SetParent(icon.backdrop)
		count:SetDrawLayer('OVERLAY')

		nameFrame:Kill()
	end

	S:HandleButton(TradeSkillCancelButton)
	S:HandleButton(TradeSkillCreateButton)
	S:HandleButton(TradeSkillCreateAllButton)

	S:HandleNextPrevButton(TradeSkillDecrementButton)
	TradeSkillInputBox:Height(16)
	S:HandleEditBox(TradeSkillInputBox)
	S:HandleNextPrevButton(TradeSkillIncrementButton)

	S:HandleCloseButton(TradeSkillFrameCloseButton)

	hooksecurefunc('TradeSkillFrame_SetSelection', function(id)
		local skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(id)
		if skillType == "header" then
			return
		end

		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:SetAlpha(1)
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			TradeSkillSkillIcon:GetNormalTexture():SetInside()
		else
			TradeSkillSkillIcon:SetAlpha(0)
		end

		TradeSkillSkillIcon:Size(40)
		TradeSkillSkillIcon:Point('TOPLEFT', 2, -3)

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality))
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E['media'].bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetTradeSkillNumReagents(id)
		for i = 1, numReagents, 1 do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)
			local icon = _G['TradeSkillReagent'..i..'IconTexture']
			local name = _G['TradeSkillReagent'..i..'Name']

			if reagentLink then
				local quality = select(3, GetItemInfo(reagentLink))
				if quality and quality > 1 then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E['media'].bordercolor))
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_TradeSkillUI', 'TradeSkill', LoadSkin)
