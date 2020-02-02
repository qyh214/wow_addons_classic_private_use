------------------------------------------------------------------------
-- Collection of functions that can be used in multiple places
------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...))

local _G = _G
local wipe, date = wipe, date
local format, type, ipairs, pairs, strlen = format, type, ipairs, pairs, strlen
local strmatch, strfind, tonumber, tostring = strmatch, strfind, tonumber, tostring
local GetAddOnEnableState = GetAddOnEnableState
local GetCVar, SetCVar = GetCVar, SetCVar
local GetCVarBool = GetCVarBool
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local UIParentLoadAddOn = UIParentLoadAddOn
local UnitHasVehicleUI = UnitHasVehicleUI
local C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
-- GLOBALS: ElvDB

function E:ClassColor(class, usePriestColor)
	if not class then return end

	local color = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class]) or _G.RAID_CLASS_COLORS[class]
	if type(color) ~= 'table' then return end

	if not color.colorStr then
		color.colorStr = E:RGBToHex(color.r, color.g, color.b, 'ff')
	elseif strlen(color.colorStr) == 6 then
		color.colorStr = 'ff'..color.colorStr
	end

	if (usePriestColor and class == 'PRIEST') and tonumber(color.colorStr, 16) > tonumber(E.PriestColors.colorStr, 16) then
		return E.PriestColors
	else
		return color
	end
end

do -- other non-english locales require this
	E.UnlocalizedClasses = {}
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do E.UnlocalizedClasses[v] = k end
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do E.UnlocalizedClasses[v] = k end

	function E:UnlocalizedClassName(className)
		return (className and className ~= '') and E.UnlocalizedClasses[className]
	end
end

function E:IsFoolsDay()
	return strfind(date(), '04/01/') and not E.global.aprilFools
end

do
	local essenceTextureID = 2975691
	function E:ScanTooltipTextures()
		local tt = E.ScanTooltip

		if not tt.gems then
			tt.gems = {}
		else
			wipe(tt.gems)
		end

		if not tt.essences then
			tt.essences = {}
		else
			for _, essences in pairs(tt.essences) do
				wipe(essences)
			end
		end

		local step = 1
		for i = 1, 10 do
			local tex = _G['ElvUI_ScanTooltipTexture'..i]
			local texture = tex and tex:IsShown() and tex:GetTexture()
			if texture then
				if texture == essenceTextureID then
					local selected = (tt.gems[i-1] ~= essenceTextureID and tt.gems[i-1]) or nil
					if not tt.essences[step] then tt.essences[step] = {} end

					tt.essences[step][1] = selected			--essence texture if selected or nil
					tt.essences[step][2] = tex:GetAtlas()	--atlas place 'tooltip-heartofazerothessence-major' or 'tooltip-heartofazerothessence-minor'
					tt.essences[step][3] = texture			--border texture placed by the atlas
					--`CollectEssenceInfo` will add 4 (hex quality color) and 5 (essence name)

					step = step + 1

					if selected then
						tt.gems[i-1] = nil
					end
				else
					tt.gems[i] = texture
				end
			end
		end

		return tt.gems, tt.essences
	end
end

function E:IsDispellableByMe(debuffType)
	local dispel = self.DispelClasses[self.myclass]
	return dispel and dispel[debuffType]
end

do
	local function SetOriginalHeight(f)
		if InCombatLockdown() then
			E:RegisterEventForObject('PLAYER_REGEN_ENABLED', SetOriginalHeight, SetOriginalHeight)
			return
		end

		E.UIParent:SetHeight(E.UIParent.origHeight)

		if f == SetOriginalHeight then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', SetOriginalHeight, SetOriginalHeight)
		end
	end

	local function SetModifiedHeight(f)
		if InCombatLockdown() then
			E:RegisterEventForObject('PLAYER_REGEN_ENABLED', SetModifiedHeight, SetModifiedHeight)
			return
		end

		E.UIParent:SetHeight(E.UIParent.origHeight - (_G.OrderHallCommandBar:GetHeight() + E.Border))

		if f == SetModifiedHeight then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', SetModifiedHeight, SetModifiedHeight)
		end
	end

	--This function handles disabling of OrderHall Bar or resizing of ElvUIParent if needed
	function E:HandleCommandBar()
		if E.global.general.commandBarSetting == 'DISABLED' then
			_G.OrderHallCommandBar:UnregisterAllEvents()
			_G.OrderHallCommandBar:SetScript('OnShow', _G.OrderHallCommandBar.Hide)
			_G.OrderHallCommandBar:Hide()
			_G.UIParent:UnregisterEvent('UNIT_AURA') --Only used for OrderHall Bar
		elseif E.global.general.commandBarSetting == 'ENABLED_RESIZEPARENT' then
			_G.OrderHallCommandBar:HookScript('OnShow', SetModifiedHeight)
			_G.OrderHallCommandBar:HookScript('OnHide', SetOriginalHeight)
		end
	end
end

do
	E.MaxNazjatarBodyguardRank = 30
	function E:GetNazjatarBodyguardXP(widgetID)
		local widget = widgetID and C_UIWidgetManager_GetStatusBarWidgetVisualizationInfo(widgetID)
		if not widget then return end

		local rank = tonumber(strmatch(widget.overrideBarText, '%d+'))
		if not rank then return end

		local cur = widget.barValue - widget.barMin
		local toNext = widget.barMax - widget.barMin
		local total = widget.barValue
		local isMax = rank == E.MaxNazjatarBodyguardRank

		return rank, cur, toNext, total, isMax
	end
end

do
	local Masque = E.Libs.Masque
	local MasqueGroupState = {}
	local MasqueGroupToTableElement = {
		['ActionBars'] = {'actionbar', 'actionbars'},
		['Pet Bar'] = {'actionbar', 'petBar'},
		['Stance Bar'] = {'actionbar', 'stanceBar'},
		['Buffs'] = {'auras', 'buffs'},
		['Debuffs'] = {'auras', 'debuffs'},
	}

	function E:MasqueCallback(Group, _, _, _, _, Disabled)
		if not E.private then return end
		local element = MasqueGroupToTableElement[Group]
		if element then
			if Disabled then
				if E.private[element[1]].masque[element[2]] and MasqueGroupState[Group] == 'enabled' then
					E.private[element[1]].masque[element[2]] = false
					E:StaticPopup_Show('CONFIG_RL')
				end
				MasqueGroupState[Group] = 'disabled'
			else
				MasqueGroupState[Group] = 'enabled'
			end
		end
	end

	if Masque then
		Masque:Register('ElvUI', E.MasqueCallback)
	end
end

do
	local CPU_USAGE = {}
	local function CompareCPUDiff(showall, minCalls)
		local greatestUsage, greatestCalls, greatestName, newName, newFunc
		local greatestDiff, lastModule, mod, usage, calls, diff = 0

		for name, oldUsage in pairs(CPU_USAGE) do
			newName, newFunc = strmatch(name, '^([^:]+):(.+)$')
			if not newFunc then
				E:Print('CPU_USAGE:', name, newFunc)
			else
				if newName ~= lastModule then
					mod = E:GetModule(newName, true) or E
					lastModule = newName
				end
				usage, calls = GetFunctionCPUUsage(mod[newFunc], true)
				diff = usage - oldUsage
				if showall and (calls > minCalls) then
					E:Print('Name('..name..')  Calls('..calls..') MS('..(usage or 0)..') Diff('..(diff > 0 and format('%.3f', diff) or 0)..')')
				end
				if (diff > greatestDiff) and calls > minCalls then
					greatestName, greatestUsage, greatestCalls, greatestDiff = name, usage, calls, diff
				end
			end
		end

		if greatestName then
			E:Print(greatestName.. ' had the CPU usage of: '..(greatestUsage > 0 and format('%.3f', greatestUsage) or 0)..'ms. And has been called '.. greatestCalls..' times.')
		else
			E:Print('CPU Usage: No CPU Usage differences found.')
		end

		wipe(CPU_USAGE)
	end

	function E:GetTopCPUFunc(msg)
		if not GetCVarBool('scriptProfile') then
			E:Print('For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
			return
		end

		local module, showall, delay, minCalls = strmatch(msg, '^(%S+)%s*(%S*)%s*(%S*)%s*(.*)$')
		local checkCore, mod = (not module or module == '') and 'E'

		showall = (showall == 'true' and true) or false
		delay = (delay == 'nil' and nil) or tonumber(delay) or 5
		minCalls = (minCalls == 'nil' and nil) or tonumber(minCalls) or 15

		wipe(CPU_USAGE)
		if module == 'all' then
			for moduName, modu in pairs(self.modules) do
				for funcName, func in pairs(modu) do
					if (funcName ~= 'GetModule') and (type(func) == 'function') then
						CPU_USAGE[moduName..':'..funcName] = GetFunctionCPUUsage(func, true)
					end
				end
			end
		else
			if not checkCore then
				mod = self:GetModule(module, true)
				if not mod then
					self:Print(module..' not found, falling back to checking core.')
					mod, checkCore = self, 'E'
				end
			else
				mod = self
			end
			for name, func in pairs(mod) do
				if (name ~= 'GetModule') and type(func) == 'function' then
					CPU_USAGE[(checkCore or module)..':'..name] = GetFunctionCPUUsage(func, true)
				end
			end
		end

		self:Delay(delay, CompareCPUDiff, showall, minCalls)
		self:Print('Calculating CPU Usage differences (module: '..(checkCore or module)..', showall: '..tostring(showall)..', minCalls: '..tostring(minCalls)..', delay: '..tostring(delay)..')')
	end
end

function E:Dump(object, inspect)
	if GetAddOnEnableState(E.myname, 'Blizzard_DebugTools') == 0 then
		E:Print('Blizzard_DebugTools is disabled.')
		return
	end

	local debugTools = IsAddOnLoaded('Blizzard_DebugTools')
	if not debugTools then UIParentLoadAddOn('Blizzard_DebugTools') end

	if inspect then
		local tableType = type(object)
		if tableType == 'table' then
			_G.DisplayTableInspectorWindow(object)
		else
			E:Print('Failed: ', tostring(object), ' is type: ', tableType,'. Requires table object.')
		end
	else
		_G.DevTools_Dump(object)
	end
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames, E.AddNonPetBattleFrames)
		return
	elseif E:IsEventRegisteredForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames) then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames, E.AddNonPetBattleFrames)
	end

	for object, data in pairs(E.FrameLocks) do
		local parent, strata
		if type(data) == 'table' then
			parent, strata = data.parent, data.strata
		elseif data == true then
			parent = _G.UIParent
		end

		local obj = _G[object] or object
		obj:SetParent(parent)
		if strata then
			obj:SetFrameStrata(strata)
		end
	end
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then
		E:RegisterEventForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames, E.RemoveNonPetBattleFrames)
		return
	elseif E:IsEventRegisteredForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames) then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames, E.RemoveNonPetBattleFrames)
	end

	for object in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(E.HiddenFrame)
	end
end

function E:RegisterObjectForVehicleLock(object, originalParent)
	if not object or not originalParent then
		E:Print('Error. Usage: RegisterObjectForVehicleLock(object, originalParent)')
		return
	end

	object = _G[object] or object
	--Entering/Exiting vehicles will often happen in combat.
	--For this reason we cannot allow protected objects.
	if object.IsProtected and object:IsProtected() then
		E:Print('Error. Object is protected and cannot be changed in combat.')
		return
	end

	--Check if we are already in a vehicles
	if UnitHasVehicleUI('player') then
		object:SetParent(E.HiddenFrame)
	end

	--Add object to table
	E.VehicleLocks[object] = originalParent
end

function E:UnregisterObjectForVehicleLock(object)
	if not object then
		E:Print('Error. Usage: UnregisterObjectForVehicleLock(object)')
		return
	end

	object = _G[object] or object
	--Check if object was registered to begin with
	if not E.VehicleLocks[object] then
		return
	end

	--Change parent of object back to original parent
	local originalParent = E.VehicleLocks[object]
	if originalParent then
		object:SetParent(originalParent)
	end

	--Remove object from table
	E.VehicleLocks[object] = nil
end

function E:EnterVehicleHideFrames(_, unit)
	if unit ~= 'player' then return end
	for object in pairs(E.VehicleLocks) do
		object:SetParent(E.HiddenFrame)
	end
end

function E:ExitVehicleShowFrames(_, unit)
	if unit ~= 'player' then return end
	for object, originalParent in pairs(E.VehicleLocks) do
		object:SetParent(originalParent)
	end
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD(_, initLogin)
	if initLogin or not ElvDB.LuaErrorDisabledAddOns then
		ElvDB.LuaErrorDisabledAddOns = {}
	end

	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' then
		self.BGTimer = self:ScheduleRepeatingTimer('RequestBGInfo', 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil
	end
end

function E:PLAYER_REGEN_ENABLED()
	if self.CVarUpdate then
		for cvarName, value in pairs(self.LockedCVars) do
			if not self.IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value) then
				SetCVar(cvarName, value)
			end
		end

		self.CVarUpdate = nil
	end

	if self.ShowOptionsUI then
		self:ToggleOptionsUI()

		self.ShowOptionsUI = nil
	end
end

function E:PLAYER_REGEN_DISABLED()
	local err

	if IsAddOnLoaded('ElvUI_OptionsUI') then
		local ACD = self.Libs.AceConfigDialog
		if ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI then
			ACD:Close('ElvUI')
			err = true
		end
	end

	if self.CreatedMovers then
		for name in pairs(self.CreatedMovers) do
			local mover = _G[name]
			if mover and mover:IsShown() then
				mover:Hide()
				err = true
			end
		end
	end

	if err then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function E:PLAYER_LEVEL_UP(_, level)
	E.mylevel = level
end

function E:LoadAPI()
	E:RegisterEvent('PLAYER_LEVEL_UP')
	E:RegisterEvent('PLAYER_ENTERING_WORLD')
	E:RegisterEvent('PLAYER_REGEN_ENABLED')
	E:RegisterEvent('PLAYER_REGEN_DISABLED')
	E:RegisterEvent('UI_SCALE_CHANGED', 'PixelScaleChanged')

	do -- setup cropIcon texCoords
		local opt = E.db.general.cropIcon
		local modifier = 0.04 * opt
		for i, v in ipairs(E.TexCoords) do
			if i % 2 == 0 then
				E.TexCoords[i] = v - modifier
			else
				E.TexCoords[i] = v + modifier
			end
		end
	end

	if not strfind(date(), '04/01/') then
		E.global.aprilFools = nil
	end
end
