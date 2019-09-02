local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetGuildRosterInfo = GetGuildRosterInfo
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local localizedTable = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	localizedTable[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	localizedTable[v] = k
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	-- Friends Frame
	local FriendsFrame = _G.FriendsFrame
	S:HandlePortraitFrame(FriendsFrame, true)
	FriendsFrame.backdrop:Point('TOPLEFT', -5, 0)
	FriendsFrame.backdrop:Point('BOTTOMRIGHT', -2, 0)

	_G.FriendsFrameCloseButton:Point("TOPRIGHT", 2, 3)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:GetRegions():Hide()

	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame.Tag:SetParent(_G.FriendsListFrame)
	FriendsFrameBattlenetFrame.Tag:Point("TOP", FriendsFrame, "TOP", 0, -8)

	_G.FriendsFrameBroadcastInput:CreateBackdrop()
	_G.FriendsFrameBroadcastInput:Width(250)
	_G.FriendsFrameBroadcastInput:Point("TOPLEFT", 22, -32)
	_G.FriendsFrameBroadcastInput:Point("TOPRIGHT", -10, -32)

	_G.FriendsFrameBroadcastInputLeft:Kill()
	_G.FriendsFrameBroadcastInputRight:Kill()
	_G.FriendsFrameBroadcastInputMiddle:Kill()

	hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
		if BNFeaturesEnabled() then
			local frame = FriendsFrameBattlenetFrame

			frame.BroadcastButton:Hide()

			if BNConnected() then
				frame:Hide()
				_G.FriendsFrameBroadcastInput:Show()
				FriendsFrameBroadcastInput_UpdateDisplay()
			end
		end
	end)
	FriendsFrame_CheckBattlenetStatus()

	hooksecurefunc("FriendsFrame_Update", function()
		if FriendsFrame.selectedTab == 1 and _G.FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
			_G.FriendsFrameTitleText:Hide()
		else
			_G.FriendsFrameTitleText:Show()
		end
	end)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate("Transparent")
	_G.ScrollOfResurrectionSelectionFrame:SetTemplate('Transparent')
	_G.ScrollOfResurrectionSelectionFrameList:SetTemplate()
	S:HandleScrollBar(_G.ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)
	S:HandleEditBox(_G.ScrollOfResurrectionSelectionFrameTargetEditBox)
	RaiseFrameLevel(_G.ScrollOfResurrectionSelectionFrameTargetEditBox)

	--Pending invites
	S:HandleButton(_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton)
	hooksecurefunc(_G.FriendsFrameFriendsScrollFrame.invitePool, "Acquire", function()
		for object in pairs(_G.FriendsFrameFriendsScrollFrame.invitePool.activeObjects) do
			SkinFriendRequest(object)
		end
	end)

	for i = 1, 5 do
		S:HandleTab(_G['FriendsFrameTab'..i])
	end

	-- Friends List Frame
	for i = 1, 2 do
		local tab = _G['FriendsTabHeaderTab'..i]
		tab:StripTextures()
		tab:CreateBackdrop('Default', true)
		tab.backdrop:Point('TOPLEFT', 3, -7)
		tab.backdrop:Point('BOTTOMRIGHT', -2, -1)

		tab:SetScript('OnEnter', S.SetModifiedBackdrop)
		tab:SetScript('OnLeave', S.SetOriginalBackdrop)
	end

	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY do
		S:HandleButtonHighlight(_G['FriendsFriendsButton'..i])
	end

	_G.FriendsFrameFriendsScrollFrame:StripTextures()
	S:HandleScrollBar(_G.FriendsFrameFriendsScrollFrameScrollBar)

	S:HandleButton(_G.FriendsFrameAddFriendButton)
	S:HandleButton(_G.FriendsFrameSendMessageButton)
	S:HandleButton(_G.FriendsFrameUnsquelchButton)

	S:HandleDropDownBox(_G.FriendsFrameStatusDropDown)
	_G.FriendsFrameStatusDropDown:Point('TOPLEFT', -12, 0)

	-- Ignore List
	_G.IgnoreListFrame:StripTextures()

	S:HandleButton(_G.FriendsFrameIgnorePlayerButton)

	_G.FriendsFrameIgnoreButton1:Point("TOPLEFT", 10, -89)
	_G.FriendsFrameUnsquelchButton:Point("RIGHT", -6, 0)
	_G.FriendsFrameUnsquelchButton:Width(131)
	_G.FriendsFrameUnsquelchButton.SetWidth = E.noop

	S:HandleScrollBar(_G.FriendsFrameIgnoreScrollFrameScrollBar)

	for i = 1, 19 do
		local button = _G["FriendsFrameIgnoreButton"..i]

		button:Width(298)
		S:HandleButtonHighlight(button)

		button.stripe = button:CreateTexture(nil, "OVERLAY")
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame")
		if i % 2 == 1 then
			button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998)
		else
			button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921)
		end
		button.stripe:SetAllPoints()
	end

	-- Who Frame
	WhoFrameListInset:StripTextures()
	WhoFrameEditBoxInset:StripTextures()
	WhoListScrollFrame:StripTextures()

	for i = 1, 4 do
		_G['WhoFrameColumnHeader'..i]:StripTextures()
		_G['WhoFrameColumnHeader'..i]:StyleButton()
		_G['WhoFrameColumnHeader'..i]:ClearAllPoints()
	end

	WhoFrameColumnHeader1:Point('LEFT', WhoFrameColumnHeader4, 'RIGHT', -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader1, 105)
	WhoFrameColumnHeader2:Point('LEFT', WhoFrameColumnHeader1, 'RIGHT', -5, 0)
	WhoFrameColumnHeader3:Point('TOPLEFT', WhoFrame, 'TOPLEFT', 8, -57)
	WhoFrameColumnHeader4:Point('LEFT', WhoFrameColumnHeader3, 'RIGHT', -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader4, 50)

	WhoFrameButton1:Point('TOPLEFT', 10, -82)

	S:HandleEditBox(WhoFrameEditBox)
	WhoFrameEditBox:Point('BOTTOM', -1, 29)
	WhoFrameEditBox:Size(326, 18)

	S:HandleButton(WhoFrameWhoButton)
	WhoFrameWhoButton:Point('RIGHT', WhoFrameAddFriendButton, 'LEFT', -2, 0)
	WhoFrameWhoButton:Width(84)

	S:HandleButton(WhoFrameAddFriendButton)
	WhoFrameAddFriendButton:Point('RIGHT', WhoFrameGroupInviteButton, 'LEFT', -2, 0)

	S:HandleButton(WhoFrameGroupInviteButton)
	WhoFrameGroupInviteButton:Point('BOTTOMRIGHT', -6, 4)

	S:HandleDropDownBox(WhoFrameDropDown)
	WhoFrameDropDown:Point('TOPLEFT', -6, 4)

	S:HandleScrollBar(WhoListScrollFrameScrollBar, 5)
	WhoListScrollFrameScrollBar:ClearAllPoints()
	WhoListScrollFrameScrollBar:Point('TOPRIGHT', WhoListScrollFrame, 'TOPRIGHT', 26, -13)
	WhoListScrollFrameScrollBar:Point('BOTTOMRIGHT', WhoListScrollFrame, 'BOTTOMRIGHT', 0, 18)

	for i = 1, _G.WHOS_TO_DISPLAY do
		local button = _G['WhoFrameButton'..i]
		local level = _G['WhoFrameButton' .. i .. 'Level']
		local name = _G['WhoFrameButton' .. i .. 'Name']

		button.icon = button:CreateTexture('$parentIcon', 'ARTWORK')
		button.icon:Point('LEFT', 45, 0)
		button.icon:Size(14)
		button.icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])

		button:CreateBackdrop('Default', true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		button.stripe = button:CreateTexture(nil, "BACKGROUND")
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame")
		button.stripe:SetInside()

		level:ClearAllPoints()
		if i == 1 then
			level:Point('TOPLEFT', 11, -2)
		else
			level:Point('TOPLEFT', 12, -2)
		end

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point('LEFT', 85, 0)

		_G['WhoFrameButton'..i..'Class']:Hide()
	end

	hooksecurefunc('WhoList_Update', function()
		local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
		local button, nameText, levelText, classText, variableText
		local info, guild, level, race, zone, classFileName
		local classTextColor, levelTextColor
		local index, columnTable

		local playerZone = GetRealZoneText()
		local playerGuild = GetGuildInfo("player")
		local playerRace = UnitRace("player")

		for i = 1, WHOS_TO_DISPLAY, 1 do
			index = whoOffset + i
			button = _G["WhoFrameButton"..i]
			nameText = _G["WhoFrameButton"..i.."Name"]
			levelText = _G["WhoFrameButton"..i.."Level"]
			classText = _G["WhoFrameButton"..i.."Class"]
			variableText = _G["WhoFrameButton"..i.."Variable"]

			info = C_FriendList.GetWhoInfo(index)

			if info then

				guild, level, race, zone, classFileName = info.fullGuildName, info.level, info.raceStr, info.filename

				classFileName = localizedTable[classFileName]
				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[info.filename] or RAID_CLASS_COLORS[info.filename]
				levelTextColor = GetQuestDifficultyColor(info.level)

				if info.filename then
					button.icon:Show()
					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[info.filename]))

					nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
					levelText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

					if zone == playerZone then zone = '|cff00ff00'..info.area end
					if guild == playerGuild then guild = '|cff00ff00'..info.fullGuildName end
					if race == E.myrace then race = '|cff00ff00'..info.raceStr end

					columnTable = {info.area, info.fullGuildName, info.raceStr}

					variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
				else
					button.icon:Hide()
				end

				if (i + whoOffset) % 2 == 1 then
					button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998)
				else
					button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921)
				end
			end
		end
	end)

	-- Guild Frame
	GuildFrame:StripTextures()

	GuildFrameColumnHeader3:ClearAllPoints()
	GuildFrameColumnHeader3:Point("TOPLEFT", 8, -57)

	GuildFrameColumnHeader4:ClearAllPoints()
	GuildFrameColumnHeader4:Point("LEFT", GuildFrameColumnHeader3, "RIGHT", -2, -0)
	GuildFrameColumnHeader4:Width(50)

	GuildFrameColumnHeader1:ClearAllPoints()
	GuildFrameColumnHeader1:Point("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, -0)
	GuildFrameColumnHeader1:Width(105)

	GuildFrameColumnHeader2:ClearAllPoints()
	GuildFrameColumnHeader2:Point("LEFT", GuildFrameColumnHeader1, "RIGHT", -2, -0)
	GuildFrameColumnHeader2:Width(127)

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = _G["GuildFrameButton"..i]
		local statusButton = _G["GuildFrameGuildStatusButton"..i]
		local name = _G["GuildFrameButton"..i.."Name"]
		local level = _G["GuildFrameButton"..i.."Level"]

		button:Width(330)
		statusButton:Width(330)

		button.icon = button:CreateTexture('$parentIcon', 'ARTWORK')
		button.icon:Point('LEFT', 45, 0)
		button.icon:Size(14)
		button.icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])

		button:CreateBackdrop('Default', true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		if i == 1 then
			level:Point('TOPLEFT', 11, -2)
		else
			level:Point('TOPLEFT', 12, -2)
		end

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point('LEFT', 85, 0)

		_G["GuildFrameButton"..i.."Class"]:Hide()

		S:HandleButtonHighlight(_G["GuildFrameGuildStatusButton"..i])

		_G["GuildFrameGuildStatusButton"..i.."Name"]:Point("TOPLEFT", 14, 0)
	end

	hooksecurefunc("GuildStatus_Update", function()
		local _, level, class, zone, online, classFileName
		local button, buttonText, classTextColor, levelTextColor
		local playerZone = GetRealZoneText()

		if FriendsFrame.playerStatusFrame then
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameButton"..i]
				_, _, _, level, class, zone, _, _, online = GetGuildRosterInfo(button.guildIndex)

				classFileName = localizedTable[class]
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						levelTextColor = GetQuestDifficultyColor(level)

						buttonText = _G["GuildFrameButton"..i.."Name"]
						buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						buttonText = _G["GuildFrameButton"..i.."Level"]
						buttonText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
						buttonText = _G["GuildFrameButton"..i.."Zone"]

						if zone == playerZone then
							buttonText:SetTextColor(0, 1, 0)
						end
					end

					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				end
			end
		else
			for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
				button = _G["GuildFrameGuildStatusButton"..i]
				_, _, _, _, class, _, _, _, online = GetGuildRosterInfo(button.guildIndex)

				classFileName = localizedTable[class]
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(1.0, 1.0, 1.0)
					end
				end
			end
		end
	end)

	GuildFrameLFGFrame:StripTextures()
	GuildFrameLFGFrame:SetTemplate("Transparent")

	S:HandleCheckBox(GuildFrameLFGButton)

	for i = 1, 4 do
		_G["GuildFrameColumnHeader"..i]:StripTextures()
		_G["GuildFrameColumnHeader"..i]:StyleButton()
		_G["GuildFrameGuildStatusColumnHeader"..i]:StripTextures()
		_G["GuildFrameGuildStatusColumnHeader"..i]:StyleButton()
	end

	GuildListScrollFrame:StripTextures()
	S:HandleScrollBar(GuildListScrollFrameScrollBar)

	S:HandleNextPrevButton(GuildFrameGuildListToggleButton)

	S:HandleButton(GuildFrameGuildInformationButton)
	S:HandleButton(GuildFrameAddMemberButton)
	S:HandleButton(GuildFrameControlButton)

	-- Member Detail Frame
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:CreateBackdrop("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 3, -1)

	S:HandleCloseButton(GuildMemberDetailCloseButton, GuildMemberDetailFrame.backdrop)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:Point("BOTTOMLEFT", 3, 3)

	S:HandleButton(GuildMemberGroupInviteButton)
	GuildMemberGroupInviteButton:Point("LEFT", GuildMemberRemoveButton, "RIGHT", 13, 0)

	S:HandleNextPrevButton(GuildFramePromoteButton)
	GuildFramePromoteButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(GuildFrameDemoteButton)
	GuildFrameDemoteButton:SetHitRectInsets(0, 0, 0, 0)
	GuildFrameDemoteButton:Point("LEFT", GuildFramePromoteButton, "RIGHT", 2, 0)

	GuildMemberNoteBackground:StripTextures()
	GuildMemberNoteBackground:CreateBackdrop("Default")
	GuildMemberNoteBackground.backdrop:Point("TOPLEFT", 0, -2)
	GuildMemberNoteBackground.backdrop:Point("BOTTOMRIGHT", 0, -1)

	GuildMemberOfficerNoteBackground:StripTextures()
	GuildMemberOfficerNoteBackground:CreateBackdrop("Default")
	GuildMemberOfficerNoteBackground.backdrop:Point("TOPLEFT", 0, -2)
	GuildMemberOfficerNoteBackground.backdrop:Point("BOTTOMRIGHT", 0, -1)

	GuildFrameNotesLabel:Point("TOPLEFT", GuildFrame, "TOPLEFT", 23, -340)
	GuildFrameNotesText:Point("TOPLEFT", GuildFrameNotesLabel, "BOTTOMLEFT", 0, -6)

	GuildFrameBarLeft:StripTextures()

	GuildMOTDEditButton:CreateBackdrop("Default")
	GuildMOTDEditButton.backdrop:Point("TOPLEFT", -7, 3)
	GuildMOTDEditButton.backdrop:Point("BOTTOMRIGHT", 7, 7)
	GuildMOTDEditButton:SetHitRectInsets(-7, -7, -3, 7)
	GuildMOTDEditButton:Width(290)
	GuildFrameNotesText:Width(290)

	-- Info Frame
	GuildInfoFrame:StripTextures()
	GuildInfoFrame:CreateBackdrop("Transparent")
	GuildInfoFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -1, 6)
	GuildInfoFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildInfoFrame.backdrop:Point("BOTTOMRIGHT", -2, 3)

	GuildInfoTextBackground:SetTemplate("Default")
	S:HandleScrollBar(GuildInfoFrameScrollFrameScrollBar)

	S:HandleCloseButton(GuildInfoCloseButton)

	S:HandleButton(GuildInfoSaveButton)
	GuildInfoSaveButton:Point("BOTTOMLEFT", 8, 11)

	S:HandleButton(GuildInfoCancelButton)
	GuildInfoCancelButton:Point("LEFT", GuildInfoSaveButton, "RIGHT", 3, 0)

	-- Control Frame
	GuildControlPopupFrame:StripTextures()
	GuildControlPopupFrame:CreateBackdrop("Transparent")
	GuildControlPopupFrame.backdrop:Point("TOPLEFT", 3, 0)

	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185)
	GuildControlPopupFrameDropDownButton:Size(18)

	local function SkinPlusMinus(button, minus)
		local texture = E.Media.Textures.PlusButton
		if minus then
			texture = E.Media.Textures.MinusButton
		end

		button:SetNormalTexture(texture)
		button.SetNormalTexture = E.noop

		button:SetPushedTexture(texture)
		button.SetPushedTexture = E.noop

		button:SetHighlightTexture("")
		button.SetHighlightTexture = E.noop

		button:SetDisabledTexture(texture)
		button.SetDisabledTexture = E.noop
		button:GetDisabledTexture():SetDesaturated(true)
	end

	SkinPlusMinus(GuildControlPopupFrameAddRankButton)
	GuildControlPopupFrameAddRankButton:Point("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -8, 3)

	SkinPlusMinus(GuildControlPopupFrameRemoveRankButton, true)
	GuildControlPopupFrameRemoveRankButton:Point("LEFT", GuildControlPopupFrameAddRankButton, "RIGHT", 4, 0)


	local left, right = select(2, GuildControlPopupFrameEditBox:GetRegions())
	left:Kill() right:Kill()

	S:HandleEditBox(GuildControlPopupFrameEditBox)
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, 17 do
		local checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end

	S:HandleButton(GuildControlPopupAcceptButton)
	S:HandleButton(GuildControlPopupFrameCancelButton)

	-- Raid Frame
	S:HandleButton(RaidFrameConvertToRaidButton)
	S:HandleButton(RaidFrameRaidInfoButton)

	S:HandleCheckBox(RaidFrameAllAssistCheckButton)

	-- Raid Info Frame
	RaidInfoFrame:StripTextures(true)
	RaidInfoFrame:SetTemplate('Transparent')

	RaidInfoFrame:HookScript('OnShow', function()
		if GetNumRaidMembers() > 0 then
			E:Point(RaidInfoFrame, 'TOPLEFT', RaidFrame, 'TOPRIGHT', -14, -12)
		else
			E:Point(RaidInfoFrame, 'TOPLEFT', RaidFrame, 'TOPRIGHT', -34, -12)
		end
	end)

	S:HandleCloseButton(RaidInfoCloseButton, RaidInfoFrame)

	RaidInfoScrollFrame:StripTextures()
	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)
end

S:AddCallback('Friends', LoadSkin)
