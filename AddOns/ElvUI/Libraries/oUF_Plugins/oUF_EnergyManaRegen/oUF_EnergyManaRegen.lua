local _, ns = ...
local oUF = ns.oUF
local LastTickTime = GetTime()
local TickValue = 2
local CurrentValue = UnitPower('player')
local LastValue = CurrentValue
local allowPowerEvent = true
local myClass = select(2, UnitClass("player"))
local Mp5Delay = 5

local Update = function(self, elapsed)
	local element = self.EnergyManaRegen

	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local powerType = UnitPowerType("player")

		if powerType ~= Enum.PowerType.Energy and powerType ~= Enum.PowerType.Mana then
			element.Spark:Hide()
			return
		end

		CurrentValue = UnitPower('player', powerType)

		if powerType == Enum.PowerType.Mana and (not CurrentValue or CurrentValue >= UnitPowerMax('player', Enum.PowerType.Mana)) then
			element:SetValue(0)
			element.Spark:Hide()
			return
		end

		local Now = GetTime() or 0
		if not (Now == nil) then
			local Timer = Now - LastTickTime

			if (CurrentValue > LastValue) or powerType == Enum.PowerType.Energy and (Now >= LastTickTime + 2) then
				LastTickTime = Now
			end

			if Timer > 0 then
				element.Spark:Show()
				element:SetMinMaxValues(0, 2)
				element.Spark:SetVertexColor(1, 1, 1, 1)
				element:SetValue(Timer)
				allowPowerEvent = true
				
				LastValue = CurrentValue
			elseif Timer < 0 then
				-- if negative, it's mp5delay
				element.Spark:Show()
				element:SetMinMaxValues(0, 5)
				element.Spark:SetVertexColor(1, 1, 0, 1)
				
				element:SetValue(math.abs(Timer))
			end

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

	if (unit == "player") and element and Power and myClass ~= 'WARRIOR' then
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
