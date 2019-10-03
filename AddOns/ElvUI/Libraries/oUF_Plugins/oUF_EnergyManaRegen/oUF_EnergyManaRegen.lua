local _, ns = ...
local oUF = ns.oUF
local LastTickTime = GetTime()
local TickValue = 2
local CurrentValue = UnitPower('player')
local LastValue = CurrentValue
local allowPowerEvent = true

local Update = function(self, elapsed)
	local element = self.EnergyManaRegen

	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local powerType = UnitPowerType("player")

		element:SetValue(0)
		element.Spark:Hide()

		if powerType ~= Enum.PowerType.Energy and powerType ~= Enum.PowerType.Mana then
			return
		end

		CurrentValue = UnitPower('player', powerType)

		if not CurrentValue or CurrentValue >= UnitPowerMax('player', powerType) then
			return
		end

		local Now = GetTime() or 0
		if not (Now == nil) then
			local Timer = Now - LastTickTime

			if (CurrentValue > LastValue) then
				LastTickTime = Now
			end

			if Timer > 0 then
				element.Spark:Show()
				element:SetValue(Timer)
				allowPowerEvent = true
			end

			LastValue = CurrentValue
			element.sinceLastUpdate = 0
		end
	end
end

local EventHandler = function(self, event, _, _, spellID)
	local powerType = UnitPowerType("player")

	if powerType ~= Enum.PowerType.Mana then
		return
	end

	if event == 'UNIT_POWER_UPDATE' and allowPowerEvent then
		local Time = GetTime()

		TickValue = Time - LastTickTime

		if TickValue > 5 then
			if powerType == Enum.PowerType.Mana and InCombatLockdown() then
				TickValue = 5
			else
				TickValue = 2
			end
		end

		LastTickTime = Time
	end

	if event == 'UNIT_SPELLCAST_SUCCEEDED' then
		if spellID == 75 or spellID == 5019 then
			return
		end

		LastTickTime = GetTime() + 5
		allowPowerEvent = false
	end
end

local Path = function(self, ...)
	return (self.EnergyManaRegen.Override or Update) (self, ...)
end

local Enable = function(self, unit)
	local element = self.EnergyManaRegen
	local Power = self.Power

	if (unit == "player") and element and Power then
		element.__owner = self

		if(element:IsObjectType('StatusBar')) then
			element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
			element:GetStatusBarTexture():SetAlpha(0)
			element:SetMinMaxValues(0, 2)
		end

		local spark = element.Spark
		if(spark and spark:IsObjectType('Texture')) then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			spark:SetSize(20, 20)
			spark:SetBlendMode('ADD')
			spark:SetPoint('CENTER', element:GetStatusBarTexture(), 'RIGHT')
		end

		self:RegisterEvent("PLAYER_REGEN_ENABLED", EventHandler, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", EventHandler, true)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", EventHandler)
		self:RegisterEvent("UNIT_POWER_UPDATE", EventHandler)

		element:SetScript('OnUpdate', function(_, elapsed) Path(self, elapsed) end)

		return true
	end
end

local Disable = function(self)
	local element = self.EnergyManaRegen
	local Power = self.Power

	if (Power) and (element) then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", EventHandler, true)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", EventHandler, true)
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", EventHandler)
		self:UnregisterEvent("UNIT_POWER_UPDATE", EventHandler)

		element.Spark:Hide()
		element:SetScript("OnUpdate", nil)

		return false
	end
end

oUF:AddElement("EnergyManaRegen", Path, Enable, Disable)
