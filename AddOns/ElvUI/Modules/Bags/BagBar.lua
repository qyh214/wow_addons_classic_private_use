local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local GetBagSlotFlag = GetBagSlotFlag
local RegisterStateDriver = RegisterStateDriver
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local LE_BAG_FILTER_FLAG_EQUIPMENT = LE_BAG_FILTER_FLAG_EQUIPMENT
local NUM_LE_BAG_FILTER_FLAGS = NUM_LE_BAG_FILTER_FLAGS

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return; end
	E:UIFrameFadeIn(B.BagBar, 0.2, B.BagBar:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return; end
	E:UIFrameFadeOut(B.BagBar, 0.2, B.BagBar:GetAlpha(), 0)
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:StripTextures()
	bag:SetTemplate()
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not B.BagBar then return; end

	local buttonSpacing = E:Scale(E.db.bags.bagBar.spacing)
	local backdropSpacing = E:Scale(E.db.bags.bagBar.backdropSpacing)
	local bagBarSize = E:Scale(E.db.bags.bagBar.size)
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection

	local visibility = E.db.bags.bagBar.visibility
	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	RegisterStateDriver(B.BagBar, "visibility", visibility)
	B.BagBar:SetAlpha(E.db.bags.bagBar.mouseover and 0 or 1)
	B.BagBar.backdrop:SetShown(showBackdrop)

	local bdpSpacing = (showBackdrop and backdropSpacing + E.Border) or 0
	local btnSpacing = (buttonSpacing + E.Border)

	for i, button in ipairs(B.BagBar.buttons) do
		local prevButton = B.BagBar.buttons[i-1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if growthDirection == 'HORIZONTAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:SetPoint('LEFT', B.BagBar, 'LEFT', bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint('LEFT', prevButton, 'RIGHT', btnSpacing, 0)
			end
		elseif growthDirection == 'VERTICAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:SetPoint('TOP', B.BagBar, 'TOP', 0, -bdpSpacing)
			elseif prevButton then
				button:SetPoint('TOP', prevButton, 'BOTTOM', 0, -btnSpacing)
			end
		elseif growthDirection == 'HORIZONTAL' and sortDirection == 'DESCENDING' then
			if i == 1 then
				button:SetPoint('RIGHT', B.BagBar, 'RIGHT', -bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint('RIGHT', prevButton, 'LEFT', -btnSpacing, 0)
			end
		else
			if i == 1 then
				button:SetPoint('BOTTOM', B.BagBar, 'BOTTOM', 0, bdpSpacing)
			elseif prevButton then
				button:SetPoint('BOTTOM', prevButton, 'TOP', 0, btnSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 2)
	local btnSpace = btnSpacing * (NUM_BAG_FRAMES + 1)
	local bdpDoubled = bdpSpacing * 2

	if growthDirection == 'HORIZONTAL' then
		B.BagBar:SetWidth(btnSize + btnSpace + bdpDoubled)
		B.BagBar:SetHeight(bagBarSize + bdpDoubled)
	else
		B.BagBar:SetHeight(btnSize + btnSpace + bdpDoubled)
		B.BagBar:SetWidth(bagBarSize + bdpDoubled)
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	B.BagBar = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	B.BagBar:Point('TOPRIGHT', _G.RightChatPanel, 'TOPLEFT', -4, 0)
	B.BagBar.buttons = {}
	B.BagBar:CreateBackdrop(E.db.bags.transparent and 'Transparent')
	B.BagBar.backdrop:SetAllPoints()
	B.BagBar:EnableMouse(true)
	B.BagBar:SetScript("OnEnter", OnEnter)
	B.BagBar:SetScript("OnLeave", OnLeave)

	_G.MainMenuBarBackpackButton:SetParent(B.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
	_G.MainMenuBarBackpackButton:HookScript('OnEnter', OnEnter)
	_G.MainMenuBarBackpackButton:HookScript('OnLeave', OnLeave)

	tinsert(B.BagBar.buttons, _G.MainMenuBarBackpackButton)
	B:SkinBag(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G["CharacterBag"..i.."Slot"]
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

	B:SizeAndPositionBagBar()
	E:CreateMover(B.BagBar, 'BagsMover', L["Bags"], nil, nil, nil, nil, nil, 'bags,general')
end
