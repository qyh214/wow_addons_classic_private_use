local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter
local REPUTATION = REPUTATION
local STANDING = STANDING

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	local name, reaction, Min, Max, value = GetWatchedFactionInfo()

	if not name then
		bar:Hide()
		return
	end

	local textFormat, text = DB.db.reputation.textFormat, ''
	local isCapped, standingLabel

	if reaction == _G.MAX_REPUTATION_REACTION then
		Min, Max, value = 0, 1, 1
		isCapped = true
	end

	bar:SetMinMaxValues(Min, Max)
	bar:SetValue(value)
	local color = _G.FACTION_BAR_COLORS[reaction]
	bar:SetStatusBarColor(color.r, color.g, color.b)

	standingLabel = _G['FACTION_STANDING_LABEL'..reaction]

	--Prevent a division by zero
	local maxMinDiff = Max - Min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	if isCapped and textFormat ~= 'NONE' then
		-- show only name and standing on exalted
		text = format('%s: [%s]', name, standingLabel)
	else
		if textFormat == 'PERCENT' then
			text = format('%s: %d%% [%s]', name, ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CURMAX' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue(Max - Min), standingLabel)
		elseif textFormat == 'CURPERC' then
			text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CUR' then
			text = format('%s: %s [%s]', name, E:ShortValue(value - Min), standingLabel)
		elseif textFormat == 'REM' then
			text = format('%s: %s [%s]', name, E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 'CURREM' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		elseif textFormat == 'CURPERCREM' then
			text = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), E:ShortValue((Max - Min) - (value-Min)), standingLabel)
		end
	end

	bar.text:SetText(text)
	bar:Show()
end

function DB:ReputationBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local name, reaction, min, max, value = GetWatchedFactionInfo()

	if name then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)
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

	bar:SetShown(bar.db.enable)
	if bar.db.enable then
		DB:RegisterEvent('UPDATE_FACTION', 'ReputationBar_Update')
		DB:RegisterEvent('COMBAT_TEXT_UPDATE', 'ReputationBar_Update')
		DB:ReputationBar_Update()
		E:EnableMover(bar.mover:GetName())
	else
		DB:UnregisterEvent('UPDATE_FACTION')
		DB:UnregisterEvent('COMBAT_TEXT_UPDATE')
		E:DisableMover(bar.mover:GetName())
	end
end

function DB:ReputationBar()
	DB.StatusBars.Reputation = DB:CreateBar('ElvUI_ReputationBar', DB.ReputationBar_OnEnter, DB.ReputationBar_OnClick, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264)

	E:CreateMover(DB.StatusBars.Reputation, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')
	DB:ReputationBar_Toggle()
end
