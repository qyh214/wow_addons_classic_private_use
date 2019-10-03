local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.questtimers then return end

	local QuestTimerFrame = _G.QuestTimerFrame
	S:HandleFrame(QuestTimerFrame, true)

	E:CreateMover(QuestTimerFrame, 'QuestTimerFrameMover', QUEST_TIMERS)

	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetAllPoints(QuestTimerFrameMover)

	_G.QuestTimerHeader:Point('TOP', 1, 8)

	local QuestTimerFrameHolder = CreateFrame('Frame', 'QuestTimerFrameHolder', E.UIParent)
	QuestTimerFrameHolder:Size(150, 22)
	QuestTimerFrameHolder:SetPoint('TOP', QuestTimerFrameMover, 'TOP')

	hooksecurefunc(QuestTimerFrame, 'SetPoint', function(_, _, parent)
		if parent ~= QuestTimerFrameHolder then
			QuestTimerFrame:ClearAllPoints()
			QuestTimerFrame:Point('TOP', QuestTimerFrameHolder, 'TOP')
		end
	end)
end

S:AddCallback('Skin_QuestTimers', LoadSkin)