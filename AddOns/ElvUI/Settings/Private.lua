------------------------------------------------------------------------------------------------------
-- Locked Settings, These settings are stored for your character only regardless of profile options.
------------------------------------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

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
	minimap = {
		enable = true,
		hideCalendar = true,
		hideTracking = false,
	},
	worldMap = true,
	classColorMentionsSpeech = true,
	raidUtility = true,
	voiceOverlay = true,
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
	},
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
		bags = true,
		inspect = true,
		binding = true,
		guild = true,
		tradeskill = true,
		raid = true,
		talent = true,
		auctionhouse = true,
		macro = true,
		debug = true,
		trainer = true,
		loot = true,
		lootRoll = true,
		alertframes = true,
		bgscore = true,
		merchant = true,
		mail = true,
		help = true,
		trade = true,
		gossip = true,
		worldmap = true,
		taxi = true,
		timemanger = true,
		tooltip = true,
		quest = true,
		questtimers = true,
		petition = true,
		dressingroom = true,
		friends = true,
		spellbook = true,
		character = true,
		craft = true,
		misc = true,
		tabard = true,
		guildregistrar = true,
		timemanager = true,
		stable = true,
		battlefield = true,
		bgmap = true,
		addonManager = true,
		mirrorTimers = true,
		tutorial = true,
		BlizzardOptions = true,
		Channels = true,
		Communities = true,
		GMChat = true,
	},
}

V.tooltip = {
	enable = true,
}

V.unitframe = {
	enable = true,
	disabledBlizzardFrames = {
		player = true,
		target = true,
		party = true,
		raid = true,
	},
}

V.actionbar = {
	enable = true,
	hideCooldownBling = false,
	masque = {
		actionbars = false,
		petBar = false,
		stanceBar = false,
	},
}
