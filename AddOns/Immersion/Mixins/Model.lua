local Model, GetTime, _, L, ani, m2 = {}, GetTime, ...
L.ModelMixin = Model

----------------------------------
-- Animation wrappers
----------------------------------
function Model:Read() self:SetAnimation(ani.reading) end
function Model:Ask() self:SetAnimation(ani.asking) end
function Model:Yell() self:SetAnimation(ani.yelling) end
function Model:Talk() self:SetAnimation(ani.talking) end
function Model:Reset() self:SetAnimation(0) end

function Model:RunNextAnimation() if
	self.reading then self:Read() elseif
	self.asking then self:Ask() elseif
	self.yelling then self:Yell() elseif
	self.talking then self:Talk() else
	self:Reset() end 
end

----------------------------------
-- Unit stuff
----------------------------------
function Model:IsPlayer() return self.unit == 'player' end
function Model:IsNPC() return ( self.unit == 'npc' or self.unit == 'questnpc' ) end
function Model:IsEther() return (self.unit == 'ether') end
function Model:GetUnit() return self.unit end

function Model:SetUnit(unit)
	self.unitDirty = unit
	if self:IsVisible() then
		self:ClearModel()
		self:ApplyModelFromUnit(unit)
	end
end

function Model:ApplyModelFromUnit(unit)
	if m2[unit] then
		self:SetModel(m2[unit])
		self:SetCamDistanceScale(.4)
		self:SetPortraitZoom(0)
		self:SetPosition(0, 0, .25)
		self.unit = 'ether'
	else
		local mt = getmetatable(self).__index
		local creatureID = tonumber(unit)
		local applyModelFunction = creatureID and mt.SetCreature or mt.SetUnit 
		self:SetCamDistanceScale(1)
		self:SetPortraitZoom(.85)
		self:SetPosition(0, 0, 0)
		applyModelFunction(self, creatureID or unit)
		self.unit = creatureID and 'npc' or unit
	end
end

----------------------------------
-- Calculate state and remaining time
----------------------------------
function Model:SetRemainingTime(start, remaining)
	self.timestamp = start or GetTime()
	self.delay = remaining or 0
end

function Model:GetRemainingTime(start, remaining)
	if start and remaining then
		local time = GetTime()
		local diff = time - start
		-- shave off a second to avoid awkwardly long animation sequences
		if diff < ( remaining  - 1 ) then
			return time, diff
		end
	end
end

function Model:PrepareAnimation(unit, text)
	-- if no unit/text or if the text is a description rather than spoken words
	if ( not unit or not text ) or ( text and text:match('%b<>') ) then
		for state in pairs(ani) do
			self[state] = nil
		end
	else
		self.reading = unit:match('player') and true
		if not self.reading then
			self.asking = text:match('?')
			self.yelling = text:match('!')
			self.talking = true
		end
	end
end

----------------------------------
-- Handler
----------------------------------
function Model:OnAnimFinished()
	if self:IsPlayer() then
		self:Read()
	else
		local newTime, difference = self:GetRemainingTime(self.timestamp, self.delay)
		if newTime and difference then
			self:SetRemainingTime(newTime, ( self.delay - 1) - difference)
			self.talking = true
			if self.asking then
				self:Ask()
			else
				-- randomize the yelling, since this animation is normally short and repetitive
				if ( self.yelling and ( random(2) == 2 ) ) then
					self:Yell()
				else
					self:Talk()
				end
			end
		else
			self:SetRemainingTime(nil, nil)
			self:PrepareAnimation(nil, nil)
			self:Reset()
		end
	end
end

function Model:OnShow()
	self:ClearModel()
	if self.unitDirty then
		self:ApplyModelFromUnit(self.unitDirty)
	end
end


----------------------------------
-- Consts
----------------------------------
ani = {
	reading = 520,
	asking = 65,
	yelling = 64,
	talking = 60,
}

m2 = {
	AvailableQuest	= 'interface\\buttons\\talktome.m2',
	ActiveQuest		= 'interface\\buttons\\talktomequestionmark.m2',
	IncompleteQuest = 'interface\\buttons\\talktomequestion_grey.m2',
	GossipGossip	= 'interface\\buttons\\talktome_chat.m2',
}

Model.LightValues = {
	true, 	-- enabled
	false, 	-- omni
	-250,	-- dirX
	0,		-- dirY
	0,		-- dirZ
	0.25,	-- ambIntensity
	1,		-- ambR
	1,		-- ambG
	1,		-- ambB
	75,		-- dirIntensity
	1,		-- dirR
	1,		-- dirG
	1,		-- dirB
}