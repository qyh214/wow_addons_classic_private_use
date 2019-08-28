local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local find = string.find
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end

	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop('Transparent')
	ClassTrainerFrame.backdrop:Point('TOPLEFT', 10, -11)
	ClassTrainerFrame.backdrop:Point('BOTTOMRIGHT', -32, 74)


	ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point('TOPRIGHT', -40, -64)

	ClassTrainerListScrollFrame:StripTextures()
	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar)

	ClassTrainerDetailScrollFrame:StripTextures()
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar)

	ClassTrainerSkillIcon:StripTextures()

	ClassTrainerCancelButton:Kill()

	S:HandleButton(ClassTrainerTrainButton)
	ClassTrainerTrainButton:Point('BOTTOMRIGHT', -38, 80)

	S:HandleCloseButton(ClassTrainerFrameCloseButton)

	hooksecurefunc('ClassTrainer_SetSelection', function()
		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture()
		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			ClassTrainerSkillIcon:SetTemplate('Default')
		end
	end)

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local button = _G['ClassTrainerSkill'..i]
		local highlight = _G['ClassTrainerSkill'..i..'Highlight']

		button:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
		button.SetNormalTexture = E.noop
		button:GetNormalTexture():Size(14)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop

		hooksecurefunc(button, 'SetNormalTexture', function(self, texture)
			if find(texture, 'MinusButton') then
				self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
			elseif find(texture, 'PlusButton') then
				self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
			end
		end)
	end

	ClassTrainerCollapseAllButton:SetNormalTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
	ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	ClassTrainerCollapseAllButton:GetNormalTexture():SetPoint('LEFT', 3, 2)
	ClassTrainerCollapseAllButton:GetNormalTexture():Size(15)

	ClassTrainerCollapseAllButton:SetHighlightTexture('')
	ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop

	ClassTrainerCollapseAllButton:SetDisabledTexture('Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton')
	ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetPoint('LEFT', 3, 2)
	ClassTrainerCollapseAllButton:GetDisabledTexture():Size(15)
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(ClassTrainerCollapseAllButton, 'SetNormalTexture', function(self, texture)
		if find(texture, 'MinusButton') then
			self:GetNormalTexture():SetTexCoord(0.545, 0.975, 0.085, 0.925)
		else
			self:GetNormalTexture():SetTexCoord(0.045, 0.475, 0.085, 0.925)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_TrainerUI', 'Trainer', LoadSkin)