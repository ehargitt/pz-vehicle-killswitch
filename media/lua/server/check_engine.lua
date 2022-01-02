require 'Vehicles/Vehicles'

local initialized = false
if not initialized then
	Vehicles.CheckEngine._Engine = Vehicles.CheckEngine.Engine;
	initialized = true
end

function Vehicles.CheckEngine.Engine(vehicle, part)
    local pass_check = Vehicles.CheckEngine._Engine(vehicle, part)
    if not pass_check then return false; end

    -- If no one trying to drive, then no theft to prevent
    local driver = vehicle:getDriver()
    if driver == nil then return true; end

    local username = driver:getUsername()
    local vehicle_id = vehicle:getId()
    local owner = KillswitchDb.GetOwner(vehicle_id)

    if owner == nil then return true; end
    if owner ~= username then return false; end
	return true
end