--- GLOBAL ---
---@class QuestieEventHandler
local QuestieEventHandler = QuestieLoader:CreateModule("QuestieEventHandler")

-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")

--- LOCAL ---
--False -> true -> nil
local playerEntered = false
local hasFirstQLU = false
local runQLU = false

-- forward declaration
local _PLAYER_LOGIN, _PLAYER_LEVEL_UP, _PLAYER_REGEN_DISABLED, _PLAYER_REGEN_ENABLED
local _QUEST_ACCEPTED, _QUEST_TURNED_IN, _UNIT_QUEST_LOG_CHANGED, _QUEST_REMOVED, _QUEST_LOG_UPDATE, _QUEST_FINISHED
local _MAP_EXPLORATION_UPDATED, _MODIFIER_STATE_CHANGED, _CHAT_MSG_SKILL, _CHAT_MSG_COMBAT_FACTION_CHANGE
local _GROUP_ROSTER_UPDATE, _GROUP_JOINED, _GROUP_LEFT
local _CompleteQuest


--- This function registeres all required ingame events to the global "Questie"
function QuestieEventHandler:RegisterAllEvents()
    -- Putting it here reduces the size of the QuestieEventHandler, since all the regular
    -- event handlers can be local

    -- Player Events
    Questie:RegisterEvent("PLAYER_LOGIN", _PLAYER_LOGIN)
    Questie:RegisterEvent("PLAYER_LEVEL_UP", _PLAYER_LEVEL_UP)
    Questie:RegisterEvent("PLAYER_REGEN_DISABLED", _PLAYER_REGEN_DISABLED)
    Questie:RegisterEvent("PLAYER_REGEN_ENABLED", _PLAYER_REGEN_ENABLED)

    -- Miscellaneous Events
    Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", _MAP_EXPLORATION_UPDATED)
    Questie:RegisterEvent("MODIFIER_STATE_CHANGED", _MODIFIER_STATE_CHANGED)
    -- Events to update a players professions and reputations
    Questie:RegisterEvent("CHAT_MSG_SKILL", _CHAT_MSG_SKILL)
    Questie:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", _CHAT_MSG_COMBAT_FACTION_CHANGE)

    -- Quest Events
    Questie:RegisterEvent("QUEST_ACCEPTED", _QUEST_ACCEPTED)
    Questie:RegisterEvent("UNIT_QUEST_LOG_CHANGED", _UNIT_QUEST_LOG_CHANGED)
    Questie:RegisterEvent("QUEST_TURNED_IN", _QUEST_TURNED_IN)
    Questie:RegisterEvent("QUEST_REMOVED", _QUEST_REMOVED)
    Questie:RegisterEvent("QUEST_FINISHED", _QUEST_FINISHED)
    -- Use bucket for QUEST_LOG_UPDATE to let information propagate through to the blizzard API
    -- Might be able to change this to 0.5 seconds instead, further testing needed.
    Questie:RegisterBucketEvent("QUEST_LOG_UPDATE", 1, _QUEST_LOG_UPDATE)
    Questie:RegisterEvent("QUEST_DETAIL", QuestieAuto.QUEST_DETAIL) -- When the quest is presented!
    Questie:RegisterEvent("QUEST_PROGRESS", QuestieAuto.QUEST_PROGRESS)
    Questie:RegisterEvent("GOSSIP_SHOW", QuestieAuto.GOSSIP_SHOW)
    Questie:RegisterEvent("QUEST_GREETING", QuestieAuto.QUEST_GREETING) -- The window when multiple quest from a NPC
    Questie:RegisterEvent("QUEST_ACCEPT_CONFIRM", QuestieAuto.QUEST_ACCEPT_CONFIRM) -- If an escort quest is taken by people close by
    Questie:RegisterEvent("GOSSIP_CLOSED", QuestieAuto.GOSSIP_CLOSED) -- Called twice when the stopping to talk to an NPC
    Questie:RegisterEvent("QUEST_COMPLETE", QuestieAuto.QUEST_COMPLETE) -- When complete window shows

    -- Questie Comms Events

    -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
    Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, _GROUP_ROSTER_UPDATE)
    Questie:RegisterEvent("GROUP_JOINED", _GROUP_JOINED) -- This is not local because QuestieComms needs to call it
    Questie:RegisterEvent("GROUP_LEFT", _GROUP_LEFT)

    -- Nameplate / Target Frame Objective Events
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated)
    Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed)
    Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame)
end


local function _Hack_prime_log() -- this seems to make it update the data much quicker
  for i=1, GetNumQuestLogEntries() + 1 do
    GetQuestLogTitle(i)
    QuestieQuest:GetRawLeaderBoardDetails(i)
  end
end

_PLAYER_LOGIN = function()
    C_Timer.After(1, function()
        QuestieDB:Initialize()
        QuestieLib:CacheAllItemNames()

        -- Initialize Journey Window
        QuestieJourney.Initialize()
    end)
    C_Timer.After(4, function()
        -- We want the framerate to be HIGH!!!
        QuestieMap:InitializeQueue()
        _Hack_prime_log()
        QuestiePlayer:Initialize()
        QuestieQuest:Initialize()
        QuestieQuest:GetAllQuestIdsNoObjectives()
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
        QuestieNameplate:Initialize()
        Questie:Debug(DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")
        playerEntered = true
        -- manually fire QLU since enter has been delayed past the first QLU
        if hasFirstQLU then
            _QUEST_LOG_UPDATE()
        end
    end)
end

--Fires when a quest is accepted in anyway.
_QUEST_ACCEPTED = function(self, questLogIndex, questId)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_ACCEPTED", "QLogIndex: "..questLogIndex,  "QuestID: "..questId)
    --Try and cache all the potential items required for the quest.
    QuestieLib:CacheItemNames(questId)
    _Hack_prime_log()
    local timer = nil
    timer = C_Timer.NewTicker(0.5, function()
        if(QuestieLib:IsResponseCorrect(questId)) then
            QuestieQuest:AcceptQuest(questId)
            QuestieJourney:AcceptQuest(questId)
            timer:Cancel()
            Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer")
        else
            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest, waiting with timer")
        end
    end)

end

--- Fires on MAP_EXPLORATION_UPDATED.
_MAP_EXPLORATION_UPDATED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] MAP_EXPLORATION_UPDATED")
    if Questie.db.char.hideUnexploredMapIcons then
        QuestieMap.utils:MapExplorationUpdate()
    end
end

-- Needed to distinguish finished quests from abandoned quests
local finishedEventReceived = false

--- Fires when a quest is removed from the questlog, this includes turning it in
--- and abandoning it.
---@param questID QuestId
_QUEST_REMOVED = function(self, questID)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_REMOVED", questID)
    _Hack_prime_log()
    if finishedEventReceived == questID then
        finishedEventReceived = false
        runQLU = false
        _CompleteQuest(questID)
        --Broadcast our removal!
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questID)
        return
    end
    QuestieQuest:AbandonedQuest(questID)
    QuestieJourney:AbandonQuest(questID)
    runQLU = false

    --Broadcast our removal!
    Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questID)
end

--- Helper function to remove quests correctly
---@param questId QuestId
---@param count integer @The amount of calls already made in recursion
_CompleteQuest = function(questId, count)
    if(not count) then
        count = 1
    end
    local quest = QuestieDB:GetQuest(questId)
    if not quest then
        return
    end
    if(IsQuestFlaggedCompleted(questId) or quest.IsRepeatable or count > 50) then
        QuestieQuest:CompleteQuest(quest)
        QuestieJourney:CompleteQuest(questId)
    else
        Questie:Debug(DEBUG_INFO, "[QuestieEventHandler]", questId, ":Quest not complete starting timer! IsQuestFlaggedCompleted", IsQuestFlaggedCompleted(questId), "Repeatable:", quest.IsRepeatable, "Count:", count)
        C_Timer.After(0.1, function()
            _CompleteQuest(questId, count + 1)
        end)
    end
end

--- Fires when a quest is turned in, but before it is remove from the quest log.
--- We need to save the ID of the finished quest to check it in QR event.
---@param questID QuestId
---@param xpReward integer
---@param moneyReward integer
_QUEST_TURNED_IN = function(self, questID, xpReward, moneyReward)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_TURNED_IN", questID, xpReward, moneyReward)
    _Hack_prime_log()
    finishedEventReceived = questID

    -- Some repeatable sub quests don't fire a UQLC event when they're completed.
    -- Therefore we have to check here to make sure the next QLU updates the state.
    local quest = QuestieDB:GetQuest(questID)
    if quest and ((quest.parentQuest and quest.IsRepeatable) or quest.Description == nil) then
        Questie:Debug(DEBUG_DEVELOP, "Enabling runQLU")
        runQLU = true
    end
end

--- Fires when the quest log changes. That includes visual changes and
--- client/server communication, so not every event really updates the log data.
_QUEST_LOG_UPDATE = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_LOG_UPDATE")
    if playerEntered then
        Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, START.")
        C_Timer.After(1, function ()
            Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, DONE.")
            QuestieQuest:GetAllQuestIds()
            QuestieTracker:Update()
            _GROUP_JOINED()
        end)
        playerEntered = nil
    end

    -- QR or UQLC events have set the flag, so we need to update Questie state.
    if runQLU then
        QuestieHash:CompareQuestHashes()
        QuestieNameplate:UpdateNameplate()
        runQLU = false
    end
end

--- Fired before data for quest log changes, including other players.
---@param unitTarget string @The unitTarget, e.g. "player"
_UNIT_QUEST_LOG_CHANGED = function(self, unitTarget)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] UNIT_QUEST_LOG_CHANGED")
    -- If the unitTarget is "player" the changed log is from "our" player and
    -- we need to tell the next QLU event to check the quest log for updated
    -- data.
    if unitTarget == "player" then
        Questie:Debug(DEBUG_DEVELOP, "UNIT_QUEST_LOG_CHANGED: player")
        runQLU = true
    end
end

--- Fires when the player levels up
---@param level integer
---@param hitpoints integer
---@param manapoints integer
---@param talentpoints integer
_PLAYER_LEVEL_UP = function(self, level, hitpoints, manapoints, talentpoints, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_LEVEL_UP", level)

    QuestiePlayer:SetPlayerLevel(level)

    -- deferred update (possible desync fix?)
    C_Timer.After(3, function()
        QuestiePlayer:SetPlayerLevel(level)

        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
    end)
    QuestieJourney:PlayerLevelUp(level)
end

--- Fires when a modifier key changed
_MODIFIER_STATE_CHANGED = function(self, key, down)
    if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
        GameTooltip:_Rebuild() -- rebuild the tooltip
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end
end

--- Fires when some chat messages about skills are displayed
_CHAT_MSG_SKILL = function()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_SKILL")
    local isProfUpdate = QuestieProfessions:Update()
    -- This needs to be done to draw new quests that just came available
    if isProfUpdate then
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
    end
end

--- Fires when some chat messages about reputations are displayed
_CHAT_MSG_COMBAT_FACTION_CHANGE = function()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_COMBAT_FACTION_CHANGE")
    local factionChanged = QuestieReputation:Update(false)
    if factionChanged then
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
    end
end

local numOfMembers = -1
_GROUP_ROSTER_UPDATE = function()
    local currentMembers = GetNumGroupMembers()
    -- Only want to do logic when number increases, not decreases.
    if(numOfMembers < currentMembers) then
        -- Tell comms to send information to members.
        --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST")
        numOfMembers = currentMembers
    else
        -- We do however always want the local to be the current number to allow up and down.
        numOfMembers = currentMembers
    end
end

_GROUP_JOINED = function()
    Questie:Debug(DEBUG_DEVELOP, "GROUP_JOINED")
    local checkTimer = nil
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.1, function()
        local partyPending = UnitInParty("player")
        local inParty = UnitInParty("party1")
        local inRaid = UnitInRaid("raid1")
        if(partyPending) then
            if(inParty or inRaid) then
                Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player joined party/raid, ask for questlogs")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                checkTimer:Cancel()
            end
        else
            Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end

_GROUP_LEFT = function()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
end

local previousTrackerState = nil

_PLAYER_REGEN_DISABLED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_DISABLED")
    if Questie.db.global.hideTrackerInCombat then
        previousTrackerState = Questie.db.char.isTrackerExpanded
        QuestieTracker:Collapse()
    end
end

_PLAYER_REGEN_ENABLED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_ENABLED")
    if Questie.db.global.hideTrackerInCombat and (previousTrackerState == true) then
        QuestieTracker:Expand()
    end
end

local function _AllQuestWindowsClosed()
    if GossipFrame and (not GossipFrame:IsVisible())
        and GossipFrameGreetingPanel and (not GossipFrameGreetingPanel:IsVisible())
        and QuestFrameGreetingPanel and (not QuestFrameGreetingPanel:IsVisible())
        and QuestFrameDetailPanel and (not QuestFrameDetailPanel:IsVisible())
        and QuestFrameProgressPanel and (not QuestFrameProgressPanel:IsVisible())
        and QuestFrameRewardPanel and (not QuestFrameRewardPanel:IsVisible()) then
        return true
    end
    return false
end

_QUEST_FINISHED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_FINISHED")

    C_Timer.After(0.5, function()
        if _AllQuestWindowsClosed() then
            Questie:Debug(DEBUG_DEVELOP, "All quest windows closed! Resetting shouldRunAuto")
            QuestieAuto:ResetModifier()
        end
    end)

    -- Quests which are just turned in don't trigger QLU.
    -- So runQLU is still active from QUEST_TURNED_IN
    if runQLU then
        Questie:Debug(DEBUG_DEVELOP, "runQLU still active")
        if finishedEventReceived then
            Questie:Debug(DEBUG_DEVELOP, "finishedEventReceived is questId")
            local quest = QuestieDB:GetQuest(finishedEventReceived)
            Questie:Debug(DEBUG_DEVELOP, "Completing automatic completion quest")
            QuestieQuest:CompleteQuest(quest)
        else
            Questie:Debug(DEBUG_DEVELOP, "finishedEventReceived is false. Something is off?")
        end
        runQLU = false
    end
end
