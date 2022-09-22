--[[
██████╗░██╗░░░░░░█████╗░░██╗░░░░░░░██╗██╗███╗░░██╗░██████╗░
██╔══██╗██║░░░░░██╔══██╗░██║░░██╗░░██║██║████╗░██║██╔════╝░
██████╔╝██║░░░░░██║░░██║░╚██╗████╗██╔╝██║██╔██╗██║██║░░██╗░
██╔═══╝░██║░░░░░██║░░██║░░████╔═████║░██║██║╚████║██║░░╚██╗
██║░░░░░███████╗╚█████╔╝░░╚██╔╝░╚██╔╝░██║██║░╚███║╚██████╔╝
╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

--require 'ZHFarming_CoreAction'
--require 'ZHFarming_Utils'
--require 'ZHFarming_VanillaTimedAction'
--
--ZHUtils = ZHUtils or {}
--ZHFarmingCore = ZHFarmingCore or {}
--ZHFarmingCore.module = ZHFarmingCore.module or {}
--plotTypes = plotTypes or {}

local function plowAt(sq, __self)
    local _self = __self
    self = _self
    if self.item then
        self.item:getContainer():setDrawDirty(true);
        self.item:setJobDelta(0.0);
    elseif ZombRand(10) == 0 then -- chance of getting hurt
        if ZombRand(2) == 0 then
            self.character:getBodyDamage():getBodyPart(BodyPartType.Hand_L):SetScratchedWeapon(true);
        else
            self.character:getBodyDamage():getBodyPart(BodyPartType.Hand_R):SetScratchedWeapon(true);
        end
    end

    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), typeOfSeed = 'Cannabis' }
    CFarmingSystem.instance:sendCommand(_self.character, 'plow', args)
    CFarmingSystem.instance:changePlayer(_self.character)
    ISBaseTimedAction.perform(_self)
end

--local function createSeedsTable(seedName, qty, __self)
--    local _self = __self;
--    local player = _self.character;
--    local playerInv = player:getInventory()
--    local props = farming_vegetableconf.props[seedName]
--    local items = playerInv:getSomeTypeRecurse(props.seedName, props.seedsRequired*qty)
--    ISInventoryPaneContextMenu.transferIfNeeded(_self.character, items)
--    local temp = {}
--    for i=1,items:size() do
--        local item = items:get(i-1)
--        table.insert(temp, item)
--    end
--    return temp, props.seedsRequired*qty, items:size()
--end

-- Flow
-- 1. Check if the player has enough seeds
--  1.1. If not, terminate continuation.
--  1.2. If yes, should do /seed/ after /plow/
--   1.2.1. iterate through the seeds and create a table of seeds
--   1.2.2. call custom TimedAction for planting the seeds
-- 2. Check if the player has enough water
--  2.1. If not, terminate continuation.
--  2.2. If yes, Should do /water/ after /plow/
--   2.2.1. Change handItem to /waterCan/
--   2.2.2. check if the player has enough water
-- 3. Check if the player has enough fertilizer
--  3.1. If not, return false
--  3.2. If yes, should do /fertilize/ after /seeding/

local vanillaPlowAction = ISPlowAction.perform
function ISPlowAction:perform()
    if not ZHFarmingCore.module.plow() then
        -- Vanilla
        return vanillaPlowAction(self)
    end

    local plowSq = self.gridSquare
    local sq = ZHUtils.fakeSq(plowSq:getX(), plowSq:getY(), plowSq:getZ())
    local plots = ZHFarmingCore:plotSchema(plotTypes.plow, plowSq)
    local plotCount = 0
    plotCount = ZHFarmingCore:tilesCount(plots);
    if plotCount == 0 then return ISBaseTimedAction.perform(self); end

    for _,v in pairs(plots) do
        plowAt(v, self)
    end
    self.character:Say("I just plowing "..plotCount.." plots!")

    -- Continuation
    if ZHFarmingCore.module.continuation() then
        ZHFarmingCore:createSeedAction(self.character, sq, plotCount)
    end
    -- [2] Seeding
    --if not ZHFarmingCore.module.seed() then return ISBaseTimedAction.perform(self); end
    --
    --local typeOfSeed = 'Cannabis'
    --local seeds, seedsUsed, seedsTblCount = createSeedsTable(typeOfSeed, plotCount, self)
    --local x,y,z = plowSq:getX(), plowSq:getY(), plowSq:getZ();
    --local plant = ZHUtils.getPlantAt(x,y,z)
    --if plant then
    --    ISTimedActionQueue.add(ISSeedAction:new(self.character, seeds, seedsUsed, typeOfSeed, plant, 40*plotCount))
    --end

    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "plow");
end
