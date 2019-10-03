local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local hooksecurefunc = hooksecurefunc
local UnitExists = UnitExists

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.stable then return end

	local PetStableFrame = _G.PetStableFrame
	S:HandleFrame(PetStableFrame, true, nil, 10, -11, -32, 71)

	S:HandleButton(PetStablePurchaseButton)
	S:HandleCloseButton(PetStableFrameCloseButton)
	S:HandleRotateButton(PetStableModelRotateRightButton)
	S:HandleRotateButton(PetStableModelRotateLeftButton)

	S:HandleItemButton(_G.PetStableCurrentPet, true)
	_G.PetStableCurrentPetIconTexture:SetDrawLayer('ARTWORK')

	for i = 1, _G.NUM_PET_STABLE_SLOTS do
		S:HandleItemButton(_G['PetStableStabledPet'..i], true)
		_G['PetStableStabledPet'..i..'IconTexture']:SetDrawLayer('ARTWORK')
	end

	PetStablePetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetStablePetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetStablePetInfo:CreateBackdrop('Default')
	PetStablePetInfo:Size(24)

	hooksecurefunc('PetStable_Update', function()
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and not isHunterPet and UnitExists("pet") then return end

		local happiness = GetPetHappiness()
		local texture = PetStablePetInfo:GetRegions()

		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end)
end

S:AddCallback('Skin_Stable', LoadSkin)
