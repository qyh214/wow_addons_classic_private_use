local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

function S:Blizzard_Channels()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Channels) then return end

	local ChannelFrame = _G.ChannelFrame
	S:HandleFrame(ChannelFrame, true, nil, -5)

	S:HandleButton(ChannelFrame.NewButton)
	S:HandleButton(ChannelFrame.SettingsButton)

	S:HandlePointXY(ChannelFrame.NewButton, -1, 4)
	S:HandlePointXY(ChannelFrameCloseButton, 2, 2)

	S:HandleScrollBar(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:Point('TOPLEFT', ChannelFrame.ChannelRoster.ScrollFrame, 'TOPRIGHT', 1, -13)
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:Point('BOTTOMLEFT', ChannelFrame.ChannelRoster.ScrollFrame, 'BOTTOMRIGHT', 1, 13)

	S:HandleScrollBar(ChannelFrame.ChannelList.ScrollBar)
	ChannelFrame.ChannelList.ScrollBar:Point('BOTTOMLEFT', ChannelFrame.ChannelList, 'BOTTOMRIGHT', 0, 15)

	local CreateChannelPopup = _G.CreateChannelPopup
	S:HandleFrame(CreateChannelPopup, true)

	S:HandleButton(CreateChannelPopup.OKButton)
	S:HandleButton(CreateChannelPopup.CancelButton)

	S:HandleEditBox(CreateChannelPopup.Name)
	S:HandleEditBox(CreateChannelPopup.Password)

	S:HandlePointXY(CreateChannelPopup.CloseButton, 2, 2)

	local VoiceChatPromptActivateChannel = _G.VoiceChatPromptActivateChannel
	S:HandleFrame(VoiceChatPromptActivateChannel, true)
	S:HandleButton(VoiceChatPromptActivateChannel.AcceptButton)
	S:HandleCloseButton(VoiceChatPromptActivateChannel.CloseButton, VoiceChatPromptActivateChannel.backrop)

	-- Hide the Channel Header Textures
	hooksecurefunc(_G.ChannelButtonHeaderMixin, "Update", function(s)
		s:SetTemplate("Transparent")
		s.NormalTexture:SetTexture()
	end)
end

S:AddCallbackForAddon('Blizzard_Channels')
