local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')

local gsub = gsub
local wipe = wipe
local next = next
local pairs = pairs
local format = format
local strmatch = strmatch
local tonumber = tonumber
local tostring = tostring
local GetSpellInfo = GetSpellInfo

-- GLOBALS: MAX_PLAYER_LEVEL

local quickSearchText, selectedSpell, selectedFilter, filterList, spellList = '', nil, nil, {}, {}
local auraBarDefaults = { enable = true, color = { r = 1, g = 1, b = 1 } }

local function IsStockFilter()
	return selectedFilter and (selectedFilter == 'Debuff Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' or E.DEFAULT_FILTER[selectedFilter])
end

local function GetSelectedFilters()
	local biPet = selectedFilter == 'Buff Indicator (Pet)'
	local biProfile = selectedFilter == 'Buff Indicator (Profile)'
	local selected = (biProfile and E.db.unitframe.filters.buffwatch) or (biPet and (E.global.unitframe.buffwatch.PET or {})) or (E.global.unitframe.buffwatch[E.myclass] or {})
	local default = (biProfile and P.unitframe.filters.buffwatch) or (biPet and G.unitframe.buffwatch.PET) or G.unitframe.buffwatch[E.myclass]
	return selected, default
end

local function GetSelectedSpell()
	if selectedSpell and selectedSpell ~= '' then
		local spell = strmatch(selectedSpell, " %((%d+)%)$") or selectedSpell
		if spell then
			return tonumber(spell) or spell
		end
	end
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..",")
end

local function removePriority(value)
	if not value then return end
	local x,y,z=E.db.unitframe.units,E.db.nameplates.units;
	for n, t in pairs(x) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= "" then
			z = filterMatch(t.buffs.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].buffs.priority = gsub(t.buffs.priority, z, "") end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= "" then
			z = filterMatch(t.debuffs.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].debuffs.priority = gsub(t.debuffs.priority, z, "") end
		end
		if t and t.aurabar and t.aurabar.priority and t.aurabar.priority ~= "" then
			z = filterMatch(t.aurabar.priority, E:EscapeString(value))
			if z then E.db.unitframe.units[n].aurabar.priority = gsub(t.aurabar.priority, z, "") end
		end
	end
	for n, t in pairs(y) do
		if t and t.buffs and t.buffs.priority and t.buffs.priority ~= "" then
			z = filterMatch(t.buffs.priority, E:EscapeString(value))
			if z then E.db.nameplates.units[n].buffs.priority = gsub(t.buffs.priority, z, "") end
		end
		if t and t.debuffs and t.debuffs.priority and t.debuffs.priority ~= "" then
			z = filterMatch(t.debuffs.priority, E:EscapeString(value))
			if z then E.db.nameplates.units[n].debuffs.priority = gsub(t.debuffs.priority, z, "") end
		end
	end
end

local FilterResetState = {}
E.Options.args.filters = {
	type = 'group',
	name = L["FILTERS"],
	order = 3,
	args = {
		createFilter = {
			order = 1,
			name = L["Create Filter"],
			desc = L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."],
			type = 'input',
			get = function(info) return "" end,
			set = function(info, value)
				if strmatch(value, "^[%s%p]-$") then
					return
				end
				if strmatch(value, ",") then
					E:Print(L["Filters are not allowed to have commas in their name. Stripping commas from filter name."])
					value = gsub(value, ",", "")
				end
				if strmatch(value, "^Friendly:") or strmatch(value, "^Enemy:") then
					return --dont allow people to create Friendly: or Enemy: filters
				end
				if G.unitframe.specialFilters[value] or E.global.unitframe.aurafilters[value] then
					E:Print(L["Filter already exists!"])
					return
				end
				E.global.unitframe.aurafilters[value] = { spells = {} }
				selectedFilter = value
			end,
		},
		selectFilter = {
			order = 2,
			type = 'select',
			name = L["Select Filter"],
			get = function(info) return selectedFilter end,
			set = function(info, value)
				selectedFilter, selectedSpell, quickSearchText = nil, nil, ''
				if value ~= '' then
					if FilterResetState[selectedFilter] then FilterResetState[selectedFilter] = nil end
					selectedFilter = value
				end
			end,
			values = function()
				wipe(filterList)

				filterList[''] = L["NONE"]
				filterList['Buff Indicator'] = 'Buff Indicator'
				filterList['Buff Indicator (Pet)'] = 'Buff Indicator (Pet)'
				filterList['Buff Indicator (Profile)'] = 'Buff Indicator (Profile)'
				filterList['AuraBar Colors'] = 'AuraBar Colors'
				filterList['Debuff Highlight'] = 'Debuff Highlight'

				local list = E.global.unitframe.aurafilters
				if list then
					for filter in pairs(list) do
						filterList[filter] = filter
					end
				end

				return filterList
			end,
		},
		deleteFilter = {
			type = 'execute',
			order = 3,
			name = L["Delete Filter"],
			desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
			func = function()
				E.global.unitframe.aurafilters[selectedFilter] = nil
				selectedFilter, selectedSpell, quickSearchText = nil, nil, ''

				removePriority(selectedFilter) --This will wipe a filter from the new aura system profile settings.
			end,
			disabled = function() return G.unitframe.aurafilters[selectedFilter] end,
			hidden = function() return not selectedFilter end,
		},
		filterGroup = {
			type = 'group',
			name = function() return selectedFilter end,
			hidden = function() return not selectedFilter end,
			guiInline = true,
			order = 10,
			args = {
				addSpell = {
					order = 1,
					name = L["Add SpellID"],
					desc = L["Add a spell to the filter."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						value = tonumber(value)
						if not value then return end

						local spellName = GetSpellInfo(value)
						selectedSpell = (spellName and value) or nil
						if not selectedSpell then return end

						if selectedFilter == 'Debuff Highlight' then
							if not E.global.unitframe.DebuffHighlightColors[value] then
								E.global.unitframe.DebuffHighlightColors[value] = { enable = true, style = 'GLOW', color = {r = 0.8, g = 0, b = 0, a = 0.85} }
							end
						elseif selectedFilter == 'AuraBar Colors' then
							if not E.global.unitframe.AuraBarColors[value] then
								E.global.unitframe.AuraBarColors[value] = E:CopyTable({}, auraBarDefaults)
							end
						elseif selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' then
							local selectedTable = GetSelectedFilters()
							if not selectedTable[value] then
								selectedTable[value] = UF:AuraWatch_AddSpell(value, 'TOPRIGHT')
							end
						elseif not E.global.unitframe.aurafilters[selectedFilter].spells[value] then
							E.global.unitframe.aurafilters[selectedFilter].spells[value] = { enable = true, priority = 0, stackThreshold = 0 }
						end

						UF:Update_AllFrames()
					end,
				},
				removeSpell = {
					order = 2,
					name = L["Remove Spell"],
					desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
					type = 'execute',
					func = function()
						local value = GetSelectedSpell()
						if not value then return end
						selectedSpell = nil

						if selectedFilter == 'Debuff Highlight' then
							E.global.unitframe.DebuffHighlightColors[value] = nil;
						elseif selectedFilter == 'AuraBar Colors' then
							if G.unitframe.AuraBarColors[value] then
								E.global.unitframe.AuraBarColors[value].enable = false;
							else
								E.global.unitframe.AuraBarColors[value] = nil;
							end
						elseif selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' then
							local selectedTable, defaultTable = GetSelectedFilters()

							if defaultTable[value] then
								selectedTable[value].enabled = false
							else
								selectedTable[value] = nil
							end
						elseif G.unitframe.aurafilters[selectedFilter] and G.unitframe.aurafilters[selectedFilter].spells[value] then
							E.global.unitframe.aurafilters[selectedFilter].spells[value].enable = false;
						else
							E.global.unitframe.aurafilters[selectedFilter].spells[value] = nil;
						end

						UF:Update_AllFrames();
					end,
					disabled = function()
						local spell = GetSelectedSpell()
						if not spell then return true end

						local _, defaultTable = GetSelectedFilters()
						return defaultTable[spell]
					end,
				},
				quickSearch = {
					order = 3,
					name = L["Filter Search"],
					desc = L["Search for a spell name inside of a filter."],
					type = "input",
					get = function() return quickSearchText end,
					set = function(info,value) quickSearchText = value end,
				},
				filterType = {
					order = 4,
					name = L["Filter Type"],
					desc = L["Set the filter type. Blacklist will hide any auras in the list and show all others. Whitelist will show any auras in the filter and hide all others."],
					type = 'select',
					values = {
						Whitelist = L["Whitelist"],
						Blacklist = L["Blacklist"],
					},
					get = function() return E.global.unitframe.aurafilters[selectedFilter].type end,
					set = function(info, value) E.global.unitframe.aurafilters[selectedFilter].type = value; UF:Update_AllFrames(); end,
					hidden = function() return (selectedFilter == 'Debuff Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' or selectedFilter == 'Whitelist' or selectedFilter == 'Blacklist') end,
				},
				selectSpell = {
					name = L["Select Spell"],
					type = 'select',
					order = 10,
					width = "double",
					get = function(info) return selectedSpell or '' end,
					set = function(info, value)
						selectedSpell = (value ~= '' and value) or nil
					end,
					values = function()
						local list
						if selectedFilter == 'Debuff Highlight' then
							list = E.global.unitframe.DebuffHighlightColors
						elseif selectedFilter == 'AuraBar Colors' then
							list = E.global.unitframe.AuraBarColors
						elseif selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' then
							list = GetSelectedFilters()
						else
							list = E.global.unitframe.aurafilters[selectedFilter].spells
						end

						if not list then return end
						wipe(spellList)

						local searchText = quickSearchText:lower()
						for filter, spell in pairs(list) do
							if spell.id and (selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator') then
								filter = spell.id
							end

							local spellName = tonumber(filter) and GetSpellInfo(filter)
							local name = (spellName and format("%s |cFF888888(%s)|r", spellName, filter)) or tostring(filter)

							if name:lower():find(searchText) then
								spellList[filter] = name
							end
						end

						if not next(spellList) then
							spellList[''] = L["NONE"]
						end

						return spellList
					end,
				},
			},
		},
		resetGroup = {
			type = "group",
			name = L["Reset Filter"],
			order = 25,
			guiInline = true,
			hidden = function() return not IsStockFilter() end,
			args = {
				enableReset = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return FilterResetState[selectedFilter] end,
					set = function(info, value) FilterResetState[selectedFilter] = value end,
				},
				resetFilter = {
					order = 2,
					type = "execute",
					name = L["Reset Filter"],
					desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed."],
					disabled = function() return not FilterResetState[selectedFilter] end,
					func = function(info)
						if selectedFilter == 'Debuff Highlight' then
							E.global.unitframe.DebuffHighlightColors = E:CopyTable({}, G.unitframe.DebuffHighlightColors)
						elseif selectedFilter == 'AuraBar Colors' then
							E.global.unitframe.AuraBarColors = E:CopyTable({}, G.unitframe.AuraBarColors)
						elseif selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator' then
							local selectedTable, defaultTable = GetSelectedFilters()
							wipe(selectedTable)
							E:CopyTable(selectedTable, defaultTable)
						else
							E.global.unitframe.aurafilters[selectedFilter].spells = E:CopyTable({}, G.unitframe.aurafilters[selectedFilter].spells)
						end

						selectedSpell = nil

						UF:Update_AllFrames()
					end,
				},
			},
		},
		buffIndicator = {
			type = 'group',
			name = function()
				local spell = GetSelectedSpell()
				local spellName = spell and GetSpellInfo(spell)
				return (spellName and spellName..' |cFF888888('..spell..')|r') or spell or ' '
			end,
			hidden = function() return not selectedSpell or (selectedFilter ~= 'Buff Indicator (Pet)' and selectedFilter ~= 'Buff Indicator (Profile)' and selectedFilter ~= 'Buff Indicator') end,
			get = function(info)
				local spell = GetSelectedSpell()
				if not spell then return end

				local selectedTable = GetSelectedFilters()
				return selectedTable[spell][info[#info]]
			end,
			set = function(info, value)
				local spell = GetSelectedSpell()
				if not spell then return end

				local selectedTable = GetSelectedFilters()
				selectedTable[spell][info[#info]] = value;
				UF:Update_AllFrames()
			end,
			order = -10,
			guiInline = true,
			args = {
				enabled = {
					name = L["Enable"],
					order = 1,
					type = 'toggle',
				},
				point = {
					name = L["Anchor Point"],
					order = 2,
					type = 'select',
					values = {
						TOPLEFT = 'TOPLEFT',
						TOPRIGHT = 'TOPRIGHT',
						BOTTOMLEFT = 'BOTTOMLEFT',
						BOTTOMRIGHT = 'BOTTOMRIGHT',
						LEFT = 'LEFT',
						RIGHT = 'RIGHT',
						TOP = 'TOP',
						BOTTOM = 'BOTTOM',
					}
				},
				style = {
					name = L["Style"],
					order = 3,
					type = 'select',
					values = {
						timerOnly = L["Timer Only"],
						coloredIcon = L["Colored Icon"],
						texturedIcon = L["Textured Icon"],
					},
				},
				color = {
					name = L["COLOR"],
					type = 'color',
					order = 4,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end
						local selectedTable = GetSelectedFilters()
						local t = selectedTable[spell][info[#info]]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						local spell = GetSelectedSpell()
						if not spell then return end
						local selectedTable = GetSelectedFilters()
						local t = selectedTable[spell][info[#info]]
						t.r, t.g, t.b = r, g, b

						UF:Update_AllFrames()
					end,
					disabled = function()
						local spell = GetSelectedSpell()
						if not spell then return end
						local selectedTable = GetSelectedFilters()
						return selectedTable[spell].style == 'texturedIcon'
					end,
				},
				sizeOffset = {
					order = 5,
					type = "range",
					name = L["Size Offset"],
					desc = L["This changes the size of the Aura Icon by this value."],
					min = -25, max = 25, step = 1,
				},
				xOffset = {
					order = 6,
					type = 'range',
					name = L["X-Offset"],
					min = -75, max = 75, step = 1,
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L["Y-Offset"],
					min = -75, max = 75, step = 1,
				},
				textThreshold = {
					name = L["Text Threshold"],
					desc = L["At what point should the text be displayed. Set to -1 to disable."],
					type = 'range',
					order = 8,
					min = -1, max = 60, step = 1,
				},
				anyUnit = {
					name = L["Show Aura From Other Players"],
					order = 9,
					customWidth = 205,
					type = 'toggle',
				},
				onlyShowMissing = {
					name = L["Show When Not Active"],
					order = 10,
					type = 'toggle',
				},
				displayText = {
					name = L["Display Text"],
					type = 'toggle',
					order = 11,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						local selectedTable = GetSelectedFilters()
						return (selectedTable[spell].style == 'timerOnly') or selectedTable[spell][info[#info]]
					end,
					disabled = function()
						local spell = GetSelectedSpell()
						if not spell then return end
						local selectedTable = GetSelectedFilters()
						return selectedTable[spell].style == 'timerOnly'
					end
				},
			},
		},
		spellGroup = {
			type = "group",
			name = function()
				local spell = GetSelectedSpell()
				local spellName = spell and GetSpellInfo(spell)
				return (spellName and spellName..' |cFF888888('..spell..')|r') or spell or ' '
			end,
			hidden = function() return not selectedSpell or (selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator') end,
			order = -15,
			guiInline = true,
			args = {
				enabled = {
					name = L["Enable"],
					order = 0,
					type = 'toggle',
					hidden = function() return (selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator') end,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						if selectedFilter == 'Debuff Highlight' then
							return E.global.unitframe.DebuffHighlightColors[spell].enable
						elseif selectedFilter == 'AuraBar Colors' then
							return E.global.unitframe.AuraBarColors[spell].enable
						else
							return E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable
						end
					end,
					set = function(info, value)
						local spell = GetSelectedSpell()
						if not spell then return end

						if selectedFilter == 'Debuff Highlight' then
							E.global.unitframe.DebuffHighlightColors[spell].enable = value
						elseif selectedFilter == 'AuraBar Colors' then
							E.global.unitframe.AuraBarColors[spell].enable = value
						else
							E.global.unitframe.aurafilters[selectedFilter].spells[spell].enable = value
						end

						UF:Update_AllFrames();
					end,
				},
				style = {
					name = L["Style"],
					type = 'select',
					order = 1,
					values = { GLOW = L["Glow"], FILL = L["Fill"] },
					hidden = function() return selectedFilter ~= 'Debuff Highlight' end,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						return E.global.unitframe.DebuffHighlightColors[spell].style
					end,
					set = function(info, value)
						local spell = GetSelectedSpell()
						if not spell then return end

						E.global.unitframe.DebuffHighlightColors[spell].style = value
						UF:Update_AllFrames()
					end,
				},
				color = {
					name = L["COLOR"],
					type = 'color',
					order = 2,
					hasAlpha = function() return selectedFilter ~= 'AuraBar Colors' end,
					hidden = function() return (selectedFilter ~= 'Debuff Highlight' and selectedFilter ~= 'AuraBar Colors' and selectedFilter ~= 'Buff Indicator (Pet)' and selectedFilter ~= 'Buff Indicator (Profile)' and selectedFilter ~= 'Buff Indicator') end,
					get = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						local t
						if selectedFilter == 'Debuff Highlight' then
							t = E.global.unitframe.DebuffHighlightColors[spell].color
						elseif selectedFilter == 'AuraBar Colors' then
							t = E.global.unitframe.AuraBarColors[spell].color
						end

						if t then
							return t.r, t.g, t.b, t.a
						end
					end,
					set = function(info, r, g, b, a)
						local spell = GetSelectedSpell()
						if not spell then return end

						local t
						if selectedFilter == 'Debuff Highlight' then
							t = E.global.unitframe.DebuffHighlightColors[spell].color
						elseif selectedFilter == 'AuraBar Colors' then
							t = E.global.unitframe.AuraBarColors[spell].color
						end

						if t then
							t.r, t.g, t.b, t.a = r, g, b, a
							UF:Update_AllFrames()
						end
					end,
				},
				removeColor = {
					type = 'execute',
					order = 3,
					name = L["Restore Defaults"],
					hidden = function() return selectedFilter ~= 'AuraBar Colors' end,
					func = function(info)
						local spell = GetSelectedSpell()
						if not spell then return end

						if G.unitframe.AuraBarColors[spell] then
							E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, G.unitframe.AuraBarColors[spell])
						else
							E.global.unitframe.AuraBarColors[spell] = E:CopyTable({}, auraBarDefaults)
						end

						UF:Update_AllFrames();
					end,
				},
				forDebuffIndicator = {
					order = 4,
					type = "group",
					name = L["Used as RaidDebuff Indicator"],
					guiInline = true,
					hidden = function() return (selectedFilter == 'Debuff Highlight' or selectedFilter == 'AuraBar Colors' or selectedFilter == 'Buff Indicator (Pet)' or selectedFilter == 'Buff Indicator (Profile)' or selectedFilter == 'Buff Indicator') end,
					args = {
						priority = {
							order = 1,
							type = "range",
							name = L["Priority"],
							desc = L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."],
							min = 0, max = 99, step = 1,
							get = function()
								local spell = GetSelectedSpell()
								if not spell then
									return 0
								else
									return E.global.unitframe.aurafilters[selectedFilter].spells[spell].priority
								end
							end,
							set = function(info, value)
								local spell = GetSelectedSpell()
								if not spell then return end

								E.global.unitframe.aurafilters[selectedFilter].spells[spell].priority = value;
								UF:Update_AllFrames();
							end,
						},
						stackThreshold = {
							order = 2,
							type = "range",
							name = L["Stack Threshold"],
							desc = L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."],
							min = 0, max = 99, step = 1,
							get = function()
								local spell = GetSelectedSpell()
								if not spell then
									return 0
								else
									return E.global.unitframe.aurafilters[selectedFilter].spells[spell].stackThreshold
								end
							end,
							set = function(info, value)
								local spell = GetSelectedSpell()
								if not spell then return end

								E.global.unitframe.aurafilters[selectedFilter].spells[spell].stackThreshold = value
								UF:Update_AllFrames()
							end,
						},
					},
				},
			},
		}
	},
}

function E:SetToFilterConfig(filter)
	selectedSpell = nil
	quickSearchText = ''
	selectedFilter = filter or ''
	E.Libs.AceConfigDialog:SelectGroup("ElvUI", "filters")
end
