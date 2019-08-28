
	----------------------------------------------------------------------
	-- 	Leatrix Maps 1.13.25 (26th August 2019, www.leatrix.com)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList = {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "1.13.25"
	LeaMapsLC["RestartReq"] = nil

	-- If client restart is required and has not been done, show warning and quit
	if LeaMapsLC["RestartReq"] then
		local metaVer = GetAddOnMetadata("Leatrix_Maps", "Version")
		if metaVer and metaVer ~= LeaMapsLC["AddonVer"] then
			C_Timer.After(1, function()
				print("NOTICE!|nYou must fully restart your game client before you can use this version of Leatrix Maps.")
			end)
			return
		end
	end

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		----------------------------------------------------------------------
		-- Show coordinates
		----------------------------------------------------------------------

		do

			-- Create cursor coordinates frame
			local cCursor = CreateFrame("Frame", nil, WorldMapFrame)
			cCursor:SetPoint("BOTTOMLEFT", 73, 7)
			cCursor:SetSize(200, 16)
			cCursor.x = cCursor:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			cCursor.x:SetJustifyH"LEFT"
			cCursor.x:SetAllPoints()
			cCursor.x:SetText(L["Cursor"] .. ": 88.8, 88.8")
			cCursor:SetWidth(cCursor.x:GetStringWidth() + 30)

			-- Create player coordinates frame
			local cPlayer = CreateFrame("Frame", nil, WorldMapFrame)
			cPlayer:SetPoint("BOTTOMRIGHT", -46, 7)
			cPlayer:SetSize(200, 16)
			cPlayer.x = cPlayer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			cPlayer.x:SetJustifyH"LEFT"
			cPlayer.x:SetAllPoints()
			cPlayer.x:SetText(L["Player"] .. ": 88.8, 88.8")
			cPlayer:SetWidth(cPlayer.x:GetStringWidth() + 30)

			-- Update timer
			local cPlayerTime = -1

			-- Update function
			cPlayer:SetScript("OnUpdate", function(self, elapsed)
				if cPlayerTime > 0.1 or cPlayerTime == -1 then
					-- Cursor coordinates
					local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					if x and y and x > 0 and y > 0 and MouseIsOver(WorldMapFrame.ScrollContainer) then
						cCursor.x:SetFormattedText("%s: %.1f, %.1f", L["Cursor"], ((floor(x * 1000 + 0.5)) / 10), ((floor(y * 1000 + 0.5)) / 10))
					else
						cCursor.x:SetFormattedText("%s:", L["Cursor"])
					end
				end
				if cPlayerTime > 0.2 or cPlayerTime == -1 then
					-- Player coordinates
					local mapID = C_Map.GetBestMapForUnit("player")
					if not mapID then
						cPlayer.x:SetFormattedText("%s:", L["Player"])
						return
					end
					local position = C_Map.GetPlayerMapPosition(mapID,"player")
					if position and position.x ~= 0 and position.y ~= 0 then
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], position.x * 100, position.y * 100)
					else
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], 0, 0)
					end
					cPlayerTime = 0
				end
				cPlayerTime = cPlayerTime + elapsed
			end)

			-- Function to show or hide coordinates frames
			local function SetupCoords()
				if LeaMapsLC["ShowCoords"] == "On" then
					cCursor:Show(); cPlayer:Show()
				else
					cCursor:Hide(); cPlayer:Hide()
				end
			end

			LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetupCoords)
			SetupCoords()

		end

		----------------------------------------------------------------------
		-- Map zoom
		----------------------------------------------------------------------

		WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
			local x, y = self:GetNormalizedCursorPosition()
			local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
			if delta == 1 then
				if nextZoomInScale > self:GetCanvasScale() then
					self:InstantPanAndZoom(nextZoomInScale, x, y)
				end
			else
				if nextZoomOutScale < self:GetCanvasScale() then
					self:InstantPanAndZoom(nextZoomOutScale, x, y)
				end
			end
		end)

		----------------------------------------------------------------------
		-- Remember zoom level
		----------------------------------------------------------------------

		do

			local lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
			local lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
			local lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
			local lastMapID = WorldMapFrame.mapID

			hooksecurefunc("ToggleWorldMap", function()
				if LeaMapsLC["RememberZoom"] == "On" then
					if not WorldMapFrame:IsShown() then
						lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
						lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
						lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
						lastMapID = WorldMapFrame.mapID
					else
						if WorldMapFrame.mapID == lastMapID then
							WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, lastHorizontal, lastVertical)
							WorldMapFrame.ScrollContainer:SetPanTarget(lastHorizontal, lastVertical)
							WorldMapFrame.ScrollContainer:Hide(); WorldMapFrame.ScrollContainer:Show()
						end
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Map position
		----------------------------------------------------------------------

		-- Remove frame management
		UIPanelWindows["WorldMapFrame"] = nil
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
		WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
		WorldMapFrame:SetIgnoreParentScale(false)
		WorldMapFrame.BlackoutFrame:Hide()
		WorldMapFrame:SetFrameStrata("MEDIUM")
		WorldMapFrame.BorderFrame:SetFrameStrata("LOW")
		WorldMapFrame.IsMaximized = function() return false end
		WorldMapFrame.HandleUserActionToggleSelf = function()
			if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
		end

		-- Close map with Escape key
		table.insert(UISpecialFrames, "WorldMapFrame")

		-- Enable movement
		WorldMapFrame:SetMovable(true)
		WorldMapFrame:RegisterForDrag("LeftButton")

		WorldMapFrame:SetScript("OnDragStart", function()
			WorldMapFrame:StartMoving()
		end)

		WorldMapFrame:SetScript("OnDragStop", function()
			WorldMapFrame:StopMovingOrSizing()
			WorldMapFrame:SetUserPlaced(false)
			-- Save map frame position
			LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
		end)

		-- Set position on startup
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])

		----------------------------------------------------------------------
		-- Rescale map frame
		----------------------------------------------------------------------

		do

			-- Create scale frame
			local scaleFrame = LeaMapsLC:CreatePanel("Rescale Map", "scaleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(scaleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeWD(scaleFrame, "Map frame scale", 16, -92)
			LeaMapsLC:MakeSL(scaleFrame, "MapScale", "Scale", "", 0.5, 2, 0.05, 36, -142, "%.1f")

			-- Function to set map frame scale
			local function SetMapScale()
				LeaMapsCB["MapScale"].f:SetFormattedText("%.0f%%", LeaMapsLC["MapScale"] * 100)
				if LeaMapsLC["RescaleMap"] == "On" then
					WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				else
					WorldMapFrame:SetScale(1)
				end
			end

			-- Give function file level scope
			LeaMapsLC.SetMapScale = SetMapScale

			-- Replace function to account for frame scale
			WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
				local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
				local s = WorldMapFrame:GetScale() * UIParent:GetEffectiveScale()
				return x/s, y/s
			end

			-- Set scale properties when controls are changed and on startup
			LeaMapsCB["RescaleMap"]:HookScript("OnClick", SetMapScale)
			LeaMapsCB["MapScale"]:HookScript("OnValueChanged", SetMapScale)
			SetMapScale()

			-- Back to Main Menu button click
			scaleFrame.b:HookScript("OnClick", function()
				scaleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			scaleFrame.r:HookScript("OnClick", function()
				LeaMapsLC["MapScale"] = 0.9
				SetMapScale()
				scaleFrame:Hide(); scaleFrame:Show()
			end)

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["RescaleMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["MapScale"] = 0.9
					SetMapScale()
					if scaleFrame:IsShown() then scaleFrame:Hide(); scaleFrame:Show(); end
				else
					scaleFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Fade map while moving
		----------------------------------------------------------------------

		do

			-- Create fade frame
			local fadeFrame = LeaMapsLC:CreatePanel("Fade Frame", "fadeFrame")

			-- Add controls
			LeaMapsLC:MakeTx(fadeFrame, "Settings", 16, -72)
			LeaMapsLC:MakeWD(fadeFrame, "Map opacity while moving", 16, -92)
			LeaMapsLC:MakeSL(fadeFrame, "FadeLevel", "Opacity", "", 0.2, 1, 0.1, 36, -142, "%.1f")

			-- Function to set fade level
			local function SetFadeLevel()
				LeaMapsCB["FadeLevel"].f:SetFormattedText("%.0f%%", LeaMapsLC["FadeLevel"] * 100)
				if LeaMapsLC["FadeMap"] == "On" then
					PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, LeaMapsLC["FadeLevel"], 1.0, 0.5)
				else
					PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, 1, 1.0, 0.5)
				end
			end

			-- Set fade properties when controls are changed and on startup
			LeaMapsCB["FadeMap"]:HookScript("OnClick", SetFadeLevel)
			LeaMapsCB["FadeLevel"]:HookScript("OnValueChanged", SetFadeLevel)
			SetFadeLevel()

			-- Back to Main Menu button click
			fadeFrame.b:HookScript("OnClick", function()
				fadeFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			fadeFrame.r:HookScript("OnClick", function()
				LeaMapsLC["FadeLevel"] = 0.5
				SetFadeLevel()
				fadeFrame:Hide(); fadeFrame:Show()
			end)

			-- Show fade configuration panel when configuration button is clicked
			LeaMapsCB["FadeMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["FadeLevel"] = 1.0
					SetFadeLevel()
					if fadeFrame:IsShown() then fadeFrame:Hide(); fadeFrame:Show(); end
				else
					fadeFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show dungeon location icons
		----------------------------------------------------------------------

		do

			local dnTex, rdTex = "Dungeon", "Raid"
			local pATex, pHTex, pNTex = "TaxiNode_Continent_Alliance", "TaxiNode_Continent_Horde", "TaxiNode_Continent_Neutral"
			local chTex = "ChallengeMode-icon-chest"

			local PinData = {

				-- Eastern Kingdoms
				[1418] =  --[[Badlands]] {{44.6, 12.1, L["Uldaman"], L["Dungeon"], dnTex},},
				[1420] =  --[[Tirisfal Glades]] {{82.6, 33.8, L["Scarlet Monastery"], L["Dungeon"], dnTex},},
				[1421] =  --[[Silverpine Forest]] {{44.8, 67.8, L["Shadowfang Keep"], L["Dungeon"], dnTex},},
				[1422] =  --[[Western Plaguelands]] {{69.7, 73.2, L["Scholomance"], L["Dungeon"], dnTex},},
				[1423] =  --[[Eastern Plaguelands]] {{31.3, 15.7, L["Stratholme (Main Entrance)"], L["Dungeon"], dnTex}, {47.9, 23.9, L["Stratholme (Side Entrance)"], L["Dungeon"], dnTex}, --[[{28.9, 11.7, L["Naxxramas"], L["Raid"], rdTex},]]},
				[1426] =  --[[Dun Morogh]] {{24.3, 39.8, L["Gnomeregan"], L["Dungeon"], dnTex},},
				[1427] =  --[[Searing Gorge]] {{34.8, 85.3, L["Blackrock Mountain"], L["Blackrock Depths"] .. ", " .. L["Lower Blackrock Spire"] .. ", " .. L["Upper Blackrock Spire"] .. ", " .. L["Molten Core"] --[[.. ", " .. L["Blackwing Lair"] ]], dnTex},},
				[1428] =  --[[Burning Steppes]] {{29.4, 38.3, L["Blackrock Mountain"], L["Blackrock Depths"] .. ", " .. L["Lower Blackrock Spire"] .. ", " .. L["Upper Blackrock Spire"] .. ", " .. L["Molten Core"] --[[.. ", " .. L["Blackwing Lair"] ]], dnTex},},
				--[1434] =  --[[Stranglethorn Vale]] {{53.9, 17.6, L["Zul'Gurub"], L["Raid"], rdTex},},
				[1435] =  --[[Swamp of Sorrows]] {{69.9, 53.6, L["Temple of Atal'Hakkar"], L["Dungeon"], dnTex},},
				[1436] =  --[[Westfall]] {{42.5, 71.7, L["The Deadmines"], L["Dungeon"], dnTex},},
				[1453] =  --[[Stormwind City]] {{42.3, 59.0, L["The Stockade"], L["Dungeon"], dnTex},},

				-- Kalimdor
				[1413] =  --[[The Barrens]] {{46.0, 36.4, L["Wailing Caverns"], L["Dungeon"], dnTex}, {42.9, 90.2, L["Razorfen Kraul"], L["Dungeon"], dnTex}, {49.0, 93.9, L["Razorfen Downs"], L["Dungeon"], dnTex},},
				[1440] =  --[[Ashenvale]] {{14.5, 14.2, L["Blackfathom Deeps"], L["Dungeon"], dnTex},},
				[1443] =  --[[Maraudon]] {{29.1, 62.5, L["Maraudon"], L["Dungeon"], dnTex},},
				-- [1444] =  --[[Feralas]] {{58.9, 41.5, L["Dire Maul"], L["Dungeon"], dnTex},},
				[1445] =  --[[Dustwallow Marsh]] {{52.6, 76.8, L["Onyxia's Lair"], L["Raid"], rdTex},},
				[1446] =  --[[Tanaris]] {{38.7, 20.0, L["Zul'Farrak"], L["Dungeon"], dnTex},},
				--[1451] =  --[[Silithus]] {{28.6, 92.4, L["Ahn'Qiraj"], L["Ruins of Ahn'Qiraj"] .. ", " .. L["Temple of Ahn'Qiraj"], rdTex},},
				[1454] =  --[[Orgrimmar]] {{52.6, 49.0, L["Ragefire Chasm"], L["Dungeon"], dnTex},},

			}

			local LeaMix = CreateFromMixins(MapCanvasDataProviderMixin)

			function LeaMix:RefreshAllData()

				-- Remove all pins created by Leatrix Maps
				self:GetMap():RemoveAllPinsByTemplate("LeaMapsGlobalPinTemplate")

				-- Show new pins if option is enabled
				if LeaMapsLC["ShowIcons"] == "On" then

					-- Make new pins
					local pMapID = WorldMapFrame.mapID
					if PinData[pMapID] then
						local count = #PinData[pMapID]
						for i = 1, count do

							-- Do nothing if pinInfo has no entry for zone we are looking at
							local pinInfo = PinData[pMapID][i]
							if not pinInfo then return nil end

							-- Get POI if any quest requirements have been met
							if not pinInfo[6] or pinInfo[6] and not pinInfo[7] and IsQuestFlaggedCompleted(pinInfo[6]) or pinInfo[6] and pinInfo[7] and IsQuestFlaggedCompleted(pinInfo[6]) and not IsQuestFlaggedCompleted(pinInfo[7]) then
								if playerFaction == "Alliance" and pinInfo[5] ~= pHTex or playerFaction == "Horde" and pinInfo[5] ~= pATex then
									local myPOI = {}
									myPOI["position"] = CreateVector2D(pinInfo[1] / 100, pinInfo[2] / 100)
									myPOI["name"] = pinInfo[3]
									myPOI["description"] = pinInfo[4]
									myPOI["atlasName"] = pinInfo[5]
									self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
								end
							end
						end
					end

				end

			end

			LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
			end

			WorldMapFrame:AddDataProvider(LeaMix)

			-- Toggle icons when option is clicked
			LeaMapsCB["ShowIcons"]:HookScript("OnClick", function() LeaMix:RefreshAllData() end)

		end

		----------------------------------------------------------------------
		-- Reveal unexplored areas
		----------------------------------------------------------------------

		-- Create table to store revealed overlays
		local overlayTextures = {}

		-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
		local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)
			overlayTextures = {}
			local mapID = WorldMapFrame.mapID; if not mapID then return end
			local artID = C_Map.GetMapArtID(mapID); if not artID or not Leatrix_Maps["Reveal"][artID] then return end
			local LeaMapsZone = Leatrix_Maps["Reveal"][artID]

			-- Store already explored tiles in a table so they can be ignored
			local TileExists = {}
			local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
			if exploredMapTextures then
				for i, exploredTextureInfo in ipairs(exploredMapTextures) do
					local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
					TileExists[key] = true
				end
			end

			-- Get the sizes
			pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
			local layers = C_Map.GetMapArtLayers(mapID)
			local layerInfo = layers and layers[pin.layerIndex]
			if not layerInfo then return end
			local TILE_SIZE_WIDTH = layerInfo.tileWidth
			local TILE_SIZE_HEIGHT = layerInfo.tileHeight

			-- Show textures if they are in database and have not been explored
			for key, files in pairs(LeaMapsZone) do
				if not TileExists[key] then
					local width, height, offsetX, offsetY = strsplit(":", key)
					local fileDataIDs = { strsplit(",", files) }
					local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
					local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
					local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
					for j = 1, numTexturesTall do
						if ( j < numTexturesTall ) then
							texturePixelHeight = TILE_SIZE_HEIGHT
							textureFileHeight = TILE_SIZE_HEIGHT
						else
							texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
							if ( texturePixelHeight == 0 ) then
								texturePixelHeight = TILE_SIZE_HEIGHT
							end
							textureFileHeight = 16
							while(textureFileHeight < texturePixelHeight) do
								textureFileHeight = textureFileHeight * 2
							end
						end
						for k = 1, numTexturesWide do
							local texture = pin.overlayTexturePool:Acquire()
							if ( k < numTexturesWide ) then
								texturePixelWidth = TILE_SIZE_WIDTH
								textureFileWidth = TILE_SIZE_WIDTH
							else
								texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
								if ( texturePixelWidth == 0 ) then
									texturePixelWidth = TILE_SIZE_WIDTH
								end
								textureFileWidth = 16
								while(textureFileWidth < texturePixelWidth) do
									textureFileWidth = textureFileWidth * 2
								end
							end
							texture:SetSize(texturePixelWidth, texturePixelHeight)
							texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
							texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
							texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
							texture:SetDrawLayer("ARTWORK", -1)
							if LeaMapsLC["RevealMap"] == "On" then
								texture:Show()
								if fullUpdate then
									pin.textureLoadGroup:AddTexture(texture)
								end
							else
								texture:Hide()
							end
							if LeaMapsLC["RevTint"] == "On" then
								texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
							end
							tinsert(overlayTextures, texture)
						end
					end
				end
			end
		end

		-- Reset texture color and alpha
		local function TexturePool_ResetVertexColor(pool, texture)
			texture:SetVertexColor(1, 1, 1)
			texture:SetAlpha(1)
			return TexturePool_HideAndClearAnchors(pool, texture)
		end

		-- Show overlays on startup
		for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
			hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
			pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
		end

		-- Toggle overlays if reveal option is clicked
		LeaMapsCB["RevealMap"]:HookScript("OnClick", function()
			if LeaMapsLC["RevealMap"] == "On" then 
				for i = 1, #overlayTextures  do
					overlayTextures[i]:Show()
				end
			else
				for i = 1, #overlayTextures  do
					overlayTextures[i]:Hide()
				end	
			end
		end)

		-- Create tint frame
		local tintFrame = LeaMapsLC:CreatePanel("Reveal Map", "tintFrame")

		-- Add controls
		LeaMapsLC:MakeTx(tintFrame, "Settings", 16, -72)
		LeaMapsLC:MakeCB(tintFrame, "RevTint", "Tint unexplored areas", 16, -92, false)
		LeaMapsLC:MakeSL(tintFrame, "tintRed", "Red", "", 0, 1, 0.1, 36, -142, "%.1f")
		LeaMapsLC:MakeSL(tintFrame, "tintGreen", "Green", "", 0, 1, 0.1, 36, -192, "%.1f")
		LeaMapsLC:MakeSL(tintFrame, "tintBlue", "Blue", "", 0, 1, 0.1, 36, -242, "%.1f")
		LeaMapsLC:MakeSL(tintFrame, "tintAlpha", "Transparency", "", 0.1, 1, 0.1, 196, -242, "%.1f")

		-- Add preview color block
		tintFrame.preview = tintFrame:CreateTexture(nil, "ARTWORK")
		tintFrame.preview:SetSize(50, 50)
		tintFrame.preview:SetPoint("TOP", LeaMapsCB["tintAlpha"], "TOP", 0, 90)

		local prvTitle = LeaMapsLC:MakeWD(tintFrame, "Preview", 196, -132)
		prvTitle:ClearAllPoints()
		prvTitle:SetPoint("TOP", tintFrame.preview, "TOP", 0, 20)

		-- Function to set tint color
		local function SetTintCol()
			tintFrame.preview:SetColorTexture(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
			-- Set slider values
			LeaMapsCB["tintRed"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintRed"] * 100)
			LeaMapsCB["tintGreen"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintGreen"] * 100)
			LeaMapsCB["tintBlue"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintBlue"] * 100)
			LeaMapsCB["tintAlpha"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintAlpha"] * 100)
			-- Set tint
			if LeaMapsLC["RevTint"] == "On" then
				-- Enable tint
				for i = 1, #overlayTextures  do
					overlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
				end
				-- Enable controls
				LeaMapsCB["tintRed"]:Enable(); LeaMapsCB["tintRed"]:SetAlpha(1.0)
				LeaMapsCB["tintGreen"]:Enable(); LeaMapsCB["tintGreen"]:SetAlpha(1.0)
				LeaMapsCB["tintBlue"]:Enable(); LeaMapsCB["tintBlue"]:SetAlpha(1.0)
				LeaMapsCB["tintAlpha"]:Enable(); LeaMapsCB["tintAlpha"]:SetAlpha(1.0)
				prvTitle:SetAlpha(1.0); tintFrame.preview:SetAlpha(1.0)
			else
				-- Disable tint
				for i = 1, #overlayTextures  do
					overlayTextures[i]:SetVertexColor(1, 1, 1)
					overlayTextures[i]:SetAlpha(1.0)
				end
				-- Disable controls
				LeaMapsCB["tintRed"]:Disable(); LeaMapsCB["tintRed"]:SetAlpha(0.3)
				LeaMapsCB["tintGreen"]:Disable(); LeaMapsCB["tintGreen"]:SetAlpha(0.3)
				LeaMapsCB["tintBlue"]:Disable(); LeaMapsCB["tintBlue"]:SetAlpha(0.3)
				LeaMapsCB["tintAlpha"]:Disable(); LeaMapsCB["tintAlpha"]:SetAlpha(0.3)
				prvTitle:SetAlpha(0.3); tintFrame.preview:SetAlpha(0.3)
			end
		end

		-- Set tint properties when controls are changed and on startup
		LeaMapsCB["RevTint"]:HookScript("OnClick", SetTintCol)
		LeaMapsCB["tintRed"]:HookScript("OnValueChanged", SetTintCol)
		LeaMapsCB["tintGreen"]:HookScript("OnValueChanged", SetTintCol)
		LeaMapsCB["tintBlue"]:HookScript("OnValueChanged", SetTintCol)
		LeaMapsCB["tintAlpha"]:HookScript("OnValueChanged", SetTintCol)
		SetTintCol()

		-- Back to Main Menu button click
		tintFrame.b:HookScript("OnClick", function()
			tintFrame:Hide()
			LeaMapsLC["PageF"]:Show()
		end)

		-- Reset button click
		tintFrame.r:HookScript("OnClick", function()
			LeaMapsLC["RevTint"] = "On"
			LeaMapsLC["tintRed"] = 0.6
			LeaMapsLC["tintGreen"] = 0.6
			LeaMapsLC["tintBlue"] = 1
			LeaMapsLC["tintAlpha"] = 1
			SetTintCol()
			tintFrame:Hide(); tintFrame:Show()
		end)

		-- Show tint configuration panel when configuration button is clicked
		LeaMapsCB["RevTintBtn"]:HookScript("OnClick", function()
			if IsShiftKeyDown() and IsControlKeyDown() then
				-- Preset profile
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1
				LeaMapsLC["tintAlpha"] = 1
				SetTintCol()
				if tintFrame:IsShown() then tintFrame:Hide(); tintFrame:Show(); end
			else
				tintFrame:Show()
				LeaMapsLC["PageF"]:Hide()
			end
		end)

		----------------------------------------------------------------------
		-- Show memory usage
		----------------------------------------------------------------------

		do

			-- Show memory usage stat
			local function ShowMemoryUsage(frame, anchor, x, y)

				-- Create frame
				local memframe = CreateFrame("FRAME", nil, frame)
				memframe:ClearAllPoints()
				memframe:SetPoint(anchor, x, y)
				memframe:SetWidth(100)
				memframe:SetHeight(20)

				-- Create labels
				local pretext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				pretext:SetPoint("TOPLEFT", 0, 0)
				pretext:SetText(L["Memory Usage"])

				local memtext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memtext:SetPoint("TOPLEFT", 0, 0 - 30)

				-- Create stat
				local memstat = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memstat:SetPoint("BOTTOMLEFT", memtext, "BOTTOMRIGHT")
				memstat:SetText("(calculating...)")

				-- Create update script
				local memtime = -1
				memframe:SetScript("OnUpdate", function(self, elapsed)
					if memtime > 2 or memtime == -1 then
						UpdateAddOnMemoryUsage()
						memtext = GetAddOnMemoryUsage("Leatrix_Maps")
						memtext = math.floor(memtext + .5) .. " KB"
						memstat:SetText(memtext)
						memtime = 0
					end
					memtime = memtime + elapsed
				end)

			end

			ShowMemoryUsage(LeaMapsLC["PageF"], "TOPLEFT", 16, -242)

		end

		----------------------------------------------------------------------
		-- Final code
		----------------------------------------------------------------------

		-- Release memory
		LeaMapsLC.MainFunc = nil

	end

	----------------------------------------------------------------------
	-- L10: Functions
	----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaMapsLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)  
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1)
		end
	end

	-- Create a configuration panel
	function LeaMapsLC:CreatePanel(title, globref)

		-- Create the panel
		local Side = CreateFrame("Frame", nil, UIParent)

		-- Make it a system frame
		_G["LeaMapsGlobalPanel_" .. globref] = Side
		table.insert(UISpecialFrames, "LeaMapsGlobalPanel_" .. globref)

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide()
		Side:SetSize(370, 340)
		Side:SetClampedToScreen(true)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")
		Side:SetFrameLevel(20)

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button
		Side.c = CreateFrame("Button", nil, Side, "UIPanelCloseButton") 
		Side.c:SetSize(30, 30)
		Side.c:SetPoint("TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaMapsLC:CreateButton("ResetButton", Side, "Reset", "BOTTOMLEFT", 16, 10, 25)
		Side.b = LeaMapsLC:CreateButton("BackButton", Side, "Back to Main Menu", "BOTTOMRIGHT", -16, 10, 25)

		-- Set textures
		LeaMapsLC:CreateBar("FootTexture", Side, 370, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaMapsLC:CreateBar("MainTexture", Side, 370, 293, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing()
			Side:SetUserPlaced(false)
			-- Save panel position
			LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16)
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32)
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8)
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP')
		Side.v:SetText(L["Configuration Panel"])
	
		-- Prevent options panel from showing while side panel is showing
		LeaMapsLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaMapsLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Hide configuration panels
	function LeaMapsLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Find out if Leatrix Maps is showing (main panel or config panel)
	function LeaMapsLC:IsMapsShowing()
		if LeaMapsLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaMapsLC:LoadVarChk(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "On" or LeaMapsDB[var] == "Off" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaMapsLC:LoadVarNum(var, def, valmin, valmax)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "number" and LeaMapsDB[var] >= valmin and LeaMapsDB[var] <= valmax then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaMapsLC:LoadVarAnc(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "CENTER" or LeaMapsDB[var] == "TOP" or LeaMapsDB[var] == "BOTTOM" or LeaMapsDB[var] == "LEFT" or LeaMapsDB[var] == "RIGHT" or LeaMapsDB[var] == "TOPLEFT" or LeaMapsDB[var] == "TOPRIGHT" or LeaMapsDB[var] == "BOTTOMLEFT" or LeaMapsDB[var] == "BOTTOMRIGHT" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Print text
	function LeaMapsLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Function to set lock state for configuration buttons
	function LeaMapsLC:LockOption(option, item)
		if LeaMapsLC[option] == "Off" then
			LeaMapsCB[item]:Disable()
			LeaMapsCB[item]:SetAlpha(0.3)
		else
			LeaMapsCB[item]:Enable()
			LeaMapsCB[item]:SetAlpha(1.0)
		end
	end

	-- Set lock state for configuration buttons
	function LeaMapsLC:SetDim()
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn")			-- Reveal map
		LeaMapsLC:LockOption("RescaleMap", "RescaleMapBtn")		-- Rescale map frame
		LeaMapsLC:LockOption("FadeMap", "FadeMapBtn")			-- Fade map while moving
	end

	-- Create a standard button
	function LeaMapsLC:CreateButton(name, frame, label, anchor, x, y, height)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaMapsCB[name] = mbtn
		mbtn:SetHeight(height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring and set button width based on it
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)

		-- Set skinned button textures
		mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

		-- Hide the default textures
		mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		return mbtn
	end

	-- Create a subheading
	function LeaMapsLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		return text
	end

	-- Create text
	function LeaMapsLC:MakeWD(frame, title, x, y, width)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetJustifyH("LEFT")
		text:SetText(L[title])
		if width then text:SetWidth(width) end
		return text
	end

	-- Create a checkbox control
	function LeaMapsLC:MakeCB(parent, field, caption, x, y, reload)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaMapsCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 24, 0)
		if reload then
			Cbox.f:SetText(L[caption] .. "*")
		else
			Cbox.f:SetText(L[caption])
		end

		-- Set label parameters
		Cbox.f:SetJustifyH("LEFT")
		Cbox.f:SetWordWrap(false)

		-- Set maximum label width
		if Cbox.f:GetWidth() > 292 then
			Cbox.f:SetWidth(292)
		end

		-- Set checkbox click width
		if Cbox.f:GetStringWidth() > 292 then
			Cbox:SetHitRectInsets(0, -272, 0, 0)
		else
			Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaMapsLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaMapsLC[field] = "On"
			else
				LeaMapsLC[field] = "Off"
			end
			LeaMapsLC:SetDim() -- Lock invalid options
		end)
	end

	-- Create configuration button
	function LeaMapsLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaMapsCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50);
	end

	-- Create a slider control
	function LeaMapsLC:MakeSL(frame, field, label, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", "LeaMapsGlobalSlider" .. field, frame, "OptionssliderTemplate")
		LeaMapsCB[field] = Slider
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0)

		-- Remove slider text
		_G[Slider:GetName().."Low"]:SetText('')
		_G[Slider:GetName().."High"]:SetText('')

		-- Set label
		_G[Slider:GetName().."Text"]:SetText(L[label])

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaMapsLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaMapsLC[field])
		end)

	end

	----------------------------------------------------------------------
	-- Stop error frame
	----------------------------------------------------------------------

	-- Create stop error frame
	local stopFrame = CreateFrame("FRAME", nil, UIParent)
	stopFrame:ClearAllPoints()
	stopFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	stopFrame:SetSize(370, 150)
	stopFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	stopFrame:SetFrameLevel(500)
	stopFrame:SetClampedToScreen(true)
	stopFrame:EnableMouse(true)
	stopFrame:SetMovable(true)
	stopFrame:Hide()
	stopFrame:RegisterForDrag("LeftButton")
	stopFrame:SetScript("OnDragStart", stopFrame.StartMoving)
	stopFrame:SetScript("OnDragStop", function()
		stopFrame:StopMovingOrSizing()
		stopFrame:SetUserPlaced(false)
	end)

	-- Add background color
	stopFrame.t = stopFrame:CreateTexture(nil, "BACKGROUND")
	stopFrame.t:SetAllPoints()
	stopFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	stopFrame.mt = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.mt:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.mt:SetSize(370, 103)
	stopFrame.mt:SetPoint("TOPRIGHT")
	stopFrame.mt:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	stopFrame.ft = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.ft:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.ft:SetSize(370, 48)
	stopFrame.ft:SetPoint("BOTTOM")
	stopFrame.ft:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	LeaMapsLC:MakeTx(stopFrame, "Leatrix Maps", 16, -12)
	LeaMapsLC:MakeWD(stopFrame, "A stop error has occurred but no need to worry.  It can happen from time to time.  Click the reload button to resolve it.", 16, -32, 338)

	-- Add reload UI Button
	local stopRelBtn = LeaMapsLC:CreateButton("StopReloadButton", stopFrame, "Reload", "BOTTOMRIGHT", -16, 10, 25)
	stopRelBtn:SetScript("OnClick", ReloadUI)
	stopRelBtn.f = stopRelBtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	stopRelBtn.f:SetHeight(32)
	stopRelBtn.f:SetPoint('RIGHT', stopRelBtn, 'LEFT', -10, 0)
	stopRelBtn.f:SetText(L["Your UI needs to be reloaded."])
	stopRelBtn:Hide(); stopRelBtn:Show()

	-- Add close Button
	local stopFrameClose = CreateFrame("Button", nil, stopFrame, "UIPanelCloseButton") 
	stopFrameClose:SetSize(30, 30)
	stopFrameClose:SetPoint("TOPRIGHT", 0, 0)

	----------------------------------------------------------------------
	-- L20: Commands
	----------------------------------------------------------------------

	-- Slash command function
	local function SlashFunc(str)
		local str = string.lower(str)
		if str and str ~= "" then
			-- Traverse parameters
			if str == "reset" then
				-- Reset the configuration panel position
				LeaMapsLC["MainPanelA"], LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaMapsLC["PageF"]:IsShown() then LeaMapsLC["PageF"]:Hide() LeaMapsLC["PageF"]:Show() end
				return
			elseif str == "wipe" then
				-- Wipe all settings
				wipe(LeaMapsDB)
				LeaMapsLC["NoSaveSettings"] = true
				ReloadUI()
			elseif str == "admin" then
				-- Preset profile (reload required)
				wipe(LeaMapsDB)
				LeaMapsLC["RevealMap"] = "On"
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1.0
				LeaMapsLC["tintAlpha"] = 1.0
				LeaMapsLC["ShowIcons"] = "On"
				LeaMapsLC["RescaleMap"] = "On"
				LeaMapsLC["MapScale"] = 0.9
				LeaMapsLC["FadeMap"] = "Off"
				LeaMapsLC["FadeLevel"] = 0.5
				LeaMapsLC["RememberZoom"] = "On"
				LeaMapsLC["ShowCoords"] = "On"
				LeaMapsLC["MapPosA"] = "CENTER"
				LeaMapsLC["MapPosR"] = "CENTER"
				LeaMapsLC["MapPosX"] = 0
				LeaMapsLC["MapPosY"] = 0
				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Classic"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
				LeaMapsLC:Print("/ltm reset - Reset the panel position.")
				LeaMapsLC:Print("/ltm wipe - Wipe all settings and reload.")
				LeaMapsLC:Print("/ltm help - Show this information.")
				return
			else
				-- Invalid command entered
				LeaMapsLC:Print("Invalid command.  Enter /ltm help for help.")
				return
			end
		else
			-- Prevent options panel from showing if a game options panel is showing
			if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
			-- Toggle the options panel
			if LeaMapsLC:IsMapsShowing() then
				LeaMapsLC["PageF"]:Hide()
				LeaMapsLC:HideConfigPanels()
			else
				LeaMapsLC["PageF"]:Show()
			end
		end
	end

	-- Add slash commands
	_G.SLASH_Leatrix_Maps1 = "/ltm"
	_G.SLASH_Leatrix_Maps2 = "/leamaps" 
	SlashCmdList["Leatrix_Maps"] = function(self)
		-- Run slash command function
		SlashFunc(self)
		-- Redirect tainted variables
		RunScript('ACTIVE_CHAT_EDIT_BOX = ACTIVE_CHAT_EDIT_BOX')
		RunScript('LAST_ACTIVE_CHAT_EDIT_BOX = LAST_ACTIVE_CHAT_EDIT_BOX')
	end

	----------------------------------------------------------------------
	-- L30: Events
	----------------------------------------------------------------------

	-- Create event frame
	local eFrame = CreateFrame("FRAME")
	eFrame:RegisterEvent("ADDON_LOADED")
	eFrame:RegisterEvent("PLAYER_LOGIN")
	eFrame:RegisterEvent("PLAYER_LOGOUT")
	eFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	eFrame:SetScript("OnEvent", function(self, event, arg1)

		if event == "ADDON_LOADED" and arg1 == "Leatrix_Maps" then
			-- Load settings or set defaults
			LeaMapsLC:LoadVarChk("RevealMap", "On")						-- Reveal unexplored areas
			LeaMapsLC:LoadVarChk("RevTint", "On")						-- Tint revealed unexplored areas
			LeaMapsLC:LoadVarNum("tintRed", 0.6, 0, 1)					-- Tint red
			LeaMapsLC:LoadVarNum("tintGreen", 0.6, 0, 1)				-- Tint green
			LeaMapsLC:LoadVarNum("tintBlue", 1, 0, 1)					-- Tint blue
			LeaMapsLC:LoadVarNum("tintAlpha", 1, 0, 1)					-- Tint transparency
			LeaMapsLC:LoadVarChk("ShowIcons", "On")						-- Show dungeon location icons
			LeaMapsLC:LoadVarChk("RescaleMap", "On")					-- Rescale map frame
			LeaMapsLC:LoadVarNum("MapScale", 0.9, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarChk("FadeMap", "Off")						-- Fade map while moving
			LeaMapsLC:LoadVarNum("FadeLevel", 0.5, 0.2, 1)				-- Fade map level
			LeaMapsLC:LoadVarChk("RememberZoom", "On")					-- Remember zoom level
			LeaMapsLC:LoadVarChk("ShowCoords", "On")					-- Show coordinates
			LeaMapsLC:LoadVarAnc("MapPosA", "CENTER")					-- Map anchor
			LeaMapsLC:LoadVarAnc("MapPosR", "CENTER")					-- Map relative
			LeaMapsLC:LoadVarNum("MapPosX", 0, -5000, 5000)				-- Map X axis
			LeaMapsLC:LoadVarNum("MapPosY", 0, -5000, 5000)				-- Map Y axis
			LeaMapsLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
			LeaMapsLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
			LeaMapsLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
			LeaMapsLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis
			LeaMapsLC:SetDim()

		elseif event == "PLAYER_LOGIN" then
			-- Run main function
			LeaMapsLC:MainFunc()

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Save settings
			LeaMapsDB["RevealMap"] = LeaMapsLC["RevealMap"]
			LeaMapsDB["RevTint"] = LeaMapsLC["RevTint"]
			LeaMapsDB["tintRed"] = LeaMapsLC["tintRed"]
			LeaMapsDB["tintGreen"] = LeaMapsLC["tintGreen"]
			LeaMapsDB["tintBlue"] = LeaMapsLC["tintBlue"]
			LeaMapsDB["tintAlpha"] = LeaMapsLC["tintAlpha"]
			LeaMapsDB["ShowIcons"] = LeaMapsLC["ShowIcons"]
			LeaMapsDB["RescaleMap"] = LeaMapsLC["RescaleMap"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["FadeMap"] = LeaMapsLC["FadeMap"]
			LeaMapsDB["FadeLevel"] = LeaMapsLC["FadeLevel"]
			LeaMapsDB["RememberZoom"] = LeaMapsLC["RememberZoom"]
			LeaMapsDB["ShowCoords"] = LeaMapsLC["ShowCoords"]
			LeaMapsDB["MapPosA"] = LeaMapsLC["MapPosA"]
			LeaMapsDB["MapPosR"] = LeaMapsLC["MapPosR"]
			LeaMapsDB["MapPosX"] = LeaMapsLC["MapPosX"]
			LeaMapsDB["MapPosY"] = LeaMapsLC["MapPosY"]
			LeaMapsDB["MainPanelA"] = LeaMapsLC["MainPanelA"]
			LeaMapsDB["MainPanelR"] = LeaMapsLC["MainPanelR"]
			LeaMapsDB["MainPanelX"] = LeaMapsLC["MainPanelX"]
			LeaMapsDB["MainPanelY"] = LeaMapsLC["MainPanelY"]

		elseif event == "ADDON_ACTION_FORBIDDEN" and arg1 == "Leatrix_Maps" then
			-- Stop error has occured
			StaticPopup_Hide("ADDON_ACTION_FORBIDDEN")
			stopFrame:Show()

		end
	end)

	----------------------------------------------------------------------
	-- L40: Panel
	----------------------------------------------------------------------

	-- Create the panel
	local PageF = CreateFrame("Frame", nil, UIParent)

	-- Make it a system frame
	_G["LeaMapsGlobalPanel"] = PageF
	table.insert(UISpecialFrames, "LeaMapsGlobalPanel")

	-- Set frame parameters
	LeaMapsLC["PageF"] = PageF
	PageF:SetSize(370, 340)
	PageF:Hide()
	PageF:SetFrameStrata("FULLSCREEN_DIALOG")
	PageF:SetFrameLevel(20)
	PageF:SetClampedToScreen(true)
	PageF:EnableMouse(true)
	PageF:SetMovable(true)
	PageF:RegisterForDrag("LeftButton")
	PageF:SetScript("OnDragStart", PageF.StartMoving)
	PageF:SetScript("OnDragStop", function()
		PageF:StopMovingOrSizing()
		PageF:SetUserPlaced(false)
		-- Save panel position
		LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = PageF:GetPoint()
	end)

	-- Add background color
	PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
	PageF.t:SetAllPoints()
	PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	local MainTexture = PageF:CreateTexture(nil, "BORDER")
	MainTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	MainTexture:SetSize(370, 293)
	MainTexture:SetPoint("TOPRIGHT")
	MainTexture:SetVertexColor(0.7, 0.7, 0.7, 0.7)
	MainTexture:SetTexCoord(0.09, 1, 0, 1)

	local FootTexture = PageF:CreateTexture(nil, "BORDER")
	FootTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	FootTexture:SetSize(370, 48)
	FootTexture:SetPoint("BOTTOM")
	FootTexture:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	-- Set panel position when shown
	PageF:SetScript("OnShow", function()
		PageF:ClearAllPoints()
		PageF:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
	end)

	-- Add main title
	PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	PageF.mt:SetPoint('TOPLEFT', 16, -16)
	PageF.mt:SetText("Leatrix Maps")

	-- Add version text
	PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	PageF.v:SetHeight(32)
	PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8)
	PageF.v:SetPoint('RIGHT', PageF, -32, 0)
	PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP')
	PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Classic"] .. " " .. LeaMapsLC["AddonVer"])

	-- Add close Button
	local CloseB = CreateFrame("Button", nil, PageF, "UIPanelCloseButton") 
	CloseB:SetSize(30, 30)
	CloseB:SetPoint("TOPRIGHT", 0, 0)

	-- Add content
	LeaMapsLC:MakeTx(PageF, "Settings", 16, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Reveal unexplored areas of the map", 16, -92, false)
	LeaMapsLC:MakeCB(PageF, "ShowIcons", "Show dungeon location icons", 16, -112, false)
	LeaMapsLC:MakeCB(PageF, "RescaleMap", "Rescale map frame", 16, -132, false)
	LeaMapsLC:MakeCB(PageF, "FadeMap", "Fade map while moving", 16, -152, false)
	LeaMapsLC:MakeCB(PageF, "RememberZoom", "Remember zoom level", 16, -172, false)
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 16, -192, false)

 	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
 	LeaMapsLC:CfgBtn("RescaleMapBtn", LeaMapsCB["RescaleMap"])
 	LeaMapsLC:CfgBtn("FadeMapBtn", LeaMapsCB["FadeMap"])

	-- Add reset map position button
	local resetMapPosBtn = LeaMapsLC:CreateButton("resetMapPosBtn", PageF, "Reset Map Layout", "BOTTOMRIGHT", -16, 60, 25)
	resetMapPosBtn:HookScript("OnClick", function()
		-- Reset map position
		LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "CENTER", "CENTER", 0, 0
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
		-- Reset map scale
		LeaMapsLC["MapScale"] = 0.9
		LeaMapsLC:SetDim()
		LeaMapsLC["PageF"]:Hide(); LeaMapsLC["PageF"]:Show()
		LeaMapsLC:SetMapScale()
	end)
