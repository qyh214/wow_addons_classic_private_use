local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate ElvUF.")
local Translit = E.Libs.Translit
local translitMark = "!"

--Lua functions
local _G = _G
local select = select
local wipe = wipe
local floor = floor
local pairs = pairs
local gmatch, gsub, format = gmatch, gsub, format
local strfind, strmatch, utf8lower, utf8sub = strfind, strmatch, string.utf8lower, string.utf8sub
local strlower = strlower
--WoW API / Variables
local GetGuildInfo = GetGuildInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetPVPTimer = GetPVPTimer
local GetQuestGreenRange = GetQuestGreenRange
local GetTime = GetTime
local GetUnitSpeed = GetUnitSpeed
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local UnitPlayerControlled = UnitPlayerControlled

local CHAT_FLAG_AFK = CHAT_FLAG_AFK:gsub('<(.-)>', '|r<|cffFF0000%1|r>')
local CHAT_FLAG_DND = CHAT_FLAG_DND:gsub('<(.-)>', '|r<|cffFFFF00%1|r>')
local PVP = PVP
local UNITNAME_SUMMON_TITLE17 = UNITNAME_SUMMON_TITLE17
local UNKNOWN = UNKNOWN

local GetCVarBool = GetCVarBool
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local UnitPVPName = UnitPVPName
local LEVEL = LEVEL

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness
local CreateTextureMarkup = CreateTextureMarkup
local CreateAtlasMarkup = CreateAtlasMarkup

local SPELL_POWER_MANA = Enum.PowerType.Mana or 0
-- GLOBALS: Hex, PowerBarColor, _TAGS, _COLORS

------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

function E:UnitHealthValues(unit)
	if _G.RealMobHealth and unit and not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) then
		local c, m, _, _ = _G.RealMobHealth.GetUnitHealth(unit);
		return c, m
	elseif _G.MobHealthFrame and unit and not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) then
		local name, level = UnitName(unit), UnitLevel(unit)
		local cur, full = _G.MI2_GetMobData(name, level, unit).healthCur, _G.MI2_GetMobData(name, level, unit).healthMax;
		return cur, full
	else
		return UnitHealth(unit), UnitHealthMax(unit)
	end
end

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)

	if (name == UNKNOWN and E.myclass == "MONK") and UnitIsUnit(unit, "pet") then
		name = format(UNITNAME_SUMMON_TITLE17, _G.UnitName("player"))
	end

	if realm and realm ~= "" then
		return name, realm
	else
		return name
	end
end

local function abbrev(name)
	local letters, lastWord = '', strmatch(name, '.+%s(.+)$')
	if lastWord then
		for word in gmatch(name, '.-%s') do
			local firstLetter = utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format('%s%s. ', letters, firstLetter)
			end
		end
		name = format('%s%s', letters, lastWord)
	end
	return name
end

ElvUF.Tags.Events['status:text'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['status:text'] = function(unit)
	if UnitIsAFK(unit) then
		return CHAT_FLAG_AFK
	elseif UnitIsDND(unit) then
		return CHAT_FLAG_DND
	end

	return nil
end

ElvUF.Tags.Events['status:icon'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['status:icon'] = function(unit)
	if UnitIsAFK(unit) then
		return CreateTextureMarkup("Interface\\FriendsFrame\\StatusIcon-Away", 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
	elseif UnitIsDND(unit) then
		return CreateTextureMarkup("Interface\\FriendsFrame\\StatusIcon-DnD", 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
	end

	return nil
end

ElvUF.Tags.Events['healthcolor'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['healthcolor'] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local cur, max = E:UnitHealthValues(unit)
		local r, g, b = ElvUF:ColorGradient(cur, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end

for textFormat in pairs(E.GetFormattedTextStyles) do
	local tagTextFormat = strlower(gsub(textFormat, '_', '-'))
	ElvUF.Tags.Events[format('health:%s', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
	ElvUF.Tags.Methods[format('health:%s', tagTextFormat)] = function(unit)
		local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		if (status) then
			return status
		else
			local min, max = E:UnitHealthValues(unit)
			return E:GetFormattedText(textFormat, min, max)
		end
	end

	ElvUF.Tags.Events[format('health:%s-nostatus', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
	ElvUF.Tags.Methods[format('health:%s-nostatus', tagTextFormat)] = function(unit)
		local min, max = E:UnitHealthValues(unit)
		return E:GetFormattedText(textFormat, min, max)
	end


	ElvUF.Tags.Events[format('power:%s', tagTextFormat)] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
	ElvUF.Tags.Methods[format('power:%s', tagTextFormat)] = function(unit)
		local pType = UnitPowerType(unit)
		local min = UnitPower(unit, pType)

		if min == 0 and tagTextFormat ~= 'deficit' then
			return ''
		else
			return E:GetFormattedText(textFormat, UnitPower(unit, pType), UnitPowerMax(unit, pType))
		end
	end

	ElvUF.Tags.Events[format('mana:%s', tagTextFormat)] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER'
	ElvUF.Tags.Methods[format('mana:%s', tagTextFormat)] = function(unit)
		local min = UnitPower(unit, SPELL_POWER_MANA)

		if min == 0 and tagTextFormat ~= 'deficit' then
			return ''
		else
			return E:GetFormattedText(textFormat, UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA))
		end
	end

	if tagTextFormat ~= 'percent' then
		ElvUF.Tags.Events[format('health:%s:shortvalue', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
		ElvUF.Tags.Methods[format('health:%s:shortvalue', tagTextFormat)] = function(unit)
			local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
			if (status) then
				return status
			else
				local min, max = E:UnitHealthValues(unit)
				return E:GetFormattedText(textFormat, min, max, nil, true)
			end
		end

		ElvUF.Tags.Events[format('health:%s-nostatus:shortvalue', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
		ElvUF.Tags.Methods[format('health:%s-nostatus:shortvalue', tagTextFormat)] = function(unit)
			local min, max = E:UnitHealthValues(unit)
			return E:GetFormattedText(textFormat, min, max, nil, true)
		end


		ElvUF.Tags.Events[format('power:%s:shortvalue', tagTextFormat)] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
		ElvUF.Tags.Methods[format('power:%s:shortvalue', tagTextFormat)] = function(unit)
			local pType = UnitPowerType(unit)
			return E:GetFormattedText(textFormat, UnitPower(unit, pType), UnitPowerMax(unit, pType), nil, true)
		end

		ElvUF.Tags.Events[format('mana:%s:shortvalue', tagTextFormat)] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER'
		ElvUF.Tags.Methods[format('mana:%s:shortvalue', tagTextFormat)] = function(unit)
			return E:GetFormattedText(textFormat, UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA), nil, true)
		end
	end
end

for textFormat, length in pairs({veryshort = 5, short = 10, medium = 15, long = 20}) do
	ElvUF.Tags.Events[format('health:deficit-percent:name-%s', textFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('health:deficit-percent:name-%s', textFormat)] = function(unit)
		local cur, max = E:UnitHealthValues(unit)
		local deficit = max - cur

		if (deficit > 0 and cur > 0) then
			return _TAGS["health:percent-nostatus"](unit)
		else
			return _TAGS[format("name:%s", textFormat)](unit)
		end
	end

	ElvUF.Tags.Events[format('name:abbrev:%s', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:abbrev:%s', textFormat)] = function(unit)
		local name = UnitName(unit)

		if name and strfind(name, '%s') then
			name = abbrev(name)
		end

		return name ~= nil and E:ShortenString(name, length) or ''
	end

	ElvUF.Tags.Events[format('name:%s', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:%s', textFormat)] = function(unit)
		local name = UnitName(unit)
		return name ~= nil and E:ShortenString(name, length) or nil
	end

	ElvUF.Tags.Events[format('name:%s:status', textFormat)] = 'UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH_FREQUENT'
	ElvUF.Tags.Methods[format('name:%s:status', textFormat)] = function(unit)
		local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		local name = UnitName(unit)
		if (status) then
			return status
		else
			return name ~= nil and E:ShortenString(name, length) or nil
		end
	end

	ElvUF.Tags.Events[format('name:%s:translit', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:%s:translit', textFormat)] = function(unit)
		local name = Translit:Transliterate(UnitName(unit), translitMark)
		return name ~= nil and E:ShortenString(name, length) or nil
	end

	ElvUF.Tags.Events[format('target:%s', textFormat)] = 'UNIT_TARGET'
	ElvUF.Tags.Methods[format('target:%s', textFormat)] = function(unit)
		local targetName = UnitName(unit.."target")
		return targetName ~= nil and E:ShortenString(targetName, length) or nil
	end

	ElvUF.Tags.Events[format('target:%s:translit', textFormat)] = 'UNIT_TARGET'
	ElvUF.Tags.Methods[format('target:%s:translit', textFormat)] = function(unit)
		local targetName = Translit:Transliterate(UnitName(unit.."target"), translitMark)
		return targetName ~= nil and E:ShortenString(targetName, length) or nil
	end
end

ElvUF.Tags.Events['name:abbrev'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbrev'] = function(unit)
	local name = UnitName(unit)

	if name and strfind(name, '%s') then
		name = abbrev(name)
	end

	return name ~= nil and name or ''
end

ElvUF.Tags.Events['health:max'] = 'UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:max'] = function(unit)
	local _, max = E:UnitHealthValues(unit)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['power:max'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:max'] = function(unit)
	local pType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, pType)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['mana:max'] = 'UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:max'] = function(unit)
	local max = UnitPowerMax(unit, SPELL_POWER_MANA)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['health:max:shortvalue'] = 'UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:max:shortvalue'] = function(unit)
	local _, max = E:UnitHealthValues(unit)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

ElvUF.Tags.Events['power:max:shortvalue'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:max:shortvalue'] = function(unit)
	local pType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, pType)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

ElvUF.Tags.Events['mana:max:shortvalue'] = 'UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:max:shortvalue'] = function(unit)
	local max = UnitPowerMax(unit, SPELL_POWER_MANA)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

ElvUF.Tags.Events['health:deficit-percent:name'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['health:deficit-percent:name'] = function(unit)
	local cur, max = E:UnitHealthValues(unit)
	local deficit = max - cur

	if (deficit > 0 and cur > 0) then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS.name(unit)
	end
end

ElvUF.Tags.Methods['manacolor'] = function()
	local color = ElvUF.colors.power.MANA
	if color then
		return Hex(color[1], color[2], color[3])
	else
		return Hex(PowerBarColor.MANA.r, PowerBarColor.MANA.g, PowerBarColor.MANA.b)
	end
end

ElvUF.Tags.Events['difficultycolor'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['difficultycolor'] = function(unit)
	local r, g, b
	local DiffColor = UnitLevel(unit) - UnitLevel('player')
	if (DiffColor >= 5) then
		r, g, b = 0.77, 0.12 , 0.23
	elseif (DiffColor >= 3) then
		r, g, b = 1.0, 0.49, 0.04
	elseif (DiffColor >= -2) then
		r, g, b = 1.0, 0.96, 0.41
	elseif (-DiffColor <= GetQuestGreenRange()) then
		r, g, b = 0.251, 0.753, 0.251
	else
		r, g, b = 0.6, 0.6, 0.6
	end

	return Hex(r, g, b)
end

ElvUF.Tags.Events['namecolor'] = 'UNIT_NAME_UPDATE UNIT_FACTION'
ElvUF.Tags.Methods['namecolor'] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local unitPlayer = UnitIsPlayer(unit)
	if (unitPlayer) then
		local _, unitClass = UnitClass(unit)
		local class = ElvUF.colors.class[unitClass]
		if not class then return "" end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return '|cFFC2C2C2'
	end
end

ElvUF.Tags.Events['smartlevel'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['smartlevel'] = function(unit)
	local level = UnitLevel(unit)
	if level == UnitLevel('player') then
		return nil
	elseif(level > 0) then
		return level
	else
		return '??'
	end
end

ElvUF.Tags.Events['realm'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm'] = function(unit)
	local _, realm = UnitName(unit)

	if realm and realm ~= "" then
		return realm
	else
		return nil
	end
end

ElvUF.Tags.Events['realm:dash'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:dash'] = function(unit)
	local _, realm = UnitName(unit)

	if realm and (realm ~= "" and realm ~= E.myrealm) then
		realm = format("-%s", realm)
	elseif realm == "" then
		realm = nil
	end

	return realm
end

ElvUF.Tags.Events['realm:translit'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:translit'] = function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)

	if realm and realm ~= "" then
		return realm
	else
		return nil
	end
end

ElvUF.Tags.Events['realm:dash:translit'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:dash:translit'] = function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)

	if realm and (realm ~= "" and realm ~= E.myrealm) then
		realm = format("-%s", realm)
	elseif realm == "" then
		realm = nil
	end

	return realm
end

ElvUF.Tags.SharedEvents.PLAYER_GUILD_UPDATE = true

ElvUF.Tags.Events['guild'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return GetGuildInfo(unit) or nil
	end
end

ElvUF.Tags.Events['guild:brackets'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets'] = function(unit)
	local guildName = GetGuildInfo(unit)

	return guildName and format("<%s>", guildName) or nil
end

ElvUF.Tags.Events['guild:translit'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:translit'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Translit:Transliterate(GetGuildInfo(unit), translitMark) or nil
	end
end

ElvUF.Tags.Events['guild:brackets:translit'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets:translit'] = function(unit)
	local guildName = Translit:Transliterate(GetGuildInfo(unit), translitMark)

	return guildName and format("<%s>", guildName) or nil
end

ElvUF.Tags.Events['target'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target'] = function(unit)
	local targetName = UnitName(unit.."target")
	return targetName or nil
end

ElvUF.Tags.Events['target:translit'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target:translit'] = function(unit)
	local targetName = Translit:Transliterate(UnitName(unit.."target"), translitMark)
	return targetName or nil
end

ElvUF.Tags.Events['happiness:full'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:full'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		return _G['PET_HAPPINESS'..GetPetHappiness()]
	end
end

ElvUF.Tags.Events['happiness:icon'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:icon'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		local left, right, top, bottom
		local happiness = GetPetHappiness()

		if(happiness == 1) then
			left, right, top, bottom = 0.375, 0.5625, 0, 0.359375
		elseif(happiness == 2) then
			left, right, top, bottom = 0.1875, 0.375, 0, 0.359375
		elseif(happiness == 3) then
			left, right, top, bottom = 0, 0.1875, 0, 0.359375
		end

		return CreateTextureMarkup([[Interface\PetPaperDollFrame\UI-PetHappiness]], 128, 64, 16, 16, left, right, top, bottom, 0, 0)
	end
end

ElvUF.Tags.Events['happiness:discord'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:discord'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		local happiness = GetPetHappiness()

		if(happiness == 1) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\Rage]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		elseif(happiness == 2) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\SlightFrown]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		elseif(happiness == 3) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\HeartEyes]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		end
	end
end

ElvUF.Tags.Events['happiness:color'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:color'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		return Hex(_COLORS.happiness[GetPetHappiness()])
	end
end

ElvUF.Tags.Events['loyalty'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['loyalty'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		local loyalty = gsub(GetPetLoyalty(), '.-(%d).*', '%1')
		return loyalty
	end
end

ElvUF.Tags.Events['diet'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['diet'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (unit == 'pet' and hasPetUI and isHunterPet) then
		return GetPetFoodTypes()
	end
end

local unitStatus = {}
ElvUF.Tags.OnUpdateThrottle['statustimer'] = 1
ElvUF.Tags.Methods['statustimer'] = function(unit)
	if not UnitIsPlayer(unit) then return; end
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'AFK' then
			unitStatus[guid] = {'AFK', GetTime()}
		end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'DND' then
			unitStatus[guid] = {'DND', GetTime()}
		end
	elseif(UnitIsDead(unit)) or (UnitIsGhost(unit))then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'Dead' then
			unitStatus[guid] = {'Dead', GetTime()}
		end
	elseif(not UnitIsConnected(unit)) then
		if not unitStatus[guid] or unitStatus[guid] and unitStatus[guid][1] ~= 'Offline' then
			unitStatus[guid] = {'Offline', GetTime()}
		end
	else
		unitStatus[guid] = nil
	end

	if unitStatus[guid] ~= nil then
		local status = unitStatus[guid][1]
		local timer = GetTime() - unitStatus[guid][2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return format("%s (%01.f:%02.f)", status, mins, secs)
	else
		return nil
	end
end

ElvUF.Tags.OnUpdateThrottle['pvptimer'] = 1
ElvUF.Tags.Methods['pvptimer'] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return format("%s (%01.f:%02.f)", PVP, mins, secs)
		else
			return PVP
		end
	else
		return nil
	end
end

local GroupUnits = {}
local f = CreateFrame("Frame")

f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
	local groupType, groupSize
	wipe(GroupUnits)

	if IsInRaid() then
		groupType = "raid"
		groupSize = GetNumGroupMembers()
	elseif IsInGroup() then
		groupType = "party"
		groupSize = GetNumGroupMembers() - 1
		GroupUnits.player = true
	else
		groupType = "solo"
		groupSize = 1
	end

	for index = 1, groupSize do
		local unit = groupType..index
		if not UnitIsUnit(unit, "player") then
			GroupUnits[unit] = true
		end
	end
end)

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:8'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:8'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit)
				if d and d <= 8 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:10'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:10'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit)
				if d and d <= 10 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:30'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:30'] = function(unit)
	local unitsInRange, d = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				d = E:GetDistance(unit, groupUnit)
				if d and d <= 30 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['distance'] = 0.1
ElvUF.Tags.Methods['distance'] = function(unit)
	local d
	if UnitIsConnected(unit) and not UnitIsUnit(unit, 'player') then
		d = E:GetDistance('player', unit)

		if d then
			d = format("%.1f", d)
		end
	end

	return d or nil
end

local baseSpeed = BASE_MOVEMENT_SPEED
local speedText = SPEED
ElvUF.Tags.OnUpdateThrottle['speed:percent'] = 0.1
ElvUF.Tags.Methods['speed:percent'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

	return format("%s: %d%%", speedText, currentSpeedInPercent)
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-moving'] = 0.1
ElvUF.Tags.Methods['speed:percent-moving'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

	if currentSpeedInPercent then
		currentSpeedInPercent = format("%s: %d%%", speedText, currentSpeedInPercent)
	end

	return currentSpeedInPercent or nil
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-raw'] = 0.1
ElvUF.Tags.Methods['speed:percent-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

	return format("%d%%", currentSpeedInPercent)
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-moving-raw'] = 0.1
ElvUF.Tags.Methods['speed:percent-moving-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

	if currentSpeedInPercent then
		currentSpeedInPercent = format("%d%%", currentSpeedInPercent)
	end

	return currentSpeedInPercent or nil
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)

	return format("%s: %.1f", speedText, currentSpeedInYards)
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-moving'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-moving'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)

	return currentSpeedInYards > 0 and format("%s: %.1f", speedText, currentSpeedInYards) or nil
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-raw'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return format("%.1f", currentSpeedInYards)
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-moving-raw'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-moving-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)

	return currentSpeedInYards > 0 and format("%.1f", currentSpeedInYards) or nil
end

ElvUF.Tags.Events['classificationcolor'] = 'UNIT_CLASSIFICATION_CHANGED'
ElvUF.Tags.Methods['classificationcolor'] = function(unit)
	local c = UnitClassification(unit)
	if(c == 'rare' or c == 'elite') then
		return Hex(1, 0.5, 0.25) --Orange
	elseif(c == 'rareelite' or c == 'worldboss') then
		return Hex(1, 0, 0) --Red
	end
end

ElvUF.Tags.Events['classification:icon'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['classification:icon'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	local classification = UnitClassification(unit)
	if classification == "elite" or classification == "worldboss" then
		return CreateAtlasMarkup("nameplates-icon-elite-gold", 16, 16)
	elseif classification == "rareelite" or classification == 'rare' then
		return CreateAtlasMarkup("nameplates-icon-elite-silver", 16, 16)
	end
end

ElvUF.Tags.Events['npctitle'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['npctitle'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local Title = _G[format('ElvUI_ScanTooltipTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]:GetText()

	if (Title and not Title:find('^'..LEVEL)) then
		return Title
	end
end

ElvUF.Tags.Events['guild:rank'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['guild:rank'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return select(2, GetGuildInfo(unit)) or ''
	end
end

ElvUF.Tags.Events['class'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['class'] = function(unit)
	return UnitClass(unit)
end

ElvUF.Tags.Events['name:title'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:title'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return UnitPVPName(unit)
	end
end

ElvUF.Tags.SharedEvents.QUEST_LOG_UPDATE = true

ElvUF.Tags.Events['quest:title'] = 'QUEST_LOG_UPDATE'
ElvUF.Tags.Methods['quest:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local QuestName

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')

			if not ( PlayerName and PlayerName ~= '' and PlayerName ~= UnitName('player') ) then
				if ProgressText then
					QuestName = _G['ElvUI_ScanTooltipTextLeft' .. i - 1]:GetText()
				end
			end
		end
		for i = 1, GetNumQuestLogEntries() do
			local title, level, _, isHeader = GetQuestLogTitle(i)
			if not isHeader and title == QuestName then
				local colors = GetQuestDifficultyColor(level)
				return Hex(colors.r, colors.g, colors.b)..QuestName..'|r'
			end
		end
	end
end

ElvUF.Tags.Events['quest:info'] = 'QUEST_LOG_UPDATE'
ElvUF.Tags.Methods['quest:info'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local ObjectiveCount = 0
	local QuestName

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')
			if (not PlayerName or PlayerName == '' or PlayerName == UnitName('player')) and ProgressText then
				local x, y
				if not QuestName and ProgressText then
					QuestName = _G['ElvUI_ScanTooltipTextLeft' .. i - 1]:GetText()
				end
				if ProgressText then
					x, y = strmatch(ProgressText, '(%d+)/(%d+)')
					if x and y then
						local NumLeft = y - x
						if NumLeft > ObjectiveCount then -- track highest number of objectives
							ObjectiveCount = NumLeft
							if ProgressText then
								return ProgressText
							end
						end
					else
						if ProgressText then
							return QuestName .. ': ' .. ProgressText
						end
					end
				end
			end
		end
	end
end
