local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local split = string.split
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:CreateBackdrop('Transparent')
	WorldStateScoreFrame.backdrop:Point('TOPLEFT', 10, -15)
	WorldStateScoreFrame.backdrop:Point('BOTTOMRIGHT', -113, 67)

	_G.WorldStateScoreScrollFrame:StripTextures()
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)

	local tab
	for i = 1, 3 do
		tab = _G['WorldStateScoreFrameTab'..i]

		S:HandleTab(tab)

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

	hooksecurefunc('WorldStateScoreFrame_Update', function()
		local offset = FauxScrollFrame_GetOffset(_G.WorldStateScoreScrollFrame)

		for i = 1, MAX_SCORE_BUTTONS do
			local index = offset + i
			local name, _, _, _, _, faction = GetBattlefieldScore(index)
			if name then
				local n, r = split('-', name, 2)
				local myName = UnitName('player')

				if name == myName then
					n = '> '..n..' <'
				end

				if r then
					local color

					if faction == 1 then
						color = '|cff00adf0'
					else
						color = '|cffff1919'
					end
					r = color..r..'|r'
					n = n..'|cffffffff - |r'..r
				end

				local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS[classToken]

				_G['WorldStateScoreButton'..i..'NameText']:SetText(n)
				_G['WorldStateScoreButton'..i..'NameText']:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end)
end

S:AddCallback('WorldStateScore', LoadSkin)