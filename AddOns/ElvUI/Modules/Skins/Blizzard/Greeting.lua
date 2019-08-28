local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.greeting ~= true then return end

	QuestFrameGreetingPanel:StripTextures()

	QuestGreetingFrameHorizontalBreak:Kill()

	S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)

	S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
	QuestFrameGreetingGoodbyeButton:Point('BOTTOMRIGHT', -37, 4)

	QuestGreetingScrollFrame:Height(403)

	QuestFrameGreetingPanel:HookScript('OnShow', function()
		GreetingText:SetTextColor(1, 0.80, 0.10)
		CurrentQuestsText:SetTextColor(1, 1, 1)
		AvailableQuestsText:SetTextColor(1, 0.80, 0.10)
	end)

	for i = 1, MAX_NUM_QUESTS do
		local button = _G['QuestTitleButton'..i]
		-- button:SetTextColor(1, 1, 0)
	end
end

S:AddCallback('Greeting', LoadSkin)