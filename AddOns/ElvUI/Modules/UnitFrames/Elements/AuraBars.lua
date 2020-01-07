local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local _G = _G
local tostring = tostring
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown

-- GLOBALS: ElvUF_Player

local function OnClick(self)
	local mod = E.db.unitframe.auraBlacklistModifier
	if mod == "NONE" or not ((mod == "SHIFT" and IsShiftKeyDown()) or (mod == "ALT" and IsAltKeyDown()) or (mod == "CTRL" and IsControlKeyDown())) then return end
	local auraName = self.name

	if auraName then
		E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
		E.global.unitframe.aurafilters.Blacklist.spells[auraName] = { enable = true, priority = 0 }
		UF:Update_AllFrames()
	end
end

function UF:Construct_AuraBars(statusBar)
	statusBar:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)
	statusBar:SetScript('OnMouseDown', OnClick)
	statusBar:SetPoint("LEFT")
	statusBar:SetPoint("RIGHT")

	statusBar.icon:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)
	UF.statusbars[statusBar] = true
	UF:Update_StatusBar(statusBar)

	UF:Configure_FontString(statusBar.timeText)
	UF:Configure_FontString(statusBar.nameText)

	UF:Update_FontString(statusBar.timeText)
	UF:Update_FontString(statusBar.nameText)

	statusBar.nameText:SetJustifyH('LEFT')
	statusBar.nameText:SetJustifyV('MIDDLE')
	statusBar.nameText:SetPoint("RIGHT", statusBar.timeText, "LEFT", -4, 0)
	statusBar.nameText:SetWordWrap(false)

	statusBar.bg = statusBar:CreateTexture(nil, 'BORDER')
	statusBar.bg:Show()

	local frame = statusBar:GetParent()
	statusBar.db = frame.db and frame.db.aurabar
end

function UF:AuraBars_SetPosition(from, to)
	local height = self.height
	local spacing = self.spacing
	local anchor = self.initialAnchor
	local growth = self.growth == 'BELOW' and -1 or 1

	for i = from, to do
		local button = self[i]
		if(not button) then break end

		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint(anchor, self, anchor, -E.Border, 0)
		else
			button:SetPoint(anchor, self, anchor, -(E.Border), growth * ((i - 1) * (height + spacing)))
		end
	end
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	auraBar:SetHeight(1)
	auraBar.PreSetPosition = UF.SortAuras
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.PostUpdateBar = UF.PostUpdateBar_AuraBars
	auraBar.CustomFilter = UF.AuraFilter
	auraBar.SetPosition = UF.AuraBars_SetPosition

	auraBar.sparkEnabled = true
	auraBar.initialAnchor = 'BOTTOMRIGHT'
	auraBar.type = 'aurabar'

	return auraBar
end

function UF:Configure_AuraBars(frame)
	if not frame.VARIABLES_SET then return end
	local auraBars = frame.AuraBars
	local db = frame.db
	auraBars.db = db.aurabar

	if db.aurabar.enable then
		if not frame:IsElementEnabled('AuraBars') then
			frame:EnableElement('AuraBars')
		end

		local index = 1
		while auraBars[index] do
			local button = auraBars[index]
			if button then
				button.db = auraBars.db
			end

			index = index + 1
		end

		auraBars.friendlyAuraType = db.aurabar.friendlyAuraType
		auraBars.enemyAuraType = db.aurabar.enemyAuraType

		auraBars:Show()

		local attachTo = frame

		auraBars.height = db.aurabar.height
		auraBars.growth = db.aurabar.anchorPoint
		auraBars.maxBars = db.aurabar.maxBars
		auraBars.spacing = db.aurabar.spacing
		auraBars.width = frame.UNIT_WIDTH - auraBars.height - (frame.BORDER * 4)

		if not auraBars.Holder then
			local holder = CreateFrame('Frame', nil, auraBars)
			holder:Point("BOTTOM", frame, "TOP", 0, 0)
			holder:Size(db.aurabar.detachedWidth, 20)

			if frame.unitframeType == "player" then
				E:CreateMover(holder, 'ElvUF_PlayerAuraMover',  "Player Aura Bars", nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,player,aurabar')
			elseif frame.unitframeType == "target" then
				E:CreateMover(holder, 'ElvUF_TargetAuraMover',  "Target Aura Bars", nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,target,aurabar')
			elseif frame.unitframeType == "pet" then
				E:CreateMover(holder, 'ElvUF_PetAuraMover',  "Pet Aura Bars", nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,pet,aurabar')
			elseif frame.unitframeType == "focus" then
				E:CreateMover(holder, 'ElvUF_FocusAuraMover',  "Focus Aura Bars", nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,focus,aurabar')
			end

			auraBars.Holder = holder
		end

		auraBars.Holder:Size(db.aurabar.detachedWidth, 20)

		if db.aurabar.attachTo ~= "DETACHED" then
			E:DisableMover(auraBars.Holder.mover:GetName())
		end

		if db.aurabar.attachTo == 'BUFFS' then
			attachTo = frame.Buffs
		elseif db.aurabar.attachTo == 'DEBUFFS' then
			attachTo = frame.Debuffs
		elseif db.aurabar.attachTo == "PLAYER_AURABARS" and _G.ElvUF_Player then
			attachTo = _G.ElvUF_Player.AuraBars
		elseif db.aurabar.attachTo == "DETACHED" then
			attachTo = auraBars.Holder
			E:EnableMover(auraBars.Holder.mover:GetName())
			auraBars.width = db.aurabar.detachedWidth - db.aurabar.height
		end

		local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
		if db.aurabar.anchorPoint == 'BELOW' then
			anchorPoint, anchorTo = 'TOP', 'BOTTOM'
		end

		local yOffset
		local spacing = (((db.aurabar.attachTo == "FRAME" and 3) or (db.aurabar.attachTo == "PLAYER_AURABARS" and 4) or 2) * frame.SPACING)
		local border = (((db.aurabar.attachTo == "FRAME" or db.aurabar.attachTo == "PLAYER_AURABARS") and 0 or 1) * frame.BORDER)

		if db.aurabar.anchorPoint == 'BELOW' then
			yOffset = -spacing + border - (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
		else
			yOffset = spacing - border + (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
		end

		local xOffset = (db.aurabar.attachTo == "FRAME" and frame.SPACING or 0)
		local offsetLeft = xOffset + ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "LEFT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "LEFT"))) and frame.POWERBAR_OFFSET or 0)
		local offsetRight = -xOffset - ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "RIGHT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "RIGHT"))) and frame.POWERBAR_OFFSET or 0)

		auraBars:ClearAllPoints()
		auraBars:Point(anchorPoint..'LEFT', attachTo, anchorTo..'LEFT', offsetLeft, db.aurabar.attachTo == "DETACHED" and 0 or yOffset)
		auraBars:Point(anchorPoint..'RIGHT', attachTo, anchorTo..'RIGHT', offsetRight, db.aurabar.attachTo == "DETACHED" and 0 or yOffset)
	elseif frame:IsElementEnabled('AuraBars') then
		frame:DisableElement('AuraBars')
		auraBars:Hide()
	end
end

local GOTAK_ID = 86659
local GOTAK = GetSpellInfo(GOTAK_ID)
function UF:PostUpdateBar_AuraBars(unit, statusBar, index, position, duration, expiration, debuffType, isStealable)
	local spellID = statusBar.spellID
	local spellName = statusBar.spell

	statusBar.db = self.db
	statusBar.icon:SetTexCoord(unpack(E.TexCoords))

	local colors = E.global.unitframe.AuraBarColors[spellID] or E.global.unitframe.AuraBarColors[tostring(spellID)] or E.global.unitframe.AuraBarColors[spellName]

	if E.db.unitframe.colors.auraBarTurtle and (E.global.unitframe.aurafilters.TurtleBuffs.spells[spellID] or E.global.unitframe.aurafilters.TurtleBuffs.spells[spellName]) and not colors and (spellName ~= GOTAK or (spellName == GOTAK and spellID == GOTAK_ID)) then
		colors = E.db.unitframe.colors.auraBarTurtleColor
	end

	if not colors then
		if UF.db.colors.auraBarByType and statusBar.filter == 'HARMFUL' then
			if (not debuffType or (debuffType == '' or debuffType == 'none')) then
				colors = UF.db.colors.auraBarDebuff
			else
				colors = DebuffTypeColor[debuffType]
			end
		elseif statusBar.filter == 'HARMFUL' then
			colors = UF.db.colors.auraBarDebuff
		else
			colors = UF.db.colors.auraBarBuff
		end
	end

	statusBar.custom_backdrop = UF.db.colors.customaurabarbackdrop and UF.db.colors.aurabar_backdrop

	if statusBar.bg then
		if (UF.db.colors.transparentAurabars and not statusBar.isTransparent) or (statusBar.isTransparent and (not UF.db.colors.transparentAurabars or statusBar.invertColors ~= UF.db.colors.invertAurabars)) then
			UF:ToggleTransparentStatusBar(UF.db.colors.transparentAurabars, statusBar, statusBar.bg, nil, UF.db.colors.invertAurabars)
		else
			local sbTexture = statusBar:GetStatusBarTexture()
			if not statusBar.bg:GetTexture() then UF:Update_StatusBar(statusBar.bg, sbTexture:GetTexture()) end

			UF:SetStatusBarBackdropPoints(statusBar, sbTexture, statusBar.bg)
		end
	end

	if colors then
		statusBar:SetStatusBarColor(colors.r, colors.g, colors.b)

		if not statusBar.hookedColor then
			UF.UpdateBackdropTextureColor(statusBar, colors.r, colors.g, colors.b)
		end
	else
		local r, g, b = statusBar:GetStatusBarColor()
		UF.UpdateBackdropTextureColor(statusBar, r, g, b)
	end
end
