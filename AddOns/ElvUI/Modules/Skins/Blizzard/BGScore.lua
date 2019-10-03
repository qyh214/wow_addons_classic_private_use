local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local format, split = string.format, string.spli
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgscore then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	S:HandleFrame(WorldStateScoreFrame, true, nil, 10, -15, -113, 67)

	_G.WorldStateScoreScrollFrame:StripTextures()
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)

	for i = 1, 3 do
		S:HandleTab(_G['WorldStateScoreFrameTab'..i])
		_G['WorldStateScoreFrameTab'..i..'Text']:SetPoint('CENTER', 0, 2)
	end

	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)
	S:HandleCloseButton(_G.WorldStateScoreFrameCloseButton)

	_G.WorldStateScoreFrameKB:StyleButton()
	_G.WorldStateScoreFrameDeaths:StyleButton()
	_G.WorldStateScoreFrameHK:StyleButton()
	_G.WorldStateScoreFrameHonorGained:StyleButton()
	_G.WorldStateScoreFrameName:StyleButton()

	for i = 1, 5 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end

	local myName = format('> %s <', E.myname)

	hooksecurefunc('WorldStateScoreFrame_Update', function()
		local offset = FauxScrollFrame_GetOffset(_G.WorldStateScoreScrollFrame)

		local _, name, faction, classToken, realm, classTextColor, nameText

		for i = 1, MAX_SCORE_BUTTONS do

			name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)
			if name then
				name, realm = split('-', name, 2)

				if name == E.myname then
					name = myName
				end

				if realm then
					local color

					if faction == 1 then
						color = '|cff00adf0'
					else
						color = '|cffff1919'
					end

					name = format('%s|cffffffff - |r%s%s|r', name, color, realm)
				end

				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS[classToken]

				nameText = _G['WorldStateScoreButton'..i..'NameText']
				nameText:SetText(name)
				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end)
end

S:AddCallback('Skin_WorldStateScore', LoadSkin)