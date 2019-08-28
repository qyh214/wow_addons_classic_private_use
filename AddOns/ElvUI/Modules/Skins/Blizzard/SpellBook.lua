local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local SpellBook_GetCurrentPage = SpellBook_GetCurrentPage
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local MAX_SKILLLINE_TABS = MAX_SKILLLINE_TABS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true then return end

	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame, true)
	SpellBookFrame.backdrop:Point('TOPLEFT', 10, -12)
	SpellBookFrame.backdrop:Point('BOTTOMRIGHT', -31, 75)

	_G.SpellBookSpellIconsFrame:StripTextures(true)
	_G.SpellBookSideTabsFrame:StripTextures(true)
	_G.SpellBookPageNavigationFrame:StripTextures(true)

	_G.SpellBookPageText:SetTextColor(1, 1, 1)
	_G.SpellBookPageText:Point('BOTTOM', _G.SpellBookFrame, 'BOTTOM', -4, 88)

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton)
	_G.SpellBookPrevPageButton:Point('BOTTOMRIGHT', _G.SpellBookFrame, 'BOTTOMRIGHT', -68, 80)
	_G.SpellBookPrevPageButton:Size(24)

	S:HandleNextPrevButton(_G.SpellBookNextPageButton)
	_G.SpellBookNextPageButton:Point('TOPLEFT', _G.SpellBookPrevPageButton, 'TOPLEFT', 30, 0)
	_G.SpellBookNextPageButton:Size(24)

	S:HandleCloseButton(_G.SpellBookCloseButton)

	for i = 1, 3 do
		local tab = _G['SpellBookFrameTabButton'..i]

		tab:GetNormalTexture():SetTexture(nil)
		tab:GetDisabledTexture():SetTexture(nil)

		S:HandleTab(tab)

		tab.backdrop:Point('TOPLEFT', 14, E.PixelMode and -17 or -19)
		tab.backdrop:Point('BOTTOMRIGHT', -14, 19)
	end

	-- Spell Buttons
	for i = 1, SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local cooldown = _G['SpellButton'..i..'Cooldown']
		local highlight = _G['SpellButton'..i..'Highlight']

		for i = 1, button:GetNumRegions() do
			local region = select(i, button:GetRegions())
			if region:GetObjectType() == 'Texture' then
				if region:GetTexture() ~= 'Interface\\Buttons\\ActionBarFlyoutButton' then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBackdrop('Default', true)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() - 1)

		button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)

		button.bg = CreateFrame('Frame', nil, button)
		button.bg:CreateBackdrop('Transparent', true)
		button.bg:Point('TOPLEFT', -7, 9)
		button.bg:Point('BOTTOMRIGHT', 116, -10)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

		icon:SetTexCoord(unpack(E.TexCoords))

		highlight:SetAllPoints()
		hooksecurefunc(highlight, 'SetTexture', function(self, texture)
			if texture == 'Interface\\Buttons\\ButtonHilight-Square' or texture == 'Interface\\Buttons\\UI-PassiveHighlight' then
				self:SetColorTexture(1, 1, 1, 0.3)
			end
		end)

		E:RegisterCooldown(cooldown)
	end

	_G.SpellButton1:Point('TOPLEFT', _G.SpellBookSpellIconsFrame, 'TOPLEFT', 24, -55)
	_G.SpellButton2:Point('TOPLEFT', _G.SpellButton1, 'TOPLEFT', 168, 0)
	_G.SpellButton3:Point('TOPLEFT', _G.SpellButton1, 'BOTTOMLEFT', 0, -23)
	_G.SpellButton4:Point('TOPLEFT', _G.SpellButton3, 'TOPLEFT', 168, 0)
	_G.SpellButton5:Point('TOPLEFT', _G.SpellButton3, 'BOTTOMLEFT', 0, -23)
	_G.SpellButton6:Point('TOPLEFT', _G.SpellButton5, 'TOPLEFT', 168, 0)
	_G.SpellButton7:Point('TOPLEFT', _G.SpellButton5, 'BOTTOMLEFT', 0, -23)
	_G.SpellButton8:Point('TOPLEFT', _G.SpellButton7, 'TOPLEFT', 168, 0)
	_G.SpellButton9:Point('TOPLEFT', _G.SpellButton7, 'BOTTOMLEFT', 0, -23)
	_G.SpellButton10:Point('TOPLEFT', _G.SpellButton9, 'TOPLEFT', 168, 0)
	_G.SpellButton11:Point('TOPLEFT', _G.SpellButton9, 'BOTTOMLEFT', 0, -23)
	_G.SpellButton12:Point('TOPLEFT', _G.SpellButton11, 'TOPLEFT', 168, 0)

	hooksecurefunc('SpellButton_UpdateButton', function(self)
		local spellName = _G[self:GetName()..'SpellName']
		local r = spellName:GetTextColor()

		if r < 0.8 then
			spellName:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G['SpellBookSkillLineTab'..i]
		local flash = _G['SpellBookSkillLineTab'..i..'Flash']

		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
		tab:SetTemplate('Default', true)
		tab.pushed = true

		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

		if i == 1 then
			tab:Point('TOPLEFT', _G.SpellBookSideTabsFrame, 'TOPRIGHT', -32, -70)
		end

		hooksecurefunc(tab:GetHighlightTexture(), 'SetTexture', function(self, texPath)
			if texPath ~= nil then
				self:SetPushedTexture(nil)
			end
		end)

		hooksecurefunc(tab:GetCheckedTexture(), 'SetTexture', function(self, texPath)
			if texPath ~= nil then
				self:SetHighlightTexture(nil)
			end
		end)

		flash:Kill()
	end
end

S:AddCallback('Spellbook', LoadSkin)
