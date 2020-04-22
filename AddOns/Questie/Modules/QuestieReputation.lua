---@class QuestieReputation
local QuestieReputation = QuestieLoader:CreateModule("QuestieReputation")

local playerReputations = {}

--- Updates all factions a player already discovered and checks if any of these
--- reached a new reputation level
---@param isInit boolean @
function QuestieReputation:Update(isInit)
    Questie:Debug(DEBUG_DEVELOP, "QuestieReputation: Update")
    ExpandFactionHeader(0) -- Expand all header

    local factionChanged = false

    for i=1, GetNumFactions() do
        local _, _, standingId, _, _, barValue, _, _, isHeader, _, _, _, _, factionID, _, _ = GetFactionInfo(i)
        if isHeader == nil or isHeader == false then
            local previousValues = playerReputations[factionID]
            playerReputations[factionID] = {standingId, barValue}

            if (not isInit) and previousValues ~= nil and previousValues[1] ~= standingId then
                factionChanged = true
            end
        end
    end

    return factionChanged
end

-- This function is just for debugging purpose
-- There is no need to access the playerReputations table somewhere else
function QuestieReputation:GetPlayerReputations()
    return playerReputations
end

-- factionIDs https://wow.gamepedia.com/FactionID
-- StandingIDs https://wow.gamepedia.com/API_TYPE_StandingId
-- Hated        -6000 to -42000     1
-- Hostile      -3000 to -5999      2
-- Unfriendly   -1 to -2999         3
-- Neutral      0 to 2999           4
-- Friendly     3000 to 8999        5
-- Honored      9000 to 20999       6
-- Revered      21000 to 41999      7
-- Exalted      42000 to 41999      8

function QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep)
    local hasMinRep = true -- the player has reached the min required reputation value
    local hasMaxRep = true -- the player has not reached the max allowed reputation value

    if requiredMinRep ~= nil then
        local minFactionID = requiredMinRep[1]
        local reqMinValue = requiredMinRep[2]

        if playerReputations[minFactionID] ~= nil then
            hasMinRep = playerReputations[minFactionID][2] >= reqMinValue
        else
            hasMinRep = false
        end
    end
    if requiredMaxRep ~= nil then
        local maxFactionID = requiredMaxRep[1]
        local reqMaxValue = requiredMaxRep[2]

        if playerReputations[maxFactionID] ~= nil then
            hasMaxRep = playerReputations[maxFactionID][2] < reqMaxValue
        else
            hasMaxRep = false
        end
    end
    return hasMinRep and hasMaxRep
end
