local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local format = format
local strjoin = strjoin
--WoW API / Variables
local UnitLevel = UnitLevel
local UnitArmor = UnitArmor
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction

local armorString = ARMOR..": "
local chanceString = "%.2f%%"
local displayString, lastPanel, effectiveArmor, _ = ''

local function OnEvent(self)
	_, effectiveArmor = UnitArmor("player")

	self.text:SetFormattedText(displayString, armorString, effectiveArmor)
	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(' ')

	local playerLevel = E.mylevel + 3
    for _  = 1, 4 do
        local armorReduction = effectiveArmor/((85 * playerLevel) + 400);
        armorReduction = 100 * (armorReduction/(armorReduction + 1));
        DT.tooltip:AddDoubleLine(playerLevel,format(chanceString, armorReduction),1,1,1)
        playerLevel = playerLevel - 1
    end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Armor', {"UNIT_STATS", "UNIT_RESISTANCES"}, OnEvent, nil, nil, OnEnter, nil, ARMOR)
