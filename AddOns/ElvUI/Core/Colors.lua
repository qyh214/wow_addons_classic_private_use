RAID_CLASS_COLORS = {
	["DRUID"] = CreateColor(1, .49, .03),
	["HUNTER"] = CreateColor(.67, .83, .45),
	["MAGE"] = CreateColor(.24, .78, .92),
	["PALADIN"] = CreateColor(.96, .55, .73),
	["PRIEST"] = CreateColor(1, 1, 1),
	["ROGUE"] = CreateColor(1, .96, .42),
	["SHAMAN"] = CreateColor(0, .44, .86),
	["WARLOCK"] = CreateColor(.53, .53, .93),
	["WARRIOR"] = CreateColor(.78, .61, .43)
}

for _, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor()
end
