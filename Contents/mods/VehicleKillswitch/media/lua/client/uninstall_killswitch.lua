require "TimedActions/ISBaseTimedAction"

UninstallKillswitch = ISBaseTimedAction:derive("UninstallKillswitch")

function UninstallKillswitch:isValid()
--	return self.vehicle:isInArea(self.part:getArea(), self.character)
	return true;
end

function UninstallKillswitch:waitToStart()
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function UninstallKillswitch:update()
	self.character:faceThisObject(self.vehicle)
	self.item:setJobDelta(self:getJobDelta())

    self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function UninstallKillswitch:start()
	self.item:setJobType("Install killswitch")
	self:setActionAnim("VehicleWorkOnMid")
end

function UninstallKillswitch:stop()
	self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function UninstallKillswitch:perform()
	ISBaseTimedAction.perform(self)
	self.item:setJobDelta(0)
	local skill = self.character:getPerkLevel(Perks.Electricity);
	local args = { vehicle_id = self.vehicle:getId(), skillLevel = skill }
	sendClientCommand(self.character, 'vehicle', 'uninstallKillswitch', args)
--[[
	local skill = self.character:getPerkLevel(Perks.Mechanics) - self.vehicle:getScript():getEngineRepairLevel();
	local condPerPart = 1 + (skill/2);
	if condPerPart > 5 then condPerPart = 5; end
	local numberOfParts = self.character:getInventory():getNumberOfItem("EngineParts", false, true);
	local done = 0;
	for i=0,numberOfParts do
		self.part:setCondition(self.part:getCondition() + condPerPart);
		self.character:getInventory():RemoveOneOf("EngineParts");
		done = done + 1;
		if self.part:getCondition() >= 100 then
			self.part:setCondition(100);
			break;
		end
	end
	if isClient() then
		local args = { vehicle = self.vehicle:getId(), condition = self.part:getCondition() }
		sendClientCommand(self.character, 'vehicle', 'repairEngine', args)
	end
	if not self.character:getMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2") then
--		print("add exp", done/2)
		self.character:getXp():AddXP(Perks.Mechanics, done);
	end
--]]
	-- self.character:addMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2", self.part, getGameTime():getCalender():getTimeInMillis());
end

function UninstallKillswitch:new(character, part, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = part:getVehicle()
	o.part = part
	o.item = item
	o.maxTime = time
	o.jobType = "Install killswitch"
	return o
end

