local mod	= DBM:NewMod("Arlokk", "DBM-ZG", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(14515)
mod:SetEncounterID(791)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 24210 24212",
	"SPELL_AURA_REMOVED 24212"
)

local warnMark		= mod:NewTargetAnnounce(24210, 3)
local warnPain		= mod:NewTargetAnnounce(24212, 2, nil, "RemoveMagic|Healer")

local specWarnMark	= mod:NewSpecialWarningYou(24210, nil, nil, nil, 1, 2)

local timerPain		= mod:NewTargetTimer(18, 24212, nil, "RemoveMagic|Healer", nil, 3, nil, DBM_CORE_MAGIC_ICON)

function mod:OnCombatStart(delay)
end

do
	local MarkofArlokk, ShadowwordPain = DBM:GetSpellInfo(24210), DBM:GetSpellInfo(24212)
	function mod:SPELL_AURA_APPLIED(args)
		--if args:IsSpellID(24210) then
		if args.spellName == MarkofArlokk then
			if args:IsPlayer() then
				specWarnMark:Show()
				specWarnMark:Play("targetyou")
			else
				warnMark:Show(args.destName)
			end
		--elseif args:IsSpellID(24212) then
		elseif args.spellName == ShadowwordPain and args:IsDestTypePlayer() then
			warnPain:Show(args.destName)
			timerPain:Start(args.destName)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args:IsSpellID(24212) then
		if args.spellName == ShadowwordPain and args:IsDestTypePlayer() then
			timerPain:Stop(args.destName)
		end
	end
end
