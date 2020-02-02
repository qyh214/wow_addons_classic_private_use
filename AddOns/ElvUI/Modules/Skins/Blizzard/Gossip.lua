local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	-- GossipFrame
	local GossipFrame = _G.GossipFrame
	S:HandleFrame(GossipFrame, true, nil, 11, -12, -32, 66)

	S:HandleFrame(_G.GossipGreetingScrollFrame, true, nil, -6, 2)

	S:HandleScrollBar(_G.GossipGreetingScrollFrameScrollBar)

	S:HandleCloseButton(_G.GossipFrameCloseButton, GossipFrame.backdrop)

	_G.GossipFrameNpcNameText:ClearAllPoints()
	_G.GossipFrameNpcNameText:Point('CENTER', _G.GossipNpcNameFrame, 'CENTER', -1, 0)

	for i = 1, _G.NUMGOSSIPBUTTONS do
		_G['GossipTitleButton'..i..'GossipIcon']:SetSize(16, 16)
		_G['GossipTitleButton'..i..'GossipIcon']:SetPoint('TOPLEFT', 3, 1)
	end

	_G.GossipGreetingText:SetTextColor(1, 1, 1)

	hooksecurefunc('GossipFrameUpdate', function()
		for i = 1, _G.NUMGOSSIPBUTTONS do
			local button = _G['GossipTitleButton'..i]
			local icon = _G['GossipTitleButton'..i..'GossipIcon']
			local text = button:GetFontString()

			if text and text:GetText() then
				local textString = gsub(text:GetText(), '|c[Ff][Ff]%x%x%x%x%x%x(.+)|r', '%1')

				button:SetText(textString)
				text:SetTextColor(1, 1, 1)

				if button.type == 'Available' or button.type == 'Active' then
					if button.type == 'Active' then
						icon:SetDesaturation(1)
						text:SetTextColor(.6, .6, .6)
					else
						icon:SetDesaturation(0)
						text:SetTextColor(1, .8, .1)
					end

					local numEntries = GetNumQuestLogEntries()
					for k = 1, numEntries, 1 do
						local questLogTitleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(k)
						if strmatch(questLogTitleText, textString) then
							if (isComplete == 1 or IsQuestComplete(questId)) then
								icon:SetDesaturation(0)
								button:GetFontString():SetTextColor(1, .8, .1)
								break
							end
						end
					end
				end
			end
		end
	end)

	S:HandleButton(_G.GossipFrameGreetingGoodbyeButton)
	_G.GossipFrameGreetingGoodbyeButton:Point('BOTTOMRIGHT', -38, 72)

	-- ItemTextFrame
	S:HandleFrame(_G.ItemTextFrame, true, nil, 11, -12, -32, 76)

	_G.ItemTextScrollFrame:StripTextures()

	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)
	S:HandleNextPrevButton(_G.ItemTextNextPageButton)

	_G.ItemTextPageText:SetTextColor(1, 1, 1)
	hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', function(pageText, headerType, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			pageText:SetTextColor(headerType, 1, 1, 1)
		end
	end)

	local StripAllTextures = { 'GossipFrameGreetingPanel', 'GossipGreetingScrollFrame' }

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)

	S:HandleCloseButton(_G.ItemTextCloseButton, ItemTextFrame.backdrop)

	local NPCFriendshipStatusBar = _G.NPCFriendshipStatusBar
	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:CreateBackdrop()

	E:RegisterStatusBar(NPCFriendshipStatusBar)
end

S:AddCallback('GossipFrame')
