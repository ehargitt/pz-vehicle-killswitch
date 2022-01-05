if isClient() then return end

local VehicleCommands = {}
local Commands = {}

VehicleCommands.wantNoise = getDebug() or false

local noise = function(msg)
	if VehicleCommands.wantNoise then
		print('VehicleCommands: '..msg)
	end
end

-- args = { vehicle_id, skillLevel, numberOfParts }
function Commands.installKillswitch(player, args)
	local vehicle = getVehicleById(args.vehicle_id)
    if not vehicle then
        noise('no such vehicle id='..tostring(args.vehicle_id))
        return
    end

    local part = vehicle:getPartById("Engine")
    if not part then
        noise('no such part Engine')
        return
    end

    local player_username = player:getUsername()

    -- Handle killswitch already installed
    if KillswitchDb.GetOwner(args.vehicle_id) ~= nil then
        noise('killswitch already installed')
        player:sendObjectChange('mechanicActionDone', { success = false, vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
        return
    end

    -- Success
    KillswitchDb.SetOwner(args.vehicle_id, player_username)
    player:sendObjectChange('removeItemType', { type = 'Base.ElectronicsScrap', count = args.numberOfParts })
    player:sendObjectChange('mechanicActionDone', { success = true, vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
end

-- args = { vehicle_id, skillLevel }
function Commands.uninstallKillswitch(player, args)
	local vehicle = getVehicleById(args.vehicle_id)
    if not vehicle then
        noise('no such vehicle id='..tostring(args.vehicle_id))
        return
    end

    local part = vehicle:getPartById("Engine")
    if not part then
        noise('no such part Engine')
        return
    end

    local player_username = player:getUsername()
    local owner = KillswitchDb.GetOwner(args.vehicle_id)

    -- Handle non-owner attempting uninstall
    -- Handle killswitch not installed
    if  owner == nil or owner ~= player_username then
        noise('No killswitch found')
        player:sendObjectChange('mechanicActionDone', { success = false, vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
        return
    end

    -- Success
    KillswitchDb.SetOwner(args.vehicle_id, nil)
    player:sendObjectChange('mechanicActionDone', { success = true, vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
end

VehicleCommands.OnClientCommand = function(module, command, player, args)
	if module == 'vehicle' and Commands[command] then
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		noise('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(VehicleCommands.OnClientCommand)