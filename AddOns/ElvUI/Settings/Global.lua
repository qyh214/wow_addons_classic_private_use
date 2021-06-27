local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Global Settings
G.general = {
	UIScale = 0.64,
	locale = E:GetLocale(),
	eyefinity = false,
	ultrawide = false,
	smallerWorldMap = true,
	allowDistributor = false,
	smallerWorldMapScale = 0.9,
	fadeMapWhenMoving = true,
	mapAlphaWhenMoving = 0.2,
	fadeMapDuration = 0.2,
	WorldMapCoordinates = {
		enable = true,
		position = 'BOTTOMLEFT',
		xOffset = 0,
		yOffset = 0
	},
	AceGUI = {
		width = 970,
		height = 755
	},
	showMissingTalentAlert = false,
	commandBarSetting = 'ENABLED_RESIZEPARENT'
}

G.classtimer = {}

G.chat = {
	classColorMentionExcludedNames = {}
}

G.bags = {
	ignoredItems = {}
}

G.datatexts = {
	customPanels = {},
	customCurrencies = {},
	settings = {
		Agility = { Label = '', NoLabel = false },
		Armor = { Label = '', NoLabel = false },
		Avoidance = { Label = '', NoLabel = false, decimalLength = 1 },
		CallToArms = { Label = '', NoLabel = false },
		Crit = { Label = '', NoLabel = false, decimalLength = 1 },
		Currencies = { goldFormat = 'BLIZZARD', goldCoins = true, displayedCurrency = 'BACKPACK', displayStyle = 'ICON', tooltipData = {} },
		Durability = { percThreshold = 30 },
		Experience = { textFormat = 'CUR' },
		Friends = {
			Label = '', NoLabel = false,
			--status
			hideAFK = false,
			hideDND = false,
			--clients
			hideWoW = false,
			hideD3 = false,
			hideVIPR = false,
			hideWTCG = false, --Hearthstone
			hideHero = false, --Heros of the Storm
			hidePro = false, --Overwatch
			hideS1 = false,
			hideS2 = false,
			hideDST2 = false,
			hideBSAp = false, --Mobile
			hideApp = false, --Launcher
		},
		Gold = { goldFormat = 'BLIZZARD', goldCoins = true },
		Guild = { Label = '', NoLabel = false },
		Hit = { Label = '', NoLabel = false, decimalLength = 1 },
		Bags = { textFormat = 'USED_TOTAL' },
		Reputation = { textFormat = 'CUR' },
		Speed = { Label = '', NoLabel = false, decimalLength = 1 },
		Stamina = { Label = '', NoLabel = false },
		Strength = { Label = '', NoLabel = false },
		Time = { time24 = _G.GetCurrentRegion() ~= 1, localTime = true },
		Versatility = { Label = '', NoLabel = false, decimalLength = 1 },
	},
	newPanelInfo = {
		name = '',
		enable = true,
		growth = 'HORIZONTAL',
		width = 300,
		height = 22,
		frameStrata = 'LOW',
		numPoints = 3,
		frameLevel = 1,
		backdrop = true,
		panelTransparency = false,
		mouseover = false,
		border = true,
		visibility = 'show',
		tooltipAnchor = 'ANCHOR_TOPLEFT',
		tooltipXOffset = -17,
		tooltipYOffset = 4,
		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontSize = 12,
			fontOutline = "OUTLINE",
		}
	},
}

G.nameplate = {
	effectiveHealth = false,
	effectivePower = false,
	effectiveAura = false,
	effectiveHealthSpeed = 0.3,
	effectivePowerSpeed = 0.3,
	effectiveAuraSpeed = 0.3,
	widgetMap = {
		[149805] = 1940, -- Farseer Ori
		[149804] = 1613, -- Hunter Akana
		[149803] = 1966, -- Bladesman Inowari
		[149904] = 1621, -- Neri Sharpfin
		[149902] = 1622, -- Poen Gillbrack
		[149906] = 1920, -- Vim Brineheart

		[154304] = 1940, -- Farseer Ori
		[150202] = 1613, -- Hunter Akana
		[154297] = 1966, -- Bladesman Inowari
		[151300] = 1621, -- Neri Sharpfin
		[151310] = 1622, -- Poen Gillbrack
		[151309] = 1920, -- Vim Brineheart

		[163541] = 2342, -- Voidtouched Egg
		[163592] = 2342, -- Yu'gaz
		[163593] = 2342, -- Bitey McStabface
		[163595] = 2342, -- Reginald
		[163596] = 2342, -- Picco
		[163648] = 2342, -- Bitey McStabface
		[163651] = 2342, -- Yu'gaz
	}
}

G.unitframe = {
	aurafilters = {},
	aurawatch = {},
	effectiveHealth = false,
	effectivePower = false,
	effectiveAura = false,
	effectiveHealthSpeed = 0.3,
	effectivePowerSpeed = 0.3,
	effectiveAuraSpeed = 0.3,
	raidDebuffIndicator = {
		instanceFilter = 'RaidDebuffs',
		otherFilter = 'CCDebuffs'
	}
}

G.profileCopy = {
	--Specific values
	selected = 'Default',
	movers = {},
	--Modules
	actionbar = {
		general = true,
		bar1 = true,
		bar2 = true,
		bar3 = true,
		bar4 = true,
		bar5 = true,
		bar6 = true,
		barPet = true,
		stanceBar = true,
		microbar = true,
		cooldown = true
	},
	auras = {
		general = true,
		buffs = true,
		debuffs = true,
		cooldown = true
	},
	bags = {
		general = true,
		split = true,
		vendorGrays = true,
		bagBar = true,
		cooldown = true
	},
	chat = {
		general = true
	},
	cooldown = {
		general = true,
		fonts = true
	},
	databars = {
		experience = true,
		reputation = true,
		honor = true,
	},
	datatexts = {
		general = true,
		panels = true
	},
	general = {
		general = true,
		minimap = true,
		threat = true,
		totems = true,
		itemLevel = true,
		altPowerBar = true
	},
	nameplates = {
		general = true,
		cooldown = true,
		threat = true,
		units = {
			PLAYER = true,
			TARGET = true,
			FRIENDLY_PLAYER = true,
			ENEMY_PLAYER = true,
			FRIENDLY_NPC = true,
			ENEMY_NPC = true
		}
	},
	tooltip = {
		general = true,
		visibility = true,
		healthBar = true
	},
	unitframe = {
		general = true,
		cooldown = true,
		colors = {
			general = true,
			power = true,
			reaction = true,
			healPrediction = true,
			classResources = true,
			frameGlow = true,
			debuffHighlight = true
		},
		units = {
			player = true,
			target = true,
			targettarget = true,
			targettargettarget = true,
			focus = true,
			focustarget = true,
			pet = true,
			pettarget = true,
			arena = true,
			party = true,
			raid = true,
			raid40 = true,
			raidpet = true,
			tank = true,
			assist = true
		}
	}
}
