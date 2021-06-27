local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local GetExpansionLevel = GetExpansionLevel
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter
local REPUTATION = REPUTATION
local STANDING = STANDING

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	DB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local name, reaction, Min, Max, value = GetWatchedFactionInfo()
	local displayString, textFormat = '', DB.db.reputation.textFormat
	local isCapped, standingLabel
	local color = DB.db.colors.useCustomFactionColors and DB.db.colors.factionColors[reaction] or _G.FACTION_BAR_COLORS[reaction]

	if reaction == _G.MAX_REPUTATION_REACTION then
		Min, Max, value = 0, 1, 1
		isCapped = true
	end

	bar:SetMinMaxValues(Min, Max)
	bar:SetValue(value)
	bar:SetStatusBarColor(color.r, color.g, color.b)

	standingLabel = _G['FACTION_STANDING_LABEL'..reaction]

	--Prevent a division by zero
	local maxMinDiff = Max - Min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	if isCapped and textFormat ~= 'NONE' then
		-- show only name and standing on exalted
		displayString = format('%s: [%s]', name, standingLabel)
	else
		if textFormat == 'PERCENT' then
			displayString = format('%s: %d%% [%s]', name, ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CURMAX' then
			displayString = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue(Max - Min), standingLabel)
		elseif textFormat == 'CURPERC' then
			displayString = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CUR' then
			displayString = format('%s: %s [%s]', name, E:ShortValue(value - Min), standingLabel)
		elseif textFormat == 'REM' then
			displayString = format('%s: %s [%s]', name, E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 'CURREM' then
			displayString = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 'CURPERCREM' then
			displayString = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		end
	end

	bar.text:SetText(displayString)
end

function DB:ReputationBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local name, reaction, min, max, value = GetWatchedFactionInfo()

	if name and not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		_G.GameTooltip:AddLine(name)
		_G.GameTooltip:AddLine(' ')
		_G.GameTooltip:AddDoubleLine(STANDING..':', _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		if reaction ~= _G.MAX_REPUTATION_REACTION then
			_G.GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
		end
		_G.GameTooltip:Show()
	end
end

function DB:ReputationBar_OnClick()
	ToggleCharacter('ReputationFrame')
end

function DB:ReputationBar_Toggle()
	local bar = DB.StatusBars.Reputation
	bar.db = DB.db.reputation

	if bar.db.enable then
		E:EnableMover(bar.holder.mover:GetName())

		DB:RegisterEvent('UPDATE_FACTION', 'ReputationBar_Update')
		DB:RegisterEvent('COMBAT_TEXT_UPDATE', 'ReputationBar_Update')

		DB:ReputationBar_Update()
	else
		E:DisableMover(bar.holder.mover:GetName())

		DB:UnregisterEvent('UPDATE_FACTION')
		DB:UnregisterEvent('COMBAT_TEXT_UPDATE')
	end
end

function DB:ReputationBar()
	local Reputation = DB:CreateBar('ElvUI_ReputationBar', 'Reputation', DB.ReputationBar_Update, DB.ReputationBar_OnEnter, DB.ReputationBar_OnClick, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264})
	DB:CreateBarBubbles(Reputation)

	Reputation.ShouldHide = function()
		return (DB.db.reputation.hideBelowMaxLevel and E.mylevel ~= _G.MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or not GetWatchedFactionInfo()
	end

	E:CreateMover(Reputation.holder, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')

	DB:ReputationBar_Toggle()
end
