local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tabard then return end

	local TabardFrame = _G.TabardFrame
	S:HandleFrame(TabardFrame, true, nil, 10, -12, -32, 74)

	S:HandleCloseButton(_G.TabardFrameCloseButton)

	S:HandleButton(_G.TabardFrameCancelButton)
	S:HandleButton(_G.TabardFrameAcceptButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateRightButton)

	_G.TabardModel:CreateBackdrop()
	_G.TabardFrameCostFrame:StripTextures()
	_G.TabardFrameCustomizationFrame:StripTextures()

	--Add Tabard Emblem back
	local emblemFrames = {
		_G.TabardFrameEmblemTopRight,
		_G.TabardFrameEmblemBottomRight,
		_G.TabardFrameEmblemTopLeft,
		_G.TabardFrameEmblemBottomLeft,
	}
	for _, frame in pairs(emblemFrames) do
		frame:SetParent(TabardFrame)
		frame.Show = nil
		frame:Show()
	end

	for i = 1, 5 do
		local custom = 'TabardFrameCustomization'..i
		_G[custom]:StripTextures()
		S:HandleNextPrevButton(_G[custom..'LeftButton'])
		S:HandleNextPrevButton(_G[custom..'RightButton'])

		if i > 1 then
			_G[custom]:ClearAllPoints()
			_G[custom]:Point('TOP', _G['TabardFrameCustomization'..i - 1], 'BOTTOM', 0, -6)
		else
			local point, anchor, point2, x, y = _G[custom]:GetPoint()
			_G[custom]:Point(point, anchor, point2, x, y+4)
		end
	end

	_G.TabardCharacterModelRotateLeftButton:Point('BOTTOMLEFT', 4, 4)
	_G.TabardCharacterModelRotateRightButton:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)

	hooksecurefunc(_G.TabardCharacterModelRotateLeftButton, 'SetPoint', function(self)
		if self._blocked then return end
		self._blocked = true
		self:Point('BOTTOMLEFT', 4, 4)
		self._blocked = nil
	end)

	hooksecurefunc(_G.TabardCharacterModelRotateRightButton, 'SetPoint', function(self)
		if self._blocked then return end
		self._blocked = true
		self:Point('TOPLEFT', TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)
		self._blocked = nil
	end)
end

S:AddCallback('Skin_Tabard', LoadSkin)
