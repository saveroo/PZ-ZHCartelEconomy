--[[
██╗░░██╗░█████╗░██████╗░██╗░░░██╗███████╗░██████╗████████╗██╗███╗░░██╗░██████╗░
██║░░██║██╔══██╗██╔══██╗██║░░░██║██╔════╝██╔════╝╚══██╔══╝██║████╗░██║██╔════╝░
███████║███████║██████╔╝╚██╗░██╔╝█████╗░░╚█████╗░░░░██║░░░██║██╔██╗██║██║░░██╗░
██╔══██║██╔══██║██╔══██╗░╚████╔╝░██╔══╝░░░╚═══██╗░░░██║░░░██║██║╚████║██║░░╚██╗
██║░░██║██║░░██║██║░░██║░░╚██╔╝░░███████╗██████╔╝░░░██║░░░██║██║░╚███║╚██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═════╝░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

-- This file is part of Farming Mechanism.
require 'ZHFarming_CoreAction'
require 'ZHFarming_Utils'
require 'ZHFarming_VanillaTimedAction'

function harvestAt(sq, _self)
    self = _self

    if not sq:getX() then
        return
    end
    local plant = ZHUtils.getPlantSquareAt(sq)
    if not plant then return; end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
    CFarmingSystem.instance:sendCommand(self.character, 'harvest', args)
    CFarmingSystem.instance:gainXp(self.character, plant)
    --ISFarmingMenu.walkToPlant(self.character, sq)
    --ISTimedActionQueue.add(ISHarvestPlantAction:new(self.character, plant, 100*count));
    ISBaseTimedAction.perform(self);
end

local vanillaHarvestPlanAction = ISHarvestPlantAction.perform
function ISHarvestPlantAction:perform()
    if not ZHFarmingCore.module.harvest() then
        --ZHFarming_VanillaHarvestPlantAction(self).perform(self)
        return vanillaHarvestPlanAction(self)
    end

    -- sound
    if self.sound and self.sound ~= 0 then
        self.character:getEmitter():stopOrTriggerSound(self.sound)
    end

    -- create Plot
    local plots = ZHFarmingCore:plotSchema(plotTypes.harvest, self.plant:getSquare())
    if not plots then return; end

    -- count plots
    local plotCount = 0; plotCount = ZHFarmingCore:tilesCount(plots) if plotCount == 0 then return ISBaseTimedAction.perform(self) end
    for _, plotSq in pairs(plots) do
        harvestAt(plotSq, self)
    end
    self.character:Say("Harvested " .. plotCount .. " plots ~!")
    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "harvest")
    return ISBaseTimedAction.perform(self)
end
