local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local unpack = unpack
local find, format, match = string.find, string.format, string.match
--WoW API / Variables
local GetMoney = GetMoney
local GetQuestMoneyToGet = GetQuestMoneyToGet
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogItemLink = GetQuestLogItemLink
local GetNumQuestLogRewards = GetNumQuestLogRewards
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local hooksecurefunc = hooksecurefunc

local function HandleReward(button)
	if not button then return end

	button:StripTextures()
	button:CreateBackdrop()
	button:StyleButton()
	button:Size(143, 40)
	button:SetFrameLevel(button:GetFrameLevel() + 2)
	button.backdrop:SetInside()

	if button.Icon then
		button.Icon:Size(E.PixelMode and 37 or 32)
		button.Icon:SetDrawLayer('OVERLAY')
		button.Icon:Point('TOPLEFT', E.PixelMode and 2 or 4, -(E.PixelMode and 2 or 4))
		S:HandleIcon(button.Icon)

		button.Count:SetParent(button.backdrop)
		button.Count:SetDrawLayer('OVERLAY')
		button.Count:ClearAllPoints()
		button.Count:Point('BOTTOMRIGHT', button.Icon, 'BOTTOMRIGHT', 2, 0)
	end

	if button.NameFrame then
		button.NameFrame:SetAlpha(0)
	end

	if button.Name then
		button.Name:SetFontObject('GameFontHighlightSmall')
	end

	if button.CircleBackground then
		button.CircleBackground:SetAlpha(0)
		button.CircleBackgroundGlow:SetAlpha(0)
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

	local QuestStrip = {
		'QuestFrame',
		'QuestLogFrame',
		'QuestLogQuestCount',
		'EmptyQuestLogFrame',
		'QuestFrameDetailPanel',
		'QuestDetailScrollFrame',
		'QuestDetailScrollChildFrame',
		'QuestRewardScrollFrame',
		'QuestRewardScrollChildFrame',
		'QuestFrameProgressPanel',
		'QuestFrameRewardPanel',
		'QuestLogListScrollFrame',
		'QuestLogDetailScrollFrame',
		'QuestRewardScrollFrame',
		'QuestProgressScrollFrame'
	}
	for _, object in pairs(QuestStrip) do
		_G[object]:StripTextures(true)
	end

	local QuestButtons = {
		'QuestLogFrameAbandonButton',
		'QuestFrameExitButton',
		'QuestFramePushQuestButton',
		'QuestFrameCompleteButton',
		'QuestFrameGoodbyeButton',
		'QuestFrameCompleteQuestButton',
		'QuestFrameCancelButton',
		'QuestFrameAcceptButton',
		'QuestFrameDeclineButton'
	}
	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	local ScrollBars = {
		'QuestLogDetailScrollFrameScrollBar',
		'QuestDetailScrollFrameScrollBar',
		'QuestLogListScrollFrameScrollBar',
		'QuestProgressScrollFrameScrollBar',
		'QuestRewardScrollFrameScrollBar',
	}
	for _, object in pairs(ScrollBars) do
		S:HandleScrollBar(_G[object])
	end

	for frame, numItems in pairs({['QuestLogItem'] = MAX_NUM_ITEMS, ['QuestProgressItem'] = MAX_REQUIRED_ITEMS, --[[['QuestInfoRewardsFrameQuestInfoItem'] = #_G.QuestInfoRewardsFrame.RewardButtons, ['MapQuestInfoRewardsFrameQuestInfoItem'] = #MapQuestInfoRewardsFrame.RewardButtons--]]}) do
		for i = 1, numItems do
			local button = _G[frame..i]

			if button then
				button:StripTextures()
				button:CreateBackdrop()
				button:StyleButton()
				button:Size(143, 40)
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				button.backdrop:SetInside()
			end

			if button.Icon then
				button.Icon:Size(E.PixelMode and 37 or 32)
				button.Icon:SetDrawLayer('OVERLAY')
				button.Icon:Point('TOPLEFT', E.PixelMode and 2 or 4, -(E.PixelMode and 2 or 4))
				S:HandleIcon(button.Icon)
			end

			if button.Count then
				button.Count:SetParent(button.backdrop)
				button.Count:SetDrawLayer('OVERLAY')
			end
		end
	end

	local function QuestQualityColors(button, text, link)
		if link then
			quality = select(3, GetItemInfo(link))
		end

		if quality and quality > 1 then
			if button and button.backdrop then
				button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
			text:SetTextColor(GetItemQualityColor(quality))
		else
			if button and button.backdrop then
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
			if text then
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	-- Hook for WorldQuestRewards / QuestLogRewards
	hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local RewardButton = rewardsFrame.RewardButtons[index]

		if not RewardButton.backdrop then
			HandleReward(RewardButton)

			RewardButton.IconBorder:SetAlpha(0)
			RewardButton.NameFrame:Hide()

			hooksecurefunc(RewardButton.IconBorder, 'SetVertexColor', function(_, r, g, b) RewardButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
		end
	end)

	hooksecurefunc('QuestInfoItem_OnClick', function(self)
		_G.QuestInfoItemHighlight:Hide()

		if self.type == 'choice' then
			_G[self:GetName()]:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName()].backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName()..'Name']:SetTextColor(1, 0.80, 0.10)

			for _, button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
				local link = button.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(button.type, button:GetID())
				if button ~= self then
					QuestQualityColors(button, button.Name, link)
				end
			end
		end
	end)

	hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local button = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			if button then
				local link = button.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(button.type, button:GetID())
				QuestQualityColors(button, button.Name, link)
			end
		end
	end)

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
			local button = _G['QuestProgressItem'..i]
			if button then
				local link = button.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(button.type, button:GetID())
				QuestQualityColors(button, button.Name, link)
			end
		end
	end)

	hooksecurefunc('QuestLog_UpdateQuestDetails', function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	local textColor = {1, 1, 1}
	local titleTextColor = {1, 0.80, 0.10}
	hooksecurefunc('QuestFrameItems_Update', function(questState)
		-- Headers
		_G.QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		_G.QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))
		_G.QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		-- Other text
		_G.QuestLogItemChooseText:SetTextColor(unpack(textColor))
		_G.QuestLogItemReceiveText:SetTextColor(unpack(textColor))
		_G.QuestLogObjectivesText:SetTextColor(unpack(textColor))
		_G.QuestLogQuestDescription:SetTextColor(unpack(textColor))
		_G.QuestLogSpellLearnText:SetTextColor(unpack(textColor))

		if GetQuestLogRequiredMoney() > 0 then
			if GetQuestLogRequiredMoney() > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		_G.QuestLogItem1:Point('TOPLEFT', _G.QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

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

		local numQuestRewards, numQuestChoices
		if questState == 'QuestLog' then
			numQuestRewards, numQuestChoices = GetNumQuestLogRewards(), GetNumQuestLogChoices()
		else
			numQuestRewards, numQuestChoices = GetNumQuestRewards(), GetNumQuestChoices()
		end

		local rewardsCount = numQuestChoices + numQuestRewards
		if rewardsCount > 0 then
			local button, name, link
			local questItemName = questState..'Item'

			for i = 1, rewardsCount do
				button = _G[questItemName..i]
				if button then
					link = button.type and (questState == 'QuestLog' and GetQuestLogItemLink or GetQuestItemLink)(button.type, button:GetID())
					QuestQualityColors(button, button.Name, link)
				end
			end
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

		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local button = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			if button then
				local link = button.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(button.type, button:GetID())
				QuestQualityColors(button, button.Name, link)
			end
		end
	end)

	for i = 1, MAX_NUM_QUESTS do
		_G['QuestTitleButton'..i..'QuestIcon']:SetPoint('TOPLEFT', 4, 2)
		_G['QuestTitleButton'..i..'QuestIcon']:SetSize(16, 16)
	end

	local function UpdateGreetingFrame()
		local i = 1
		while _G['QuestTitleButton'..i]:IsVisible() do
			local title = _G['QuestTitleButton'..i]
			local icon = _G['QuestTitleButton'..i..'QuestIcon']
			local text = title:GetFontString()
			local textString = gsub(title:GetText(), '|c[Ff][Ff]%x%x%x%x%x%x(.+)|r', '%1')

			title:SetText(textString)

			if title.isActive == 1 then
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
	end

	_G.QuestFrameGreetingPanel:HookScript('OnShow', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

	_G.QuestLogTimerText:SetTextColor(1, 1, 1)

	_G.QuestFrame:CreateBackdrop('Transparent')
	_G.QuestFrame.backdrop:Point('TOPLEFT', 11, -12)
	_G.QuestFrame.backdrop:Point('BOTTOMRIGHT', -32, 0)

	_G.QuestLogFrame:CreateBackdrop('Transparent')
	_G.QuestLogFrame.backdrop:Point('TOPLEFT', 11, -12)
	_G.QuestLogFrame.backdrop:Point('BOTTOMRIGHT', -32, 0)

	_G.QuestLogListScrollFrame:CreateBackdrop('Transparent')
	_G.QuestLogListScrollFrame.backdrop:Point('TOPLEFT', -1, 2)
	_G.QuestLogListScrollFrame:Width(303)

	_G.QuestLogDetailScrollFrame:CreateBackdrop('Transparent')
	_G.QuestLogDetailScrollFrame.backdrop:Point('TOPLEFT', -1, 2)
	_G.QuestLogDetailScrollFrame:Size(303)

	_G.QuestDetailScrollFrame:CreateBackdrop('Transparent')
	_G.QuestDetailScrollFrame.backdrop:Point('TOPLEFT', -6, 2)
	_G.QuestDetailScrollFrame:Size(300, 396)

	_G.QuestRewardScrollFrame:CreateBackdrop('Transparent')
	_G.QuestRewardScrollFrame.backdrop:Point('TOPLEFT', -6, 2)
	_G.QuestRewardScrollFrame:Size(300, 396)

	_G.QuestProgressScrollFrame:CreateBackdrop('Transparent')
	_G.QuestProgressScrollFrame.backdrop:Point('TOPLEFT', -6, 2)
	_G.QuestProgressScrollFrame:Size(300, 396)

	_G.QuestLogNoQuestsText:ClearAllPoints()
	_G.QuestLogNoQuestsText:Point('CENTER', EmptyQuestLogFrame, 'CENTER', -45, 65)

	_G.QuestLogFrameAbandonButton:Point('BOTTOMLEFT', 18, 7)
	_G.QuestLogFrameAbandonButton:Width(107)
	_G.QuestLogFrameAbandonButton:SetText(ABANDON_QUEST_ABBREV)

	_G.QuestFramePushQuestButton:ClearAllPoints()
	_G.QuestFramePushQuestButton:Point('LEFT', QuestLogFrameAbandonButton, 'RIGHT', 4, 0)
	_G.QuestFramePushQuestButton:Width(106)
	_G.QuestFramePushQuestButton:SetText(SHARE_QUEST_ABBREV)

	_G.QuestFrameExitButton:Point('BOTTOMRIGHT', -38, 7)
	_G.QuestFrameExitButton:Width(107)

	_G.QuestFrameAcceptButton:Point('BOTTOMLEFT', 18, 7)
	_G.QuestFrameDeclineButton:Point('BOTTOMRIGHT', -38, 7)
	_G.QuestFrameCompleteButton:Point('BOTTOMLEFT', 18, 7)
	_G.QuestFrameGoodbyeButton:Point('BOTTOMRIGHT', -38, 7)
	_G.QuestFrameCompleteQuestButton:Point('BOTTOMLEFT', 18, 7)
	_G.QuestFrameCancelButton:Point('BOTTOMRIGHT', -38, 7)

	_G.QuestLogSkillHighlight:StripTextures()

	local QuestLogHighlightFrame = _G.QuestLogHighlightFrame
	QuestLogHighlightFrame:Width(300)
	QuestLogHighlightFrame.SetWidth = E.noop

	QuestLogHighlightFrame.Left = QuestLogHighlightFrame:CreateTexture(nil, 'ARTWORK')
	QuestLogHighlightFrame.Left:Size(152, 15)
	QuestLogHighlightFrame.Left:SetPoint('LEFT', QuestLogHighlightFrame, 'CENTER')
	QuestLogHighlightFrame.Left:SetTexture(E.media.blankTex)

	QuestLogHighlightFrame.Right = QuestLogHighlightFrame:CreateTexture(nil, 'ARTWORK')
	QuestLogHighlightFrame.Right:Size(152, 15)
	QuestLogHighlightFrame.Right:SetPoint('RIGHT', QuestLogHighlightFrame, 'CENTER')
	QuestLogHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc(QuestLogSkillHighlight, 'SetVertexColor', function(_, r, g, b)
		QuestLogHighlightFrame.Left:SetGradientAlpha('Horizontal', r, g, b, 0.35, r, g, b, 0)
		QuestLogHighlightFrame.Right:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.35)
	end)

	_G.QuestFrameNpcNameText:Point('CENTER', _G.QuestNpcNameFrame, 'CENTER', -1, 0)

	S:HandleCloseButton(_G.QuestFrameCloseButton, _G.QuestFrame.backdrop)
	_G.QuestFrameCloseButton:Point('TOPRIGHT', -28, -9)

	S:HandleCloseButton(_G.QuestLogFrameCloseButton, _G.QuestLogFrame.backdrop)
	_G.QuestLogFrameCloseButton:Point('TOPRIGHT', -28, -9)

	for i = 1, _G.QUESTS_DISPLAYED do
		local questLogTitle = _G['QuestLogTitle'..i]

		questLogTitle:SetNormalTexture(E.Media.Textures.PlusButton)
		questLogTitle.SetNormalTexture = E.noop

		questLogTitle:GetNormalTexture():Size(16)
		questLogTitle:GetNormalTexture():Point('LEFT', 5, 0)

		questLogTitle:SetHighlightTexture('')
		questLogTitle.SetHighlightTexture = E.noop

		questLogTitle:Width(300)

		_G['QuestLogTitle'..i..'Highlight']:SetAlpha(0)

		_G['QuestLogTitle'..i..'Tag']:Point('RIGHT', -30, 0)

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

	local QuestLogCollapseAllButton = _G.QuestLogCollapseAllButton
	QuestLogCollapseAllButton:StripTextures()
	QuestLogCollapseAllButton:Point('TOPLEFT', -45, 7)

	QuestLogCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton.SetNormalTexture = E.noop
	QuestLogCollapseAllButton:GetNormalTexture():Size(16)

	QuestLogCollapseAllButton:SetHighlightTexture('')
	QuestLogCollapseAllButton.SetHighlightTexture = E.noop

	QuestLogCollapseAllButton:SetDisabledTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton.SetDisabledTexture = E.noop
	QuestLogCollapseAllButton:GetDisabledTexture():Size(16)
	QuestLogCollapseAllButton:GetDisabledTexture():SetTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

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