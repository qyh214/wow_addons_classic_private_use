local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack, select = unpack, select
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true then return; end

	local TradeFrame = _G.TradeFrame
	TradeFrame:StripTextures(true)
	TradeFrame:CreateBackdrop('Transparent')

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	S:HandleButton(_G.TradeFrameTradeButton, true)
	S:HandleButton(_G.TradeFrameCancelButton, true)

	S:HandleEditBox(_G.TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameCopper)
	_G.TradeRecipientItemsInset:Kill()
	_G.TradePlayerItemsInset:Kill()
	_G.TradePlayerInputMoneyInset:Kill()
	_G.TradePlayerEnchantInset:Kill()
	_G.TradeRecipientEnchantInset:Kill()
	_G.TradeRecipientMoneyInset:Kill()
	_G.TradeRecipientMoneyBg:Kill()


	for i = 1, _G.MAX_TRADE_ITEMS do
		local player = _G['TradePlayerItem'..i]
		local recipient = _G['TradeRecipientItem'..i]
		local playerButton = _G['TradePlayerItem'..i..'ItemButton']
		local playerButtonIcon = _G['TradePlayerItem'..i..'ItemButtonIconTexture']
		local recipientButton = _G['TradeRecipientItem'..i..'ItemButton']
		local recipientButtonIcon = _G['TradeRecipientItem'..i..'ItemButtonIconTexture']

		player:StripTextures()
		recipient:StripTextures()

		playerButton:StripTextures()
		playerButton:StyleButton()
		playerButton:SetTemplate('Default', true)

		playerButtonIcon:SetInside()
		playerButtonIcon:SetTexCoord(unpack(E.TexCoords))

		recipientButton:StripTextures()
		recipientButton:StyleButton()
		recipientButton:SetTemplate('Default', true)

		recipientButtonIcon:SetInside()
		recipientButtonIcon:SetTexCoord(unpack(E.TexCoords))

		playerButton.bg = CreateFrame('Frame', nil, playerButton)
		playerButton.bg:SetTemplate('Default')
		playerButton.bg:Point('TOPLEFT', playerButton, 'TOPRIGHT', 4, 0)
		playerButton.bg:Point('BOTTOMRIGHT', _G['TradePlayerItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
		playerButton.bg:SetFrameLevel(playerButton:GetFrameLevel() - 3)

		recipientButton.bg = CreateFrame('Frame', nil, recipientButton)
		recipientButton.bg:SetTemplate('Default')
		recipientButton.bg:Point('TOPLEFT', recipientButton, 'TOPRIGHT', 4, 0)
		recipientButton.bg:Point('BOTTOMRIGHT', _G['TradeRecipientItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
		recipientButton.bg:SetFrameLevel(recipientButton:GetFrameLevel() - 3)
	end

	_G.TradeHighlightPlayerTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayer:SetFrameStrata('HIGH')

	_G.TradeHighlightPlayerEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchant:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipient:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchant:SetFrameStrata('HIGH')

	hooksecurefunc('TradeFrame_UpdatePlayerItem', function(id)
		local tradeItemButton = _G['TradePlayerItem'..id..'ItemButton']
		local tradeItemName = _G['TradePlayerItem'..id..'Name']
		local link = GetTradePlayerItemLink(id)
		if link then
			local quality = select(3, GetItemInfo(link))
			tradeItemName:SetTextColor(GetItemQualityColor(quality))
			if quality then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc('TradeFrame_UpdateTargetItem', function(id)
		local tradeItemButton = _G['TradeRecipientItem'..id..'ItemButton']
		local tradeItemName = _G['TradeRecipientItem'..id..'Name']
		local link = GetTradeTargetItemLink(id)
		if link then
			local quality = select(3, GetItemInfo(link))
			tradeItemName:SetTextColor(GetItemQualityColor(quality))
			if quality then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

S:AddCallback('Trade', LoadSkin)