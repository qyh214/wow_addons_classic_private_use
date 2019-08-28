local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins');

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.questtimers ~= true then return end

	local QuestTimerFrame = _G.QuestTimerFrame
	QuestTimerFrame:StripTextures()
	QuestTimerFrame:SetTemplate('Transparent')

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

S:AddCallback('QuestTimer', LoadSkin)