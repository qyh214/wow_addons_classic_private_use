local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = E.Libs.LSM
UF.LSM = E.Libs.LSM

--Lua functions
local _G = _G
local select, type, unpack, assert, tostring = select, type, unpack, assert, tostring
local min, pairs, ipairs, tinsert, strsub = min, pairs, ipairs, tinsert, strsub
local strfind, gsub, format = strfind, gsub, format
--WoW API / Variables
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local hooksecurefunc = hooksecurefunc
local IsReplacingUnit = IsReplacingUnit
local RegisterStateDriver = RegisterStateDriver
local UnitExists = UnitExists
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local UnregisterStateDriver = UnregisterStateDriver
local PlaySound = PlaySound

local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local SOUNDKIT_IG_CREATURE_AGGRO_SELECT = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
local SOUNDKIT_IG_CHARACTER_NPC_SELECT = SOUNDKIT.IG_CHARACTER_NPC_SELECT
local SOUNDKIT_IG_CREATURE_NEUTRAL_SELECT = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
local SOUNDKIT_INTERFACE_SOUND_LOST_TARGET_UNIT = SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT
-- GLOBALS: ElvUF_Parent

local hiddenParent = CreateFrame("Frame", nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

UF.headerstoload = {}
UF.unitgroupstoload = {}
UF.unitstoload = {}

UF.groupPrototype = {}
UF.headerPrototype = {}
UF.headers = {}
UF.groupunits = {}
UF.units = {}

UF.statusbars = {}
UF.fontstrings = {}
UF.badHeaderPoints = {
	['TOP'] = 'BOTTOM',
	['LEFT'] = 'RIGHT',
	['BOTTOM'] = 'TOP',
	['RIGHT'] = 'LEFT',
}

UF.headerFunctions = {}
UF.classMaxResourceBar = {
	['PALADIN'] = 5,
	['WARLOCK'] = 5,
	['MAGE'] = 4,
	['SHAMAN'] = 4,
	['ROGUE'] = 6,
	['DRUID'] = 5
}

UF.instanceMapIDs = {
	[30]   = 40, -- Alterac Valley
	[489]  = 10, -- Classic Warsong Gulch
	[529]  = 15, -- Classic Arathi Basin
	[566]  = 15, -- Eye of the Storm
	[2107] = 15, -- Arathi Basin
}

UF.headerGroupBy = {
	['CLASS'] = function(header)
		header:SetAttribute("groupingOrder", "DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", 'CLASS')
	end,
	['ROLE'] = function(header) UF.headerGroupBy['CLASS'](header) end,
	['ROLE2'] = function(header) UF.headerGroupBy['CLASS'](header) end,
	['CLASSROLE'] = function(header) UF.headerGroupBy['CLASS'](header) end,
	['MTMA'] = function(header)
		header:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", "ROLE")
	end,
	['NAME'] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
	end,
	["GROUP"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", "GROUP")
	end,
	['PETNAME'] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
		header:SetAttribute("filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
}

local POINT_COLUMN_ANCHOR_TO_DIRECTION = {
	['TOPTOP'] = 'UP_RIGHT',
	['BOTTOMBOTTOM'] = 'TOP_RIGHT',
	['LEFTLEFT'] = 'RIGHT_UP',
	['RIGHTRIGHT'] = 'LEFT_UP',
	['RIGHTTOP'] = 'LEFT_DOWN',
	['LEFTTOP'] = 'RIGHT_DOWN',
	['LEFTBOTTOM'] = 'RIGHT_UP',
	['RIGHTBOTTOM'] = 'LEFT_UP',
	['BOTTOMRIGHT'] = 'UP_LEFT',
	['BOTTOMLEFT'] = 'UP_RIGHT',
	['TOPRIGHT'] = 'DOWN_LEFT',
	['TOPLEFT'] = 'DOWN_RIGHT'
}

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOP",
	DOWN_LEFT = "TOP",
	UP_RIGHT = "BOTTOM",
	UP_LEFT = "BOTTOM",
	RIGHT_DOWN = "LEFT",
	RIGHT_UP = "LEFT",
	LEFT_DOWN = "RIGHT",
	LEFT_UP = "RIGHT",
	UP = "BOTTOM",
	DOWN = "TOP"
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
	OUT_RIGHT_UP = "BOTTOM",
	OUT_LEFT_UP = "BOTTOM",
	OUT_RIGHT_DOWN = "TOP",
	OUT_LEFT_DOWN = "TOP",
	OUT_UP_RIGHT = "LEFT",
	OUT_UP_LEFT = "RIGHT",
	OUT_DOWN_RIGHT = "LEFT",
	OUT_DOWN_LEFT = "RIGHT",
}

local INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "RIGHT",
	DOWN_LEFT = "LEFT",
	UP_RIGHT = "RIGHT",
	UP_LEFT = "LEFT",
	RIGHT_DOWN = "BOTTOM",
	RIGHT_UP = "TOP",
	LEFT_DOWN = "BOTTOM",
	LEFT_UP = "TOP",
	UP = "TOP",
	DOWN = "BOTTOM"
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "LEFT",
	DOWN_LEFT = "RIGHT",
	UP_RIGHT = "LEFT",
	UP_LEFT = "RIGHT",
	RIGHT_DOWN = "TOP",
	RIGHT_UP = "BOTTOM",
	LEFT_DOWN = "TOP",
	LEFT_UP = "BOTTOM",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

function UF:ConvertGroupDB(group)
	local db = self.db.units[group.groupName]
	if db.point and db.columnAnchorPoint then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint];
		db.point = nil;
		db.columnAnchorPoint = nil;
	end

	if db.growthDirection == "UP" then
		db.growthDirection = "UP_RIGHT"
	end

	if db.growthDirection == "DOWN" then
		db.growthDirection = "DOWN_RIGHT"
	end
end

function UF:Construct_UF(frame, unit)
	frame:SetScript('OnEnter', UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UnitFrame_OnLeave)

	if(self.thinBorders) then
		frame.SPACING = 0
		frame.BORDER = E.mult
	else
		frame.BORDER = E.Border
		frame.SPACING = E.Spacing
	end

	frame.SHADOW_SPACING = 3
	frame.CLASSBAR_YOFFSET = 0	--placeholder
	frame.BOTTOM_OFFSET = 0 --placeholder

	frame.RaisedElementParent = CreateFrame('Frame', nil, frame)
	frame.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 100)

	if not self.groupunits[unit] then
		UF["Construct_"..gsub(E:StringTitle(unit), 't(arget)', 'T%1').."Frame"](self, frame, unit)
	else
		UF["Construct_"..E:StringTitle(self.groupunits[unit]).."Frames"](self, frame, unit)
	end

	return frame
end

function UF:GetObjectAnchorPoint(frame, point)
	if point == 'Frame' then
		return frame
	end

	local place = frame[point]
	if place and place:IsShown() then
		return place
	else
		return frame
	end
end

function UF:GetPositionOffset(position, offset)
	if not offset then offset = 2; end
	local x, y = 0, 0
	if strfind(position, 'LEFT') then
		x = offset
	elseif strfind(position, 'RIGHT') then
		x = -offset
	end

	if strfind(position, 'TOP') then
		y = -offset
	elseif strfind(position, 'BOTTOM') then
		y = offset
	end

	return x, y
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0
	if p1 == "RIGHT" and p2 == "LEFT" then
		x = -3
	elseif p1 == "LEFT" and p2 == "RIGHT" then
		x = 3
	end

	if strfind(p1, 'TOP') and strfind(p2, 'BOTTOM') then
		y = -1
	elseif strfind(p1, 'BOTTOM') and strfind(p2, 'TOP') then
		y = 1
	end

	return E:Scale(x), E:Scale(y)
end

function UF:GetAuraAnchorFrame(frame, attachTo)
	if attachTo == 'FRAME' then
		return frame
	elseif attachTo == 'BUFFS' and frame.Buffs then
		return frame.Buffs
	elseif attachTo == 'DEBUFFS' and frame.Debuffs then
		return frame.Debuffs
	elseif attachTo == 'HEALTH' and frame.Health then
		return frame.Health
	elseif attachTo == 'POWER' and frame.Power then
		return frame.Power
	elseif attachTo == 'TRINKET' and frame.PVPSpecIcon then
		return frame.PVPSpecIcon
	else
		return frame
	end
end

function UF:ClearChildPoints(...)
	for i=1, select("#", ...) do
		local child = select(i, ...)
		child:ClearAllPoints()
	end
end

function UF:UpdateColors()
	local db = self.db.colors

	ElvUF.colors.tapped = E:SetColorTable(ElvUF.colors.tapped, db.tapped)
	ElvUF.colors.disconnected = E:SetColorTable(ElvUF.colors.disconnected, db.disconnected)
	ElvUF.colors.health = E:SetColorTable(ElvUF.colors.health, db.health)
	ElvUF.colors.power.MANA = E:SetColorTable(ElvUF.colors.power.MANA, db.power.MANA)
	ElvUF.colors.power.RAGE = E:SetColorTable(ElvUF.colors.power.RAGE, db.power.RAGE)
	ElvUF.colors.power.FOCUS = E:SetColorTable(ElvUF.colors.power.FOCUS, db.power.FOCUS)
	ElvUF.colors.power.ENERGY = E:SetColorTable(ElvUF.colors.power.ENERGY, db.power.ENERGY)

	if not ElvUF.colors.ComboPoints then ElvUF.colors.ComboPoints = {} end
	ElvUF.colors.ComboPoints[1] = E:SetColorTable(ElvUF.colors.ComboPoints[1], db.classResources.comboPoints[1])
	ElvUF.colors.ComboPoints[2] = E:SetColorTable(ElvUF.colors.ComboPoints[2], db.classResources.comboPoints[2])
	ElvUF.colors.ComboPoints[3] = E:SetColorTable(ElvUF.colors.ComboPoints[3], db.classResources.comboPoints[3])

	if not ElvUF.colors.ClassBars then ElvUF.colors.ClassBars = {} end

	-- these are just holders.. to maintain and update tables
	if not ElvUF.colors.reaction.good then ElvUF.colors.reaction.good = {} end
	if not ElvUF.colors.reaction.bad then ElvUF.colors.reaction.bad = {} end
	if not ElvUF.colors.reaction.neutral then ElvUF.colors.reaction.neutral = {} end
	ElvUF.colors.reaction.good = E:SetColorTable(ElvUF.colors.reaction.good, db.reaction.GOOD)
	ElvUF.colors.reaction.bad = E:SetColorTable(ElvUF.colors.reaction.bad, db.reaction.BAD)
	ElvUF.colors.reaction.neutral = E:SetColorTable(ElvUF.colors.reaction.neutral, db.reaction.NEUTRAL)

	if not ElvUF.colors.smoothHealth then ElvUF.colors.smoothHealth = {} end
	ElvUF.colors.smoothHealth = E:SetColorTable(ElvUF.colors.smoothHealth, db.health)

	if not ElvUF.colors.smooth then ElvUF.colors.smooth = {1, 0, 0,	1, 1, 0} end
	-- end

	ElvUF.colors.reaction[1] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[2] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[3] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[4] = ElvUF.colors.reaction.neutral
	ElvUF.colors.reaction[5] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[6] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[7] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[8] = ElvUF.colors.reaction.good
	ElvUF.colors.smooth[7] = ElvUF.colors.smoothHealth[1]
	ElvUF.colors.smooth[8] = ElvUF.colors.smoothHealth[2]
	ElvUF.colors.smooth[9] = ElvUF.colors.smoothHealth[3]

	ElvUF.colors.castColor = E:SetColorTable(ElvUF.colors.castColor, db.castColor)
	ElvUF.colors.castNoInterrupt = E:SetColorTable(ElvUF.colors.castNoInterrupt, db.castNoInterrupt)

	if not ElvUF.colors.DebuffHighlight then ElvUF.colors.DebuffHighlight = {} end
	ElvUF.colors.DebuffHighlight.Magic = E:SetColorTable(ElvUF.colors.DebuffHighlight.Magic, db.debuffHighlight.Magic)
	ElvUF.colors.DebuffHighlight.Curse = E:SetColorTable(ElvUF.colors.DebuffHighlight.Curse, db.debuffHighlight.Curse)
	ElvUF.colors.DebuffHighlight.Disease = E:SetColorTable(ElvUF.colors.DebuffHighlight.Disease, db.debuffHighlight.Disease)
	ElvUF.colors.DebuffHighlight.Poison = E:SetColorTable(ElvUF.colors.DebuffHighlight.Poison, db.debuffHighlight.Poison)
end

function UF:Update_StatusBars()
	local statusBarTexture = LSM:Fetch("statusbar", self.db.statusbar)
	for statusbar in pairs(UF.statusbars) do
		if statusbar then
			local useBlank = statusbar.isTransparent
			if statusbar.parent then useBlank = statusbar.parent.isTransparent end
			if statusbar:IsObjectType('StatusBar') then
				if not useBlank then
					statusbar:SetStatusBarTexture(statusBarTexture)
					if statusbar.texture then statusbar.texture = statusBarTexture end --Update .texture on oUF Power element
				end
			elseif statusbar:IsObjectType('Texture') then
				statusbar:SetTexture(statusBarTexture)
			end

			UF:Update_StatusBar(statusbar.bg or statusbar.BG, (not useBlank and statusBarTexture) or E.media.blankTex)
		end
	end
end

function UF:Update_StatusBar(statusbar, texture)
	if not statusbar then return end
	if not texture then texture = LSM:Fetch("statusbar", self.db.statusbar) end

	if statusbar:IsObjectType('StatusBar') then
		statusbar:SetStatusBarTexture(texture)
	elseif statusbar:IsObjectType('Texture') then
		statusbar:SetTexture(texture)
	end
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function UF:Update_FontStrings()
	local stringFont = LSM:Fetch("font", self.db.font)
	for font in pairs(UF.fontstrings) do
		font:FontTemplate(stringFont, self.db.fontSize, self.db.fontOutline)
	end
end

function UF:Construct_Fader()
	return { UpdateRange = UF.UpdateRange }
end

function UF:Configure_Fader(frame)
	if frame.db and frame.db.enable and (frame.db.fader and frame.db.fader.enable) then
		if not frame:IsElementEnabled('Fader') then
			frame:EnableElement('Fader')
		end

		frame.Fader:SetOption('Hover', frame.db.fader.hover)
		frame.Fader:SetOption('Combat', frame.db.fader.combat)
		frame.Fader:SetOption('PlayerTarget', frame.db.fader.playertarget)
		frame.Fader:SetOption('Health', frame.db.fader.health)
		frame.Fader:SetOption('Power', frame.db.fader.power)
		frame.Fader:SetOption('Casting', frame.db.fader.casting)
		frame.Fader:SetOption('MinAlpha', frame.db.fader.minAlpha)
		frame.Fader:SetOption('MaxAlpha', frame.db.fader.maxAlpha)

		if frame ~= _G.ElvUF_Player then
			frame.Fader:SetOption('Range', frame.db.fader.range)
			frame.Fader:SetOption('UnitTarget', frame.db.fader.unittarget)
		end

		frame.Fader:SetOption('Smooth', (frame.db.fader.smooth > 0 and frame.db.fader.smooth) or nil)
		frame.Fader:SetOption('Delay', (frame.db.fader.delay > 0 and frame.db.fader.delay) or nil)

		frame.Fader:ClearTimers()
		frame.Fader.configTimer = E:ScheduleTimer(frame.Fader.ForceUpdate, 0.25, frame.Fader, true)
	elseif frame:IsElementEnabled('Fader') then
		frame:DisableElement('Fader')
		E:UIFrameFadeIn(frame, 1, frame:GetAlpha(), 1)
	end
end

function UF:Configure_FontString(obj)
	UF.fontstrings[obj] = true
	obj:FontTemplate() --This is temporary.
end

function UF:Update_AllFrames()
	if not E.private.unitframe.enable then return end
	UF:UpdateColors()
	UF:Update_FontStrings()
	UF:Update_StatusBars()

	for unit in pairs(UF.units) do
		if UF.db.units[unit].enable then
			UF[unit]:Update()
			UF[unit]:Enable()
			E:EnableMover(UF[unit].mover:GetName())
		else
			UF[unit]:Update()
			UF[unit]:Disable()
			E:DisableMover(UF[unit].mover:GetName())
		end
	end

	for unit, group in pairs(UF.groupunits) do
		if UF.db.units[group].enable then
			UF[unit]:Enable()
			UF[unit]:Update()
			E:EnableMover(UF[unit].mover:GetName())
		else
			UF[unit]:Disable()
			E:DisableMover(UF[unit].mover:GetName())
		end

		if UF[unit].isForced then
			UF:ForceShow(UF[unit])
		end
	end

	if UF.db.smartRaidFilter then
		UF:HandleSmartVisibility()
	else
		UF:UpdateAllHeaders()
	end
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	for i=1, numGroup do
		local unit = group..i
		local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
		local frame = self[unit]

		if not frame then
			self.groupunits[unit] = group;
			frame = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
			frame.index = i
			frame:SetParent(ElvUF_Parent)
			frame:SetID(i)
			self[unit] = frame
		end

		frameName = gsub(E:StringTitle(group), 't(arget)', 'T%1')
		frame.Update = function()
			UF["Update_"..E:StringTitle(frameName).."Frames"](self, frame, self.db.units[group])
		end

		if self.db.units[group].enable then
			frame:Enable()

			frame.Update()

			E:EnableMover(frame.mover:GetName())
		else
			frame:Disable()

			E:DisableMover(frame.mover:GetName())
		end

		if frame.isForced then
			self:ForceShow(frame)
		end
	end
end

function UF:HeaderUpdateSpecificElement(group, elementName)
	local Header = self[group]
	assert(Header, "Invalid group specified.")

	for i=1, Header:GetNumChildren() do
		local frame = select(i, Header:GetChildren())
		if frame and frame.Health then
			frame:UpdateElement(elementName)
		end
	end
end

--Keep an eye on this one, it may need to be changed too
--Reference: http://www.tukui.org/forums/topic.php?id=35332
function UF.groupPrototype:GetAttribute(name)
	return self.groups[1]:GetAttribute(name)
end

function UF.groupPrototype:Configure_Groups(Header)
	local db = UF.db.units[Header.groupName]

	local width, height, newCols, newRows = 0, 0, 0, 0
	local direction, dbWidth, dbHeight = db.growthDirection, db.width, db.height
	local xMult, yMult = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]
	local UNIT_HEIGHT = dbHeight + (db.infoPanel and db.infoPanel.enable and db.infoPanel.height or 0)

	local groupBy = db.groupBy
	local groupSpacing = db.groupSpacing
	local groupsPerRowCol = db.groupsPerRowCol
	local horizontalSpacing = db.horizontalSpacing
	local invertGroupingOrder = db.invertGroupingOrder
	local raidWideSorting = db.raidWideSorting
	local showPlayer = db.showPlayer
	local sortDir = db.sortDir
	local startFromCenter = db.startFromCenter
	local verticalSpacing = db.verticalSpacing

	local numGroups = Header.numGroups
	for i = 1, numGroups do
		local group = Header.groups[i]

		if group then
			UF:ConvertGroupDB(group)
			group:ClearAllPoints()
			group:ClearChildPoints()

			local point = DIRECTION_TO_POINT[direction]
			group:SetAttribute("point", point)

			if point == "LEFT" or point == "RIGHT" then
				group:SetAttribute("xOffset", horizontalSpacing * DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("yOffset", 0)
				group:SetAttribute("columnSpacing", verticalSpacing)
			else
				group:SetAttribute("xOffset", 0)
				group:SetAttribute("yOffset", verticalSpacing * DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("columnSpacing", horizontalSpacing)
			end

			if not group.isForced then
				if not group.initialized then
					group:SetAttribute("startingIndex", raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), _G.MAX_RAID_MEMBERS) + 1) or -4)
					group:Show()
					group.initialized = true
				end
				group:SetAttribute('startingIndex', 1)
			end

			if raidWideSorting and invertGroupingOrder then
				group:SetAttribute("columnAnchorPoint", INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			else
				group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			end

			if not group.isForced then
				group:SetAttribute("maxColumns", raidWideSorting and numGroups or 1)
				group:SetAttribute("unitsPerColumn", raidWideSorting and (groupsPerRowCol * 5) or 5)
				group:SetAttribute("sortDir", sortDir)
				group:SetAttribute("showPlayer", showPlayer)
				UF.headerGroupBy[groupBy](group)
			end

			local groupWide = i == 1 and raidWideSorting and strsub("1,2,3,4,5,6,7,8", 1, numGroups + numGroups-1)
			group:SetAttribute("groupFilter", groupWide or tostring(i))
		end

		--MATH!! WOOT
		local point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		if raidWideSorting and startFromCenter then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT_"..direction]
		end

		if (i - 1) % groupsPerRowCol == 0 then
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if group then group:Point(point, Header, point, 0, height * yMult) end
				height = height + UNIT_HEIGHT + verticalSpacing + groupSpacing
				newRows = newRows + 1
			else
				if group then group:Point(point, Header, point, width * xMult, 0) end
				width = width + dbWidth + horizontalSpacing + groupSpacing
				newCols = newCols + 1
			end
		else
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if newRows == 1 then
					if group then group:Point(point, Header, point, width * xMult, 0) end
					width = width + ((dbWidth + horizontalSpacing) * 5) + groupSpacing
					newCols = newCols + 1
				elseif group then
					group:Point(point, Header, point, ((((dbWidth + horizontalSpacing) * 5) * ((i-1) % groupsPerRowCol))+((i-1) % groupsPerRowCol)*groupSpacing) * xMult, (((UNIT_HEIGHT + verticalSpacing+groupSpacing) * (newRows - 1))) * yMult)
				end
			else
				if newCols == 1 then
					if group then group:Point(point, Header, point, 0, height * yMult) end
					height = height + ((UNIT_HEIGHT + verticalSpacing) * 5) + groupSpacing
					newRows = newRows + 1
				elseif group then
					group:Point(point, Header, point, (((dbWidth + horizontalSpacing +groupSpacing) * (newCols - 1))) * xMult, ((((UNIT_HEIGHT + verticalSpacing) * 5) * ((i-1) % groupsPerRowCol))+((i-1) % groupsPerRowCol)*groupSpacing) * yMult)
				end
			end
		end

		if height == 0 then
			height = height + ((UNIT_HEIGHT + verticalSpacing) * 5) +groupSpacing
		elseif width == 0 then
			width = width + ((dbWidth + horizontalSpacing) * 5) +groupSpacing
		end
	end

	Header:Size(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
end

function UF.groupPrototype:Update(Header)
	local group = Header.groupName

	UF[group].db = UF.db.units[group]

	for _, Group in ipairs(Header.groups) do
		Group.db = UF.db.units[group]
		Group:Update()
	end
end

function UF.groupPrototype:AdjustVisibility(Header)
	if not Header.isForced then
		local numGroups = Header.numGroups
		for i=1, #Header.groups do
			local group = Header.groups[i]
			if (i <= numGroups) and ((Header.db.raidWideSorting and i <= 1) or not Header.db.raidWideSorting) then
				group:Show()
			else
				if group.forceShow then
					group:Hide()
					group:SetAttribute('startingIndex', 1)
					UF:UnshowChildUnits(group, group:GetChildren())
				else
					group:Reset()
				end
			end
		end
	end
end

function UF.headerPrototype:ClearChildPoints()
	for i=1, self:GetNumChildren() do
		select(i, self:GetChildren()):ClearAllPoints()
	end
end

function UF.headerPrototype:UpdateChild(func, child, db)
	func(UF, child, db)

	local name = child:GetName()

	local target = name..'Target'
	if _G[target] then func(UF, _G[target], db) end

	local pet = name..'Pet'
	if _G[pet] then func(UF, _G[pet], db) end
end

function UF.headerPrototype:Update(isForced)
	local group = self.groupName
	local db = UF.db.units[group]
	local groupName = E:StringTitle(group)

	UF["Update_"..groupName.."Header"](UF, self, db, isForced)

	local i = 1
	local child = self:GetAttribute("child" .. i)
	local func = UF["Update_"..groupName.."Frames"]

	while child do
		self:UpdateChild(func, child, db)

		i = i + 1
		child = self:GetAttribute("child" .. i)
	end
end

function UF.headerPrototype:Reset()
	self:Hide()

	self:SetAttribute("showPlayer", true)

	self:SetAttribute("showSolo", true)
	self:SetAttribute("showParty", true)
	self:SetAttribute("showRaid", true)

	self:SetAttribute("columnSpacing", nil)
	self:SetAttribute("columnAnchorPoint", nil)
	self:SetAttribute("groupBy", nil)
	self:SetAttribute("groupFilter", nil)
	self:SetAttribute("groupingOrder", nil)
	self:SetAttribute("maxColumns", nil)
	self:SetAttribute("nameList", nil)
	self:SetAttribute("point", nil)
	self:SetAttribute("sortDir", nil)
	self:SetAttribute("sortMethod", "NAME")
	self:SetAttribute("startingIndex", nil)
	self:SetAttribute("strictFiltering", nil)
	self:SetAttribute("unitsPerColumn", nil)
	self:SetAttribute("xOffset", nil)
	self:SetAttribute("yOffset", nil)
end

UF.SmartSettings = {
	raid = {},
	raid40 = { numGroups = 8 },
	raidpet = { enable = false }
}

function UF:HandleSmartVisibility(skip)
	local sv = UF.SmartSettings
	sv.raid.numGroups = 6

	local _, instanceType, _, _, maxPlayers, _, _, instanceID = GetInstanceInfo()
	if instanceType == 'raid' or instanceType == 'pvp' then
		local maxInstancePlayers = UF.instanceMapIDs[instanceID]
		if maxInstancePlayers then
			maxPlayers =  maxInstancePlayers
		elseif not maxPlayers or maxPlayers == 0 then
			maxPlayers = 40
		end

		sv.raid.visibility = '[@raid6,noexists] hide;show'
		sv.raid40.visibility = '[@raid6,noexists] hide;show'
		sv.raid.enable = maxPlayers < 40
		sv.raid40.enable = maxPlayers == 40

		if sv.raid.enable then
			local maxGroups = E:Round(maxPlayers/5)
			if sv.raid.numGroups ~= maxGroups and maxGroups > 0 then
				sv.raid.numGroups = maxGroups
			end
		end
	else
		sv.raid.visibility = '[@raid6,noexists][@raid31,exists] hide;show'
		sv.raid40.visibility = '[@raid31,noexists] hide;show'
		sv.raid.enable = true
		sv.raid40.enable = true
	end

	UF:UpdateAllHeaders(sv, skip)
end

function UF:ZONE_CHANGED_NEW_AREA()
	if UF.db.smartRaidFilter then
		UF:HandleSmartVisibility(true)
	end
end

function UF:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	UF:RegisterRaidDebuffIndicator()

	if initLogin or isReload then
		UF:Update_AllFrames()
	elseif UF.db.smartRaidFilter then
		UF:HandleSmartVisibility(true)
	end
end

function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
	local group = parent.groupName or groupName
	local db = UF.db.units[group]
	ElvUF:SetActiveStyle("ElvUF_"..E:StringTitle(group))

	local header = ElvUF:SpawnHeader(overrideName, headerTemplate, nil,
		'oUF-initialConfigFunction', format('self:SetWidth(%d); self:SetHeight(%d);', db.width, db.height),
		'groupFilter', groupFilter, 'showParty', true, 'showRaid', true, 'showSolo', true,
		template and 'template', template
	)

	header.groupName = group
	header:SetParent(parent)
	header:Show()

	for k, v in pairs(self.headerPrototype) do
		header[k] = v
	end

	return header
end

function UF:GetSmartVisibilitySetting(setting, group, smart, db)
	if smart and smart[group] and smart[group][setting] ~= nil then
		return smart[group][setting]
	end

	return db[setting]
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerTemplate, smart, skip)
	local db = UF.db.units[group]
	local Header = UF[group]

	local numGroups = UF:GetSmartVisibilitySetting('numGroups', group, smart, db)
	local visibility = UF:GetSmartVisibilitySetting('visibility', group, smart, db)
	local enable = UF:GetSmartVisibilitySetting('enable', group, smart, db)
	local name = E:StringTitle(group)

	if not Header then
		ElvUF:RegisterStyle("ElvUF_"..name, UF["Construct_"..name.."Frames"])
		ElvUF:SetActiveStyle("ElvUF_"..name)

		if numGroups then
			Header = CreateFrame('Frame', 'ElvUF_'..name, ElvUF_Parent, 'SecureHandlerStateTemplate');
			Header.groups = {}
			Header.groupName = group
			Header.template = Header.template or template
			Header.headerTemplate = Header.headerTemplate or headerTemplate
			if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
			for k, v in pairs(self.groupPrototype) do
				UF.headerFunctions[group][k] = v
			end
		else
			Header = self:CreateHeader(ElvUF_Parent, groupFilter, "ElvUF_"..name, template, group, headerTemplate)
		end

		Header:Show()

		self[group] = Header
		self.headers[group] = Header
	end

	local groupsChanged = (Header.numGroups ~= numGroups)
	local stateChanged = (Header.enableState ~= enable)
	Header.enableState = enable
	Header.numGroups = numGroups
	Header.db = db

	if numGroups then
		if db.raidWideSorting then
			if not Header.groups[1] then
				Header.groups[1] = self:CreateHeader(Header, nil, "ElvUF_"..name..'Group1', template or Header.template, nil, headerTemplate or Header.headerTemplate)
			end
		else
			while numGroups > #Header.groups do
				local index = tostring(#Header.groups + 1)
				tinsert(Header.groups, self:CreateHeader(Header, index, "ElvUF_"..name..'Group'..index, template or Header.template, nil, headerTemplate or Header.headerTemplate))
			end
		end

		if groupsChanged or not skip then
			UF.headerFunctions[group]:AdjustVisibility(Header)
			UF.headerFunctions[group]:Configure_Groups(Header)
		end
	else
		if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
		if not UF.headerFunctions[group].Update then
			UF.headerFunctions[group].Update = function()
				local func = UF["Update_"..name.."Frames"]
				UF["Update_"..name.."Header"](UF, Header, Header.db)

				for i = 1, Header:GetNumChildren() do
					Header:UpdateChild(func, select(i, Header:GetChildren()), Header.db)
				end
			end
		end
	end

	if stateChanged or not skip then
		UF.headerFunctions[group]:Update(Header)
	end

	if enable then
		if not Header.isForced then
			RegisterStateDriver(Header, "visibility", visibility)
		end
		if Header.mover then
			E:EnableMover(Header.mover:GetName())
		end
	else
		UnregisterStateDriver(Header, "visibility")
		Header:Hide()
		if Header.mover then
			E:DisableMover(Header.mover:GetName())
		end
	end
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, 'No unit provided to create or update.')

	local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
	if not UF[unit] then
		UF[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
		UF.units[unit] = unit
	end

	UF[unit].Update = function()
		UF["Update_"..frameName.."Frame"](UF, UF[unit], UF.db.units[unit])
	end

	if UF[unit]:GetParent() ~= ElvUF_Parent then
		UF[unit]:SetParent(ElvUF_Parent)
	end

	if UF.db.units[unit] then
		if UF.db.units[unit].enable then
			UF[unit]:Enable()
			UF[unit].Update()
			E:EnableMover(UF[unit].mover:GetName())
		else
			UF[unit].Update()
			UF[unit]:Disable()
			E:DisableMover(UF[unit].mover:GetName())
		end
	end
end

function UF:LoadUnits()
	for _, unit in pairs(UF.unitstoload) do
		UF:CreateAndUpdateUF(unit)
	end
	UF.unitstoload = nil

	for group, groupOptions in pairs(UF.unitgroupstoload) do
		local numGroup, template = unpack(groupOptions)
		UF:CreateAndUpdateUFGroup(group, numGroup, template)
	end
	UF.unitgroupstoload = nil

	for group, groupOptions in pairs(UF.headerstoload) do
		local groupFilter, template, headerTemplate
		if type(groupOptions) == 'table' then
			groupFilter, template, headerTemplate = unpack(groupOptions)
		end

		UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerTemplate)
	end
	UF.headerstoload = nil
end

function UF:RegisterRaidDebuffIndicator()
	local ORD = ns.oUF_RaidDebuffs or _G.oUF_RaidDebuffs
	if ORD then
		ORD:ResetDebuffData()

		local _, instanceType = GetInstanceInfo()
		if instanceType == "party" or instanceType == "raid" then
			local instance = E.global.unitframe.raidDebuffIndicator.instanceFilter
			local instanceSpells = ((E.global.unitframe.aurafilters[instance] and E.global.unitframe.aurafilters[instance].spells) or E.global.unitframe.aurafilters.RaidDebuffs.spells)
			ORD:RegisterDebuffs(instanceSpells)
		else
			local other = E.global.unitframe.raidDebuffIndicator.otherFilter
			local otherSpells = ((E.global.unitframe.aurafilters[other] and E.global.unitframe.aurafilters[other].spells) or E.global.unitframe.aurafilters.CCDebuffs.spells)
			ORD:RegisterDebuffs(otherSpells)
		end
	end
end

function UF:UpdateAllHeaders(smart, skip)
	if E.private.unitframe.disabledBlizzardFrames.party then
		ElvUF:DisableBlizzard('party')
	end

	for group in pairs(self.headers) do
		self:CreateAndUpdateHeaderGroup(group, nil, nil, nil, smart, skip)
	end
end

function UF:DisableBlizzard()
	if (not E.private.unitframe.disabledBlizzardFrames.raid) and (not E.private.unitframe.disabledBlizzardFrames.party) then return; end
	if not CompactRaidFrameManager_SetSetting then
		E:StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	else
		CompactRaidFrameManager_SetSetting("IsShown", "0")
		_G.UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
		_G.CompactRaidFrameManager:UnregisterAllEvents()
		_G.CompactRaidFrameManager:SetParent(hiddenParent)
	end
end

local HandleFrame = function(baseName)
	local frame
	if (type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if (frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthBar or frame.healthbar
		if (health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if (power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if (spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if (altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if (buffFrame) then
			buffFrame:UnregisterAllEvents()
		end
	end
end

function ElvUF:DisableBlizzard(unit)
	if(not unit) then return end

	if (unit == 'player') and E.private.unitframe.disabledBlizzardFrames.player then
		local PlayerFrame = _G.PlayerFrame
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

		-- User placed frames don't animate
		PlayerFrame:SetMovable(true)
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	elseif (unit == 'pet') and E.private.unitframe.disabledBlizzardFrames.player then
		HandleFrame(_G.PetFrame)
	elseif (unit == 'target') and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(_G.TargetFrame)
		HandleFrame(_G.ComboFrame)
	elseif (unit == 'targettarget') and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(_G.TargetFrameToT)
	elseif (unit:match('party%d?$')) and E.private.unitframe.disabledBlizzardFrames.party then
		local id = unit:match('party(%d)')
		if (id) then
			HandleFrame('PartyMemberFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('PartyMemberFrame%d'):format(i))
			end
		end
		HandleFrame(_G.PartyMemberBackground)
	elseif (unit:match('nameplate%d+$')) then
		local frame = C_NamePlate_GetNamePlateForUnit(unit)
		if (frame and frame.UnitFrame) then
			HandleFrame(frame.UnitFrame)
		end
	end
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db.units[unit], P.unitframe.units[unit]);

	if self.db.units[unit].buffs and self.db.units[unit].buffs.sizeOverride then
		self.db.units[unit].buffs.sizeOverride = P.unitframe.units[unit].buffs.sizeOverride or 0
	end

	if self.db.units[unit].debuffs and self.db.units[unit].debuffs.sizeOverride then
		self.db.units[unit].debuffs.sizeOverride = P.unitframe.units[unit].debuffs.sizeOverride or 0
	end

	self:Update_AllFrames()
end

function UF:ToggleForceShowGroupFrames(unitGroup, numGroup)
	for i=1, numGroup do
		if self[unitGroup..i] and not self[unitGroup..i].isForced then
			UF:ForceShow(self[unitGroup..i])
		elseif self[unitGroup..i] then
			UF:UnforceShow(self[unitGroup..i])
		end
	end
end

local Blacklist = {
	arena = {
		enable = true,
		fader = true,
	},
	assist = {
		enable = true,
		fader = true,
	},
	boss = {
		enable = true,
		fader = true,
	},
	focus = {
		enable = true,
		fader = true,
	},
	focustarget = {
		enable = true,
		fader = true,
	},
	party = {
		enable = true,
		visibility = true,
		fader = true,
	},
	pet = {
		enable = true,
		fader = true,
	},
	pettarget = {
		enable = true,
		fader = true,
	},
	player = {
		enable = true,
		aurabars = true,
		fader = true,
		buffs = {
			priority = true,
			minDuration = true,
			maxDuration = true,
		},
		debuffs = {
			priority = true,
			minDuration = true,
			maxDuration = true,
		},
	},
	raid = {
		enable = true,
		fader = true,
		visibility = true,
	},
	raid40 = {
		enable = true,
		fader = true,
		visibility = true,
	},
	raidpet = {
		enable = true,
		fader = true,
		visibility = true,
	},
	tank = {
		fader = true,
		enable = true,
	},
	target = {
		fader = true,
		enable = true,
	},
	targettarget = {
		fader = true,
		enable = true,
	},
	targettargettarget = {
		fader = true,
		enable = true,
	},
}

function UF:MergeUnitSettings(from, to)
	if from == to then
		E:Print(L["You cannot copy settings from the same unit."])
		return
	end

	E:CopyTable(UF.db.units[to], E:FilterTableFromBlacklist(UF.db.units[from], Blacklist[to]))

	UF:Update_AllFrames()
end

function UF:UpdateBackdropTextureColor(r, g, b)
	local m = 0.35
	local n = self.isTransparent and (m * 2) or m

	if self.invertColors then
		local nn = n;n=m;m=nn
	end

	if self.isTransparent then
		if self.backdrop then
			local _, _, _, a = E:GetBackdropColor(self.backdrop)
			self.backdrop:SetBackdropColor(r * n, g * n, b * n, a)
		else
			local parent = self:GetParent()
			if parent and parent.template then
				local _, _, _, a = E:GetBackdropColor(parent)
				parent:SetBackdropColor(r * n, g * n, b * n, a)
			end
		end
	end

	local bg = self.bg or self.BG
	if bg and bg:IsObjectType('Texture') and not bg.multiplier then
		if self.custom_backdrop then
			bg:SetVertexColor(self.custom_backdrop.r, self.custom_backdrop.g, self.custom_backdrop.b)
		else
			bg:SetVertexColor(r * m, g * m, b * m)
		end
	end
end

function UF:UpdatePredictionStatusBar(prediction, parent, name)
	if not (prediction and parent) then return end
	local texture = (not parent.isTransparent and parent:GetStatusBarTexture():GetTexture()) or E.media.blankTex
	if name == "Health" then
		UF:Update_StatusBar(prediction.myBar, texture)
		UF:Update_StatusBar(prediction.otherBar, texture)
		UF:Update_StatusBar(prediction.absorbBar, texture)
		UF:Update_StatusBar(prediction.healAbsorbBar, texture)
		UF:Update_StatusBar(prediction.overAbsorb, texture)
		UF:Update_StatusBar(prediction.overHealAbsorb, texture)
	elseif name == "Power" then
		UF:Update_StatusBar(prediction.mainBar, texture)
	end
end

function UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation, reverseFill)
	backdropTex:ClearAllPoints()
	if statusBarOrientation == 'VERTICAL' then
		if reverseFill then
			backdropTex:Point("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
			backdropTex:Point("TOPRIGHT", statusBarTex, "BOTTOMRIGHT")
			backdropTex:Point("TOPLEFT", statusBarTex, "BOTTOMLEFT")
		else
			backdropTex:Point("TOPLEFT", statusBar, "TOPLEFT")
			backdropTex:Point("BOTTOMLEFT", statusBarTex, "TOPLEFT")
			backdropTex:Point("BOTTOMRIGHT", statusBarTex, "TOPRIGHT")
		end
	else
		if reverseFill then
			backdropTex:Point("TOPRIGHT", statusBarTex, "TOPLEFT")
			backdropTex:Point("BOTTOMRIGHT", statusBarTex, "BOTTOMLEFT")
			backdropTex:Point("BOTTOMLEFT", statusBar, "BOTTOMLEFT")
		else
			backdropTex:Point("TOPLEFT", statusBarTex, "TOPRIGHT")
			backdropTex:Point("BOTTOMLEFT", statusBarTex, "BOTTOMRIGHT")
			backdropTex:Point("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
		end
	end
end

function UF:ToggleTransparentStatusBar(isTransparent, statusBar, backdropTex, adjustBackdropPoints, invertColors, reverseFill)
	statusBar.isTransparent = isTransparent
	statusBar.invertColors = invertColors
	statusBar.backdropTex = backdropTex

	local statusBarTex = statusBar:GetStatusBarTexture()
	local statusBarOrientation = statusBar:GetOrientation()

	if not statusBar.hookedColor then
		hooksecurefunc(statusBar, "SetStatusBarColor", UF.UpdateBackdropTextureColor)
		statusBar.hookedColor = true
	end

	if isTransparent then
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate("Transparent", nil, nil, nil, true)
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate("Transparent", nil, nil, nil, true)
		end

		statusBar:SetStatusBarTexture(0, 0, 0, 0)
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, E.media.blankTex)

		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end --Needed for Power element

		UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation, reverseFill)
	else
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate(nil, nil, nil, not statusBar.PostCastStart and self.thinBorders, true)
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate(nil, nil, nil, self.thinBorders, true)
		end

		local texture = LSM:Fetch("statusbar", self.db.statusbar)
		statusBar:SetStatusBarTexture(texture)
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, texture)

		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end

		if adjustBackdropPoints then
			UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation, reverseFill)
		end
	end
end

function UF:TargetSound(unit)
	if UnitExists(unit) and not IsReplacingUnit() then
		if UnitIsEnemy(unit, "player") then
			PlaySound(SOUNDKIT_IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(SOUNDKIT_IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(SOUNDKIT_IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(SOUNDKIT_INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function UF:PLAYER_TARGET_CHANGED()
	if E.db.unitframe.targetSound then
		UF:TargetSound("target")
	end
end

function UF:AfterStyleCallback()
	-- this will wait until after ouf pushes `EnableElement` onto the newly spawned frames
	-- calling an update onto assist or tank in the styleFunc is before the `EnableElement`
	-- that would cause the auras to be shown when a new frame is spawned (tank2, assist2)
	-- even when they are disabled. this makes sure the update happens after so its proper.
	if self.unitframeType == "tank" or self.unitframeType == "tanktarget" then
		UF:Update_TankFrames(self, E.db.unitframe.units.tank)
	elseif self.unitframeType == "assist" or self.unitframeType == "assisttarget" then
		UF:Update_AssistFrames(self, E.db.unitframe.units.assist)
	end
end

function UF:Initialize()
	UF.db = E.db.unitframe
	UF.thinBorders = UF.db.thinBorders or E.PixelMode
	if E.private.unitframe.enable ~= true then return end
	UF.Initialized = true

	E.ElvUF_Parent = CreateFrame('Frame', 'ElvUF_Parent', E.UIParent, 'SecureHandlerStateTemplate');
	E.ElvUF_Parent:SetFrameStrata("LOW")
	RegisterStateDriver(E.ElvUF_Parent, "visibility", "[petbattle] hide; show")

	UF:UpdateColors()
	ElvUF:RegisterInitCallback(UF.AfterStyleCallback)
	ElvUF:RegisterStyle('ElvUF', function(frame, unit)
		UF:Construct_UF(frame, unit)
	end)
	ElvUF:SetActiveStyle("ElvUF")
	UF:LoadUnits()

	UF:RegisterEvent('PLAYER_ENTERING_WORLD')
	UF:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	UF:RegisterEvent('PLAYER_TARGET_CHANGED')

	if E.private.unitframe.disabledBlizzardFrames.party and E.private.unitframe.disabledBlizzardFrames.raid then
		UF:DisableBlizzard()
		--InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)
	else
		_G.CompactUnitFrameProfiles:RegisterEvent('VARIABLES_LOADED')
	end

	if (not E.private.unitframe.disabledBlizzardFrames.party) and (not E.private.unitframe.disabledBlizzardFrames.raid) then
		E.RaidUtility.Initialize = E.noop
	end

	local ORD = ns.oUF_RaidDebuffs or _G.oUF_RaidDebuffs
	if ORD then
		ORD.ShowDispellableDebuff = true
		ORD.FilterDispellableDebuff = true
		ORD.MatchBySpellName = false
	end
end

local function InitializeCallback()
	UF:Initialize()
end

E:RegisterInitialModule(UF:GetName(), InitializeCallback)
