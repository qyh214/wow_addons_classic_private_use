local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mirrorTimers then return end

	local function MirrorTimer_OnUpdate(frame, elapsed)
		if frame.paused then return end

		if frame.timeSinceUpdate >= 0.3 then
			local text = frame.label:GetText()

			if frame.value > 0 then
				frame.TimerText:SetFormattedText('%s (%d:%02d)', text, frame.value / 60, frame.value % 60)
			else
				frame.TimerText:SetFormattedText('%s (0:00)', text)
			end

			frame.timeSinceUpdate = 0
		else
			frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
		end
	end

	for i = 1, _G.MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G['MirrorTimer'..i]
		local statusBar = _G['MirrorTimer'..i..'StatusBar']
		local text = _G['MirrorTimer'..i..'Text']

		mirrorTimer:StripTextures()
		mirrorTimer:Size(222, 18)
		mirrorTimer.label = text
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)
		statusBar:CreateBackdrop()
		statusBar:Size(222, 18)
		text:Hide()

		local timerText = mirrorTimer:CreateFontString(nil, 'OVERLAY')
		timerText:FontTemplate()
		timerText:Point('CENTER', statusBar, 'CENTER', 0, 0)
		mirrorTimer.TimerText = timerText

		mirrorTimer.timeSinceUpdate = 0.3
		mirrorTimer:HookScript('OnUpdate', MirrorTimer_OnUpdate)

		E:CreateMover(mirrorTimer, 'MirrorTimer'..i..'Mover', L["MirrorTimer"]..i, nil, nil, nil, 'ALL,SOLO')
	end
end

S:AddCallback('Skin_MirrorTimers', LoadSkin)
