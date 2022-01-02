local initialized = false
if not initialized then
	ISVehicleMechanics._doMenuTooltip = ISVehicleMechanics.doMenuTooltip;
	ISVehicleMechanics._doPartContextMenu = ISVehicleMechanics.doPartContextMenu;
	initialized = true
end

function onInstallKillswitch(playerObj, part)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	
	local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
	local item = typeToItem["Base.Screwdriver"][1]
	ISVehiclePartMenu.toPlayerInventory(playerObj, item)
	
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
	
	local engineCover = nil
	local doorPart = part:getVehicle():getPartById("EngineDoor")
	if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() and not doorPart:getDoor():isOpen() then
		engineCover = doorPart
	end
	
	local time = 300;
	if engineCover then
		-- The hood is magically unlocked if any door/window is broken/open/uninstalled.
		-- If the player can get in the vehicle, they can pop the hood, no key required.
		if engineCover:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(engineCover, playerObj) then
			ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineCover))
		end
		ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
		ISTimedActionQueue.add(InstallKillswitch:new(playerObj, part, item, time))
		ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
	else
		ISTimedActionQueue.add(InstallKillswitch:new(playerObj, part, item, time))
	end
end

function onUninstallKillswitch(playerObj, part)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	
	local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
	local item = typeToItem["Base.Screwdriver"][1]
	ISVehiclePartMenu.toPlayerInventory(playerObj, item)
	
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
	
	local engineCover = nil
	local doorPart = part:getVehicle():getPartById("EngineDoor")
	if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() and not doorPart:getDoor():isOpen() then
		engineCover = doorPart
	end
	
	local time = 300;
	if engineCover then
		-- The hood is magically unlocked if any door/window is broken/open/uninstalled.
		-- If the player can get in the vehicle, they can pop the hood, no key required.
		if engineCover:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(engineCover, playerObj) then
			ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineCover))
		end
		ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
		ISTimedActionQueue.add(UninstallKillswitch:new(playerObj, part, item, time))
		ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
	else
		ISTimedActionQueue.add(UninstallKillswitch:new(playerObj, part, item, time))
	end
end

function ISVehicleMechanics:doMenuTooltip(part, option, lua, name)
    self:_doMenuTooltip(part, option, lua, name)
	local tooltip = option.toolTip

	local white_txt = " <RGB:1,1,1>"
	local red_txt = " <RGB:1,0,0>"

	------ Install killswitch ------
    if lua == "installkillswitch" then
		-- Handle Electricity skill
		local rgb = white_txt;
		if self.chr:getPerkLevel(Perks.Electricity) < 1 then
			rgb = red_txt;
		end
		tooltip.description = tooltip.description .. rgb .. getText("IGUI_perks_Electricity") .. " " .. self.chr:getPerkLevel(Perks.Electricity) .. "/1" .. " <LINE>";
		----

		-- Handle Screwdriver
		local screwdriver_item = InventoryItemFactory.CreateItem("Base.Screwdriver");
		if not self.chr:getInventory():contains("Screwdriver") then
			tooltip.description = tooltip.description .. red_txt .. screwdriver_item:getDisplayName() .. " 0/1 <LINE>";
		else
			tooltip.description = tooltip.description .. white_txt .. screwdriver_item:getDisplayName() .. " 1/1 <LINE>";
		end
		
		----

		-- Handle Electronics scraps
		local electronics_scrap_item = InventoryItemFactory.CreateItem("Base.ElectronicsScrap");
		if not self.chr:getInventory():contains("ElectronicsScrap") then
			tooltip.description = tooltip.description .. red_txt .. electronics_scrap_item:getDisplayName() .. " 0/1 <LINE>";
		else
			tooltip.description = tooltip.description .. white_txt .. electronics_scrap_item:getDisplayName() .. " 1/1 <LINE>";
		end
		----
		
		-- TODO localization
		tooltip.description = tooltip.description .. white_txt .. " " .. "Installs an engine killswitch to prevent theft.";
    end
	--------------------------------

	------ Uninstall killswitch ------
	if lua == "uninstallkillswitch" then
		-- Handle Electricity skill
		local rgb = white_txt;
		if self.chr:getPerkLevel(Perks.Electricity) < 1 then
			rgb = red_txt;
		end
		tooltip.description = tooltip.description .. rgb .. getText("IGUI_perks_Electricity") .. " " .. self.chr:getPerkLevel(Perks.Electricity) .. "/1" .. " <LINE>";
		----

		-- Handle Screwdriver
		rgb = white_txt;
		local screwdriver_item = InventoryItemFactory.CreateItem("Base.Screwdriver");
		if not self.chr:getInventory():contains("Screwdriver") then
			tooltip.description = tooltip.description .. red_txt .. screwdriver_item:getDisplayName() .. " 0/1 <LINE>";
		else
			tooltip.description = tooltip.description .. white_txt .. screwdriver_item:getDisplayName() .. " 1/1 <LINE>";
		end
		----
		
		-- TODO localization
		tooltip.description = tooltip.description .. white_txt .. " " .. "Uninstalls an engine killswitch, if you can find it...";
	end
	--------------------------------
end

function ISVehicleMechanics:doPartContextMenu(part, x,y)
    self:_doPartContextMenu(part, x,y)
	local playerObj = getSpecificPlayer(self.playerNum)

    if part:getId() == "Engine" and not VehicleUtils.RequiredKeyNotFound(part, self.chr) then
		------ Install killswitch ------
        if self.chr:getPerkLevel(Perks.Electricity) >= 1 and
		   self.chr:getInventory():contains("Screwdriver") and
		   self.chr:getInventory():getNumberOfItem("ElectronicsScrap", false, true) > 0
		then
            -- TODO: localization
			local option = self.context:addOption("Install killswitch", playerObj, onInstallKillswitch, part);
			self:doMenuTooltip(part, option, "installkillswitch");
		else
			local option = self.context:addOption("Install killswitch", playerObj, onInstallKillswitch, part);
			self:doMenuTooltip(part, option, "installkillswitch");
			option.notAvailable = true;
		end
		--------------------------------

		------ Uninstall killswitch ------
		if self.chr:getPerkLevel(Perks.Electricity) >= 1 and
			self.chr:getInventory():contains("Screwdriver")
		then
			-- TODO: localization
			local option = self.context:addOption("Uninstall killswitch", playerObj, onUninstallKillswitch, part);
			self:doMenuTooltip(part, option, "uninstallkillswitch");
		else
			local option = self.context:addOption("Uninstall killswitch", playerObj, onUninstallKillswitch, part);
			self:doMenuTooltip(part, option, "uninstallkillswitch");
			option.notAvailable = true;
		end
		--------------------------------
    end
end