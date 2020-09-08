local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local CreateFrame = CreateFrame

function DB:OnLeave()
	if self.db.mouseover then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	_G.GameTooltip:Hide()
end

function DB:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame('StatusBar', name, E.UIParent)
	bar:Point(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', DB.OnLeave)
	bar:SetScript('OnMouseDown', onClick)
	bar:SetFrameStrata('LOW')
	bar:SetStatusBarTexture(E.media.normTex)
	bar:CreateBackdrop(DB.db.transparent and 'Transparent')
	bar:Hide()

	bar.text = bar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:Point('CENTER')

	return bar
end

function DB:UpdateAll()
	for _, bar in pairs(DB.StatusBars) do
		bar:SetWidth(bar.db.width)
		bar:SetHeight(bar.db.height)
		bar:SetReverseFill(bar.db.reverseFill)
		bar:SetOrientation(bar.db.orientation)
		bar:SetRotatesTexture(bar.db.orientation ~= 'HORIZONTAL')
		bar:SetStatusBarTexture(DB.db.customTexture and E.LSM:Fetch('statusbar', DB.db.statusbar) or E.media.normTex)
		bar.backdrop:SetTemplate(DB.db.transparent and 'Transparent')
		bar.text:FontTemplate(E.Libs.LSM:Fetch('font', bar.db.font), bar.db.fontSize, bar.db.fontOutline)
		if bar.db.enable then
			bar:SetAlpha(bar.db.mouseover and 0 or 1)
		end

		if bar.Rested then
			bar.Rested:SetOrientation(bar.db.orientation)
			bar.Rested:SetReverseFill(bar.db.reverseFill)
			bar.Rested:SetRotatesTexture(bar.db.orientation ~= 'HORIZONTAL')
		end
	end
end

function DB:PLAYER_LEVEL_UP()
	local isMaxLevel = UnitLevel('player') == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

	for _, bar in pairs(DB.StatusBars) do
		if bar.db.enable and (bar.db.hideAtMaxLevel ~= nil or bar.db.hideBelowMaxLevel ~= nil) then
			bar:SetShown(not ((bar.db.hideAtMaxLevel and isMaxLevel) or (bar.db.hideBelowMaxLevel and not isMaxLevel)))
		end
	end
end

function DB:CombatCheck(event)
	for _, bar in pairs(DB.StatusBars) do
		if bar.db.enable and bar.db.hideInCombat then
			bar:SetShown(event == 'PLAYER_REGEN_ENABLED')
		end
	end
end

function DB:Initialize()
	DB.Initialized = true
	DB.StatusBars = {}

	DB.db = E.db.databars

	DB:ExperienceBar()
	DB:PetExperienceBar()
	DB:ReputationBar()
	DB:ThreatBar()

	DB:UpdateAll()

	DB:RegisterEvent('PLAYER_LEVEL_UP')
	DB:RegisterEvent('PLAYER_REGEN_ENABLED', 'CombatCheck')
	DB:RegisterEvent('PLAYER_REGEN_DISABLED', 'CombatCheck')
end

E:RegisterModule(DB:GetName())
