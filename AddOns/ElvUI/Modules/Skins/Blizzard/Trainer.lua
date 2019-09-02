local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local strfind = strfind
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end

	local ClassTrainerFrame = _G.ClassTrainerFrame
	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop('Transparent')
	ClassTrainerFrame.backdrop:Point('TOPLEFT', 10, -11)
	ClassTrainerFrame.backdrop:Point('BOTTOMRIGHT', -32, 74)

	_G.ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(_G.ClassTrainerFrameFilterDropDown)
	_G.ClassTrainerFrameFilterDropDown:Point('TOPRIGHT', -40, -64)

	_G.ClassTrainerListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerListScrollFrameScrollBar)

	_G.ClassTrainerDetailScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerDetailScrollFrameScrollBar)

	_G.ClassTrainerSkillIcon:StripTextures()

	_G.ClassTrainerCancelButton:Kill()

	S:HandleButton(_G.ClassTrainerTrainButton)
	_G.ClassTrainerTrainButton:Point('BOTTOMRIGHT', -38, 80)

	S:HandleCloseButton(_G.ClassTrainerFrameCloseButton)

	hooksecurefunc('ClassTrainer_SetSelection', function()
		local skillIcon = _G.ClassTrainerSkillIcon:GetNormalTexture()
		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			_G.ClassTrainerSkillIcon:SetTemplate('Default')
		end
	end)

	for i = 1, _G.CLASS_TRAINER_SKILLS_DISPLAYED do
		local button = _G['ClassTrainerSkill'..i]
		local highlight = _G['ClassTrainerSkill'..i..'Highlight']

		button:SetNormalTexture(E.Media.Textures.PlusButton)
		button.SetNormalTexture = E.noop

		button:GetNormalTexture():Size(16)
		button:GetNormalTexture():Point('LEFT', 5, 0)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop

		hooksecurefunc(button, 'SetNormalTexture', function(self, texture)
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

	_G.ClassTrainerCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
	_G.ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	_G.ClassTrainerCollapseAllButton:GetNormalTexture():SetPoint('LEFT', 3, 2)
	_G.ClassTrainerCollapseAllButton:GetNormalTexture():Size(15)

	_G.ClassTrainerCollapseAllButton:SetHighlightTexture('')
	_G.ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop

	_G.ClassTrainerCollapseAllButton:SetDisabledTexture(E.Media.Textures.PlusButton)
	_G.ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():SetPoint('LEFT', 3, 2)
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():Size(15)
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(_G.ClassTrainerCollapseAllButton, 'SetNormalTexture', function(self, texture)
		local tex = self:GetNormalTexture()

		if strfind(texture, 'MinusButton') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		else
			tex:SetTexture(E.Media.Textures.PlusButton)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_TrainerUI', 'Trainer', LoadSkin)
