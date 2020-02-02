local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local strjoin = strjoin
local tinsert = tinsert
--WoW API / Variables
local GetMoney = GetMoney
local IsControlKeyDown = IsControlKeyDown
local IsLoggedIn = IsLoggedIn
local IsShiftKeyDown = IsShiftKeyDown
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
-- GLOBALS: ElvDB

local Profit, Spent = 0, 0
local resetCountersFormatter = strjoin('', '|cffaaaaaa', L["Reset Counters: Hold Shift + Right Click"], '|r')
local resetInfoFormatter = strjoin('', '|cffaaaaaa', L["Reset Data: Hold Shift + Right Click"], '|r')

local function OnEvent(self)
	if not IsLoggedIn() then return end

	ElvDB = ElvDB or {}

	ElvDB.gold = ElvDB.gold or {}
	ElvDB.gold[E.myrealm] = ElvDB.gold[E.myrealm] or {}

	ElvDB.class = ElvDB.class or {}
	ElvDB.class[E.myrealm] = ElvDB.class[E.myrealm] or {}
	ElvDB.class[E.myrealm][E.myname] = E.myclass

	ElvDB.faction = ElvDB.faction or {}
	ElvDB.faction[E.myrealm] = ElvDB.faction[E.myrealm] or {}
	ElvDB.faction[E.myrealm][E.myname] = E.myfaction

	--prevent an error possibly from really old profiles
	local oldMoney = ElvDB.gold[E.myrealm][E.myname]
	if oldMoney and type(oldMoney) ~= 'number' then
		ElvDB.gold[E.myrealm][E.myname] = nil
		oldMoney = nil
	end

	local NewMoney = GetMoney()
	ElvDB.gold[E.myrealm][E.myname] = NewMoney

	local OldMoney = oldMoney or NewMoney
	local Change = NewMoney-OldMoney -- Positive if we gain money
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end

	self.text:SetText(E:FormatMoney(NewMoney, E.db.datatexts.goldFormat or 'BLIZZARD', not E.db.datatexts.goldCoins))
end

local function Click(self, btn)
	if btn == 'RightButton' then
		if IsShiftKeyDown() then
			wipe(ElvDB.gold)
			OnEvent(self)
			DT.tooltip:Hide()
		elseif IsControlKeyDown() then
			Profit = 0
			Spent = 0
			DT.tooltip:Hide()
		end
	else
		_G.ToggleAllBags()
	end
end

local myGold = {}
local function OnEnter(self)
	DT:SetupTooltip(self)
	local textOnly = not E.db.datatexts.goldCoins and true or false
	local style = E.db.datatexts.goldFormat or 'BLIZZARD'

	DT.tooltip:AddLine(L["Session:"])
	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], E:FormatMoney(Profit-Spent, style, textOnly), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		DT.tooltip:AddDoubleLine(L["Profit:"], E:FormatMoney(Profit-Spent, style, textOnly), 0, 1, 0, 1, 1, 1)
	end
	DT.tooltip:AddLine(' ')

	local totalGold, totalHorde, totalAlliance = 0, 0, 0
	DT.tooltip:AddLine(L["Character: "])

	wipe(myGold)
	for k,_ in pairs(ElvDB.gold[E.myrealm]) do
		if ElvDB.gold[E.myrealm][k] then
			local class = ElvDB.class[E.myrealm][k] or 'PRIEST'
			local color = E:ClassColor(class) or PRIEST_COLOR
			tinsert(myGold,
				{
					name = k,
					amount = ElvDB.gold[E.myrealm][k],
					amountText = E:FormatMoney(ElvDB.gold[E.myrealm][k], E.db.datatexts.goldFormat or 'BLIZZARD', not E.db.datatexts.goldCoins),
					faction = ElvDB.faction[E.myrealm][k] or '',
					r = color.r, g = color.g, b = color.b,
				}
			)
		end

		if ElvDB.faction[E.myrealm][k] == 'Alliance' then
			totalAlliance = totalAlliance+ElvDB.gold[E.myrealm][k]
		else
			totalHorde = totalHorde+ElvDB.gold[E.myrealm][k]
		end

		totalGold = totalGold+ElvDB.gold[E.myrealm][k]
	end

	for _, g in ipairs(myGold) do
		local nameLine = ''
		if g.faction ~= '' and g.faction ~= 'Neutral' then
			nameLine = format('|TInterface/FriendsFrame/PlusManz-%s:14|t ', g.faction)
		end

		nameLine = g.name == E.myname and nameLine..g.name..' |TInterface/COMMON/Indicator-Green:14|t' or nameLine..g.name

		DT.tooltip:AddDoubleLine(nameLine, g.amountText, g.r, g.g, g.b, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Server: "])
	DT.tooltip:AddDoubleLine(L["Alliance: "], E:FormatMoney(totalAlliance, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Horde: "], E:FormatMoney(totalHorde, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddDoubleLine(L["Total: "], E:FormatMoney(totalGold, style, textOnly), 1, 1, 1, 1, 1, 1)

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(resetCountersFormatter)
	DT.tooltip:AddLine(resetInfoFormatter)

	DT.tooltip:Show()
end

DT:RegisterDatatext('Gold', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED'}, OnEvent, nil, Click, OnEnter, nil, L["Gold"])
