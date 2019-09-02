local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local gsub, type, pairs, ipairs, select, unpack, strfind = gsub, type, pairs, ipairs, select, unpack, strfind
--WoW API / Variables
local GetMoney = GetMoney
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetQuestID = GetQuestID
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestMoneyToGet = GetQuestMoneyToGet
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogRewardSpells = GetNumQuestLogRewardSpells
local GetQuestLogItemLink = GetQuestLogItemLink
local GetNumRewardSpells = GetNumRewardSpells
local GetQuestLogSelection = GetQuestLogSelection
local hooksecurefunc = hooksecurefunc

local function HandleReward(frame)
	if (not frame) then return end

	if frame.Icon then
		S:HandleIcon(frame.Icon, true)

		frame.Count:ClearAllPoints()
		frame.Count:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 2, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:SetFontObject('GameFontHighlightSmall')
	end

	if (frame.CircleBackground) then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end
end

-- Quest objective text color
local function Quest_GetQuestID()
	if _G.QuestInfoFrame.questLog then
		return select(8, GetQuestLogTitle(GetQuestLogSelection()))
	else
		return GetQuestID()
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

	local QuestLogFrame = _G.QuestLogFrame
	S:HandlePortraitFrame(QuestLogFrame, true)
	QuestLogFrame.backdrop:Point('TOPLEFT', 10, -12)
	QuestLogFrame.backdrop:Point('BOTTOMRIGHT', -1, 8)
	QuestLogFrame:Width(374)

	for frame, numItems in pairs({['QuestLogItem'] = _G.MAX_NUM_ITEMS, ['QuestProgressItem'] = _G.MAX_REQUIRED_ITEMS, ['MapQuestInfoRewardsFrameQuestInfoItem'] = _G.MAX_REQUIRED_ITEMS}) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i..'IconTexture']
			if item then
				item:StripTextures()
				item:SetTemplate('Transparent')
				item:StyleButton()
				--item:Size(143, 40)
				item:SetFrameLevel(item:GetFrameLevel() + 2)
			end
			if icon then
				--icon:Size(E.PixelMode and 38 or 32)
				icon:SetDrawLayer('OVERLAY')
				--icon:Point('TOPLEFT', E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
				S:HandleIcon(icon, true)
			end
		end
	end

	local function QuestQualityColors(frame, text, link, quality)
		if link and not quality then
			quality = select(3, GetItemInfo(link))
		end

		if quality and quality > 1 then
			if frame and frame.Icon and frame.Icon.backdrop then
				frame.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
			text:SetTextColor(GetItemQualityColor(quality))
		else
			if frame and frame.Icon and frame.Icon.backdrop then
				frame.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
			if text then
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local QuestInfoItemHighlight = _G.QuestInfoItemHighlight
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate(nil, nil, true)
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		if self.type == "choice" then
			QuestInfoItemHighlight:ClearAllPoints()
			QuestInfoItemHighlight:SetAllPoints(self.Icon)
			--self:SetBackdropBorderColor(1, 0.80, 0.10)

			for i = 1, _G.MAX_NUM_ITEMS do
				local item = _G["QuestInfoRewardsFrameQuestInfoItem"..i]
				if item then
					item.Name:SetTextColor(1, 1, 1)
				end
			end

			self.Name:SetTextColor(1, 0.80, 0.10)
		end
	end)

	_G.QuestRewardScrollFrame:CreateBackdrop()
	_G.QuestRewardScrollFrame:Height(_G.QuestRewardScrollFrame:GetHeight() - 2)

	S:HandleButton(_G.QuestLogFrameAbandonButton)
	_G.QuestLogFrameAbandonButton:Point('BOTTOMLEFT', 14, 14)

	S:HandleButton(_G.QuestFramePushQuestButton)
	_G.QuestFramePushQuestButton:Point('LEFT', _G.QuestLogFrameAbandonButton, 'RIGHT', 2, 0)

	S:HandleButton(_G.QuestFrameExitButton)
	_G.QuestFrameExitButton:Point('BOTTOMRIGHT', -9, 14)

	local textColor = {1, 1, 1}
	local titleTextColor = {1, .8, .1}

	hooksecurefunc(_G, 'QuestLog_UpdateQuestDetails', function()
		_G.QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		_G.QuestLogObjectivesText:SetTextColor(unpack(textColor))

		_G.QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		_G.QuestLogQuestDescription:SetTextColor(unpack(textColor))

		_G.QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))

		_G.QuestLogItemChooseText:SetTextColor(unpack(textColor))
		_G.QuestLogSpellLearnText:SetTextColor(unpack(textColor))

		_G.QuestLogItemReceiveText:SetTextColor(unpack(textColor))

		local numObjectives = GetNumQuestLeaderBoards()
		local numVisibleObjectives = 0

		for i = 1, numObjectives do
			local _, _, finished = GetQuestLogLeaderBoard(i)
			if (type ~= 'spell' and type ~= 'log' and numVisibleObjectives < _G.MAX_OBJECTIVES) then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G['QuestLogObjective'..numVisibleObjectives]
				if objective then
					if finished then
						objective:SetTextColor(1, .8, .1)
					else
						objective:SetTextColor(.63, .09, .09)
					end
				end
			end
		end

		if _G.QuestLogRequiredMoneyText:GetTextColor() == 0 then
			_G.QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
		else
			_G.QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
		end
	end)

	hooksecurefunc('QuestInfo_Display', function()
		-- Headers
		_G.QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoRewardsFrame.Header:SetTextColor(unpack(titleTextColor))
		-- Other text
		_G.QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		_G.QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		_G.QuestInfoGroupSize:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardText:SetTextColor(unpack(textColor))
		-- Reward frame text
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(unpack(textColor))

		_G.QuestInfoRewardsFrame.spellHeaderPool.textR, _G.QuestInfoRewardsFrame.spellHeaderPool.textG, _G.QuestInfoRewardsFrame.spellHeaderPool.textB = unpack(textColor)

		if GetQuestLogRequiredMoney() > 0 then
			if GetQuestLogRequiredMoney() > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, _G.MAX_NUM_ITEMS do
			local item = _G["QuestInfoRewardsFrameQuestInfoItem"..i]
			if item then
				local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())
				QuestQualityColors(item, item.Name, link)
			end
		end
	end)

	for i = 1, MAX_NUM_QUESTS do
		_G["QuestTitleButton"..i.."QuestIcon"]:SetPoint('TOPLEFT', 4, 2)
		_G["QuestTitleButton"..i.."QuestIcon"]:SetSize(16, 16)
	end

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		local i = 1
		while _G["QuestTitleButton"..i]:IsVisible() do
			local title = _G["QuestTitleButton"..i]
			local icon = _G["QuestTitleButton"..i.."QuestIcon"]
			local text = title:GetFontString()
			local textString = gsub(title:GetText(), "|c[Ff][Ff]%x%x%x%x%x%x(.+)|r", "%1")

			title:SetText(textString)

			if (title.isActive == 1) then
				icon:SetTexture(132048)
				icon:SetDesaturation(1)
				text:SetTextColor(.6, .6, .6)
			else
				icon:SetTexture(132049)
				icon:SetDesaturation(0)
				text:SetTextColor(1, .8, .1)
			end

			local numEntries = GetNumQuestLogEntries()
			for k = 1, numEntries, 1 do
				local questLogTitleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(k)
				if strmatch(questLogTitleText, textString) then
					if (isComplete == 1 or IsQuestComplete(questId)) then
						icon:SetDesaturation(0)
						text:SetTextColor(1, .8, .1)
						break
					end
				end
			end

			i = i + 1
		end
	end)

	for _, frame in pairs({'MoneyFrame', 'HonorFrame', 'XPFrame', 'SpellFrame', 'SkillPointFrame'}) do
		HandleReward(_G.MapQuestInfoRewardsFrame[frame])
		HandleReward(_G.QuestInfoRewardsFrame[frame])
	end

	-- Hook for WorldQuestRewards / QuestLogRewards
	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local RewardButton = rewardsFrame.RewardButtons[index]

		if (not RewardButton.Icon.backdrop) then
			HandleReward(RewardButton)

			RewardButton.IconBorder:SetAlpha(0)
			RewardButton.NameFrame:Hide()

			hooksecurefunc(RewardButton.IconBorder, 'SetVertexColor', function(_, r, g, b) RewardButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(.6, .6, .6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, .8, .1)
			end
		end
	end)

	--Reward: Title
	local QuestInfoPlayerTitleFrame = _G.QuestInfoPlayerTitleFrame
	QuestInfoPlayerTitleFrame.FrameLeft:SetTexture()
	QuestInfoPlayerTitleFrame.FrameCenter:SetTexture()
	QuestInfoPlayerTitleFrame.FrameRight:SetTexture()
	QuestInfoPlayerTitleFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	QuestInfoPlayerTitleFrame:CreateBackdrop()
	QuestInfoPlayerTitleFrame.backdrop:SetOutside(QuestInfoPlayerTitleFrame.Icon)

	_G.QuestLogTimerText:SetTextColor(1, 1, 1)

	_G.QuestInfoTimerText:SetTextColor(1, 1, 1)
	_G.QuestInfoAnchor:SetTextColor(1, 1, 1)

	_G.QuestLogDetailScrollFrame:StripTextures()

	_G.QuestLogFrame:HookScript('OnShow', function()
		if not _G.QuestLogDetailScrollFrame.backdrop then
			_G.QuestLogDetailScrollFrame:CreateBackdrop('Transparent')
		end

		_G.QuestLogDetailScrollFrame.backdrop:Point('TOPLEFT', 0, 2)
		_G.QuestLogDetailScrollFrame.backdrop:Point('BOTTOMRIGHT', 0, -2)
		_G.QuestLogDetailScrollFrame:Point('TOPRIGHT', -32, -76)
		_G.QuestLogDetailScrollFrame:Size(302, 296)

		_G.QuestLogDetailScrollFrameScrollBar:Point('TOPLEFT', _G.QuestLogDetailScrollFrame, 'TOPRIGHT', 5, -12)
	end)

	_G.QuestLogDetailScrollFrame:HookScript('OnShow', function()
		if not _G.QuestLogDetailScrollFrame.backdrop then
			_G.QuestLogDetailScrollFrame:CreateBackdrop('Transparent')
		end
	end)

	_G.QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	_G.QuestLogSkillHighlight:SetAlpha(0.35)

	S:HandleCloseButton(_G.QuestLogFrameCloseButton, _G.QuestLogFrame.backdrop)

	_G.EmptyQuestLogFrame:StripTextures()

	S:HandleScrollBar(_G.QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestLogListScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestRewardScrollFrameScrollBar)

	-- Quest Frame
	local QuestFrame = _G.QuestFrame
	S:HandlePortraitFrame(QuestFrame, true)
	QuestFrame.backdrop:Point('TOPLEFT', 11, -12)
	QuestFrame.backdrop:Point('BOTTOMRIGHT', -22, 0)
	QuestFrame:Width(374)

	_G.QuestFrameDetailPanel:StripTextures(true)
	_G.QuestDetailScrollFrame:StripTextures(true)
	_G.QuestDetailScrollFrame:SetTemplate()
	_G.QuestProgressScrollFrame:SetTemplate()
	_G.QuestGreetingScrollFrame:SetTemplate()

	_G.QuestFrameDetailPanel:StripTextures(true)
	_G.QuestDetailScrollFrame:StripTextures(true)
	_G.QuestDetailScrollFrame:Height(400)
	_G.QuestDetailScrollChildFrame:StripTextures(true)
	_G.QuestRewardScrollFrame:StripTextures(true)
	_G.QuestRewardScrollFrame:Height(400)
	_G.QuestRewardScrollChildFrame:StripTextures(true)
	_G.QuestFrameProgressPanel:StripTextures(true)
	_G.QuestProgressScrollFrame:Height(400)
	_G.QuestProgressScrollFrame:StripTextures()
	_G.QuestFrameRewardPanel:StripTextures(true)

	_G.QuestProgressScrollFrame:CreateBackdrop('Default')
	_G.QuestDetailScrollFrame:CreateBackdrop('Default')

	_G.QuestLogListScrollFrame:CreateBackdrop('Transparent')
	_G.QuestLogListScrollFrame:SetWidth(323)

	_G.QuestNpcNameFrame:Width(300)
	_G.QuestNpcNameFrame:Point('TOPLEFT', QuestFrame.backdrop, 'TOPLEFT', 18, -10)

	S:HandleButton(_G.QuestFrameAcceptButton, true)
	_G.QuestFrameAcceptButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(_G.QuestFrameDeclineButton, true)
	_G.QuestFrameDeclineButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleButton(_G.QuestFrameCompleteButton, true)
	_G.QuestFrameCompleteButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(_G.QuestFrameGoodbyeButton, true)
	_G.QuestFrameGoodbyeButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleButton(_G.QuestFrameCompleteQuestButton, true)
	_G.QuestFrameCompleteQuestButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(_G.QuestFrameCancelButton)
	_G.QuestFrameCancelButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleCloseButton(_G.QuestFrameCloseButton, QuestFrame.backdrop)
	_G.QuestFrameCloseButton:Point('TOPRIGHT', -18, -9)

	hooksecurefunc('QuestFrameProgressItems_Update', function()
		_G.QuestProgressTitleText:SetTextColor(1, .8, .1)
		_G.QuestProgressText:SetTextColor(1, 1, 1)
		_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, 0.1)

		if GetQuestMoneyToGet() > 0 then
			if GetQuestMoneyToGet() > GetMoney() then
				_G.QuestProgressRequiredMoneyText:SetTextColor(.6, .6, .6)
			else
				_G.QuestProgressRequiredMoneyText:SetTextColor(1, .8, .1)
			end
		end

		for i = 1, _G.MAX_REQUIRED_ITEMS do
			local item = _G['QuestProgressItem'..i]
			local name = _G['QuestProgressItem'..i..'Name']
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	for i = 1, _G.QUESTS_DISPLAYED do
		local questLogTitle = _G['QuestLogTitle'..i]

		_G['QuestLogTitle'..i..'Highlight']:SetAlpha(0)

		questLogTitle:SetNormalTexture(E.Media.Textures.PlusButton)
		questLogTitle.SetNormalTexture = E.noop

		questLogTitle:GetNormalTexture():Size(16)
		questLogTitle:GetNormalTexture():Point('LEFT', 5, 0)

		questLogTitle:SetHighlightTexture('')
		questLogTitle.SetHighlightTexture = E.noop

		questLogTitle:Width(344)

		hooksecurefunc(questLogTitle, 'SetNormalTexture', function(self, texture)
			local tex = self:GetNormalTexture()

			if strfind(texture, 'MinusButton') then
				tex:SetTexture(E.Media.Textures.MinusButton)
			elseif strfind(texture, 'PlusButton') then
				tex:SetTexture(E.Media.Textures.PlusButton)
			else
				tex:SetTexture()
			end
		end)
	end

	_G.QuestLogCollapseAllButton:StripTextures()
	_G.QuestLogCollapseAllButton:Point('TOPLEFT', -45, 7)

	_G.QuestLogCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
	_G.QuestLogCollapseAllButton.SetNormalTexture = E.noop
	_G.QuestLogCollapseAllButton:GetNormalTexture():Size(16)

	_G.QuestLogCollapseAllButton:SetHighlightTexture('')
	_G.QuestLogCollapseAllButton.SetHighlightTexture = E.noop

	_G.QuestLogCollapseAllButton:SetDisabledTexture(E.Media.Textures.PlusButton)
	_G.QuestLogCollapseAllButton.SetDisabledTexture = E.noop
	_G.QuestLogCollapseAllButton:GetDisabledTexture():Size(16)
	_G.QuestLogCollapseAllButton:GetDisabledTexture():SetTexture(E.Media.Textures.PlusButton)
	_G.QuestLogCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(_G.QuestLogCollapseAllButton, 'SetNormalTexture', function(self, texture)
		local tex = self:GetNormalTexture()

		if strfind(texture, 'MinusButton') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		else
			tex:SetTexture(E.Media.Textures.PlusButton)
		end
	end)
end

S:AddCallback('Quest', LoadSkin)
