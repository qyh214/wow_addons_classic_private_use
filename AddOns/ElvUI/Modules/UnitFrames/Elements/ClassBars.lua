local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local select, unpack = select, unpack
local strfind, strsub, gsub = strfind, strsub, gsub
local floor, max = floor, max
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
-- GLOBALS: ElvUF_Player

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Configure_ClassBar(frame, cur)
	if not frame.VARIABLES_SET then return end
	local bars = frame[frame.ClassBar]
	if not bars then return end

	local db = frame.db
	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars)  --Trigger update to health if needed
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		--Override visibility if Classbar is Additional Power in order to fix a bug when Auto Hide is enabled, height is higher than 30 and it goes from detached to not detached
		local overrideVisibility = frame.ClassBar == "AdditionalPower"
		UF.ToggleResourceBar(bars, overrideVisibility)  --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local color = E.db.unitframe.colors.borderColor
	bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if frame.MAX_CLASS_BAR == 1 or frame.ClassBar == "AdditionalPower" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then --Detached
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	if (frame.ClassBar == 'ClassPower' or frame.ClassBar == 'Totems') then
		--This fixes issue with ComboPoints showing as active when they are not.
		if frame.ClassBar == "ClassPower" and not cur then
			cur = 0
		end

		local maxClassBarButtons = UF.classMaxResourceBar[E.myclass] or MAX_COMBO_POINTS
		for i = 1, maxClassBarButtons do
			if frame.ClassBar == 'ClassPower' then
				bars[i]:Hide()
			end

			bars[i].backdrop:Hide()

			if i <= frame.MAX_CLASS_BAR then
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

				bars[i]:Height(bars:GetHeight())
				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:Width(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
						bars[i]:Width(CLASSBAR_WIDTH)
					else
						bars[i]:Width((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
							bars[i]:Point("BOTTOM", bars[i-1], "TOP", 0, (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2))
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
					end
				end

				if not frame.USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end

				if frame.ClassBar == "ClassPower" then
					local r1, g1, b1 = unpack(ElvUF.colors.ComboPoints[1])
					local r2, g2, b2 = unpack(ElvUF.colors.ComboPoints[2])
					local r3, g3, b3 = unpack(ElvUF.colors.ComboPoints[3])
					local maxComboPoints = ((frame.MAX_CLASS_BAR == 10 and 10) or (frame.MAX_CLASS_BAR > 5 and 6 or 5))

					bars[i]:SetStatusBarColor(ElvUF:ColorGradient(i, maxComboPoints, r1, g1, b1, r2, g2, b2, r3, g3, b3))
				elseif frame.ClassBar == "Totems" then
					bars[1]:SetStatusBarColor(.58, .23, .10)
					bars[2]:SetStatusBarColor(.23, .45, .13)
					bars[3]:SetStatusBarColor(.19, .48, .60)
					bars[4]:SetStatusBarColor(.42, .18, .74)
				end

				if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
					bars[i]:SetOrientation("VERTICAL")
				else
					bars[i]:SetOrientation("HORIZONTAL")
				end

				--Fix missing backdrop colors on Combo Points when using Spaced style
				if frame.ClassBar == "ClassPower" or frame.ClassBar == 'Totems' then
					if frame.USE_MINI_CLASSBAR then
						bars[i].bg:SetParent(bars[i].backdrop)
					else
						bars[i].bg:SetParent(bars)
					end
				end

				if cur and cur >= i then
					bars[i]:Show()
				end
			end
		end

		if (not frame.USE_MINI_CLASSBAR) and frame.USE_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
	elseif (frame.ClassBar == "AdditionalPower") then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation("VERTICAL")
		else
			bars:SetOrientation("HORIZONTAL")
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif frame.CLASSBAR_DETACHED then
		bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)

		if not bars.Holder.mover then
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,player,classbar')
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata("LOW")
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame:GetFrameLevel() + 5)
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	else
		bars:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end

		bars:SetFrameStrata("LOW")
		bars:SetFrameLevel(frame:GetFrameLevel() + 5)

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == "UIPARENT" then
		E.FrameLocks[bars] = true
		bars:SetParent(E.UIParent)
	else
		E.FrameLocks[bars] = nil
		bars:SetParent(frame)
	end

	if frame.USE_CLASSBAR then
		if frame.ClassPower and not frame:IsElementEnabled("ClassPower") then
			frame:EnableElement("ClassPower")
		end
		if frame.AdditionalPower and not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
		end
		if frame.Totems and not frame:IsElementEnabled("Totems") then
			frame:EnableElement("Totems")
		end
	else
		if frame.ClassPower and frame:IsElementEnabled("ClassPower") then
			frame:DisableElement("ClassPower")
		end
		if frame.AdditionalPower and frame:IsElementEnabled("AdditionalPower") then
			frame:DisableElement("AdditionalPower")
		end
		if frame.Totems and frame:IsElementEnabled("Totems") then
			frame:DisableElement("Totems")
		end
	end
end

local function ToggleResourceBar(bars, overrideVisibility)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = (not not overrideVisibility) or frame[frame.ClassBar]:IsShown()

	local height
	if db.classbar then
		height = db.classbar.height
	elseif frame.AlternativePower then
		height = db.power.height
	end

	if bars.text then
		if frame.CLASSBAR_SHOWN then
			bars.text:SetAlpha(1)
		else
			bars.text:SetAlpha(0)
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	if not frame.CLASSBAR_DETACHED then --Only update when necessary
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame, true) --running :Hide on portrait makes the frame all funky
	end
end
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	bars:Hide()

	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
	for i = 1, maxBars do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassIconButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, 'BACKGROUND')
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(current, maxBars, hasMaxChanged)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local isShown = self:IsShown()
	local stateChanged

	if not frame.USE_CLASSBAR or (current == 0 and db.classbar.autoHide) or maxBars == nil then
		self:Hide()
		if isShown then
			stateChanged = true
		end
	else
		self:Show()
		if not isShown then
			stateChanged = true
		end
	end

	if hasMaxChanged then
		frame.MAX_CLASS_BAR = maxBars
		UF:Configure_ClassBar(frame, current)
	elseif stateChanged then
		UF:Configure_ClassBar(frame, current)
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i=1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * .35, g * .35, b * .35)
		end

		if maxBars and (i <= maxBars) then
			self[i].bg:Show()
		else
			self[i].bg:Hide()
		end
	end
end

-------------------------------------------------------------
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', "AdditionalPowerBar", frame)
	additionalPower:SetFrameLevel(additionalPower:GetFrameLevel() + 1)
	additionalPower.colorPower = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	additionalPower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[additionalPower] = true

	additionalPower.bg = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.bg:SetAllPoints(additionalPower)
	additionalPower.bg:SetTexture(E.media.blankTex)
	additionalPower.bg.multiplier = 0.35

	additionalPower.text = additionalPower:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(additionalPower.text)

	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(_, MIN, MAX, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and ((MIN ~= MAX or (not db.classbar.autoHide)) and (event ~= "ElementDisable")) then
		if db.classbar.additionalPowerText then
			local powerValue = frame.Power.value
			local powerValueText = powerValue:GetText()
			local powerValueParent = powerValue:GetParent()
			local powerTextPosition = db.power.position
			local color = ElvUF.colors.power.MANA
			color = E:RGBToHex(color[1], color[2], color[3])

			--Attempt to remove |cFFXXXXXX color codes in order to determine if power text is really empty
			if powerValueText then
				local _, endIndex = strfind(powerValueText, "|cff")
				if endIndex then
					endIndex = endIndex + 7 --Add hex code
					powerValueText = strsub(powerValueText, endIndex)
					powerValueText = gsub(powerValueText, "%s+", "")
				end
			end

			self.text:ClearAllPoints()
			if not frame.CLASSBAR_DETACHED then
				self.text:SetParent(powerValueParent)
				if (powerValueText and (powerValueText ~= "" and powerValueText ~= " ")) then
					if strfind(powerTextPosition, "RIGHT") then
						self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
						self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(MIN / MAX * 100))
					elseif strfind(powerTextPosition, "LEFT") then
						self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
						self.text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(MIN / MAX * 100))
					else
						if select(4, powerValue:GetPoint()) <= 0 then
							self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
							self.text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(MIN / MAX * 100))
						else
							self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
							self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(MIN / MAX * 100))
						end
					end
				else
					self.text:Point(powerValue:GetPoint())
					self.text:SetFormattedText(color.."%d%%|r", floor(MIN / MAX * 100))
				end
			else
				self.text:SetParent(frame.RaisedElementParent) -- needs to be 'frame.RaisedElementParent' otherwise the new PowerPrediction Bar will overlap
				self.text:Point("CENTER", self)
				self.text:SetFormattedText(color.."%d%%|r", floor(MIN / MAX * 100))
			end
		else --Text disabled
			self.text:SetText('')
		end

		local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
		if custom_backdrop then
			self.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		end

		self:Show()
	else --Bar disabled
		self.text:SetText('')
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = 'AdditionalPower'
	else
		frame.ClassBar = 'ClassPower'
		self.text:SetText('')
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

-----------------------------------------------------------
-- Totems
-----------------------------------------------------------
local TotemColors = {
	[1] = {.58,.23,.10},
	[2] = {.23,.45,.13},
	[3] = {.19,.48,.60},
	[4] = {.42,.18,.74},
}

function UF:Construct_Totems(frame)
	local totems = CreateFrame("Frame", nil, frame)
	totems:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
	totems.Destroy = {}

	for i = 1, 4 do
		local r, g, b = unpack(TotemColors[i])

		totems[i] = CreateFrame("StatusBar", frame:GetName().."Totem"..i, totems)
		totems[i]:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
		totems[i].backdrop:SetParent(totems)

		totems[i]:SetStatusBarTexture(E.media.blankTex)
		totems[i]:SetStatusBarColor(r, g, b)

		UF.statusbars[totems[i]] = true

		totems[i]:SetMinMaxValues(0, 1)
		totems[i]:SetValue(0)

		totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
		totems[i].bg:SetAllPoints(totems[i])
		totems[i].bg:SetTexture(E['media'].blankTex)
		totems[i].bg.multiplier = 0.3

		totems[i].bg:SetVertexColor(r * .3, g * .3, b * .3)

		totems.Destroy[i] = CreateFrame("Button", totems[i]:GetName().."Destroy", UIParent, "SecureUnitButtonTemplate")
		totems.Destroy[i]:RegisterForClicks("RightButtonUp")
		totems.Destroy[i]:SetAllPoints(totems[i])
		totems.Destroy[i]:SetID(i)
		totems.Destroy[i]:SetAttribute("type2", "destroytotem")
		totems.Destroy[i]:SetAttribute("*totem-slot*", i)
	end

	frame.MAX_CLASS_BAR = 4
	frame.ClassBar = 'Totems'

	return totems
end

