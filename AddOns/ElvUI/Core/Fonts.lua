local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

local _G = _G
local SetCVar = SetCVar

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()
	local NORMAL		= E.media.normFont
	local NUMBER		= E.media.normFont
	local COMBAT		= LSM:Fetch('font', E.private.general.dmgfont)
	local NAMEFONT		= LSM:Fetch('font', E.private.general.namefont)
	local BUBBLE		= LSM:Fetch('font', E.private.general.chatBubbleFont)
	local SHADOWCOLOR	= _G.SHADOWCOLOR
	local NORMALOFFSET	= _G.NORMALOFFSET
	local BIGOFFSET		= _G.BIGOFFSET
	local MONOCHROME	= ''

	_G.CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	if E.db.general.font == 'Homespun' then
		MONOCHROME = 'MONOCHROME'
	end

	if E.eyefinity then
		-- set an invisible font for xp, honor kill, etc
		COMBAT = E.Media.Fonts.Invisible
	end

	if E.private.general.replaceNameFont then
		_G.UNIT_NAME_FONT		= NAMEFONT
	end

	if E.private.general.replaceCombatFont then
		_G.DAMAGE_TEXT_FONT		= COMBAT
		-- No matter what we do here with the Combat Font, the player Combat Font will always looks like shit, so just dont touch it.
		--SetFont(_G.CombatTextFont,						COMBAT, 200, 'OUTLINE')						-- number here just increase the font quality.
	end

	if E.private.general.replaceBlizzFonts then
		--_G.NAMEPLATE_FONT		= NAMEFONT
		_G.STANDARD_TEXT_FONT	= NORMAL

		--SetFont(_G.NumberFontNormal,					LSM:Fetch('font', 'Homespun'), 10, 'MONOCHROMEOUTLINE', 1, 1, 1, 0, 0, 0)
		--SetFont(_G.GameFontNormalSmall,					NORMAL, 12, nil, nil, nil, nil, nil, nil, nil, unpack(E.media.rgbvaluecolor))
		SetFont(_G.AchievementFont_Small,				NORMAL, E.db.general.fontSize)			-- Achiev dates
		SetFont(_G.BossEmoteNormalHuge,					NORMAL, 24)									-- Talent Title
		SetFont(_G.ChatBubbleFont,						BUBBLE, E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		SetFont(_G.CoreAbilityFont,						NORMAL, 26)									-- Core abilities(title)
		SetFont(_G.DestinyFontHuge,						NORMAL, 20, nil, SHADOWCOLOR, BIGOFFSET)	-- Garrison Mission Report
		SetFont(_G.DestinyFontMed,						NORMAL, 14)									-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy12Font,							NORMAL, 12)									-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy14Font,							NORMAL, 14)									-- Added in 7.3.5 used for ?
		SetFont(_G.Fancy22Font,							NORMAL, 20)									-- Talking frame Title font
		SetFont(_G.Fancy24Font,							NORMAL, 20)									-- Artifact frame - weapon name
		SetFont(_G.FriendsFont_Large,					NORMAL, E.db.general.fontSize)
		SetFont(_G.FriendsFont_Normal,					NORMAL, E.db.general.fontSize)
		SetFont(_G.FriendsFont_Small,					NORMAL, E.db.general.fontSize)
		SetFont(_G.FriendsFont_UserText,				NORMAL, E.db.general.fontSize)
		SetFont(_G.Game13FontShadow,					NORMAL, 14)									-- InspectPvpFrame
		SetFont(_G.Game15Font_o1,						NORMAL, 15)									-- CharacterStatsPane (ItemLevelFrame)
		SetFont(_G.Game16Font,							NORMAL, 16)									-- Added in 7.3.5 used for ?
		SetFont(_G.Game18Font,							NORMAL, 18)									-- MissionUI Bonus Chance
		SetFont(_G.Game24Font, 							NORMAL, 24)									-- Garrison Mission level (in detail frame)
		SetFont(_G.Game30Font,							NORMAL, 28)									-- Mission Level
		SetFont(_G.Game46Font,							NORMAL, 46)									-- Added in 7.3.5 used for ?
		SetFont(_G.GameFont_Gigantic,					NORMAL, 32, nil, SHADOWCOLOR, BIGOFFSET)	-- Used at the install steps
		SetFont(_G.GameFontHighlightMedium,				NORMAL, 15)									-- Fix QuestLog Title mouseover
		SetFont(_G.GameFontHighlightSmall2,				NORMAL, E.db.general.fontSize)			-- Skill or Recipe description on TradeSkill frame
		SetFont(_G.GameFontNormalHuge2,					NORMAL, 24)									-- Mythic weekly best dungeon name
		SetFont(_G.GameFontNormalLarge2,				NORMAL, 15) 								-- Garrison Follower Names
		SetFont(_G.GameFontNormalMed2,					NORMAL, E.db.general.fontSize*1.1)		-- Quest tracker
		SetFont(_G.GameFontNormalMed3,					NORMAL, 15)
		SetFont(_G.GameFontNormalSmall2,				NORMAL, 12)									-- MissionUI Followers names
		SetFont(_G.GameTooltipHeader,					NORMAL, E.db.general.fontSize)
		SetFont(_G.InvoiceFont_Med,						NORMAL, 12)									-- Mail
		SetFont(_G.InvoiceFont_Small,					NORMAL, E.db.general.fontSize)			-- Mail
		SetFont(_G.MailFont_Large,						NORMAL, 14)									-- Mail
		SetFont(_G.NumberFont_Outline_Huge,				NUMBER, 28, MONOCHROME..'THICKOUTLINE', 28)
		SetFont(_G.NumberFont_Outline_Large,			NUMBER, 15, MONOCHROME..'OUTLINE')
		SetFont(_G.NumberFont_Outline_Med,				NUMBER, E.db.general.fontSize*1.1, 'OUTLINE')
		SetFont(_G.NumberFont_OutlineThick_Mono_Small,	NUMBER, E.db.general.fontSize, 'OUTLINE')
		SetFont(_G.NumberFont_Shadow_Med,				NORMAL, E.db.general.fontSize)			-- Chat EditBox
		SetFont(_G.NumberFont_Shadow_Small,				NORMAL, E.db.general.fontSize)
		SetFont(_G.NumberFontNormalSmall,				NORMAL, 11, 'OUTLINE')						-- Calendar, EncounterJournal
		SetFont(_G.PVPInfoTextString,					NORMAL, 22, MONOCHROME..'OUTLINE')
		SetFont(_G.QuestFont,							NORMAL, E.db.general.fontSize)
		SetFont(_G.QuestFont_Enormous, 					NORMAL, 24, nil, SHADOWCOLOR, NORMALOFFSET) -- Garrison Titles
		SetFont(_G.QuestFont_Huge,						NORMAL, 15, nil, SHADOWCOLOR, BIGOFFSET)	-- Quest rewards title(Rewards)
		SetFont(_G.QuestFont_Large,						NORMAL, 14)
		SetFont(_G.QuestFont_Shadow_Huge,				NORMAL, 15, nil, SHADOWCOLOR, NORMALOFFSET) -- Quest Title
		SetFont(_G.QuestFont_Shadow_Small,				NORMAL, 14, nil, SHADOWCOLOR, NORMALOFFSET)
		SetFont(_G.QuestFont_Super_Huge,				NORMAL, 22, nil, SHADOWCOLOR, BIGOFFSET)
		SetFont(_G.ReputationDetailFont,				NORMAL, E.db.general.fontSize)			-- Rep Desc when clicking a rep
		SetFont(_G.SubZoneTextFont,						NORMAL, 24, MONOCHROME..'OUTLINE')			-- World Map(SubZone)
		SetFont(_G.SubZoneTextString,					NORMAL, 25, MONOCHROME..'OUTLINE')
		SetFont(_G.SystemFont_Huge1, 					NORMAL, 20)									-- Garrison Mission XP
		SetFont(_G.SystemFont_Huge1_Outline, 			NORMAL, 18, MONOCHROME..'OUTLINE')			-- Garrison Mission Chance
		SetFont(_G.SystemFont_Large,					NORMAL, 15)
		SetFont(_G.SystemFont_Med1,						NORMAL, E.db.general.fontSize)
		SetFont(_G.SystemFont_Med3,						NORMAL, E.db.general.fontSize*1.1)
		SetFont(_G.SystemFont_Outline,					NORMAL, 13, MONOCHROME..'OUTLINE')			-- Pet level on World map
		SetFont(_G.SystemFont_Outline_Small,			NUMBER, E.db.general.fontSize, 'OUTLINE')
		SetFont(_G.SystemFont_OutlineThick_Huge2,		NORMAL, 20, MONOCHROME..'THICKOUTLINE')
		SetFont(_G.SystemFont_OutlineThick_WTF,			NORMAL, 32, MONOCHROME..'OUTLINE')			-- World Map
		SetFont(_G.SystemFont_Shadow_Huge1,				NORMAL, 20, MONOCHROME..'OUTLINE')			-- Raid Warning, Boss emote frame too
		SetFont(_G.SystemFont_Shadow_Huge3,				NORMAL, 22, nil, SHADOWCOLOR, BIGOFFSET)	-- FlightMap
		SetFont(_G.SystemFont_Shadow_Large,				NORMAL, 15)
		SetFont(_G.SystemFont_Shadow_Large_Outline,		NUMBER, 20, 'OUTLINE')
		SetFont(_G.SystemFont_Shadow_Med1,				NORMAL, E.db.general.fontSize)
		SetFont(_G.SystemFont_Shadow_Med2,				NORMAL, 13 * 1.1)							-- Shows Order resourses on OrderHallTalentFrame
		SetFont(_G.SystemFont_Shadow_Med3,				NORMAL, 13 * 1.1)
		SetFont(_G.SystemFont_Shadow_Med3,				NORMAL, E.db.general.fontSize*1.1)
		SetFont(_G.SystemFont_Shadow_Outline_Huge2,		NORMAL, 20, MONOCHROME..'OUTLINE')
		SetFont(_G.SystemFont_Shadow_Small,				NORMAL, E.db.general.fontSize*0.9)
		SetFont(_G.SystemFont_Small,					NORMAL, E.db.general.fontSize)
		SetFont(_G.SystemFont_Tiny,						NORMAL, E.db.general.fontSize)
		SetFont(_G.Tooltip_Med,							NORMAL, E.db.general.fontSize)
		SetFont(_G.Tooltip_Small,						NORMAL, E.db.general.fontSize)
		SetFont(_G.ZoneTextString,						NORMAL, 32, MONOCHROME..'OUTLINE')
	end
end
