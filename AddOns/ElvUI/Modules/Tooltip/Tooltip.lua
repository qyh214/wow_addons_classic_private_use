local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')

--Lua functions
local _G = _G
local strmatch = strmatch
local unpack, select, ipairs = unpack, select, ipairs
local wipe, tinsert, tconcat = wipe, tinsert, table.concat
local floor, tonumber, strlower = floor, tonumber, strlower
local strfind, format, strmatch, gmatch, gsub = strfind, format, strmatch, gmatch, gsub

local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetGuildInfo = GetGuildInfo
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMouseFocus = GetMouseFocus
local GetNumGroupMembers = GetNumGroupMembers
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsShiftKeyDown = IsShiftKeyDown
local SetTooltipMoney = SetTooltipMoney
local UnitAura = UnitAura
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsAFK = UnitIsAFK
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitRealmRelationship = UnitRealmRelationship
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local UNKNOWN = UNKNOWN

local IsModifierKeyDown = IsModifierKeyDown
-- GLOBALS: ElvUF, ElvUI_KeyBinder, ElvUI_ContainerFrame

-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?',''))
local LEVEL2 = strlower(_G.TOOLTIP_UNIT_LEVEL_CLASS:gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?',''))

local GameTooltip, GameTooltipStatusBar = _G.GameTooltip, _G.GameTooltipStatusBar
local targetList, TAPPED_COLOR, keybindFrame = {}, { r=0.6, g=0.6, b=0.6 }
local AFK_LABEL = ' |cffFFFFFF[|r|cffFF0000'..L["AFK"]..'|r|cffFFFFFF]|r'
local DND_LABEL = ' |cffFFFFFF[|r|cffFFFF00'..L["DND"]..'|r|cffFFFFFF]|r'

function TT:IsModKeyDown(db)
	local k = db or TT.db.modifierID -- defaulted to 'HIDE' unless otherwise specified
	return k == 'SHOW' or ((k == 'SHIFT' and IsShiftKeyDown()) or (k == 'CTRL' and IsControlKeyDown()) or (k == 'ALT' and IsAltKeyDown()))
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private.tooltip.enable ~= true then return end
	if tt:IsForbidden() or not TT.db.visibility then return end
	if tt:GetAnchorType() ~= 'ANCHOR_NONE' then return end

	if InCombatLockdown() and not TT:IsModKeyDown(TT.db.visibility.combatOverride) then
		tt:Hide()
		return
	end

	local owner = tt:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Bar') or strfind(ownerName, 'ElvUI_StanceBar') or strfind(ownerName, 'PetAction')) and not keybindFrame.active and not TT:IsModKeyDown(TT.db.visibility.actionbars) then
		tt:Hide()
		return
	end

	if tt.StatusBar then
		if TT.db.healthBar.statusPosition == "BOTTOM" then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		else
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, (E.Spacing * 3))
				tt.StatusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if TT.db.cursorAnchor then
			tt:SetOwner(parent, TT.db.cursorAnchorType, TT.db.cursorAnchorX, TT.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local ElvUI_ContainerFrame = ElvUI_ContainerFrame
	local RightChatPanel = _G.RightChatPanel
	local TooltipMover = _G.TooltipMover
	local _, anchor = tt:GetPoint()

	if (anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == TooltipMover or anchor == _G.UIParent or anchor == E.UIParent) then
		tt:ClearAllPoints()
		if (not E:HasMoverBeenMoved('TooltipMover')) then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', ElvUI_ContainerFrame, 'TOPRIGHT', 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
			else
				tt:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
			end
		end
	end
end

function TT:RemoveTrashLines(tt)
	if tt:IsForbidden() then return end
	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if(linetext == _G.PVP or linetext == _G.FACTION_ALLIANCE or linetext == _G.FACTION_HORDE) then
			tiptext:SetText('')
			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	if tt:IsForbidden() then return end
	for i = offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft"..i]
		local tipText = tipLine and tipLine.GetText and tipLine:GetText() and strlower(tipLine:GetText())
		if tipText and (strfind(tipText, LEVEL1) or strfind(tipText, LEVEL2)) then
			return tipLine
		end
	end
end

function TT:SetUnitText(tt, unit)
	local name, realm = UnitName(unit)

	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local nameRealm = (realm and realm ~= "" and format("%s-%s", name, realm)) or name
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local level = UnitLevel(unit)
		local relationship = UnitRealmRelationship(unit)
		local isShiftKeyDown = IsShiftKeyDown()

		local nameColor = E:ClassColor(class) or PRIEST_COLOR

		if TT.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if isShiftKeyDown or TT.db.alwaysShowRealm then
				name = name.."-"..realm
			elseif(relationship == _G.LE_REALM_RELATION_COALESCED) then
				name = name.._G.FOREIGN_SERVER_LABEL
			elseif(relationship == _G.LE_REALM_RELATION_VIRTUAL) then
				name = name.._G.INTERACTIVE_SERVER_LABEL
			end
		end

		local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ''
		_G.GameTooltipTextLeft1:SetFormattedText("|c%s%s%s|r", nameColor.colorStr, name or UNKNOWN, awayText)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			if TT.db.guildRanks then
				_G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
			else
				_G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
			end

			lineOffset = 3
		end

		local levelLine = TT:GetLevelLine(tt, lineOffset)

		local diffColor = GetCreatureDifficultyColor(level)
		local race = UnitRace(unit)
		local levelString = format("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or '', nameColor.colorStr, localeClass)

		if levelLine then
			levelLine:SetText(levelString)
		else
			GameTooltip:AddLine(levelString)
		end

		if TT.db.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local v,r,g,b = addonUser == E.version, unpack(E.media.rgbvaluecolor)
				GameTooltip:AddDoubleLine(L["ElvUI Version:"], addonUser, r,g,b, v and 0 or 1, v and 1 or 0, 0)
			end
		end

		return nameColor
	else
		local levelLine = TT:GetLevelLine(tt, 2)
		if levelLine then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local level = UnitLevel(unit)
			local diffColor = GetCreatureDifficultyColor(level)

			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", _G.PVP)
			end

			local classificationString = ''
			if (creatureClassification == 'rare' or creatureClassification == 'elite' or creatureClassification == 'rareelite' or creatureClassification == 'worldboss') then
				classificationString = format('%s %s|r', ElvUF.Tags.Methods['classificationcolor'](unit), ElvUF.Tags.Methods['classification'](unit))
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classificationString, creatureType or "", pvpFlag)
		end

		local unitReaction = UnitReaction(unit, "player")
		local nameColor = unitReaction and ((TT.db.useCustomFactionColors and TT.db.factionColors[unitReaction]) or _G.FACTION_BAR_COLORS[unitReaction]) or PRIEST_COLOR
		local nameColorStr = nameColor.colorStr or E:RGBToHex(nameColor.r, nameColor.g, nameColor.b, 'ff')

		_G.GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColorStr, name or UNKNOWN)

		return (UnitIsTapDenied(unit) and TAPPED_COLOR) or nameColor
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	if tt:IsForbidden() or not TT.db.visibility then return end

	local unit = select(2, tt:GetUnit())
	local isPlayerUnit = UnitIsPlayer(unit)
	if tt:GetOwner() ~= _G.UIParent and not TT:IsModKeyDown(TT.db.visibility.unitFrames) then
		tt:Hide()
		return
	end

	if not unit then
		local GMF = GetMouseFocus()
		local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute("unit")
		if focusUnit then unit = focusUnit end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	TT:RemoveTrashLines(tt) --keep an eye on this may be buggy

	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local color = TT:SetUnitText(tt, unit)

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit.."target"
		if TT.db.targetInfo and unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if UnitIsPlayer(unitTarget) then
				local _, class = UnitClass(unitTarget)
				targetColor = E:ClassColor(class) or PRIEST_COLOR
			else
				local reaction = UnitReaction(unitTarget, "player")
				targetColor = (TT.db.useCustomFactionColors and TT.db.factionColors[reaction]) or _G.FACTION_BAR_COLORS[reaction] or PRIEST_COLOR
			end

			tt:AddDoubleLine(format("%s:", _G.TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		if TT.db.targetInfo and IsInGroup() then
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (IsInRaid() and "raid"..i or "party"..i);
				if (UnitIsUnit(groupUnit.."target", unit)) and (not UnitIsUnit(groupUnit,"player")) then
					local _, class = UnitClass(groupUnit);
					local classColor = E:ClassColor(class) or PRIEST_COLOR
					tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
				end
			end
			local numList = #targetList
			if (numList > 0) then
				tt:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], numList, tconcat(targetList, ", ")), nil, nil, nil, true);
				wipe(targetList);
			end
		end
	end

	-- NPC ID's
	if unit and not isPlayerUnit and TT:IsModKeyDown() then
		local guid = UnitGUID(unit) or ""
		local id = tonumber(strmatch(guid, "%-(%d-)%-%x-$"), 10)
		if id then
			tt:AddLine(format("|cFFCA3C3C%s|r %d", _G.ID, id))
		end
	end

	if color then
		tt.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		tt.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = tt.StatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if tt:IsForbidden() then return end
	if not value or not TT.db.healthBar.text or not tt.text then return end
	local unit = select(2, tt:GetParent():GetUnit())
	if(not unit) then
		local GMF = GetMouseFocus()
		if(GMF and GMF.GetAttribute and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if(value > 0 and max == 1) then
		tt.text:SetFormattedText("%d%%", floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif(value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		tt.text:SetText(_G.DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	if tt:IsForbidden() then return end
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if tt:IsForbidden() or not TT.db.visibility then return end

	local owner = tt:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Container') or strfind(ownerName, 'ElvUI_BankContainer')) and not TT:IsModKeyDown(TT.db.visibility.bags) then
		tt.itemCleared = true
		tt:Hide()
		return
	end

	if not tt.itemCleared then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link,true)
		local left, right, bankCount = " ", " ", " "

		if link and TT:IsModKeyDown() then
			left = format("|cFFCA3C3C%s|r %s", _G.ID, strmatch(link, ":(%w+)"))
		end

		if TT.db.itemCount == "BAGS_ONLY" then
			right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
		elseif TT.db.itemCount == "BANK_ONLY" then
			bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"],(numall - num))
		elseif TT.db.itemCount == "BOTH" then
			right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
			bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"],(numall - num))
		end

		if left ~= " " or right ~= " " then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end
		if bankCount ~= " " then
			tt:AddDoubleLine(" ", bankCount)
		end

		tt.itemCleared = true
	end
end

function TT:GameTooltip_AddQuestRewardsToTooltip(tt, questID)
	if not (tt and questID and tt.pbBar and tt.pbBar.GetValue) or tt:IsForbidden() then return end
	local cur = tt.pbBar:GetValue()
	if cur then
		local max, _
		if tt.pbBar.GetMinMaxValues then
			_, max = tt.pbBar:GetMinMaxValues()
		end

		Skins:StatusBarColorGradient(tt.pbBar, cur, max)
	end
end

function TT:GameTooltip_ShowProgressBar(tt)
	if not tt or tt:IsForbidden() or not tt.progressBarPool then return end

	local sb = tt.progressBarPool:GetNextActive()
	if (not sb or not sb.Bar) or sb.Bar.backdrop then return end

	sb.Bar:StripTextures()
	sb.Bar:CreateBackdrop('Transparent', nil, true)
	sb.Bar:SetStatusBarTexture(E.media.normTex)

	tt.pbBar = sb.Bar
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt or tt:IsForbidden() or not tt.statusBarPool then return end

	local sb = tt.statusBarPool:GetNextActive()
	if (not sb or not sb.Text) or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:CheckBackdropColor(tt)
	if not tt or tt:IsForbidden() then return end

	local r, g, b = E:GetBackdropColor(tt)
	if r and g and b then
		r, g, b = E:Round(r, 1), E:Round(g, 1), E:Round(b, 1)

		local red, green, blue = unpack(E.media.backdropfadecolor)
		if r ~= red or g ~= green or b ~= blue then
			tt:SetBackdropColor(red, green, blue, TT.db.colorAlpha)
		end
	end
end

function TT:SetBorderColor(_, tt)
	if not tt.GetItem then return end

	local _, link = tt:GetItem()
	if link then
		local _, _, quality = GetItemInfo(link)
		if quality and quality > 1 then
			tt:SetBackdropBorderColor(GetItemQualityColor(quality))
		end
	end
end

function TT:ToggleItemQualityBorderColor()
	if E.db.tooltip.itemQualityBorderColor then
		if not self:IsHooked(TT, "SetStyle", "SetBorderColor") then
			self:SecureHook(TT, "SetStyle", "SetBorderColor")
		end
	else
		self:Unhook(TT, "SetStyle", "SetBorderColor")
	end
end

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip or tt.IsEmbedded) or tt:IsForbidden() then return end
	tt:SetTemplate("Transparent", nil, true) --ignore updates

	local r, g, b = E:GetBackdropColor(tt)
	tt:SetBackdropColor(r, g, b, TT.db.colorAlpha)
end

function TT:MODIFIER_STATE_CHANGED(_, key)
	if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
		local owner = GameTooltip:GetOwner()
		local notOnAuras = not (owner and owner.UpdateTooltip)
		if notOnAuras and UnitExists("mouseover") then
			GameTooltip:SetUnit('mouseover')
		end
	end
end

function TT:SetUnitAura(tt, unit, index, filter)
	if not tt or tt:IsForbidden() then return end
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	if id then
		if TT:IsModKeyDown() then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = E:ClassColor(class) or PRIEST_COLOR
				tt:AddDoubleLine(format("|cFFCA3C3C%s|r %d", _G.ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				tt:AddLine(format("|cFFCA3C3C%s|r %d", _G.ID, id))
			end
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	if tt:IsForbidden() or not TT:IsModKeyDown() then return end

	local _, id = tt:GetSpell()
	if not id then return end

	tt:AddLine(format("|cFFCA3C3C%s|r %d", _G.ID, id))
	tt:Show()
end

function TT:SetItemRef(link)
	if IsModifierKeyDown() or not (link and strfind(link, '^spell:')) then return end

	_G.ItemRefTooltip:AddLine(format("|cFFCA3C3C%s|r %d", _G.ID, strmatch(link, ':(%d+)')))
	_G.ItemRefTooltip:Show()
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= _G.BNETMover then
		frame:ClearAllPoints()
		frame:Point(_G.BNETMover.anchorPoint or 'TOPLEFT', _G.BNETMover, _G.BNETMover.anchorPoint or 'TOPLEFT');
	end
end

function TT:SetTooltipFonts()
	local font = E.Libs.LSM:Fetch("font", TT.db.font)
	local fontOutline = TT.db.fontOutline
	local headerSize = TT.db.headerFontSize
	local smallTextSize = TT.db.smallTextFontSize
	local textSize = TT.db.textFontSize

	_G.GameTooltipHeaderText:FontTemplate(font, headerSize, fontOutline)
	_G.GameTooltipTextSmall:FontTemplate(font, smallTextSize, fontOutline)
	_G.GameTooltipText:FontTemplate(font, textSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."GoldButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SilverButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."CopperButtonText"]:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if _G.DatatextTooltip then
		_G.DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		_G.DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	-- Comparison Tooltips should use smallTextSize
	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i=1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())
			if region:IsObjectType('FontString') then
				region:FontTemplate(font, smallTextSize, fontOutline)
			end
		end
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter();
	local screenHeight = E.UIParent:GetTop();
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if (y > (screenHeight / 2)) then
		anchorPoint = (x > (screenWidth/2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth/2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	mover.anchorPoint = anchorPoint

	_G.BNToastFrame:ClearAllPoints()
	_G.BNToastFrame:Point(anchorPoint, mover)
end

function TT:Initialize()
	TT.db = E.db.tooltip

	_G.BNToastFrame:Point('TOPRIGHT', _G.MMHolder, 'BOTTOMRIGHT', 0, -10)
	E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostBNToastMove)
	_G.BNToastFrame.mover:SetSize(_G.BNToastFrame:GetSize())
	TT:SecureHook(_G.BNToastFrame, "SetPoint", "RepositionBNET")

	if E.private.tooltip.enable ~= true then return end
	TT.Initialized = true

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(TT.db.healthBar.height)
	GameTooltip.StatusBar:SetScript("OnValueChanged", nil) -- Do we need to unset this?
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltip.StatusBar.text:Point("CENTER", GameTooltip.StatusBar, 0, 0)
	GameTooltip.StatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", TT.db.healthBar.font), TT.db.healthBar.fontSize, TT.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	TT:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', _G.RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 400)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L["Tooltip"], nil, nil, nil, nil, nil, 'tooltip,general')

	TT:ToggleItemQualityBorderColor()

	TT:SecureHook('SetItemRef')
	TT:SecureHook('GameTooltip_SetDefaultAnchor')
	TT:SecureHook(GameTooltip, 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitBuff', 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitDebuff', 'SetUnitAura')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetSpell', 'GameTooltip_OnTooltipSetSpell')
	TT:SecureHookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	TT:SecureHookScript(GameTooltip.StatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	TT:RegisterEvent("MODIFIER_STATE_CHANGED")

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don't hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder
end

E:RegisterModule(TT:GetName())
