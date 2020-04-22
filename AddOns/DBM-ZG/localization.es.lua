﻿if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Sumo sacerdote Venoxis"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Jeklik"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Mar'li"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Sumo sacerdote Thekal"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Primer add muerto - Resurrección en ~12 segundos"
})

L:SetTimerLocalization({
	TimerSimulKill	= "Resurrección"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Anunciar primer add muerto",
	TimerSimulKill	= "Mostrar tiempo para resurrección de sacerdote"
})

L:SetMiscLocalization({
	PriestDied	= "%s muere.",
	YellPhase2	= "Shirvallah, ¡lléname de IRA!",
	YellKill	= "¡Hakkar ya no me controla! ¡Por fin algo de paz!"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Arlokk"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "Hakkar"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "Señor sangriento Mandokir"
}
L:SetMiscLocalization{
	Bloodlord 	= "Señor sangriento Mandokir",
	Ohgan		= "Ohgan"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Blandón de la Locura"
}
L:SetMiscLocalization{
	Hazzarah = "Hazza'rah",
	Renataki = "Renataki",
	Wushoolay = "Wushoolay",
	Grilek = "Gri'lek"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "Gahz'ranka"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "Jin'do el Aojador"
}
