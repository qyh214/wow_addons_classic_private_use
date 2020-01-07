local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local select = select
local strjoin = strjoin
--WoW API / Variables
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatData = GetBattlefieldStatData
local BATTLEGROUND = BATTLEGROUND

local displayString, lastPanel = ''
local dataLayout = {
	['LeftChatDataPanel'] = {
		['middle'] = 5,
		['right'] = 2,
	},
	['RightChatDataPanel'] = {
		['left'] = 4,
		['middle'] = 3,
	},
}

local dataStrings = {
	[5] = _G.HONOR,
	[2] = _G.KILLING_BLOWS,
	[4] = _G.DEATHS,
	[3] = _G.KILLS,
}

function DT:UPDATE_BATTLEFIELD_SCORE()
	lastPanel = self

	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex]
	for i = 1, GetNumBattlefieldScores() do
		local name = GetBattlefieldScore(i)
		if name == E.myname then
			if pointIndex then
				local val = select(pointIndex, GetBattlefieldScore(i))

				if val then
					self.text:SetFormattedText(displayString, dataStrings[pointIndex], E:ShortValue(val))
				end
			end

			break
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self)

	local classColor = E:ClassColor(E.myclass)
	local numStatInfo = GetNumBattlefieldStats()
	if numStatInfo then
		for i = 1, GetNumBattlefieldScores() do
			local name = GetBattlefieldScore(i)
			if name and name == E.myname then
				DT.tooltip:AddDoubleLine(BATTLEGROUND, E.MapInfo.name, 1,1,1, classColor.r, classColor.g, classColor.b)
				DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1, 1, 1, classColor.r, classColor.g, classColor.b)
				DT.tooltip:AddLine(" ")

				-- Add extra statistics to watch based on what BG you are in.
				for j = 1, numStatInfo do
					DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(j), GetBattlefieldStatData(i, j), 1, 1, 1)
				end

				break
			end
		end
	end

	DT.tooltip:Show()
end

function DT:HideBattlegroundTexts()
	DT.ForceHideBGStats = true
	DT:LoadDataTexts()
	E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."])
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true
