local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local tinsert, xpcall, next, wipe, format = tinsert, xpcall, next, wipe, format
local unpack, assert, pairs, select, type, strfind = unpack, assert, pairs, select, type, strfind

local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded

S.allowBypass = {}
S.addonsToLoad = {}
S.nonAddonsToLoad = {}

S.Blizzard = {}
S.Blizzard.Regions = {
	'Left',
	'Middle',
	'Right',
	'Mid',
	'LeftDisabled',
	'MiddleDisabled',
	'RightDisabled',
	'TopLeft',
	'TopRight',
	'BottomLeft',
	'BottomRight',
	'TopMiddle',
	'MiddleLeft',
	'MiddleRight',
	'BottomMiddle',
	'MiddleMiddle',
	'TabSpacer',
	'TabSpacer1',
	'TabSpacer2',
	'_RightSeparator',
	'_LeftSeparator',
	'Cover',
	'Border',
	'Background',
	'TopTex',
	'TopLeftTex',
	'TopRightTex',
	'LeftTex',
	'BottomTex',
	'BottomLeftTex',
	'BottomRightTex',
	'RightTex',
	'MiddleTex',
	'Center',
}

-- Depends on the arrow texture to be up by default.
S.ArrowRotation = {
	up = 0,
	down = 3.14,
	left = 1.57,
	right = -1.57,
}

function S:HandleFrame(frame, setBackdrop, template, x1, y1, x2, y2)
	assert(frame, 'doesnt exist!')

	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		S:HandleInsetFrame(insetFrame)
	end

	if frame.CloseButton then
		S:HandleCloseButton(frame.CloseButton)
	end

	if setBackdrop then
		frame:CreateBackdrop(template or 'Transparent')
	else
		frame:SetTemplate(template or 'Transparent')
	end

	if frame.backdrop then
		frame.backdrop:Point('TOPLEFT', x1 or 0, y1 or 0)
		frame.backdrop:Point('BOTTOMRIGHT', x2 or 0, y2 or 0)
	end
end

function S:HandleInsetFrame(frame)
	assert(frame, 'doesnt exist!')

	if frame.InsetBorderTop then frame.InsetBorderTop:Hide() end
	if frame.InsetBorderTopLeft then frame.InsetBorderTopLeft:Hide() end
	if frame.InsetBorderTopRight then frame.InsetBorderTopRight:Hide() end

	if frame.InsetBorderBottom then frame.InsetBorderBottom:Hide() end
	if frame.InsetBorderBottomLeft then frame.InsetBorderBottomLeft:Hide() end
	if frame.InsetBorderBottomRight then frame.InsetBorderBottomRight:Hide() end

	if frame.InsetBorderLeft then frame.InsetBorderLeft:Hide() end
	if frame.InsetBorderRight then frame.InsetBorderRight:Hide() end

	if frame.Bg then frame.Bg:Hide() end
end

-- All frames that have a Portrait
function S:HandlePortraitFrame(frame, setTemplate)
	assert(frame, 'doesnt exist!')

	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		S:HandleInsetFrame(insetFrame)
	end

	if frame.CloseButton then
		S:HandleCloseButton(frame.CloseButton)
	end

	if setTemplate then
		frame:CreateBackdrop('Transparent')
	else
		frame:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)
	end
end

function S:SetModifiedBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		if self.SetBackdropBorderColor then
			self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end
	end
end

function S:SetOriginalBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		if self.SetBackdropBorderColor then
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
end

-- function to handle the recap button script
function S:UpdateRecapButton()
	-- when UpdateRecapButton runs and enables the button, it unsets OnEnter
	-- we need to reset it with ours. blizzard will replace it when the button
	-- is disabled. so, we don't have to worry about anything else.
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript('OnEnter', S.SetModifiedBackdrop)
		self.button4:SetScript('OnLeave', S.SetOriginalBackdrop)
	end
end

-- We need to test this for the BGScore frame
S.PVPHonorXPBarFrames = {}
S.PVPHonorXPBarSkinned = false

function S:SkinPVPHonorXPBar(frame)
	S.PVPHonorXPBarFrames[frame] = true

	if S.PVPHonorXPBarSkinned then return end
	S.PVPHonorXPBarSkinned = true

	hooksecurefunc('PVPHonorXPBar_SetNextAvailable', function(XPBar)
		if not S.PVPHonorXPBarFrames[XPBar:GetParent():GetName()] then return end
		XPBar:StripTextures() --XPBar

		if XPBar.Bar and not XPBar.Bar.backdrop then
			XPBar.Bar:CreateBackdrop()
			if XPBar.Bar.Background then
				XPBar.Bar.Background:SetInside(XPBar.Bar.backdrop)
			end
			if XPBar.Bar.Spark then
				XPBar.Bar.Spark:SetAlpha(0)
			end
			if XPBar.Bar.OverlayFrame and XPBar.Bar.OverlayFrame.Text then
				XPBar.Bar.OverlayFrame.Text:ClearAllPoints()
				XPBar.Bar.OverlayFrame.Text:Point('CENTER', XPBar.Bar)
			end
		end

		if XPBar.PrestigeReward and XPBar.PrestigeReward.Accept then
			XPBar.PrestigeReward.Accept:ClearAllPoints()
			XPBar.PrestigeReward.Accept:Point('TOP', XPBar.PrestigeReward, 'BOTTOM', 0, 0)
			if not XPBar.PrestigeReward.Accept.template then
				S:HandleButton(XPBar.PrestigeReward.Accept)
			end
		end

		if XPBar.NextAvailable then
			if XPBar.Bar then
				XPBar.NextAvailable:ClearAllPoints()
				XPBar.NextAvailable:Point('LEFT', XPBar.Bar, 'RIGHT', 0, -2)
			end

			if not XPBar.NextAvailable.backdrop then
				XPBar.NextAvailable:StripTextures()
				XPBar.NextAvailable:CreateBackdrop()

				if XPBar.NextAvailable.Icon then
					local x = E.PixelMode and 1 or 2
					XPBar.NextAvailable.backdrop:Point('TOPLEFT', XPBar.NextAvailable.Icon, -x, x)
					XPBar.NextAvailable.backdrop:Point('BOTTOMRIGHT', XPBar.NextAvailable.Icon, x, -x)
				end
			end

			if XPBar.NextAvailable.Icon then
				XPBar.NextAvailable.Icon:SetDrawLayer('ARTWORK')
				XPBar.NextAvailable.Icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	end)
end

function S:StatusBarColorGradient(bar, value, max, backdrop)
	local current = (not max and value) or (value and max and max ~= 0 and value/max)
	if not (bar and current) then return end
	local r, g, b = E:ColorGradient(current, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
	local bg = backdrop or bar.backdrop
	if bg then bg:SetBackdropColor(r*0.25, g*0.25, b*0.25) end
	bar:SetStatusBarColor(r, g, b)
end

-- DropDownMenu library support
function S:SkinLibDropDownMenu(prefix)
	if _G[prefix..'_UIDropDownMenu_CreateFrames'] and not S[prefix..'_UIDropDownMenuSkinned'] then
		local bd = _G[prefix..'_DropDownList1Backdrop']
		local mbd = _G[prefix..'_DropDownList1MenuBackdrop']
		if bd and not bd.template then bd:SetTemplate('Transparent') end
		if mbd and not mbd.template then mbd:SetTemplate('Transparent') end

		S[prefix..'_UIDropDownMenuSkinned'] = true
		hooksecurefunc(prefix..'_UIDropDownMenu_CreateFrames', function()
			local lvls = _G[(prefix == 'Lib' and 'LIB' or prefix)..'_UIDROPDOWNMENU_MAXLEVELS'];
			local ddbd = lvls and _G[prefix..'_DropDownList'..lvls..'Backdrop'];
			local ddmbd = lvls and _G[prefix..'_DropDownList'..lvls..'MenuBackdrop'];
			if ddbd and not ddbd.template then ddbd:SetTemplate('Transparent') end
			if ddmbd and not ddmbd.template then ddmbd:SetTemplate('Transparent') end
		end)
	end
end

function S:SkinTalentListButtons(frame)
	local name = frame and frame.GetName and frame:GetName()
	if name then
		local bcl = _G[name..'BtnCornerLeft']
		local bcr = _G[name..'BtnCornerRight']
		local bbb = _G[name..'ButtonBottomBorder']
		if bcl then bcl:SetTexture() end
		if bcr then bcr:SetTexture() end
		if bbb then bbb:SetTexture() end
	end

	if frame.Inset then
		S:HandleInsetFrame(frame.Inset)

		frame.Inset:Point('TOPLEFT', 4, -60)
		frame.Inset:Point('BOTTOMRIGHT', -6, 26)
	end
end

do
	local function iconBorderColor(border, r, g, b, a)
		border:StripTextures()

		if border.customFunc then
			local br, bg, bb = unpack(E.media.bordercolor)
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	local function iconBorderHide(border)
		local br, bg, bb = unpack(E.media.bordercolor)
		if border.customFunc then
			local r, g, b, a = border:GetVertexColor()
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end

	function S:HandleIconBorder(border, backdrop, customFunc)
		if not backdrop then
			local parent = border:GetParent()
			backdrop = parent.backdrop or parent
		end

		border.customBackdrop = backdrop

		if not border.IconBorderHooked then
			border:StripTextures()

			hooksecurefunc(border, 'SetVertexColor', iconBorderColor)
			hooksecurefunc(border, 'Hide', iconBorderHide)

			border.IconBorderHooked = true
		end

		local r, g, b, a = border:GetVertexColor()
		if customFunc then
			border.customFunc = customFunc
			local br, bg, bb = unpack(E.media.bordercolor)
			customFunc(border, r, g, b, a, br, bg, bb)
		elseif r then
			backdrop:SetBackdropBorderColor(r, g, b, a)
		else
			local br, bg, bb = unpack(E.media.bordercolor)
			backdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end
end

function S:HandleButton(button, strip, isDeclineButton, noStyle, setTemplate, styleTemplate, noGlossTex, overrideTex, frameLevel)
	assert(button, 'doesnt exist!')

	if button.isSkinned then return end

	if button.SetNormalTexture and not overrideTex then button:SetNormalTexture('') end
	if button.SetHighlightTexture then button:SetHighlightTexture('') end
	if button.SetPushedTexture then button:SetPushedTexture('') end
	if button.SetDisabledTexture then button:SetDisabledTexture('') end

	if strip then button:StripTextures() end
	S:HandleBlizzardRegions(button)

	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
			button.Icon:SetTexture(E.Media.Textures.ArrowUp)
			button.Icon:SetRotation(S.ArrowRotation.right)
			button.Icon:SetVertexColor(1, 1, 1)
		end
	end

	if isDeclineButton then
		if button.Icon then
			button.Icon:SetTexture(E.Media.Textures.Close)
		end
	end

	if not noStyle then
		if setTemplate then
			button:SetTemplate(styleTemplate, not noGlossTex)
		else
			button:CreateBackdrop(styleTemplate, not noGlossTex, nil, nil, nil, nil, true, frameLevel)
		end

		button:HookScript('OnEnter', S.SetModifiedBackdrop)
		button:HookScript('OnLeave', S.SetOriginalBackdrop)
	end

	button.isSkinned = true
end

function S:HandleCategoriesButtons(button, strip)
	if button.isSkinned then return end

	local ButtonName = button.GetName and button:GetName()

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetHighlightTexture then button:SetHighlightTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.SetDisabledTexture then button:SetDisabledTexture("") end

	if strip then button:StripTextures() end

	for _, Region in pairs(S.Blizzard.Regions) do
		Region = ButtonName and _G[ButtonName..Region] or button[Region]
		if Region and Region.SetAlpha then
			Region:SetAlpha(0)
		end
	end

	local r, g, b = unpack(E.media.rgbvaluecolor)

	button.HighlightTexture = button:CreateTexture(nil, "BACKGROUND")
	button.HighlightTexture:SetBlendMode("BLEND")
	button.HighlightTexture:SetSnapToPixelGrid(false)
	button.HighlightTexture:SetTexelSnappingBias(0)
	button.HighlightTexture:Size(button:GetSize())
	button.HighlightTexture:Point("CENTER", button, 0, 2)
	button.HighlightTexture:SetTexture(E.Media.Textures.Highlight)
	button.HighlightTexture:SetVertexColor(0, 0, 0, 0)
	button.HighlightTexture:Hide()

	button:HookScript("OnEnter", function()
		button.HighlightTexture:SetVertexColor(r, g, b, 0.50)
		button.HighlightTexture:Show()
	end)

	button:HookScript("OnLeave", function()
		button.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		button.HighlightTexture:Hide()
	end)

	button.isSkinned = true
end

do
	local function GrabScrollBarElement(frame, element)
		local FrameName = frame:GetName()
		return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
	end

	function S:HandleScrollBar(frame, thumbTrimY, thumbTrimX)
		assert(frame, 'doesnt exist!')

		if frame.backdrop then return end
		local parent = frame:GetParent()
		local ScrollUpButton = GrabScrollBarElement(frame, 'ScrollUpButton') or GrabScrollBarElement(frame, 'UpButton') or GrabScrollBarElement(frame, 'ScrollUp') or GrabScrollBarElement(parent, 'scrollUp')
		local ScrollDownButton = GrabScrollBarElement(frame, 'ScrollDownButton') or GrabScrollBarElement(frame, 'DownButton') or GrabScrollBarElement(frame, 'ScrollDown') or GrabScrollBarElement(parent, 'scrollDown')
		local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

		frame:StripTextures()
		frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
		frame.backdrop:Point('TOPLEFT', ScrollUpButton or frame, ScrollUpButton and 'BOTTOMLEFT' or 'TOPLEFT', 0, 0)
		frame.backdrop:Point('BOTTOMRIGHT', ScrollDownButton or frame, ScrollUpButton and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 0)

		if frame.ScrollUpBorder then
			frame.ScrollUpBorder:Hide()
		end
		if frame.ScrollDownBorder then
			frame.ScrollDownBorder:Hide()
		end

		for _, Button in pairs({ ScrollUpButton, ScrollDownButton }) do
			if Button then
				S:HandleNextPrevButton(Button)
			end
		end

		if Thumb and not Thumb.backdrop then
			Thumb:SetTexture()
			Thumb:CreateBackdrop(nil, true, true, nil, nil, nil, nil, frame:GetFrameLevel() + 1)

			if Thumb.backdrop then
				if not thumbTrimY then thumbTrimY = 3 end
				if not thumbTrimX then thumbTrimX = 2 end
				Thumb.backdrop:Point('TOPLEFT', Thumb, 'TOPLEFT', 2, -thumbTrimY)
				Thumb.backdrop:Point('BOTTOMRIGHT', Thumb, 'BOTTOMRIGHT', -thumbTrimX, thumbTrimY)
				Thumb.backdrop:SetBackdropColor(0.6, 0.6, 0.6)
			end

			frame.Thumb = Thumb
		end
	end
end

do --Tab Regions
	local tabs = {
		'LeftDisabled',
		'MiddleDisabled',
		'RightDisabled',
		'Left',
		'Middle',
		'Right'
	}

	function S:HandleTab(tab, noBackdrop)
		if not tab or (tab.backdrop and not noBackdrop) then return end

		for _, object in pairs(tabs) do
			local textureName = tab:GetName() and _G[tab:GetName()..object]
			if textureName then
				textureName:SetTexture()
			elseif tab[object] then
				tab[object]:SetTexture()
			end
		end

		local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
		if highlightTex then
			highlightTex:SetTexture()
		else
			tab:StripTextures()
		end

		if not noBackdrop then
			tab:CreateBackdrop()
			tab.backdrop:Point('TOPLEFT', 10, E.PixelMode and -1 or -3)
			tab.backdrop:Point('BOTTOMRIGHT', -10, 3)
		end
	end
end

function S:HandleRotateButton(btn)
	if btn.isSkinned then return end

	btn:CreateBackdrop()
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)

	local normTex = btn:GetNormalTexture()
	local pushTex = btn:GetPushedTexture()
	local highlightTex = btn:GetHighlightTexture()

	normTex:SetInside()
	normTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	pushTex:SetAllPoints(normTex)
	pushTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	highlightTex:SetAllPoints(normTex)
	highlightTex:SetColorTexture(1, 1, 1, 0.3)

	btn.isSkinned = true
end

do
	local btns = {MaximizeButton = 'up', MinimizeButton = 'down'}
	function S:HandleMaxMinFrame(frame)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures(true)

		for name, direction in pairs(btns) do
			local button = frame[name]
			if button then
				button:Size(14, 14)
				button:ClearAllPoints()
				button:Point('CENTER')
				button:SetHitRectInsets(1, 1, 1, 1)
				button:GetHighlightTexture():Kill()

				button:SetScript('OnEnter', function(btn)
					local r,g,b = unpack(E.media.rgbvaluecolor)
					btn:GetNormalTexture():SetVertexColor(r,g,b)
					btn:GetPushedTexture():SetVertexColor(r,g,b)
				end)

				button:SetScript('OnLeave', function(btn)
					btn:GetNormalTexture():SetVertexColor(1, 1, 1)
					btn:GetPushedTexture():SetVertexColor(1, 1, 1)
				end)

				button:SetNormalTexture(E.Media.Textures.ArrowUp)
				button:GetNormalTexture():SetRotation(S.ArrowRotation[direction])

				button:SetPushedTexture(E.Media.Textures.ArrowUp)
				button:GetPushedTexture():SetRotation(S.ArrowRotation[direction])
			end
		end

		frame.isSkinned = true
	end
end

function S:HandleBlizzardRegions(frame, name, kill)
	if not name then name = frame.GetName and frame:GetName() end
	for _, area in pairs(S.Blizzard.Regions) do
		local object = (name and _G[name..area]) or frame[area]
		if object then
			if kill then
				object:Kill()
			elseif object.SetAlpha then
				object:SetAlpha(0)
			end
		end
	end
end

function S:HandleEditBox(frame)
	assert(frame, 'doesnt exist!')

	if frame.backdrop then return end

	frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
	S:HandleBlizzardRegions(frame)

	local EditBoxName = frame:GetName()
	if EditBoxName and (strfind(EditBoxName, 'Silver') or strfind(EditBoxName, 'Copper')) then
		frame.backdrop:Point('BOTTOMRIGHT', -12, -2)
	end
end

function S:HandleDropDownBox(frame, width, pos)
	assert(frame, 'doesnt exist!')

	local frameName = frame.GetName and frame:GetName()
	local button = frame.Button or frameName and (_G[frameName..'Button'] or _G[frameName..'_Button'])
	local text = frameName and _G[frameName..'Text'] or frame.Text
	local icon = frame.Icon

	if not width then
		width = 155
	end

	frame:StripTextures()
	frame:Width(width)

	frame:CreateBackdrop()
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	frame.backdrop:Point('TOPLEFT', 20, -2)
	frame.backdrop:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 2, -2)

	button:ClearAllPoints()

	if pos then
		button:Point('TOPRIGHT', frame.Right, -20, -21)
	else
		button:Point('RIGHT', frame, 'RIGHT', -10, 3)
	end

	button.SetPoint = E.noop
	S:HandleNextPrevButton(button, 'down')

	if text then
		text:ClearAllPoints()
		text:Point('RIGHT', button, 'LEFT', -2, 0)
	end

	if icon then
		icon:Point('LEFT', 23, 0)
	end
end

function S:HandleStatusBar(frame, color)
	frame:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')
	frame:SetStatusBarTexture(E.media.normTex)
	frame:SetStatusBarColor(unpack(color or {.01, .39, .1}))
	E:RegisterStatusBar(frame)
end

do
	local check = [[Interface\Buttons\UI-CheckBox-Check]]
	local disabled = [[Interface\Buttons\UI-CheckBox-Check-Disabled]]
	function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, frameLevel)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures()

		if noBackdrop then
			frame:Size(16)
		else
			frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, frameLevel)
			frame.backdrop:SetInside(nil, 4, 4)
		end

		if not noReplaceTextures then
			if frame.SetCheckedTexture then
				if E.private.skins.checkBoxSkin then
					frame:SetCheckedTexture(E.Media.Textures.Melli)

					local checkedTexture = frame:GetCheckedTexture()
					checkedTexture:SetVertexColor(1, .82, 0, 0.8)
					checkedTexture:SetInside(frame.backdrop)
				else
					frame:SetCheckedTexture(check)

					if noBackdrop then
						frame:GetCheckedTexture():SetInside(nil, -4, -4)
					end
				end
			end

			if frame.SetDisabledTexture then
				if E.private.skins.checkBoxSkin then
					frame:SetDisabledTexture(E.Media.Textures.Melli)

					local disabledTexture = frame:GetDisabledTexture()
					disabledTexture:SetVertexColor(.6, .6, .6, .8)
					disabledTexture:SetInside(frame.backdrop)
				else
					frame:SetDisabledTexture(disabled)

					if noBackdrop then
						frame:GetDisabledTexture():SetInside(nil, -4, -4)
					end
				end
			end

			frame:HookScript('OnDisable', function(checkbox)
				if not checkbox.SetDisabledTexture then return; end
				if checkbox:GetChecked() then
					if E.private.skins.checkBoxSkin then
						checkbox:SetDisabledTexture(E.Media.Textures.Melli)
					else
						checkbox:SetDisabledTexture(disabled)
					end
				else
					checkbox:SetDisabledTexture('')
				end
			end)

			hooksecurefunc(frame, 'SetNormalTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetNormalTexture('') end
			end)
			hooksecurefunc(frame, 'SetPushedTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetPushedTexture('') end
			end)
			hooksecurefunc(frame, 'SetHighlightTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetHighlightTexture('') end
			end)
			hooksecurefunc(frame, 'SetCheckedTexture', function(checkbox, texPath)
				if texPath == E.Media.Textures.Melli or texPath == check then return end
				if E.private.skins.checkBoxSkin then
					checkbox:SetCheckedTexture(E.Media.Textures.Melli)
				else
					checkbox:SetCheckedTexture(check)
				end
			end)
		end

		frame.isSkinned = true
	end
end

function S:HandleRadioButton(Button)
	if Button.isSkinned then return end

	local InsideMask = Button:CreateMaskTexture()
	InsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	InsideMask:Size(10, 10)
	InsideMask:Point('CENTER')

	Button.InsideMask = InsideMask

	local OutsideMask = Button:CreateMaskTexture()
	OutsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	OutsideMask:Size(13, 13)
	OutsideMask:Point('CENTER')

	Button.OutsideMask = OutsideMask

	Button:SetCheckedTexture(E.media.normTex)
	Button:SetNormalTexture(E.media.normTex)
	Button:SetHighlightTexture(E.media.normTex)
	Button:SetDisabledTexture(E.media.normTex)

	local Check = Button:GetCheckedTexture()
	Check:SetVertexColor(unpack(E.media.rgbvaluecolor))
	Check:SetTexCoord(0, 1, 0, 1)
	Check:SetInside()
	Check:AddMaskTexture(InsideMask)

	local Highlight = Button:GetHighlightTexture()
	Highlight:SetTexCoord(0, 1, 0, 1)
	Highlight:SetVertexColor(1, 1, 1)
	Highlight:AddMaskTexture(InsideMask)

	local Normal = Button:GetNormalTexture()
	Normal:SetOutside()
	Normal:SetTexCoord(0, 1, 0, 1)
	Normal:SetVertexColor(unpack(E.media.bordercolor))
	Normal:AddMaskTexture(OutsideMask)

	local Disabled = Button:GetDisabledTexture()
	Disabled:SetVertexColor(.3, .3, .3)
	Disabled:AddMaskTexture(OutsideMask)

	hooksecurefunc(Button, 'SetNormalTexture', function(f, t) if t ~= '' then f:SetNormalTexture('') end end)
	hooksecurefunc(Button, 'SetPushedTexture', function(f, t) if t ~= '' then f:SetPushedTexture('') end end)
	hooksecurefunc(Button, 'SetHighlightTexture', function(f, t) if t ~= '' then f:SetHighlightTexture('') end end)
	hooksecurefunc(Button, 'SetDisabledTexture', function(f, t) if t ~= '' then f:SetDisabledTexture('') end end)

	Button.isSkinned = true
end

function S:HandleIcon(icon, backdrop)
	icon:SetTexCoord(unpack(E.TexCoords))

	if backdrop and not icon.backdrop then
		icon:CreateBackdrop()
	end
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return; end

	local name = b:GetName()
	local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name..'IconTexture'] or _G[name..'Icon']))
	local texture = icon and icon.GetTexture and icon:GetTexture()

	b:StripTextures()
	b:CreateBackdrop(nil, true, nil, nil, nil, nil, true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		-- create a backdrop around the icon
		if shrinkIcon then
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon, 1, 1)
		end

		icon:SetParent(b.backdrop)

		if texture then
			icon:SetTexture(texture)
		end
	end

	b.isSkinned = true
end

local handleCloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
local handleCloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

function S:HandleCloseButton(f, point, x, y)
	assert(f, 'doenst exist!')

	f:StripTextures()

	if not f.Texture then
		f.Texture = f:CreateTexture(nil, 'OVERLAY')
		f.Texture:Point('CENTER')
		f.Texture:SetTexture(E.Media.Textures.Close)
		f.Texture:Size(12, 12)
		f:HookScript('OnEnter', handleCloseButtonOnEnter)
		f:HookScript('OnLeave', handleCloseButtonOnLeave)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if point then
		f:Point('TOPRIGHT', point, 'TOPRIGHT', x or 2, y or 2)
	end
end

function S:HandleSliderFrame(frame)
	assert(frame, 'doesnt exist!')

	local orientation = frame:GetOrientation()
	local SIZE = 12

	frame:SetBackdrop()
	frame:StripTextures()
	frame:SetThumbTexture(E.Media.Textures.Melli)

	if not frame.backdrop then
		frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, true)
	end

	local thumb = frame:GetThumbTexture()
	thumb:SetVertexColor(1, .82, 0, 0.8)
	thumb:Size(SIZE-2,SIZE-2)

	if orientation == 'VERTICAL' then
		frame:Width(SIZE)
	else
		frame:Height(SIZE)

		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

-- Interface\SharedXML\SharedUIPanelTemplatex.xml - line 780
function S:HandleTooltipBorderedFrame(frame)
	assert(frame, 'doesnt exist!')

	if frame.BorderTopLeft then frame.BorderTopLeft:Hide() end
	if frame.BorderTopRight then frame.BorderTopRight:Hide() end

	if frame.BorderBottomLeft then frame.BorderBottomLeft:Hide() end
	if frame.BorderBottomRight then frame.BorderBottomRight:Hide() end

	if frame.BorderTop then frame.BorderTop:Hide() end
	if frame.BorderBottom then frame.BorderBottom:Hide() end
	if frame.BorderLeft then frame.BorderLeft:Hide() end
	if frame.BorderRight then frame.BorderRight:Hide() end

	if frame.Background then frame.Background:Hide() end

	frame:CreateBackdrop('Transparent')
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	assert(frame, 'HandleIconSelectionFrame: frame argument missing')
	assert(numIcons and type(numIcons) == 'number', 'HandleIconSelectionFrame: numIcons argument missing or not a number')
	assert(buttonNameTemplate and type(buttonNameTemplate) == 'string', 'HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string')

	local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName..'ScrollFrame']
	local editBox = _G[frameName..'EditBox']

	frame:StripTextures()
	frame.BorderBox:StripTextures()
	scrollFrame:StripTextures()
	editBox:DisableDrawLayer('BACKGROUND') -- Removes textures around it

	frame:CreateBackdrop('Transparent')
	frame:Height(frame:GetHeight() + 10)
	scrollFrame:Height(scrollFrame:GetHeight() + 10)

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate..i]
		if button then
			button:StripTextures()
			button:CreateBackdrop()
			button:StyleButton(true)

			local icon = _G[buttonNameTemplate..i..'Icon']
			if icon then
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:Point('TOPLEFT', 1, -1)
				icon:Point('BOTTOMRIGHT', -1, 1)
			end
		end
	end
end

function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts, frameLevel)
	if btn.isSkinned then return end

	if not arrowDir then
		arrowDir = 'down'
		local name = btn:GetDebugName()
		local ButtonName = name and name:lower()
		if ButtonName then
			if strfind(ButtonName, 'left') or strfind(ButtonName, 'prev') or strfind(ButtonName, 'decrement') or strfind(ButtonName, 'backward') or strfind(ButtonName, 'back') then
				arrowDir = 'left'
			elseif strfind(ButtonName, 'right') or strfind(ButtonName, 'next') or strfind(ButtonName, 'increment') or strfind(ButtonName, 'forward') then
				arrowDir = 'right'
			elseif strfind(ButtonName, 'scrollup') or strfind(ButtonName, 'upbutton') or strfind(ButtonName, 'top') or strfind(ButtonName, 'asc') or strfind(ButtonName, 'home') or strfind(ButtonName, 'maximize') then
				arrowDir = 'up'
			end
		end
	end

	btn:StripTextures()
	if not noBackdrop then
		S:HandleButton(btn, nil, nil, nil, nil, nil, nil, nil, frameLevel)
	end

	if stripTexts then
		btn:StripTexts()
	end

	btn:SetNormalTexture(E.Media.Textures.ArrowUp)
	btn:SetPushedTexture(E.Media.Textures.ArrowUp)
	btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

	local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

	if noBackdrop then
		btn:Size(20, 20)
		Disabled:SetVertexColor(.5, .5, .5)
		btn.Texture = Normal

		if not color then
			btn:HookScript('OnEnter', handleCloseButtonOnEnter)
			btn:HookScript('OnLeave', handleCloseButtonOnLeave)
		end
	else
		btn:Size(18, 18)
		Disabled:SetVertexColor(.3, .3, .3)
	end

	Normal:SetInside()
	Pushed:SetInside()
	Disabled:SetInside()

	Normal:SetTexCoord(0, 1, 0, 1)
	Pushed:SetTexCoord(0, 1, 0, 1)
	Disabled:SetTexCoord(0, 1, 0, 1)

	local rotation = S.ArrowRotation[arrowDir]
	if rotation then
		Normal:SetRotation(rotation)
		Pushed:SetRotation(rotation)
		Disabled:SetRotation(rotation)
	end

	if color then
		Normal:SetVertexColor(color.r, color.g, color.b)
	else
		Normal:SetVertexColor(1, 1, 1)
	end

	btn.isSkinned = true
end

do -- Handle collapse
	local function UpdateCollapseTexture(button, texture)
		local tex = button:GetNormalTexture()
		if strfind(texture, 'Plus') or strfind(texture, 'Closed') then
			tex:SetTexture(E.Media.Textures.PlusButton)
		elseif strfind(texture, 'Minus') or strfind(texture, 'Open') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		end
	end

	local function syncPushTexture(button, _, skip)
		if not skip then
			local normal = button:GetNormalTexture():GetTexture()
			button:SetPushedTexture(normal, true)
		end
	end

	function S:HandleCollapseTexture(button, syncPushed)
		if syncPushed then -- not needed always
			hooksecurefunc(button, 'SetPushedTexture', syncPushTexture)
			syncPushTexture(button)
		else
			button:SetPushedTexture('')
		end

		hooksecurefunc(button, 'SetNormalTexture', UpdateCollapseTexture)
		UpdateCollapseTexture(button, button:GetNormalTexture():GetTexture())
	end
end

-- World Map related Skinning functions used for WoW 8.0
function S:WorldMapMixin_AddOverlayFrame(frame, templateName)
	S[templateName](frame.overlayFrames[#frame.overlayFrames])
end

-- Classic Specific S functions
function S:HandleButtonHighlight(frame, r, g, b)
	if frame.SetHighlightTexture then
		frame:SetHighlightTexture('')
	end

	if not r then r = 0.9 end
	if not g then g = 0.9 end
	if not b then b = 0.9 end

	local leftGrad = frame:CreateTexture(nil, 'HIGHLIGHT')
	leftGrad:Size(frame:GetWidth() * 0.5, frame:GetHeight() * 0.95)
	leftGrad:Point('LEFT', frame, 'CENTER')
	leftGrad:SetTexture(E.media.blankTex)
	leftGrad:SetGradientAlpha('Horizontal', r, g, b, 0.35, r, g, b, 0)

	local rightGrad = frame:CreateTexture(nil, 'HIGHLIGHT')
	rightGrad:Size(frame:GetWidth() * 0.5, frame:GetHeight() * 0.95)
	rightGrad:Point('RIGHT', frame, 'CENTER')
	rightGrad:SetTexture(E.media.blankTex)
	rightGrad:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.35)
end

function S:HandlePointXY(frame, x, y)
	local a, b, c, d, e = frame:GetPoint()
	frame:SetPoint(a, b, c, x or d, y or e)
end

function S:SetNextPrevButtonDirection(frame, arrowDir)
	local direction = self.ArrowRotation[(arrowDir or 'down')]

	frame:GetNormalTexture():SetRotation(direction)
	frame:GetDisabledTexture():SetRotation(direction)
	frame:GetPushedTexture():SetRotation(direction)
end

do
	local function SetPanelWindowInfo(frame, name, value, igroneUpdate)
		frame:SetAttribute('UIPanelLayout-'..name, value)

		if name == 'width' then
			frame.__uiPanelWidth = value
		end

		if not igroneUpdate and frame:IsShown() then
			_G.UpdateUIPanelPositions(frame)
		end
	end

	local UI_PANEL_OFFSET = 7
	local inCombat, panelQueue = nil, {}
	function S:SetUIPanelWindowInfo(frame, name, value, offset, igroneUpdate)
		local frameName = frame and frame.GetName and frame:GetName()
		if not (frameName and _G.UIPanelWindows[frameName]) then return end

		if name == 'width' then
			value = E:Scale(value or (frame.backdrop and frame.backdrop:GetWidth() or frame:GetWidth())) + (offset or 0) + UI_PANEL_OFFSET
		end

		if inCombat or InCombatLockdown() then
			local info = format('%s-%s', frameName, name)

			if panelQueue[info] then
				if name == 'width' and frame.__uiPanelWidth and frame.__uiPanelWidth == value then
					panelQueue[info] = nil
				else
					panelQueue[info][3] = value
					panelQueue[info][4] = igroneUpdate
				end
			else
				panelQueue[info] = {frame, name, value, igroneUpdate}
			end

			if not inCombat then
				inCombat = true
				S:RegisterEvent('PLAYER_REGEN_ENABLED')
			end
		else
			SetPanelWindowInfo(frame, name, value, igroneUpdate)
		end
	end

	function S:PLAYER_REGEN_ENABLED()
		S:UnregisterEvent('PLAYER_REGEN_ENABLED')
		inCombat = nil

		for _, info in pairs(panelQueue) do
			SetPanelWindowInfo(unpack(info))
		end

		wipe(panelQueue)
	end
end

function S:ADDON_LOADED(_, addonName)
	if not self.allowBypass[addonName] and not E.initialized then
		return
	end

	local object = self.addonsToLoad[addonName]
	if object then
		S:CallLoadedAddon(addonName, object)
	end
end

-- EXAMPLE:
--- S:AddCallbackForAddon('Details', 'MyAddon_Details', MyAddon.SkinDetails)
---- arg1: Addon name (same as the toc): MyAddon.toc (without extension)
---- arg2: Given name (try to use something that won't be used by someone else)
---- arg3: load function (preferably not-local)
-- this is used for loading skins that should be executed when the addon loads (including blizzard addons that load later).
-- please add a given name, non-given-name is specific for elvui core addon.
function S:AddCallbackForAddon(addonName, name, func, forceLoad, bypass, position) -- arg2: name is 'given name'; see example above.
	local load = (type(name) == 'function' and name) or (not func and (S[name] or S[addonName]))
	S:RegisterSkin(addonName, load or func, forceLoad, bypass, position)
end

-- nonAddonsToLoad:
--- this is used for loading skins when our skin init function executes.
--- please add a given name, non-given-name is specific for elvui core addon.
function S:AddCallback(name, func, position) -- arg1: name is 'given name'
	local load = (type(name) == 'function' and name) or (not func and S[name])
	S:RegisterSkin('ElvUI', load or func, nil, nil, position)
end

local function errorhandler(err)
	return _G.geterrorhandler()(err)
end

function S:RegisterSkin(addonName, func, forceLoad, bypass, position)
	if bypass then
		self.allowBypass[addonName] = true
	end

	if forceLoad then
		xpcall(func, errorhandler)
		self.addonsToLoad[addonName] = nil
	elseif addonName == 'ElvUI' then
		if position then
			tinsert(self.nonAddonsToLoad, position, func)
		else
			tinsert(self.nonAddonsToLoad, func)
		end
	else
		local addon = self.addonsToLoad[addonName]
		if not addon then
			self.addonsToLoad[addonName] = {}
			addon = self.addonsToLoad[addonName]
		end

		if position then
			tinsert(addon, position, func)
		else
			tinsert(addon, func)
		end
	end
end

function S:CallLoadedAddon(addonName, object)
	for _, func in next, object do
		xpcall(func, errorhandler)
	end

	self.addonsToLoad[addonName] = nil
end

function S:Initialize()
	self.Initialized = true
	self.db = E.private.skins

	for index, func in next, self.nonAddonsToLoad do
		xpcall(func, errorhandler)
		self.nonAddonsToLoad[index] = nil
	end

	for addonName, object in pairs(self.addonsToLoad) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			S:CallLoadedAddon(addonName, object)
		end
	end

	-- Early Skin Handling (populated before ElvUI is loaded from the Ace3 file)
	if E.private.skins.ace3Enable and S.EarlyAceWidgets then
		for _, n in next, S.EarlyAceWidgets do
			if n.SetLayout then
				S:Ace3_RegisterAsContainer(n)
			else
				S:Ace3_RegisterAsWidget(n)
			end
		end
		for _, n in next, S.EarlyAceTooltips do
			S:Ace3_SkinTooltip(_G.LibStub(n, true))
		end
	end
	if S.EarlyDropdowns then
		for _, n in next, S.EarlyDropdowns do
			S:SkinLibDropDownMenu(n)
		end
	end
end

-- Keep this outside, it's used for skinning addons before ElvUI load
S:RegisterEvent('ADDON_LOADED')

E:RegisterModule(S:GetName())
