--[[
# Element: Power Prediction Bar

Handles the visibility and updating of power cost prediction.

## Widget

PowerPrediction - A `StatusBar` used to represent power cost of spells on top of the Power element.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Examples

    -- Position and size
    local PowerPrediction = CreateFrame('StatusBar', nil, self.Power)
    PowerPrediction:SetReverseFill(true)
    PowerPrediction:SetPoint('TOP')
    PowerPrediction:SetPoint('BOTTOM')
    PowerPrediction:SetPoint('RIGHT', self.Power:GetStatusBarTexture(), 'RIGHT')
    PowerPrediction:SetWidth(200)

    -- Register with oUF
    self.PowerPrediction = PowerPrediction
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.PowerPrediction

	--[[ Callback: PowerPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the PowerPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local _, _, _, startTime, endTime, _, _, _, spellID = CastingInfo()
	local powerType = UnitPowerType(unit)
	local cost = 0

	if(event == 'UNIT_SPELLCAST_START' and startTime ~= endTime) then
		local costTable = GetSpellPowerCost(spellID)
		for _, costInfo in next, costTable do
			-- costInfo content:
			-- - name: string (powerToken)
			-- - type: number (powerType)
			-- - cost: number
			-- - costPercent: number
			-- - costPerSec: number
			-- - minCost: number
			-- - hasRequiredAura: boolean
			-- - requiredAuraID: number
			if(costInfo.type == powerType) then
				cost = costInfo.cost
			end
		end
	end

	element:SetMinMaxValues(0, UnitPowerMax(unit, powerType))
	element:SetValue(cost)
	element:Show()

	--[[ Callback: PowerPrediction:PostUpdate(unit, mainCost, altCost, hasAltManaBar)
	Called after the element has been updated.

	* self          - the PowerPrediction element
	* unit          - the unit for which the update has been triggered (string)
    * cost          - the cost of the cast ability (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cost)
	end
end

local function Path(self, ...)
	--[[ Override: PowerPrediction.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PowerPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PowerPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_SPELLCAST_START', Path)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', Path)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', Path)
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.PowerPrediction
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_SPELLCAST_START', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
	end
end

oUF:AddElement('PowerPrediction', Path, Enable, Disable)
