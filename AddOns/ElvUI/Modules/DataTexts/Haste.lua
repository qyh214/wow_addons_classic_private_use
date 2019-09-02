local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local strjoin = strjoin
--WoW API / Variables
local GetHaste = GetHaste
local STAT_HASTE = STAT_HASTE

local displayString, lastPanel = ''

local function OnEvent(self)
	local haste = GetHaste()
	self.text:SetFormattedText(displayString, STAT_HASTE, haste)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Haste', {"UNIT_STATS", "UNIT_AURA", "UNIT_SPELL_HASTE"}, OnEvent, nil, nil, nil, nil, STAT_HASTE)
