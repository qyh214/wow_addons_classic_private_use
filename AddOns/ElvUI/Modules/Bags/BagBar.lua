local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

local _G = _G
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert
local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local RegisterStateDriver = RegisterStateDriver
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots
local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeIn(B.BagBar, 0.2, B.BagBar:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(B.BagBar, 0.2, B.BagBar:GetAlpha(), 0)
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName()..'IconTexture']
	bag.oldTex = icon:GetTexture()

	bag:StripTextures()
	bag:CreateBackdrop(nil, nil, nil, nil, nil, nil, true)
	bag:StyleButton(true)
	bag.IconBorder:Kill()

	icon:SetInside()
	icon:SetTexture(bag.oldTex)
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not B.BagBar then return end

	local bagBarSize = E.db.bags.bagBar.size
	local buttonSpacing = E.db.bags.bagBar.spacing
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection

	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local backdropSpacing = not showBackdrop and 0 or E.db.bags.bagBar.backdropSpacing
	local justBackpack = E.private.bags.enable and E.db.bags.bagBar.justBackpack

	local visibility = E.db.bags.bagBar.visibility
	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	RegisterStateDriver(B.BagBar, 'visibility', visibility)
	B.BagBar:SetAlpha(E.db.bags.bagBar.mouseover and 0 or 1)

	local firstButton, lastButton
	for i, button in ipairs(B.BagBar.buttons) do
		local prevButton = B.BagBar.buttons[i-1]
		button:Size(bagBarSize)
		button:ClearAllPoints()
		button:SetShown(i == 1 and justBackpack or not justBackpack)

		if sortDirection == 'ASCENDING'then
			if i == 1 then firstButton = button else lastButton = button end
		else
			if i == 1 then lastButton = button else firstButton = button end
		end

		if growthDirection == 'HORIZONTAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', B.BagBar, 'LEFT', backdropSpacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', buttonSpacing, 0)
			end
		elseif growthDirection == 'VERTICAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', B.BagBar, 'TOP', 0, -backdropSpacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -buttonSpacing)
			end
		elseif growthDirection == 'HORIZONTAL' and sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', B.BagBar, 'RIGHT', -backdropSpacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', B.BagBar, 'BOTTOM', 0, backdropSpacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, buttonSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = buttonSpacing * NUM_BAG_FRAMES
	local bdpDoubled = backdropSpacing * 2

	B.BagBar.backdrop:ClearAllPoints()
	B.BagBar.backdrop:Point('TOPLEFT', firstButton, 'TOPLEFT', -backdropSpacing, backdropSpacing)
	B.BagBar.backdrop:Point('BOTTOMRIGHT', lastButton, 'BOTTOMRIGHT', backdropSpacing, -backdropSpacing)
	B.BagBar.backdrop:SetShown(showBackdrop)

	if growthDirection == 'HORIZONTAL' then
		B.BagBar:Size(btnSize + btnSpace + bdpDoubled, bagBarSize + bdpDoubled)
	else
		B.BagBar:Size(bagBarSize + bdpDoubled, btnSize + btnSpace + bdpDoubled)
	end

	B.BagBar.mover:SetSize(B.BagBar.backdrop:GetSize())
	B:UpdateMainButtonCount()
end

function B:UpdateMainButtonCount()
	B.BagBar.buttons[1].Count:SetShown(GetCVarBool('displayFreeBagSlots'))
	B.BagBar.buttons[1].Count:SetText(CalculateTotalNumberOfFreeBagSlots())
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	B.BagBar = CreateFrame('Frame', 'ElvUIBags', E.UIParent)
	B.BagBar:Point('TOPRIGHT', _G.RightChatPanel, 'TOPLEFT', -4, 0)
	B.BagBar:CreateBackdrop(E.db.bags.transparent and 'Transparent', nil, nil, nil, nil, nil, true)
	B.BagBar:SetScript('OnEnter', OnEnter)
	B.BagBar:SetScript('OnLeave', OnLeave)
	B.BagBar:EnableMouse(true)
	B.BagBar.buttons = {}

	_G.MainMenuBarBackpackButton:SetParent(B.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:Point('BOTTOMRIGHT', _G.MainMenuBarBackpackButton, 'BOTTOMRIGHT', -1, 4)
	_G.MainMenuBarBackpackButton:HookScript('OnEnter', OnEnter)
	_G.MainMenuBarBackpackButton:HookScript('OnLeave', OnLeave)

	tinsert(B.BagBar.buttons, _G.MainMenuBarBackpackButton)
	B:SkinBag(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G['CharacterBag'..i..'Slot']
		b:SetParent(B.BagBar)
		b:HookScript('OnEnter', OnEnter)
		b:HookScript('OnLeave', OnLeave)

		B:SkinBag(b)

		tinsert(B.BagBar.buttons, b)
	end

	_G.KeyRingButton:SetParent(B.BagBar)
	_G.KeyRingButton.SetParent = E.dummy
	_G.KeyRingButton:HookScript('OnEnter', OnEnter)
	_G.KeyRingButton:HookScript('OnLeave', OnLeave)

	if E.private.bags.enable then
		_G.KeyRingButton:HookScript('PostClick', function()
			B.ShowKeyRing = not B.ShowKeyRing
			B:Layout()
		end)
	end

	_G.KeyRingButton:StripTextures()
	_G.KeyRingButton:SetTemplate(nil, true)
	_G.KeyRingButton:StyleButton(true)
	_G.KeyRingButton:SetNormalTexture("Interface/ICONS/INV_Misc_Key_03")
	_G.KeyRingButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	_G.KeyRingButton:GetNormalTexture():SetInside()
	_G.KeyRingButton:SetPushedTexture("Interface/ICONS/INV_Misc_Key_03")
	_G.KeyRingButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
	_G.KeyRingButton:GetPushedTexture():SetInside()
	tinsert(B.BagBar.buttons, _G.KeyRingButton)

	E:CreateMover(B.BagBar, 'BagsMover', L["Bags"], nil, nil, nil, nil, nil, 'bags,general')
	B.BagBar:SetPoint('BOTTOMLEFT', B.BagBar.mover)
	B:RegisterEvent('BAG_SLOT_FLAGS_UPDATED', 'SizeAndPositionBagBar')
	B:RegisterEvent('BAG_UPDATE_DELAYED', 'UpdateMainButtonCount')
	B:SizeAndPositionBagBar()
end
