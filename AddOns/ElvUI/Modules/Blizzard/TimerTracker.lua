local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local select, unpack = select, unpack
local CreateFrame = CreateFrame

local function SkinIt(bar)
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture()
		elseif region:IsObjectType('FontString') then
			region:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	bar:SetStatusBarTexture(E.media.normTex)
	if E.PixelMode then
		bar:SetStatusBarColor(.31, .31, .31)
	else
		bar:SetStatusBarColor(unpack(E.media.bordercolor))
	end

	if not bar.backdrop then
		bar.backdrop = CreateFrame('Frame', nil, bar, 'BackdropTemplate')
		bar.backdrop:SetFrameLevel(0)
		bar.backdrop:SetTemplate('Transparent')
		bar.backdrop:SetOutside()
		E:RegisterStatusBar(bar)
	end
end
