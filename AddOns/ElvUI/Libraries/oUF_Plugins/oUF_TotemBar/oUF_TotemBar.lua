local _, ns = ...
local oUF = ns.oUF

-- In the order, fire, earth, water, air
local colors = {
	[1] = {0.58, 0.23, 0.10},
	[2] = {0.23, 0.45, 0.13},
	[3] = {0.19, 0.48, 0.60},
	[4] = {0.42, 0.18, 0.74},
}

local function UpdateTotem(self, elapsed)
	self.total = (self.total or 0) + elapsed
	if (self.total >= .01) then
		self.total = 0
		local _, _, startTime, duration = GetTotemInfo(self.ID)
		if startTime == 0 then return end
		if ((GetTime() - startTime) == 0) then
			self:SetValue(0)
		else
			self:SetValue(1 - ((GetTime() - startTime) / duration))
		end
	end
end

local function UpdateSlot(self, slot)
	local totem = self.TotemBar
	if not totem[slot] then return end
	local _, _, startTime, duration = GetTotemInfo(slot)

	totem[slot]:SetStatusBarColor(unpack(colors[slot]))
	totem[slot]:SetValue(0)

	if totem[slot].bg.multiplier then
		local mu = totem[slot].bg.multiplier
		local r, g, b = unpack(colors[slot])
		r, g, b = r * mu, g * mu, b * mu
		totem[slot].bg:SetVertexColor(r, g, b)
	end

	totem[slot].ID = slot

	if duration > 0 then
		totem[slot]:SetValue(1 - ((GetTime() - startTime) / duration))
		totem[slot]:SetScript("OnUpdate", UpdateTotem)
	else
		totem[slot]:SetScript("OnUpdate", nil)
	end
end

local function Update(self)
	for i = 1, MAX_TOTEMS do
		UpdateSlot(self, i)
	end
end

local Path = function(self, ...)
	return (self.TotemBar.Override or Update) (self, ...)
end

local function Event(self, event, ...)
	UpdateSlot(self, ...)
end

local function Enable(self, unit)
	local totem = self.TotemBar
	if totem then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE", Event, true)

		return true
	end
end

local function Disable(self, unit)
	local totem = self.TotemBar
	if totem then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Event)
	end
end

oUF:AddElement("TotemBar", Path, Enable, Disable)
