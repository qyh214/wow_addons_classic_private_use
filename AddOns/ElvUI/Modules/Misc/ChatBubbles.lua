local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local CH = E:GetModule('Chat')

--Lua functions
local _G = _G
local format = format
local select, unpack, pairs, wipe = select, unpack, pairs, wipe
--WoW API / Variables
local Ambiguate = Ambiguate
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local RemoveExtraSpaces = RemoveExtraSpaces
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

--Message caches
local messageToGUID = {}
local messageToSender = {}

function M:UpdateBubbleBorder()
	if not self.text then return end

	if(E.private.general.chatBubbles == 'backdrop') then
		if E.PixelMode then
			self:SetBackdropBorderColor(self.text:GetTextColor())
		else
			local r, g, b = self.text:GetTextColor()
			self.bordertop:SetColorTexture(r, g, b)
			self.borderbottom:SetColorTexture(r, g, b)
			self.borderleft:SetColorTexture(r, g, b)
			self.borderright:SetColorTexture(r, g, b)
		end
	end

	local text = self.text:GetText()
	if self.Name then
		self.Name:SetText('') --Always reset it
		if text and E.private.general.chatBubbleName then
			M:AddChatBubbleName(self, messageToGUID[text], messageToSender[text])
		end
	end

	if E.private.chat.enable and E.private.general.classColorMentionsSpeech then
		local classColorTable, lowerCaseWord, isFirstWord, rebuiltString, tempWord, wordMatch, classMatch
		if text and text:match("%s-%S+%s*") then
			for word in text:gmatch("%s-%S+%s*") do
				tempWord = word:gsub("^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
				lowerCaseWord = tempWord:lower()

				classMatch = CH.ClassNames[lowerCaseWord]
				wordMatch = classMatch and lowerCaseWord

				if(wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch]) then
					classColorTable = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[classMatch] or _G.RAID_CLASS_COLORS[classMatch];
					word = word:gsub(tempWord:gsub("%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
				end

				if not isFirstWord then
					rebuiltString = word
					isFirstWord = true
				else
					rebuiltString = format("%s%s", rebuiltString, word)
				end
			end

			if rebuiltString ~= nil then
				self.text:SetText(RemoveExtraSpaces(rebuiltString))
			end
		end
	end
end

function M:AddChatBubbleName(chatBubble, guid, name)
	if not name then return end

	local defaultColor, color = "ffffffff"
	if guid ~= nil and guid ~= "" then
		local _, class = GetPlayerInfoByGUID(guid)
		if class then
			color = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] and _G.CUSTOM_CLASS_COLORS[class].colorStr) or (_G.RAID_CLASS_COLORS[class] and _G.RAID_CLASS_COLORS[class].colorStr)
		end
	else
		color = defaultColor
	end

	chatBubble.Name:SetFormattedText("|c%s%s|r", color, name)
end

function M:SkinBubble(frame)
	if frame:IsForbidden() then return end
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture()
		elseif region:IsObjectType('FontString') then
			frame.text = region
		end
	end

	local name = frame:CreateFontString(nil, "BORDER")
	name:Point("TOPLEFT", 5, 5)
	name:Point("BOTTOMRIGHT", frame, "TOPRIGHT", -5, -5)
	name:SetJustifyH("LEFT")
	name:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize * 0.85, E.private.general.chatBubbleFontOutline)
	frame.Name = name

	if(E.private.general.chatBubbles == 'backdrop') then
		if E.PixelMode then
			frame:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = { left = 0, right = 0, top = 0, bottom = 0}
			})
			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(0, 0, 0)
		else
			frame:SetBackdrop(nil)
		end

		local r, g, b = frame.text:GetTextColor()
		if not E.PixelMode then
			frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.backdrop:SetAllPoints(frame)
			frame.backdrop:SetColorTexture(unpack(E.media.backdropfadecolor))
			frame.backdrop:SetDrawLayer("ARTWORK", -8)

			frame.bordertop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop:Point("TOPLEFT", frame, "TOPLEFT", -E.mult*2, E.mult*2)
			frame.bordertop:Point("TOPRIGHT", frame, "TOPRIGHT", E.mult*2, E.mult*2)
			frame.bordertop:Height(E.mult)
			frame.bordertop:SetColorTexture(r, g, b)
			frame.bordertop:SetDrawLayer("ARTWORK", -6)

			frame.bordertop.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop.backdrop:Point("TOPLEFT", frame.bordertop, "TOPLEFT", -E.mult, E.mult)
			frame.bordertop.backdrop:Point("TOPRIGHT", frame.bordertop, "TOPRIGHT", E.mult, E.mult)
			frame.bordertop.backdrop:Height(E.mult * 3)
			frame.bordertop.backdrop:SetColorTexture(0, 0, 0)
			frame.bordertop.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderbottom = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", -E.mult*2, -E.mult*2)
			frame.borderbottom:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", E.mult*2, -E.mult*2)
			frame.borderbottom:Height(E.mult)
			frame.borderbottom:SetColorTexture(r, g, b)
			frame.borderbottom:SetDrawLayer("ARTWORK", -6)

			frame.borderbottom.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom.backdrop:Point("BOTTOMLEFT", frame.borderbottom, "BOTTOMLEFT", -E.mult, -E.mult)
			frame.borderbottom.backdrop:Point("BOTTOMRIGHT", frame.borderbottom, "BOTTOMRIGHT", E.mult, -E.mult)
			frame.borderbottom.backdrop:Height(E.mult * 3)
			frame.borderbottom.backdrop:SetColorTexture(0, 0, 0)
			frame.borderbottom.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderleft = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft:Point("TOPLEFT", frame, "TOPLEFT", -E.mult*2, E.mult*2)
			frame.borderleft:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", E.mult*2, -E.mult*2)
			frame.borderleft:Width(E.mult)
			frame.borderleft:SetColorTexture(r, g, b)
			frame.borderleft:SetDrawLayer("ARTWORK", -6)

			frame.borderleft.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft.backdrop:Point("TOPLEFT", frame.borderleft, "TOPLEFT", -E.mult, E.mult)
			frame.borderleft.backdrop:Point("BOTTOMLEFT", frame.borderleft, "BOTTOMLEFT", -E.mult, -E.mult)
			frame.borderleft.backdrop:Width(E.mult * 3)
			frame.borderleft.backdrop:SetColorTexture(0, 0, 0)
			frame.borderleft.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderright = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright:Point("TOPRIGHT", frame, "TOPRIGHT", E.mult*2, E.mult*2)
			frame.borderright:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -E.mult*2, -E.mult*2)
			frame.borderright:Width(E.mult)
			frame.borderright:SetColorTexture(r, g, b)
			frame.borderright:SetDrawLayer("ARTWORK", -6)

			frame.borderright.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright.backdrop:Point("TOPRIGHT", frame.borderright, "TOPRIGHT", E.mult, E.mult)
			frame.borderright.backdrop:Point("BOTTOMRIGHT", frame.borderright, "BOTTOMRIGHT", E.mult, -E.mult)
			frame.borderright.backdrop:Width(E.mult * 3)
			frame.borderright.backdrop:SetColorTexture(0, 0, 0)
			frame.borderright.backdrop:SetDrawLayer("ARTWORK", -7)
		end
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
	elseif E.private.general.chatBubbles == 'backdrop_noborder' then
		frame:SetBackdrop(nil)
		frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
		frame.backdrop:SetInside(frame, 4, 4)
		frame.backdrop:SetColorTexture(unpack(E.media.backdropfadecolor))
		frame.backdrop:SetDrawLayer("ARTWORK", -8)
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
	elseif E.private.general.chatBubbles == 'nobackdrop' then
		frame:SetBackdrop(nil)
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
		frame.Name:Hide()
	end

	frame:HookScript('OnShow', M.UpdateBubbleBorder)
	frame:SetFrameStrata("DIALOG") --Doesn't work currently in Legion due to a bug on Blizzards end
	M.UpdateBubbleBorder(frame)

	frame.isSkinnedElvUI = true
end

local function ChatBubble_OnEvent(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if not E.private.general.chatBubbleName then return end

	messageToGUID[msg] = guid
	messageToSender[msg] = Ambiguate(sender, "none")
end

local function ChatBubble_OnUpdate(self, elapsed)
	if not M.BubbleFrame then return end
	if not M.BubbleFrame.lastupdate then
		M.BubbleFrame.lastupdate = -2 -- wait 2 seconds before hooking frames
	end

	M.BubbleFrame.lastupdate = M.BubbleFrame.lastupdate + elapsed
	if (M.BubbleFrame.lastupdate < .1) then return end
	M.BubbleFrame.lastupdate = 0

	for _, chatBubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		if not chatBubble.isSkinnedElvUI then
			M:SkinBubble(chatBubble)
		end
	end
end

function M:ToggleChatBubbleScript()
	local _, instanceType = GetInstanceInfo()
	if instanceType == "none" and E.private.general.chatBubbles ~= "disabled" then
		M.BubbleFrame:SetScript('OnEvent', ChatBubble_OnEvent)
		M.BubbleFrame:SetScript('OnUpdate', ChatBubble_OnUpdate)
	else
		M.BubbleFrame:SetScript('OnEvent', nil)
		M.BubbleFrame:SetScript('OnUpdate', nil)
		--Clear caches
		wipe(messageToGUID)
		wipe(messageToSender)
	end
end

function M:LoadChatBubbles()
	self.BubbleFrame = CreateFrame("Frame")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_YELL")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end
