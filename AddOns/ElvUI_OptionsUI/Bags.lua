local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local B = E:GetModule('Bags')
local ACH = E.Libs.ACH

local _G = _G
local gsub = gsub
local next = next
local strmatch = strmatch
local SetCVar = SetCVar
local GetCVarBool = GetCVarBool
local SetInsertItemsLeftToRight = SetInsertItemsLeftToRight
local GameTooltip = _G.GameTooltip
local textAnchors = { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' }

local Bags = ACH:Group(L["BAGSLOT"], nil, 2, 'tab', function(info) return E.db.bags[info[#info]] end, function(info, value) E.db.bags[info[#info]] = value end)
E.Options.args.bags = Bags

Bags.args.intro = ACH:Description(L["BAGS_DESC"], 0)
Bags.args.enable = ACH:Toggle(L["Enable"], L["Enable/Disable the all-in-one bag."], 1, nil, nil, nil, function() return E.private.bags.enable end, function(info, value) E.private.bags[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
Bags.args.cooldownShortcut = ACH:Execute(L["Cooldown Text"], nil, 3, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'cooldown', 'bags') end)

Bags.args.general = ACH:Group(L["General"], nil, 1, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateAll() end, function() return not E.Bags.Initialized end)
Bags.args.general.args.strata = ACH:Select(L["Frame Strata"], nil, 1, { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH' })
Bags.args.general.args.currencyFormat = ACH:Select(L["Currency Format"], L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"], 2, { ICON = L["Icons Only"], ICON_TEXT = L["Icons and Text"], ICON_TEXT_ABBR = L["Icons and Text (Short)"] }, nil, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateTokens() end)
Bags.args.general.args.moneyFormat = ACH:Select(L["Gold Format"], L["The display format of the money text that is shown at the top of the main bag."], 3, { SMART = L["Smart"], FULL = L["Full"], SHORT = L["SHORT"], SHORTSPACED = L["Short (Whole Numbers Spaced)"], SHORTINT = L["Short (Whole Numbers)"], CONDENSED = L["Condensed"], CONDENSED_SPACED = L["Condensed (Spaced)"], BLIZZARD = L["Blizzard Style"], BLIZZARD2 = L["Blizzard Style"].." 2" }, nil, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateGoldText() end)
Bags.args.general.args.moneyCoins = ACH:Toggle(L["Show Coins"], L["Use coin icons instead of colored text."], 4, nil, nil, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateGoldText() end)

Bags.args.general.args.generalGroup = ACH:MultiSelect(L["General"], nil, 5, nil, nil, nil, function(_, key) return E.db.bags[key] end)
Bags.args.general.args.generalGroup.values = {
	transparent = L["Transparent"],
	questIcon = L["Quest Icon"],
	junkIcon = L["Junk Icon"],
	junkDesaturate = L["Desaturate Junk"],
	newItemGlow = L["New Item Glow"],
	showBindType = L["Bind on Equip/Use Text"],
	clearSearchOnClose = L["Clear Search On Close"],
	reverseLoot = L["REVERSE_NEW_LOOT_TEXT"],
	reverseSlots = L["Reverse Bag Slots"],
	auctionToggle = L["Auction Toggle"],
}

Bags.args.general.args.generalGroup.set = function(_, key, value)
	E.db.bags[key] = value
	if key == 'reverseLoot' then
		SetInsertItemsLeftToRight(value)
	elseif key == 'reverseSlots' or key == 'transparent' then
		B:UpdateAll()
	end
end

Bags.args.general.args.countGroup = ACH:Group(L["Item Count"], nil, 6, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateCountDisplay() end)
Bags.args.general.args.countGroup.inline = true
Bags.args.general.args.countGroup.args.countFontColor = ACH:Color(L["COLOR"], nil, 1, nil, nil, function(info) local t = E.db.bags[info[#info]] local d = P.bags[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.bags[info[#info]] t.r, t.g, t.b = r, g, b B:UpdateCountDisplay() end)
Bags.args.general.args.countGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 2)
Bags.args.general.args.countGroup.args.fontGroup.inline = true
Bags.args.general.args.countGroup.args.fontGroup.args.countFontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
Bags.args.general.args.countGroup.args.fontGroup.args.countFont = ACH:SharedMediaFont(L["Font"], nil, 4)
Bags.args.general.args.countGroup.args.fontGroup.args.countFontOutline = ACH:FontFlags(L["Font Outline"], nil, 5)
Bags.args.general.args.countGroup.args.positionGroup = ACH:Group(L["Position"], nil, 6)
Bags.args.general.args.countGroup.args.positionGroup.inline = true
Bags.args.general.args.countGroup.args.positionGroup.args.countPosition = ACH:Select(L["Position"], nil, 7, textAnchors)
Bags.args.general.args.countGroup.args.positionGroup.args.countxOffset = ACH:Range(L["X-Offset"], nil, 8, { min = -45, max = 45, step = 1 })
Bags.args.general.args.countGroup.args.positionGroup.args.countyOffset = ACH:Range(L["Y-Offset"], nil, 9, { min = -45, max = 45, step = 1 })

Bags.args.general.args.itemLevelGroup = ACH:Group(L["Item Level"], nil, 7, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:UpdateItemLevelDisplay() end)
Bags.args.general.args.itemLevelGroup.inline = true
Bags.args.general.args.itemLevelGroup.args.itemLevel = ACH:Toggle(L["Display Item Level"], L["Displays item level on equippable items."], 1)
Bags.args.general.args.itemLevelGroup.args.itemLevelCustomColorEnable = ACH:Toggle(L["Custom Color"], nil, 2, nil, nil, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.itemLevelCustomColor = ACH:Color(L["COLOR"], nil, 3, nil, nil, function(info) local t = E.db.bags[info[#info]] local d = P.bags[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.bags[info[#info]] t.r, t.g, t.b = r, g, b B:UpdateItemLevelDisplay() end, nil, function() return not E.db.bags.itemLevel or not E.db.bags.itemLevelCustomColorEnable end)
Bags.args.general.args.itemLevelGroup.args.itemLevelThreshold = ACH:Range(L["Item Level Threshold"], L["The minimum item level required for it to be shown."], 4, { min = 1, max = 500, step = 1 }, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.fontGroup = ACH:Group(L["Fonts"], nil, 5, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.fontGroup.inline = true
Bags.args.general.args.itemLevelGroup.args.fontGroup.args.itemLevelFontSize = ACH:Range(L["Font Size"], nil, 6, C.Values.FontSize, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.fontGroup.args.itemLevelFont = ACH:SharedMediaFont(L["Font"], nil, 7, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.fontGroup.args.itemLevelFontOutline = ACH:FontFlags(L["Font Outline"], nil, 8, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.positionGroup = ACH:Group(L["Position"], nil, 9, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.positionGroup.inline = true
Bags.args.general.args.itemLevelGroup.args.positionGroup.args.itemLevelPosition = ACH:Select(L["Position"], nil, 10, textAnchors, nil, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.positionGroup.args.itemLevelxOffset = ACH:Range(L["X-Offset"], nil, 11, { min = -45, max = 45, step = 1 }, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)
Bags.args.general.args.itemLevelGroup.args.positionGroup.args.itemLevelyOffset = ACH:Range(L["Y-Offset"], nil, 12, { min = -45, max = 45, step = 1 }, nil, nil, nil, nil, function() return not E.db.bags.itemLevel end)

Bags.args.general.args.playerGroup = ACH:Group(L["Player"], nil, 8, nil, nil, nil, function() return not E.Bags.Initialized end)
Bags.args.general.args.playerGroup.inline = true
Bags.args.general.args.playerGroup.args.generalGroup = ACH:Group(' ', nil, 1, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:Layout() end)
Bags.args.general.args.playerGroup.args.generalGroup.args.disableBagSort = ACH:Toggle(L["Disable Sort"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:ToggleSortButtonState(false) end)
Bags.args.general.args.playerGroup.args.generalGroup.args.bagSize = ACH:Range(L["Button Size"], nil, 2, { min = 15, max = 45, step = 1 })
Bags.args.general.args.playerGroup.args.generalGroup.args.bagButtonSpacing = ACH:Range(L["Button Spacing"], nil, 3, { min = -3, max = 20, step = 1 })
Bags.args.general.args.playerGroup.args.generalGroup.args.bagWidth = ACH:Range(L["Panel Width"], nil, 4, { min = 150, max = 1400, step = 1 })

Bags.args.general.args.playerGroup.args.split = ACH:Group(L["Split"], nil, 1, nil, function(info) return E.db.bags.split[info[#info]] end, function(info, value) E.db.bags.split[info[#info]] = value B:Layout() end)
Bags.args.general.args.playerGroup.args.split.args.player = ACH:Toggle(L["Enable"], nil, 1)
Bags.args.general.args.playerGroup.args.split.args.bagSpacing = ACH:Range(L["Bag Spacing"], nil, 2, { min = -3, max = 20, step = 1 }, nil, nil, nil, nil, function() return not E.db.bags.split.player end)
Bags.args.general.args.playerGroup.args.split.args.splitbags = ACH:MultiSelect(' ', nil, 4, { bag1 = L["Bag 1"], bag2 = L["Bag 2"], bag3 = L["Bag 3"], bag4 = L["Bag 4"] }, nil, nil, function(_, key) return E.db.bags.split[key] end, function(_, key, value) E.db.bags.split[key] = value B:Layout() end, nil, function() return not E.db.bags.split.player end)

Bags.args.general.args.bankGroup = ACH:Group(L["Bank"], nil, 9, nil, nil, nil, function() return not E.Bags.Initialized end)
Bags.args.general.args.bankGroup.inline = true
Bags.args.general.args.bankGroup.args.generalGroup = ACH:Group(' ', nil, 1, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:Layout(true) end)
Bags.args.general.args.bankGroup.args.generalGroup.args.disableBankSort = ACH:Toggle(L["Disable Sort"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.bags[info[#info]] = value B:ToggleSortButtonState(true) end)
Bags.args.general.args.bankGroup.args.generalGroup.args.bankSize = ACH:Range(L["Button Size"], nil, 2, { min = 15, max = 45, step = 1 })
Bags.args.general.args.bankGroup.args.generalGroup.args.bankButtonSpacing = ACH:Range(L["Button Spacing"], nil, 3, { min = -3, max = 20, step = 1 })
Bags.args.general.args.bankGroup.args.generalGroup.args.bankWidth = ACH:Range(L["Panel Width"], nil, 4, { min = 150, max = 1400, step = 1 })

Bags.args.general.args.bankGroup.args.split = ACH:Group(L["Split"], nil, 1, nil, function(info) return E.db.bags.split[info[#info]] end, function(info, value) E.db.bags.split[info[#info]] = value B:Layout(true) end)
Bags.args.general.args.bankGroup.args.split.args.bank = ACH:Toggle(L["Enable"], nil, 1)
Bags.args.general.args.bankGroup.args.split.args.bankSpacing = ACH:Range(L["Bag Spacing"], nil, 2, { min = -3, max = 20, step = 1 }, nil, nil, nil, nil, function() return not E.db.bags.split.bank end)
Bags.args.general.args.bankGroup.args.split.args.splitbank = ACH:MultiSelect(' ', nil, 4, { bag5 = L["Bank 1"], bag6 = L["Bank 2"], bag7 = L["Bank 3"], bag8 = L["Bank 4"], bag9 = L["Bank 5"], bag10 = L["Bank 6"], bag11 = L["Bank 7"] }, nil, nil, function(_, key) return E.db.bags.split[key] end, function(_, key, value) E.db.bags.split[key] = value B:Layout(true) end, nil, function() return not E.db.bags.split.bank end)
Bags.args.general.args.bankGroup.args.split.args.splitbank.sortByValue = true

Bags.args.colorGroup = ACH:Group(L["COLORS"], nil, 2, nil, function(info) local t = E.db.bags.colors[info[#info - 1]][info[#info]] local d = P.bags.colors[info[#info - 1]][info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b end, function(info, r, g, b) local t = E.db.bags.colors[info[#info - 1]][info[#info]] t.r, t.g, t.b = r, g, b B:UpdateBagColors(info[#info - 1], info[#info], r, g, b) B:UpdateAllBagSlots() end, function() return not E.Bags.Initialized end)
Bags.args.colorGroup.args.general = ACH:Group(L["General"], nil, 0, nil, function(info) return E.db.bags[info[#info]] end, function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end, function() return not E.Bags.Initialized end)
Bags.args.colorGroup.args.general.inline = true
Bags.args.colorGroup.args.general.args.qualityColors = ACH:Toggle(L["Show Quality Color"], L["Colors the border according to the Quality of the Item."], 2)
Bags.args.colorGroup.args.general.args.specialtyColors = ACH:Toggle(L["Show Special Bags Color"], nil, 3)
Bags.args.colorGroup.args.general.args.colorBackdrop = ACH:Toggle(L["Color Backdrop"], nil, 4)

Bags.args.colorGroup.args.profession = ACH:Group(L["Profession Bags"], nil, 1)
Bags.args.colorGroup.args.profession.inline = true
Bags.args.colorGroup.args.profession.args.quiver = ACH:Color(L["Quiver"])
Bags.args.colorGroup.args.profession.args.ammoPouch = ACH:Color(L["Ammo Pouch"])
Bags.args.colorGroup.args.profession.args.herbs = ACH:Color(L["Herbalism"])
Bags.args.colorGroup.args.profession.args.enchanting = ACH:Color(L["Enchanting"])
Bags.args.colorGroup.args.profession.args.soulBag = ACH:Color(L["Soul Bag"])

Bags.args.colorGroup.args.items = ACH:Group(L["ITEMS"], nil, 3)
Bags.args.colorGroup.args.items.inline = true
Bags.args.colorGroup.args.items.args.questStarter = ACH:Color(L["Quest Starter"])
Bags.args.colorGroup.args.items.args.questItem = ACH:Color(L["ITEM_BIND_QUEST"])

Bags.args.bagBar = ACH:Group(L["Bag Bar"], nil, 3, nil, function(info) return E.db.bags.bagBar[info[#info]] end, function(info, value) E.db.bags.bagBar[info[#info]] = value; B:SizeAndPositionBagBar() end)
Bags.args.bagBar.args.enable = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, function() return E.private.bags.bagBar end, function(_, value) E.private.bags.bagBar = value E:StaticPopup_Show('PRIVATE_RL') end)
Bags.args.bagBar.args.showBackdrop = ACH:Toggle(L["Backdrop"], nil, 2)
Bags.args.bagBar.args.mouseover = ACH:Toggle(L["Mouse Over"], L["The frame is not shown unless you mouse over the frame."], 3)
Bags.args.bagBar.args.showCount = ACH:Toggle(L["Show Count"], nil, 4, nil, nil, nil, function() return GetCVarBool('displayFreeBagSlots') end, function(_, value) SetCVar('displayFreeBagSlots', value and 1 or 0) B:SizeAndPositionBagBar() end)
Bags.args.bagBar.args.size = ACH:Range(L["Button Size"], L["Set the size of your bag buttons."], 5, { min = 12, max = 128, step = 1 })
Bags.args.bagBar.args.justBackpack = ACH:Toggle(L['Backpack Only'], nil, 6)
Bags.args.bagBar.args.spacing = ACH:Range(L["Button Spacing"], L["The spacing between buttons."], 7, { min = -3, max = 20, step = 1 }, nil, nil, nil, nil, function() return E.db.bags.bagBar.justBackpack end)
Bags.args.bagBar.args.backdropSpacing = ACH:Range(L["Backdrop Spacing"], L["The spacing between the backdrop and the buttons."], 8, { min = 0, max = 10, step = 1 }, nil, nil, nil, nil, function() return E.db.bags.bagBar.justBackpack end)
Bags.args.bagBar.args.sortDirection = ACH:Select(L["Sort Direction"], L["The direction that the bag frames will grow from the anchor."], 9, { ASCENDING = L["Ascending"], DESCENDING = L["Descending"] })
Bags.args.bagBar.args.growthDirection = ACH:Select(L["Bar Direction"], L["The direction that the bag frames be (Horizontal or Vertical)."], 10, { VERTICAL = L["Vertical"], HORIZONTAL = L["Horizontal"] })
Bags.args.bagBar.args.visibility = ACH:Input(L["Visibility State"], L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"], 11, true, 'full', nil, function(_, value) E.db.bags.bagBar.visibility = value B:SizeAndPositionBagBar() end)

Bags.args.vendorGrays = ACH:Group(L["Vendor Grays"], nil, 4, nil, function(info) return E.db.bags.vendorGrays[info[#info]] end, function(info, value) E.db.bags.vendorGrays[info[#info]] = value; B:UpdateSellFrameSettings() end)
Bags.args.vendorGrays.args.enable = ACH:Toggle(L["Enable"], L["Automatically vendor gray items when visiting a vendor."], 1)
Bags.args.vendorGrays.args.interval = ACH:Range(L["Sell Interval"], L["Will attempt to sell another item in set interval after previous one was sold."], 2, { min = .1, max = 1, step = .1 })
Bags.args.vendorGrays.args.details = ACH:Toggle(L["Vendor Gray Detailed Report"], L["Displays a detailed report of every item sold when enabled."], 3)
Bags.args.vendorGrays.args.progressBar = ACH:Toggle(L["Progress Bar"], nil, 4)

Bags.args.bagSortingGroup = ACH:Group(L["Sorting"], nil, 5, nil, nil, nil, function() return (not E.Bags.Initialized) end)
Bags.args.bagSortingGroup.args.sortInverted = ACH:Toggle(L["Sort Inverted"], L["Direction the bag sorting will use to allocate the items."], 1)
Bags.args.bagSortingGroup.args.description = ACH:Description(L["Here you can add items or search terms that you want to be excluded from sorting. To remove an item just click on its name in the list."], 3)
Bags.args.bagSortingGroup.args.addEntryGroup = ACH:Group(L["Add Item or Search Syntax"], nil, 3)
Bags.args.bagSortingGroup.args.addEntryGroup.inline = true
Bags.args.bagSortingGroup.args.addEntryGroup.args.addEntryProfile = ACH:Input(L["Profile"], L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."], 1, nil, nil, function() return '' end, function(_, value) if value == '' or gsub(value, '%s+', '') == '' then return end local itemID = strmatch(value, 'item:(%d+)') E.db.bags.ignoredItems[(itemID or value)] = value end)
Bags.args.bagSortingGroup.args.addEntryGroup.args.addEntryGlobal = ACH:Input(L["Global"], L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."], 2, nil, nil, function() return '' end, function(_, value) if value == '' or gsub(value, '%s+', '') == '' then return end local itemID = strmatch(value, 'item:(%d+)') E.global.bags.ignoredItems[(itemID or value)] = value if E.db.bags.ignoredItems[(itemID or value)] then E.db.bags.ignoredItems[(itemID or value)] = nil end end)
Bags.args.bagSortingGroup.args.ignoredEntriesProfile = ACH:MultiSelect(L["Ignored Items and Search Syntax (Profile)"], nil, 4, function() return E.db.bags.ignoredItems end, nil, nil, function(_, value) return E.db.bags.ignoredItems[value] end, function(_, value) E.db.bags.ignoredItems[value] = nil GameTooltip:Hide() end, nil, function() return not next(E.db.bags.ignoredItems) end)
Bags.args.bagSortingGroup.args.ignoredEntriesGlobal = ACH:MultiSelect(L["Ignored Items and Search Syntax (Global)"], nil, 5, function() return E.global.bags.ignoredItems end, nil, nil, function(_, value) return E.global.bags.ignoredItems[value] end, function(_, value) E.global.bags.ignoredItems[value] = nil GameTooltip:Hide() end, nil, function() return not next(E.global.bags.ignoredItems) end)

Bags.args.search_syntax = ACH:Group(L["Search Syntax"], nil, 6, nil, nil, nil, function() return not E.Bags.Initialized end)
Bags.args.search_syntax.args.link = ACH:Input(L['More Info'], nil, 0, nil, 'full', function() return [[https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax]] end)
Bags.args.search_syntax.args.text = ACH:Description(function() return L["SEARCH_SYNTAX_DESC"]; end, 1, 'medium')
