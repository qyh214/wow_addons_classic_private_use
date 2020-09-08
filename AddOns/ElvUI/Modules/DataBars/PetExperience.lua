local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local GetExpansionLevel = GetExpansionLevel
local UnitLevel = UnitLevel
local HasPetUI = HasPetUI
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local GetPetExperience = GetPetExperience

function DB:PetExperienceBar_Update()
	if E.myclass ~= 'HUNTER' then return end
	local bar = DB.StatusBars.PetExperience
	if not HasPetUI() or not DB.db.petExperience.enable or (bar.db.hideAtMaxLevel and UnitLevel('pet') == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) then
		bar:Hide()
		return
	else
		bar:Show()
	end

	local color = DB.db.colors.petExperience
	bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

	local cur, max = GetPetExperience()
	if max <= 0 then max = 1 end
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)

	local text, textFormat = '', bar.db.textFormat

	if textFormat == 'PERCENT' then
		text = format('%d%%', cur / max * 100)
	elseif textFormat == 'CURMAX' then
		text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max))
	elseif textFormat == 'CURPERC' then
		text = format('%s - %d%%', E:ShortValue(cur), cur / max * 100)
	elseif textFormat == 'CUR' then
		text = format('%s', E:ShortValue(cur))
	elseif textFormat == 'REM' then
		text = format('%s', E:ShortValue(max - cur))
	elseif textFormat == 'CURREM' then
		text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max - cur))
	elseif textFormat == 'CURPERCREM' then
		text = format('%s - %d%% (%s)', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
	end

	bar.text:SetText(text)
end

function DB:PetExperienceBar_OnEnter()
	local GameTooltip = _G.GameTooltip
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max = GetPetExperience()
	if max <= 0 then max = 1 end

	GameTooltip:AddLine(L["Pet Experience"])
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	GameTooltip:Show()
end

function DB:PetExperienceBar_OnClick() end

function DB:PetExperienceBar_Toggle()
	if E.myclass ~= 'HUNTER' then return end
	local bar = DB.StatusBars.PetExperience
	bar.db = DB.db.petExperience

	if bar.db.enable and HasPetUI() and not (bar.db.hideAtMaxLevel and UnitLevel('pet') == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) then
		DB:PetExperienceBar_Update()
		E:EnableMover(bar.mover:GetName())
	else
		bar:Hide()
		E:DisableMover(bar.mover:GetName())
	end
end

function DB:PetExperienceBar()
	if E.myclass ~= 'HUNTER' then return end

	DB.StatusBars.PetExperience = DB:CreateBar('ElvUI_PetExperienceBar', DB.ExperienceBar_OnEnter, DB.ExperienceBar_OnClick, 'LEFT', _G.LeftChatPanel, 'RIGHT', -E.Border + E.Spacing*3, 0)

	DB:RegisterEvent('PET_BAR_UPDATE', 'PetExperienceBar_Toggle')
	DB:RegisterEvent('UNIT_PET_EXPERIENCE', 'PetExperienceBar_Update')

	E:CreateMover(DB.StatusBars.PetExperience, 'PetExperienceBarMover', L["Pet Experience Bar"], nil, nil, nil, nil, nil, 'databars,petExperience')
	DB:PetExperienceBar_Toggle()
end
