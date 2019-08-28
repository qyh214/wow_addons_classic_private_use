local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.battlefield ~= true then return end

	local BattlefieldFrame = _G.BattlefieldFrame
	BattlefieldFrame:StripTextures()
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 11, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -34, 74)

	_G.BattlefieldListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.BattlefieldListScrollFrameScrollBar)

	_G.BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
end

S:AddCallback('Battlefield', LoadSkin)