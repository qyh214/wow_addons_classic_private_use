local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	S:HandleFrame(AddonList, true)

	S:HandleButton(AddonList.EnableAllButton, true)
	S:HandleButton(AddonList.DisableAllButton, true)
	S:HandleButton(AddonList.OkayButton, true)
	S:HandleButton(AddonList.CancelButton, true)

	S:HandleDropDownBox(_G.AddonCharacterDropDown, 165)

	S:HandleScrollBar(_G.AddonListScrollFrameScrollBar)
	S:HandleCheckBox(_G.AddonListForceLoad)

	_G.AddonListForceLoad:Size(26, 26)

	S:HandleFrame(_G.AddonListScrollFrame, true, nil, -14, 0, 0, -1)

	for i = 1, _G.MAX_ADDONS_DISPLAYED do
		S:HandleCheckBox(_G['AddonListEntry'..i..'Enabled'], nil, nil, true)
		S:HandleButton(_G['AddonListEntry'..i].LoadAddonButton)
	end
end

S:AddCallback('AddonList')
