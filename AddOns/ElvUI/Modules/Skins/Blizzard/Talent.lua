local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	TalentFrame:StripTextures()
	TalentFrame:CreateBackdrop('Transparent')
	TalentFrame.backdrop:Point('TOPLEFT', 13, -12)
	TalentFrame.backdrop:Point('BOTTOMRIGHT', -31, 76)

	TalentFramePortrait:Hide()

	S:HandleCloseButton(TalentFrameCloseButton)

	TalentFrameCancelButton:Kill()

	for i = 1, 5 do
		S:HandleTab(_G['TalentFrameTab'..i])
	end

	TalentFrameScrollFrame:StripTextures()
	TalentFrameScrollFrame:CreateBackdrop('Default')

	S:HandleScrollBar(TalentFrameScrollFrameScrollBar)
	TalentFrameScrollFrameScrollBar:Point('TOPLEFT', TalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	TalentFrameSpentPoints:Point('TOP', 0, -42)
	TalentFrameTalentPointsText:Point('BOTTOMRIGHT', TalentFrame, 'BOTTOMLEFT', 220, 84)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G['TalentFrameTalent'..i]
		local icon = _G['TalentFrameTalent'..i..'IconTexture']
		local rank = _G['TalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate('Default')
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
		end
	end
end

S:AddCallbackForAddon('Blizzard_TalentUI', 'Talent', LoadSkin)