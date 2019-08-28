local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	local GameTooltip = _G.GameTooltip
	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point('TOPLEFT', GameTooltip, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point('TOPRIGHT', GameTooltip, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))

	local tooltips = {
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.ItemRefShoppingTooltip3,
		_G.AutoCompleteBox,
		_G.FriendsTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.ShoppingTooltip3,
		_G.ReputationParagonTooltip,
		_G.EmbeddedItemTooltip,
		-- already have locals
		GameTooltip,
	}
	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- EmbeddedItemTooltip
	local reward = _G.EmbeddedItemTooltip.ItemTooltip
	local icon = reward.Icon
	if reward and reward.backdrop then
		reward.backdrop:Point('TOPLEFT', icon, 'TOPLEFT', -2, 2)
		reward.backdrop:Point('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 2, -2)
	end

	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('GameTooltip_UpdateStyle', 'SetStyle')

	-- [Backdrop coloring] There has to be a more elegant way of doing this.
	TT:SecureHookScript(GameTooltip, 'OnUpdate', 'CheckBackdropColor')
end

S:AddCallback('SkinTooltip', LoadSkin)
