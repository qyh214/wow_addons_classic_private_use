local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local pairs = pairs
local match = string.match
--WoW API / Variables
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	local InspectFrame = _G.InspectFrame
	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop('Transparent')
	InspectFrame.backdrop:Point('TOPLEFT', 10, -12)
	InspectFrame.backdrop:Point('BOTTOMRIGHT', -31, 75)

	S:HandleCloseButton(InspectFrameCloseButton)

	for i = 1, 2 do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	InspectPaperDollFrame:StripTextures()

	local slots = {
		'HeadSlot',
		'NeckSlot',
		'ShoulderSlot',
		'BackSlot',
		'ChestSlot',
		'ShirtSlot',
		'TabardSlot',
		'WristSlot',
		'HandsSlot',
		'WaistSlot',
		'LegsSlot',
		'FeetSlot',
		'Finger0Slot',
		'Finger1Slot',
		'Trinket0Slot',
		'Trinket1Slot',
		'MainHandSlot',
		'SecondaryHandSlot',
		'RangedSlot'
	}

	for _, slot in pairs(slots) do
		local icon = _G['Inspect'..slot..'IconTexture']
		local slot = _G['Inspect'..slot]

		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate('Default', true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', function(button)
		if button.hasItem then
			local itemLink = GetInventoryItemLink(InspectFrame.unit, button:GetID())
			if itemLink then
				local quality = select(3, GetItemInfo(itemLink))
				if not quality then
					E:Delay(0.1, function()
						if InspectFrame.unit then
							InspectPaperDollItemSlotButton_Update(button)
						end
					end)
					return
				elseif quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
				end
			end
		end
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	S:HandleRotateButton(InspectModelFrameRotateLeftButton)
	InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)

	S:HandleRotateButton(InspectModelFrameRotateRightButton)
	InspectModelFrameRotateRightButton:Point('TOPLEFT', InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Honor Frame
	InspectHonorFrame:StripTextures()

	InspectHonorFrameProgressButton:CreateBackdrop()
	InspectHonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(InspectHonorFrameProgressBar)
end

S:AddCallbackForAddon('Blizzard_InspectUI', 'Inspect', LoadSkin)