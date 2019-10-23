local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local _G = _G
local unpack, abs = unpack, abs
local strjoin = strjoin
local CreateFrame = CreateFrame
local UnitCanAttack = UnitCanAttack
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local INTERRUPTED = INTERRUPTED

function NP:Castbar_CheckInterrupt(unit)
	if (unit == 'vehicle') then
		unit = 'player'
	end

	if (self.notInterruptible and UnitCanAttack('player', unit)) then
		self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b)

		if self.Icon and NP.db.colors.castbarDesaturate then
			self.Icon:SetDesaturated(true)
		end
	else
		self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function NP:Castbar_CustomDelayText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText("%.1f |cffaf5050%.1f|r", abs(duration - self.max), self.delay)
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%.1f|r", duration, self.max, self.delay)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText("%.1f |cffaf5050%.1f|r", duration, self.delay)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%.1f|r", abs(duration - self.max), self.max, self.delay)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText("%.1f |cffaf5050%s %.1f|r", duration, "+", self.delay)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%s %.1f|r", duration, self.max, "+", self.delay)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText("%.1f |cffaf5050%s %.1f|r", abs(duration - self.max), "+", self.delay)
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f |cffaf5050%s %.1f|r", abs(duration - self.max), self.max, "+", self.delay)
		end
	end
end

function NP:Castbar_CustomTimeText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText("%.1f", abs(duration - self.max))
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", abs(duration - self.max), self.max)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText("%.1f", duration)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", duration, self.max)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText("%.1f", duration)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", duration, self.max)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText("%.1f", abs(duration - self.max))
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText("%.1f / %.1f", abs(duration - self.max), self.max)
		end
	end
end

function NP:Castbar_PostCastStart(unit)
	self:CheckInterrupt(unit)
	--NP:StyleFilterUpdate(self.__owner, 'FAKE_Casting')
end

function NP:Castbar_PostCastFail()
	--NP:StyleFilterUpdate(self.__owner, 'FAKE_Casting')
end

function NP:Castbar_PostCastInterruptible(unit)
	self:CheckInterrupt(unit)
end

function NP:Castbar_PostCastStop()
	--NP:StyleFilterUpdate(self.__owner, 'FAKE_Casting')
end

function NP:Construct_Castbar(nameplate)
	local Castbar = CreateFrame('StatusBar', nameplate:GetDebugName()..'Castbar', nameplate)
	Castbar:SetFrameStrata(nameplate:GetFrameStrata())
	Castbar:SetFrameLevel(5)
	Castbar:CreateBackdrop('Transparent')
	Castbar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))

	NP.StatusBars[Castbar] = true

	Castbar.Button = CreateFrame('Frame', nil, Castbar)
	Castbar.Button:SetTemplate()

	Castbar.Icon = Castbar.Button:CreateTexture(nil, 'ARTWORK')
	Castbar.Icon:SetTexCoord(unpack(E.TexCoords))
	Castbar.Icon:SetInside()
	Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Time:Point('RIGHT', Castbar, 'RIGHT', -4, 0)
	Castbar.Time:SetJustifyH('RIGHT')
	Castbar.Time:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Text:SetJustifyH('LEFT')
	Castbar.Text:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	Castbar.CheckInterrupt = NP.Castbar_CheckInterrupt
	Castbar.CustomDelayText = NP.Castbar_CustomDelayText
	Castbar.CustomTimeText = NP.Castbar_CustomTimeText
	Castbar.PostCastStart = NP.Castbar_PostCastStart
	Castbar.PostCastFail = NP.Castbar_PostCastFail
	Castbar.PostCastInterruptible = NP.Castbar_PostCastInterruptible
	Castbar.PostCastStop = NP.Castbar_PostCastStop

	if nameplate == _G.ElvNP_Test then
		Castbar.Hide = Castbar.Show
		Castbar:Show()
		Castbar.Text:SetText('Casting')
		Castbar.Time:SetText('3.1')
		Castbar.Icon:SetTexture([[Interface\Icons\Achievement_Character_Pandaren_Female]])
		Castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
	end

	return Castbar
end

function NP:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, sourceGUID, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()
	if (event == "SPELL_INTERRUPT") and targetGUID and (sourceName and sourceName ~= "") then
		local plate = NP.PlateGUID[targetGUID]
		if plate and plate.Castbar then
			local db = plate.frameType and self.db and self.db.units and self.db.units[plate.frameType]
			if (db and db.castbar and db.castbar.enable) and db.castbar.sourceInterrupt then
				if db.castbar.timeToHold > 0 then
					if db.castbar.sourceInterruptClassColor then
						local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
						if sourceClass then
							local classColor = E:ClassColor(sourceClass)
							sourceClass = classColor and classColor.colorStr
						end

						plate.Castbar.Text:SetText(INTERRUPTED.." > "..(sourceClass and strjoin('', '|c', sourceClass, sourceName) or sourceName))
					else
						plate.Castbar.Text:SetText(INTERRUPTED.." > "..sourceName)
					end
				end
			end
		end
	end
end

function NP:Update_Castbar(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.castbar.enable then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		nameplate.Castbar.timeToHold = db.castbar.timeToHold
		nameplate.Castbar.castTimeFormat = db.castbar.castTimeFormat
		nameplate.Castbar.channelTimeFormat = db.castbar.channelTimeFormat

		nameplate.Castbar:Size(db.castbar.width, db.castbar.height)
		nameplate.Castbar:Point('CENTER', nameplate, 'CENTER', db.castbar.xOffset, db.castbar.yOffset)

		if db.castbar.showIcon then
			nameplate.Castbar.Button:ClearAllPoints()
			nameplate.Castbar.Button:Point(db.castbar.iconPosition == 'RIGHT' and 'BOTTOMLEFT' or 'BOTTOMRIGHT', nameplate.Castbar, db.castbar.iconPosition == 'RIGHT' and 'BOTTOMRIGHT' or 'BOTTOMLEFT', db.castbar.iconOffsetX, db.castbar.iconOffsetY)
			nameplate.Castbar.Button:Size(db.castbar.iconSize, db.castbar.iconSize)
			nameplate.Castbar.Button:Show()
		else
			nameplate.Castbar.Button:Hide()
		end

		nameplate.Castbar.Time:ClearAllPoints()
		nameplate.Castbar.Text:ClearAllPoints()

		if db.castbar.textPosition == "BELOW" then
			nameplate.Castbar.Time:Point('TOPRIGHT', nameplate.Castbar, 'BOTTOMRIGHT')
			nameplate.Castbar.Text:Point('TOPLEFT', nameplate.Castbar, 'BOTTOMLEFT')
		elseif db.castbar.textPosition == "ABOVE" then
			nameplate.Castbar.Time:Point('BOTTOMRIGHT', nameplate.Castbar, 'TOPRIGHT')
			nameplate.Castbar.Text:Point('BOTTOMLEFT', nameplate.Castbar, 'TOPLEFT')
		else
			nameplate.Castbar.Time:Point('RIGHT', nameplate.Castbar, 'RIGHT', -4, 0)
			nameplate.Castbar.Text:Point('LEFT', nameplate.Castbar, 'LEFT', 4, 0)
		end

		if db.castbar.hideTime then
			nameplate.Castbar.Time:Hide()
		else
			nameplate.Castbar.Time:FontTemplate(E.LSM:Fetch('font', db.castbar.font), db.castbar.fontSize, db.castbar.fontOutline)
			nameplate.Castbar.Time:Show()
		end

		if db.castbar.hideSpellName then
			nameplate.Castbar.Text:Hide()
		else
			nameplate.Castbar.Text:FontTemplate(E.LSM:Fetch('font', db.castbar.font), db.castbar.fontSize, db.castbar.fontOutline)
			nameplate.Castbar.Text:Show()
		end
	else
		if nameplate:IsElementEnabled('Castbar') then
			nameplate:DisableElement('Castbar')
		end
	end
end
