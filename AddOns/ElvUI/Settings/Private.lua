------------------------------------------------------------------------------------------------------
-- Locked Settings, These settings are stored for your character only regardless of profile options.
------------------------------------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

V.general = {
	loot = true,
	lootRoll = true,
	normTex = 'ElvUI Norm',
	glossTex = 'ElvUI Norm',
	dmgfont = 'PT Sans Narrow',
	namefont = 'PT Sans Narrow',
	chatBubbles = 'backdrop',
	chatBubbleFont = 'PT Sans Narrow',
	chatBubbleFontSize = 14,
	chatBubbleFontOutline = 'NONE',
	chatBubbleName = false,
	pixelPerfect = true,
	replaceNameFont = true,
	replaceCombatFont = true,
	replaceBlizzFonts = true,
	unifiedBlizzFonts = false,
	totemBar = true,
	minimap = {
		enable = true,
		hideTracking = false,
	},
	classColorMentionsSpeech = true,
	raidUtility = true,
	voiceOverlay = true,
	worldMap = true,
}

V.bags = {
	enable = true,
	bagBar = false,
}

V.nameplates = {
	enable = true,
}

V.auras = {
	enable = true,
	disableBlizzard = true,
	buffsHeader = true,
	debuffsHeader = true,
	masque = {
		buffs = false,
		debuffs = false,
	}
}

V.chat = {
	enable = true,
}

V.skins = {
	ace3Enable = true,
	checkBoxSkin = true,
	parchmentRemoverEnable = false,
	blizzard = {
		enable = true,

		addonManager = true,
		arena = true,
		arenaRegistrar = true,
		auctionhouse = true,
		bags = true,
		battlefield = true,
		bgmap = true,
		bgscore = true,
		binding = true,
		blizzardOptions = true,
		channels = true,
		character = true,
		communities = true,
		craft = true,
		debug = true,
		dressingroom = true,
		eventLog = true,
		friends = true,
		gossip = true,
		guild = true,
		guildcontrol = true,
		guildregistrar = true,
		help = true,
		inspect = true,
		loot = true,
		macro = true,
		mail = true,
		merchant = true,
		mirrorTimers = true,
		misc = true,
		petition = true,
		quest = true,
		questChoice = true,
		raid = true,
		socket = true,
		spellbook = true,
		stable = true,
		tabard = true,
		talent = true,
		taxi = true,
		timemanager = true,
		tooltip = true,
		trade = true,
		tradeskill = true,
		trainer = true,
		tutorials = true,
		worldmap = true,
	}
}

V.tooltip = {
	enable = true,
}

V.unitframe = {
	enable = true,
	disabledBlizzardFrames = {
		player = true,
		target = true,
		focus = true,
		arena = true,
		party = true,
		raid = true,
	}
}

V.actionbar = {
	enable = true,
	hideCooldownBling = false,
	masque = {
		actionbars = false,
		petBar = false,
		stanceBar = false,
	}
}
