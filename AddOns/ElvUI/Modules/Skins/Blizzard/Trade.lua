local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trade then return end

	local TradeFrame = _G.TradeFrame
	S:HandleFrame(TradeFrame, true, nil, -5, 0, -7)

	S:HandleButton(_G.TradeFrameTradeButton, true)
	S:HandleButton(_G.TradeFrameCancelButton, true)

	S:HandlePointXY(_G.TradeFrameCloseButton, -6, 2)
	S:HandlePointXY(_G.TradeFrameTradeButton, -91)
	S:HandlePointXY(_G.TradePlayerItem1, 7)
	S:HandlePointXY(_G.TradeRecipientItem1, 170)

	S:HandleEditBox(_G.TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameCopper)

	local tradeFrames = {
		'TradeFramePlayerPortrait',
		'TradeFrameRecipientPortrait',
		'TradePlayerEnchantInset',
		'TradePlayerInputMoneyInset',
		'TradePlayerItemsInset',
		'TradeRecipientEnchantInset',
		'TradeRecipientItemsInset',
		'TradeRecipientMoneyBg',
		'TradeRecipientMoneyInset',
		'TradeRecipientPortraitFrame'
	}

	for _, frame in ipairs(tradeFrames) do
		_G[frame]:Kill()
	end

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

	_G.TradeHighlightPlayerTop:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayerBottom:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayerMiddle:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayer:SetFrameStrata('HIGH')

	_G.TradeHighlightPlayerEnchantTop:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayerEnchantBottom:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayerEnchantMiddle:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightPlayerEnchant:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientTop:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipientBottom:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipientMiddle:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipient:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientEnchantTop:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipientEnchantBottom:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipientEnchantMiddle:SetColorTexture(0, 1, 0, 0.3)
	_G.TradeHighlightRecipientEnchant:SetFrameStrata('HIGH')

	hooksecurefunc('TradeFrame_UpdatePlayerItem', function(id)
		local tradeItemButton = _G['TradePlayerItem'..id..'ItemButton']
		local link = GetTradePlayerItemLink(id)

		tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))

		if link then
			local tradeItemName = _G['TradePlayerItem'..id..'Name']
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end)

	hooksecurefunc('TradeFrame_UpdateTargetItem', function(id)
		local tradeItemButton = _G['TradeRecipientItem'..id..'ItemButton']
		local link = GetTradeTargetItemLink(id)

		tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))

		if link then
			local tradeItemName = _G['TradeRecipientItem'..id..'Name']
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end)
end

S:AddCallback('Skin_Trade', LoadSkin)
