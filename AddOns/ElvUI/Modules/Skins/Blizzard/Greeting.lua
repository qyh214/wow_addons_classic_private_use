local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local find = string.find
local gsub = gsub

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.greeting ~= true then return end

	_G.QuestFrameGreetingPanel:StripTextures()

	_G.QuestGreetingScrollFrameTop:StripTextures()
	_G.QuestGreetingScrollFrameMiddle:StripTextures()
	_G.QuestGreetingScrollFrameBottom:StripTextures()

	S:HandleButton(_G.QuestFrameGreetingGoodbyeButton, true)
	_G.QuestFrameGreetingGoodbyeButton:Point('BOTTOMRIGHT', -37, 4)

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestGreetingScrollFrame:Height(403)

	S:HandleScrollBar(_G.QuestGreetingScrollFrameScrollBar)

	QuestFrameGreetingPanel:HookScript('OnShow', function()
		_G.GreetingText:SetTextColor(1, 1, 1)
		_G.CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		_G.AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

		for i = 1, MAX_NUM_QUESTS do
			local button = _G['QuestTitleButton'..i]
			if button:GetFontString() then
				if button:GetFontString():GetText() and find(button:GetFontString():GetText(), '|cff000000') then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), '|cff000000', '|cffFFFF00'))
				end
			end
		end
	end)
end

S:AddCallback('Greeting', LoadSkin)