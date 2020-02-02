local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local ipairs = ipairs
--WoW API / Variables
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()

	for _, slot in ipairs({ _G.InspectPaperDollItemsFrame:GetChildren() }) do
		local icon = _G[slot:GetName()..'IconTexture']
		local cooldown = _G[slot:GetName()..'Cooldown']

		slot:StripTextures()
		slot:CreateBackdrop('Default')
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	local function styleButton(button)
		if button.hasItem then
			local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
			if itemID then
				local quality = select(3, GetItemInfo(itemID))

				if not quality then
					E:Delay(0.1, function()
						if InspectFrame.unit then
							styleButton(button)
						end
					end)

					return
				elseif quality and quality > 1 then
					button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
				end
			end
		end

		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', styleButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)

	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Honor Frame
	local InspectHonorFrame = _G.InspectHonorFrame
	S:HandleFrame(InspectHonorFrame, true, nil, 18, -105, -39, 83)
	InspectHonorFrame.backdrop:SetFrameLevel(InspectHonorFrame:GetFrameLevel())

	_G.InspectHonorFrameProgressButton:CreateBackdrop('Transparent')

	local InspectHonorFrameProgressBar = _G.InspectHonorFrameProgressBar
	InspectHonorFrameProgressBar:Width(325)
	InspectHonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)

	S:HandlePointXY(InspectHonorFrameProgressBar, 19, -74)

	E:RegisterStatusBar(InspectHonorFrameProgressBar)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
