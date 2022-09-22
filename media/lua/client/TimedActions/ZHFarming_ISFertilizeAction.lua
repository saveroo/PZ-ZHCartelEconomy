--[[
███████╗███████╗██████╗░████████╗██╗██╗░░░░░██╗███████╗██╗███╗░░██╗░██████╗░
██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██║░░░░░██║╚════██║██║████╗░██║██╔════╝░
█████╗░░█████╗░░██████╔╝░░░██║░░░██║██║░░░░░██║░░███╔═╝██║██╔██╗██║██║░░██╗░
██╔══╝░░██╔══╝░░██╔══██╗░░░██║░░░██║██║░░░░░██║██╔══╝░░██║██║╚████║██║░░╚██╗
██║░░░░░███████╗██║░░██║░░░██║░░░██║███████╗██║███████╗██║██║░╚███║╚██████╔╝
╚═╝░░░░░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚══════╝╚═╝╚══════╝╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

-- Fertilize plant
local function fertilizeAt(sq, _self)
    local char = _self.character
    local plant = _self.plant
    if plant and plant.fertilizer < 4 then
        local args = {
            x = sq:getX(),
            y = sq:getY(),
            z = sq:getZ(),
        }
        CFarmingSystem.instance:sendCommand(char, 'fertilize', args)

        -- MP shouldn't do this directly
        self.item:Use()
        self.character:getInventory():Remove("FertilizerEmpty")
        --plant.fertilizer = plant.fertilizer + 1
        --char:setPrimaryHandItem("farming.Compost_bag")
        --ISFarmingMenu.walkToPlant(char, ZHUtils.fakeSq(args.x, args.y, args.z))
        --ISTimedActionQueue.add(ISFertilizeAction:new(getSpecificPlayer(0), char:getPrimaryHandItem(), plant, 40));
    end
    ISBaseTimedAction.perform(_self)
end

local vanillaFertilize = ISFertilizeAction.perform
function ISFertilizeAction:perform()
    if not ZHFarmingCore.module.fertilize() then
        -- Vanilla
        return vanillaFertilize(self)
        --ZHFarming_VanillaFertilizeAction(self).perform(self)
        --return;
    end

    -- Check if player holding Guidebook and know the recipes.
    if not ZHFarmingCore.enablePlot() then return; end

    --local x,y,z = plantSq:getX(), plantSq:getY(), plantSq:getZ();
    local plots = ZHFarmingCore.plotSchema(plotTypes.fertilize, self.plant:getSquare())
    local plotCount = ZHFarmingCore.tilesCount(plots)
    if plotCount == 0 then return ISBaseTimedAction.perform(self); end
    -- █▀▀ █▀▀ █▀█ ▀█▀ █ █░░ █ ▀█ █ █▄░█ █▀▀
    -- █▀░ ██▄ █▀▄ ░█░ █ █▄▄ █ █▄ █ █░▀█ █▄█
    for _,v in pairs(plots) do fertilizeAt(v, self) end
    self.character:Say("I just fertilizing "..plotCount.." plots!")

    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "fertilize")
end
