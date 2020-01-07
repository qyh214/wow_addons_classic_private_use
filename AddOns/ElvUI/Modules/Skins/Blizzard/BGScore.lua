local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local format, split = string.format, string.split
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgscore then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	S:HandleFrame(WorldStateScoreFrame, true, nil, 0, -5, -107, 25)

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

	for i = 1, 7 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end

	hooksecurefunc('WorldStateScoreFrame_Update', function()
		local offset = FauxScrollFrame_GetOffset(_G.WorldStateScoreScrollFrame)
		for i = 1, 22 do
			local name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)
			if name then
				if name == E.myname then
					name = format('> %s <', name)
				else
					local Name, Realm = strsplit('-', name, 2)
					if Realm then
						name = format('%s|cffffffff - |r%s%s|r', Name, (faction == 1 and '|cff00adf0') or '|cffff1919', Realm)
					end
				end

				local classTextColor = E:ClassColor(classToken)
				local nameText = _G['WorldStateScoreButton'..i..'NameText']
				nameText:SetText(' '..name)
				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end)
end

S:AddCallback('Skin_WorldStateScore', LoadSkin)