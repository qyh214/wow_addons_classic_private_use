local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local gsub, type, pairs, ipairs, select, unpack, strstrfind = gsub, type, pairs, ipairs, select, unpack, strstrfind
--WoW API / Variables
local GetMoney = GetMoney
local CreateFrame = CreateFrame
local GetQuestID = GetQuestID
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogRewardSpells = GetNumQuestLogRewardSpells
local GetNumRewardSpells = GetNumRewardSpells
local GetQuestLogSelection = GetQuestLogSelection
local hooksecurefunc = hooksecurefunc

local function HandleReward(frame)
	if (not frame) then return end

	if frame.Icon then
		S:HandleIcon(frame.Icon, true)

		frame.Count:ClearAllPoints()
		frame.Count:Point("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:SetFontObject("GameFontHighlightSmall")
	end

	if (frame.CircleBackground) then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end
end


local function StyleScrollFrame(scrollFrame, widthOverride, heightOverride, inset)
	scrollFrame:SetTemplate()
	if not scrollFrame.spellTex then
		scrollFrame.spellTex = scrollFrame:CreateTexture(nil, 'BACKGROUND', 1)
	end

	scrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	if inset then
		scrollFrame.spellTex:Point("TOPLEFT", 1, -1)
	else
		scrollFrame.spellTex:Point("TOPLEFT")
	end
	scrollFrame.spellTex:Size(widthOverride or 506, heightOverride or 615)
	scrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
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

	for frame, numItems in pairs({['QuestLogItem'] = MAX_NUM_ITEMS, ['QuestProgressItem'] = MAX_REQUIRED_ITEMS}) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i..'IconTexture']

			item:StripTextures()
			item:SetTemplate('Default')
			item:StyleButton()
			item:Size(143, 40)
			item:SetFrameLevel(item:GetFrameLevel() + 2)

			icon:Size(E.PixelMode and 38 or 32)
			icon:SetDrawLayer('OVERLAY')
			icon:Point('TOPLEFT', E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
			S:HandleIcon(icon)
		end
	end

	local QuestInfoItemHighlight = _G.QuestInfoItemHighlight
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate(nil, nil, true)
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc('QuestInfoItem_OnClick', function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(self.Icon)

		for _, Button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
			Button.Name:SetTextColor(1, 1, 1)
		end

		self.Name:SetTextColor(1, .8, .1)
	end)

	_G.QuestRewardScrollFrame:CreateBackdrop()
	_G.QuestRewardScrollFrame:Height(_G.QuestRewardScrollFrame:GetHeight() - 2)

	S:HandleButton(QuestLogFrameAbandonButton)
	QuestLogFrameAbandonButton:Point('BOTTOMLEFT', 14, 14)

	S:HandleButton(QuestFramePushQuestButton)
	QuestFramePushQuestButton:Point('LEFT', QuestLogFrameAbandonButton, 'RIGHT', 2, 0)

	S:HandleButton(QuestFrameExitButton)
	QuestFrameExitButton:Point('BOTTOMRIGHT', -9, 14)

	hooksecurefunc(_G, 'QuestLog_UpdateQuestDetails', function()
		_G.QuestLogQuestTitle:SetTextColor(1, .8, .1)
		_G.QuestLogObjectivesText:SetTextColor(1, 1, 1)

		_G.QuestLogDescriptionTitle:SetTextColor(1, .8, .1)
		_G.QuestLogQuestDescription:SetTextColor(1, 1, 1)

		_G.QuestLogRewardTitleText:SetTextColor(1, .8, .1)

		_G.QuestLogItemChooseText:SetTextColor(1, 1, 1)
		_G.QuestLogSpellLearnText:SetTextColor(1, 1, 1)

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

		if QuestLogRequiredMoneyText:GetTextColor() == 0 then
			QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
		else
			QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
		end
	end)

	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local _, type, finished
		local numVisibleObjectives = 0
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i)
			if type ~= "spell" then
				numVisibleObjectives = numVisibleObjectives + 1
				objective = _G["QuestInfoObjective"..numVisibleObjectives]
				if finished then
					objective:SetTextColor(1, 0.80, 0.10)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc('QuestInfo_Display', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local questItem = _G.QuestInfoRewardsFrame.RewardButtons[i]
			print(questItem)
			if not questItem:IsShown() then break end

			local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
			if point and relativeTo and relativePoint then
				if i == 1 then
					questItem:Point(point, relativeTo, relativePoint, 0, y)
				elseif relativePoint == "BOTTOMLEFT" then
					questItem:Point(point, relativeTo, relativePoint, 0, -4)
				else
					questItem:Point(point, relativeTo, relativePoint, 4, 0)
				end
			end

			questItem.Name:SetTextColor(1, 1, 1)
		end

		local rewardsFrame = _G.QuestInfoFrame.rewardsFrame
		local isQuestLog = _G.QuestInfoFrame.questLog ~= nil

		local textColor = {1, 1, 1}
		local titleTextColor = {1, 0.80, 0.10}
		-- headers
		QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoRewardsFrame.Header:SetTextColor(unpack(titleTextColor))
		-- other text
		QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		QuestInfoGroupSize:SetTextColor(unpack(textColor))
		QuestInfoRewardText:SetTextColor(unpack(textColor))
		-- reward frame text
		QuestInfoRewardsFrame.ItemChooseText:SetTextColor(unpack(textColor))
		QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(unpack(textColor))
		QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(unpack(textColor))
		QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(unpack(textColor))

		QuestInfoRewardsFrame.spellHeaderPool.textR, QuestInfoRewardsFrame.spellHeaderPool.textG, QuestInfoRewardsFrame.spellHeaderPool.textB = unpack(textColor)

		local questID = Quest_GetQuestID()
		local numObjectives = GetNumQuestLeaderBoards()
		local numVisibleObjectives = 0

		for i = 1, numObjectives do
			local _, _, finished = GetQuestLogLeaderBoard(i)
			if (type ~= "spell" and type ~= "log" and numVisibleObjectives < _G.MAX_OBJECTIVES) then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G['QuestInfoObjective'..numVisibleObjectives]
				if objective then
					if finished then
						objective:SetTextColor(1, .8, .1)
					else
						objective:SetTextColor(.63, .09, .09)
					end
				end
			end
		end
	end)

	local Rewards = { 'MoneyFrame', 'HonorFrame', 'XPFrame', 'SpellFrame', 'SkillPointFrame' }

	for _, frame in pairs(Rewards) do
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
	--Reward: Title
	local QuestInfoPlayerTitleFrame = _G.QuestInfoPlayerTitleFrame
	QuestInfoPlayerTitleFrame.FrameLeft:SetTexture()
	QuestInfoPlayerTitleFrame.FrameCenter:SetTexture()
	QuestInfoPlayerTitleFrame.FrameRight:SetTexture()
	QuestInfoPlayerTitleFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	QuestInfoPlayerTitleFrame:CreateBackdrop()
	QuestInfoPlayerTitleFrame.backdrop:SetOutside(QuestInfoPlayerTitleFrame.Icon)



	QuestLogTimerText:SetTextColor(1, 1, 1)

	QuestInfoTimerText:SetTextColor(1, 1, 1)
	QuestInfoAnchor:SetTextColor(1, 1, 1)

	QuestLogDetailScrollFrame:StripTextures()

	QuestLogFrame:HookScript('OnShow', function()
		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop('Transparent')
		end

		QuestLogDetailScrollFrame.backdrop:Point('TOPLEFT', 0, 2)
		QuestLogDetailScrollFrame.backdrop:Point('BOTTOMRIGHT', 0, -2)
		QuestLogDetailScrollFrame:Point('TOPRIGHT', -32, -76)
		QuestLogDetailScrollFrame:Size(302, 296)

		QuestLogDetailScrollFrameScrollBar:Point('TOPLEFT', QuestLogDetailScrollFrame, 'TOPRIGHT', 5, -12)
	end)

	QuestLogDetailScrollFrame:HookScript('OnShow', function()
		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop('Transparent')
		end
	end)

	QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	QuestLogSkillHighlight:SetAlpha(0.35)

	S:HandleCloseButton(QuestLogFrameCloseButton, QuestLogFrame.backdrop)

	EmptyQuestLogFrame:StripTextures()

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	-- Quest Frame
	local QuestFrame = _G.QuestFrame
	S:HandlePortraitFrame(QuestFrame, true)
	QuestFrame.backdrop:Point('TOPLEFT', 15, -11)
	QuestFrame.backdrop:Point('BOTTOMRIGHT', -20, 0)
	QuestFrame:Width(374)

	_G.QuestFrameDetailPanel:StripTextures(true)
	_G.QuestDetailScrollFrame:StripTextures(true)
	_G.QuestDetailScrollFrame:SetTemplate()
	_G.QuestProgressScrollFrame:SetTemplate()
	_G.QuestGreetingScrollFrame:SetTemplate()

	local function UpdateGreetingFrame()
		for Button in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
			Button.Icon:SetDrawLayer("ARTWORK")
			if E.private.skins.parchmentRemover.enable then
				local Text = Button:GetFontString():GetText()
				if Text and strfind(Text, '|cff000000') then
					Button:GetFontString():SetText(gsub(Text, '|cff000000', '|cffffe519'))
				end
			end
		end
	end


	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollFrame:Height(400)
	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollFrame:Height(400)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestProgressScrollFrame:Height(400)
	QuestProgressScrollFrame:StripTextures()
	QuestFrameRewardPanel:StripTextures(true)

	QuestNpcNameFrame:Width(300)
	QuestNpcNameFrame:Point("TOPLEFT", QuestFrame.backdrop, "TOPLEFT", 18, -10)

	S:HandleButton(QuestFrameAcceptButton, true)
	QuestFrameAcceptButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(QuestFrameDeclineButton, true)
	QuestFrameDeclineButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleButton(QuestFrameCompleteButton, true)
	QuestFrameCompleteButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(QuestFrameGoodbyeButton, true)
	QuestFrameGoodbyeButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleButton(QuestFrameCompleteQuestButton, true)
	QuestFrameCompleteQuestButton:Point('BOTTOMLEFT', 20, 4)

	S:HandleButton(QuestFrameCancelButton)
	QuestFrameCancelButton:Point('BOTTOMRIGHT', -37, 4)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	hooksecurefunc('QuestFrameProgressItems_Update', function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		if GetQuestMoneyToGet() > 0 then
			if GetQuestMoneyToGet() > GetMoney() then
				QuestProgressRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestProgressRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, MAX_REQUIRED_ITEMS do
			local item = _G['QuestProgressItem'..i]
			local name = _G['QuestProgressItem'..i..'Name']
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	for i = 1, QUESTS_DISPLAYED do
		local questLogTitle = _G['QuestLogTitle'..i]

		_G['QuestLogTitle'..i..'Highlight']:SetAlpha(0)

		questLogTitle:SetNormalTexture(E.Media.Textures.PlusButton)
		questLogTitle.SetNormalTexture = E.noop

		questLogTitle:GetNormalTexture():Size(16)
		questLogTitle:GetNormalTexture():Point('LEFT', 5, 0)

		questLogTitle:SetHighlightTexture('')
		questLogTitle.SetHighlightTexture = E.noop

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

	hooksecurefunc(QuestLogCollapseAllButton, 'SetNormalTexture', function(self, texture)
		local tex = self:GetNormalTexture()

		if strfind(texture, 'MinusButton') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		else
			tex:SetTexture(E.Media.Textures.PlusButton)
		end
	end)
end

S:AddCallback('Quest', LoadSkin)
