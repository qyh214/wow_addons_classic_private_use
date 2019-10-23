local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')

--Lua functions
local _G = _G
local pairs, unpack, ipairs, next, tonumber, tinsert = pairs, unpack, ipairs, next, tonumber, tinsert
--WoW API / Variables
local ChatEdit_InsertLink = ChatEdit_InsertLink
local CreateFrame = CreateFrame
local CursorOnUpdate = CursorOnUpdate
local DressUpItemLink = DressUpItemLink
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsControlKeyDown = IsControlKeyDown
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local ResetCursor = ResetCursor
local RollOnLoot = RollOnLoot
local SetDesaturation = SetDesaturation
local ShowInspectCursor = ShowInspectCursor

local C_LootHistoryGetItem = C_LootHistory.GetItem
local C_LootHistoryGetPlayerInfo = C_LootHistory.GetPlayerInfo
local GREED = GREED
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local NEED = NEED
local PASS = PASS

local pos = 'TOP';
local cancelled_rolls = {}
local cachedRolls = {}
local completedRolls = {}
local FRAME_WIDTH, FRAME_HEIGHT = 328, 28
M.RollBars = {}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip() _G.GameTooltip:Hide() end
local function HideTip2() _G.GameTooltip:Hide(); ResetCursor() end

local rolltypes = {[1] = "need", [2] = "greed", [0] = "pass"}
local function SetTip(frame)
	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	for name, tbl in pairs(frame.parent.rolls) do
		if rolltypes[tbl[1]] == rolltypes[frame.rolltype] then
			local classColor = E:ClassColor(tbl[2])
			GameTooltip:AddLine(name, classColor.r, classColor.g, classColor.b)
		end
	end
	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then return end
	_G.GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	_G.GameTooltip:SetHyperlink(frame.link)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end

local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end

local function OnEvent(frame, _, rollID)
	cancelled_rolls[rollID] = true
	if frame.rollID ~= rollID then return end

	frame.rollID = nil
	frame.time = nil
	frame:Hide()
end

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
	local t = GetLootRollTimeLeft(frame.parent.rollID)
	local perc = t / frame.parent.time
	frame.spark:Point("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)

	if t > 1000000000 then
		frame:GetParent():Hide()
	end
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:Point(...)
	f:Size(FRAME_HEIGHT - 4)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil)
	txt:FontTemplate(nil, nil, "OUTLINE")
	txt:Point("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
	return f, txt
end

function M:CreateRollFrame()
	local frame = CreateFrame("Frame", nil, E.UIParent)
	frame:Size(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetTemplate()
	frame:SetScript("OnEvent", OnEvent)
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:Point("RIGHT", frame, 'LEFT', -(E.Spacing*3), 0)
	button:Size(FRAME_HEIGHT - (E.Border * 2))
	button:CreateBackdrop()
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	frame.button = button

	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(E.TexCoords))

	local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:Point("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetInside()
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(status)
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status

	status.bg = status:CreateTexture(nil, 'BACKGROUND')
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()
	status.bg:SetDrawLayer('BACKGROUND', 2)
	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:Size(14, FRAME_HEIGHT)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", greed, "RIGHT", 0, 2)
	frame.needbutt, frame.greedbutt = need, greed
	frame.need, frame.greed, frame.pass = needtext, greedtext, passtext

	local bind = frame:CreateFontString()
	bind:Point("LEFT", pass, "RIGHT", 3, 1)
	bind:FontTemplate(nil, nil, "OUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:FontTemplate(nil, nil, "OUTLINE")
	loot:Point("LEFT", bind, "RIGHT", 0, 0)
	loot:Point("RIGHT", frame, "RIGHT", -5, 0)
	loot:Size(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

local function GetFrame()
	for _,f in ipairs(M.RollBars) do
		if not f.rollID then return f end
	end

	local f = M:CreateRollFrame()
	if pos == "TOP" then
		f:Point("TOP", next(M.RollBars) and M.RollBars[#M.RollBars] or _G.AlertFrameHolder, "BOTTOM", 0, -4)
	else
		f:Point("BOTTOM", next(M.RollBars) and M.RollBars[#M.RollBars] or _G.AlertFrameHolder, "TOP", 0, 4)
	end
	tinsert(M.RollBars, f)
	return f
end

function M:START_LOOT_ROLL(_, rollID, time)
	if cancelled_rolls[rollID] then return end
	local f = GetFrame()
	f.rollID = rollID
	f.time = time
	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)

	local texture, name, _, quality, bop, canNeed, canGreed, _, reasonNeed, reasonGreed = GetLootRollItemInfo(rollID)

	f.button.icon:SetTexture(texture)
	f.button.link = GetLootRollItemLink(rollID)

	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed)
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed)

	if canNeed then
		f.needbutt:Enable()
		f.needbutt:SetAlpha(1)
		f.needbutt.tiptext = NEED
	else
		f.needbutt:Disable()
		f.needbutt:SetAlpha(0.2)
		f.needbutt.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed]
	end
	if canGreed then
		f.greedbutt:Enable()
		f.greedbutt:SetAlpha(1)
		f.greedbutt.tiptext = GREED
	else
		f.greedbutt:Disable()
		f.greedbutt:SetAlpha(0.2)
		f.greedbutt.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed]
	end

	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetText(name)
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	f.status.bg:SetColorTexture(color.r, color.g, color.b)

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:Point("CENTER", _G.WorldFrame, "CENTER")
	f:Show()
	_G.AlertFrame:UpdateAnchors()

	--Add cached roll info, if any
	for rollid, rollTable in pairs(cachedRolls) do
		if f.rollID == rollid then --rollid matches cached rollid
			for rollerName, rollerInfo in pairs(rollTable) do
				local rollType, class = rollerInfo[1], rollerInfo[2]
				f.rolls[rollerName] = {rollType, class}
				f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
			end
			completedRolls[rollid] = true
			break
		end
	end

	if E.db.general.autoRoll and E.mylevel == MAX_PLAYER_LEVEL and quality == 2 and not bop then
		RollOnLoot(rollID, 2)
	end
end

function M:LOOT_HISTORY_ROLL_CHANGED(_, itemIdx, playerIdx)
	local rollID = C_LootHistoryGetItem(itemIdx);
	local name, class, rollType = C_LootHistoryGetPlayerInfo(itemIdx, playerIdx);

	local rollIsHidden = true
	if name and rollType then
		for _,f in ipairs(M.RollBars) do
			if f.rollID == rollID then
				f.rolls[name] = {rollType, class}
				f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
				rollIsHidden = false
				break
			end
		end

		--History changed for a loot roll that hasn't popped up for the player yet, so cache it for later
		if rollIsHidden then
			cachedRolls[rollID] = cachedRolls[rollID] or {}
			if not cachedRolls[rollID][name] then
				cachedRolls[rollID][name] = {rollType, class}
			end
		end
	end
end

function M:LOOT_HISTORY_ROLL_COMPLETE()
	--Remove completed rolls from cache
	for rollID in pairs(completedRolls) do
		cachedRolls[rollID] = nil
		completedRolls[rollID] = nil
	end
end
M.LOOT_ROLLS_COMPLETE = M.LOOT_HISTORY_ROLL_COMPLETE

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	self:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
	self:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE')
	self:RegisterEvent("START_LOOT_ROLL")
	self:RegisterEvent("LOOT_ROLLS_COMPLETE")

	_G.UIParent:UnregisterEvent("START_LOOT_ROLL")
	_G.UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end
