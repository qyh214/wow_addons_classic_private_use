local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local RC = E.Libs.RC

--WoW API / Variables
local CheckInteractDistance = CheckInteractDistance

function UF:UpdateRange(unit)
	if not self.Fader then return end
	local alpha

	unit = unit or self.unit

	if self.forceInRange or unit == 'player' then
		alpha = self.Fader.MaxAlpha
	elseif self.forceNotInRange then
		alpha = self.Fader.MinAlpha
	elseif unit then
	    local _, inRange = RC:GetRange(unit, true)
        if not inRange then
            alpha = self.Fader.MinAlpha
        elseif inRange then
            alpha = self.Fader.MaxAlpha
        end
	else
		alpha = self.Fader.MaxAlpha
	end

	self.Fader.RangeAlpha = alpha
end
