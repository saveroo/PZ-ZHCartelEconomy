--[[
░██████╗███████╗███████╗██████╗░██╗███╗░░██╗░██████╗░
██╔════╝██╔════╝██╔════╝██╔══██╗██║████╗░██║██╔════╝░
╚█████╗░█████╗░░█████╗░░██║░░██║██║██╔██╗██║██║░░██╗░
░╚═══██╗██╔══╝░░██╔══╝░░██║░░██║██║██║╚████║██║░░╚██╗
██████╔╝███████╗███████╗██████╔╝██║██║░╚███║╚██████╔╝
╚═════╝░╚══════╝╚══════╝╚═════╝░╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

require 'ZHFarming_CoreAction'
require 'ZHFarming_Utils'
require 'ZHFarming_VanillaTimedAction'

-- Seeding to server
function seedingAt(sq, __self)
    local _self = __self
    if _self.sound and _self.sound ~= 0 then
        _self.character:getEmitter():stopOrTriggerSound(_self.sound)
    end

    if _self.plant then
        local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), typeOfSeed = _self.typeOfSeed }
        CFarmingSystem.instance:sendCommand(_self.character, 'seed', args)
        --wateringAt(x, y, z, _self)
    end
    ISBaseTimedAction.perform(_self);
end

-- Remove seed workaround
function seedingRemoveSeed(qty, __self)
    local _self = __self;
    local player = _self.character;
    local playerInv = player:getInventory()
    local props = farming_vegetableconf.props[__self.typeOfSeed]
    local items = playerInv:getSomeTypeRecurse(props.seedName, props.seedsRequired*qty)
    ISInventoryPaneContextMenu.transferIfNeeded(_self.character, items)
    local temp = {}
    for i=1,items:size() do
        local item = items:get(i-1)
        table.insert(temp, item)
    end
    for i=1, props.seedsRequired*qty do
        local seed = temp[i];
        _self.character:getInventory():Remove(seed);
    end
end

-- Get the seed required * quantity from inventory
function getSeedsQtyFromInv(_self, qty)
    local playerInv = _self.character:getInventory()
    local props = farming_vegetableconf.props[_self.typeOfSeed]
    local items = playerInv:getSomeTypeRecurse(props.seedName, props.seedsRequired*qty)
    return items:size()
end

-- El Vero Seeding Technique
local vanillaSeedingAction = ISSeedAction.perform
function ISSeedAction:perform()
    if not ZHFarmingCore.module.seed() then
        -- Vanilla
        return vanillaSeedingAction(self)
    end

    --ZHUtils.debugSay(self.character, "Seeding at " .. self.plant:getSquare():getX() .. ", " .. self.plant:getSquare():getY() .. ", " .. self.plant:getSquare():getZ())
    local plantSq = self.plant:getSquare()
    --local x,y,z = plantSq:getX(), plantSq:getY(), plantSq:getZ();
    local plots = ZHFarmingCore:plotSchema(plotTypes.seed, plantSq)
    if not plots then return; end

    local plotCount = 0
    plotCount = ZHFarmingCore:tilesCount(plots)
    local seedType = self.typeOfSeed;

    --█▀ █▀▀ █▀▀ █▀▄ █ █▄░█ █▀▀
    --▄█ ██▄ ██▄ █▄▀ █ █░▀█ █▄█
    -- Check if seeds are enough
    if not (getSeedsQtyFromInv(self, plotCount) >= plotCount) then
        self.character:Say("I don't have enough seeds to use this technique!")
    end
    for _,v in pairs(plots) do
        seedingAt(v, self)
    end
    -- Removing seed artificially
    seedingRemoveSeed(plotCount, self)

    --█░█░█ ▄▀█ ▀█▀ █▀▀ █▀█ █ █▄░█ █▀▀
    --▀▄▀▄▀ █▀█ ░█░ ██▄ █▀▄ █ █░▀█ █▄█
    --ZHFarmingCore:createWaterAction(self.character, plots, seedType)
    self.character:Say("I just seeding "..plotCount.." plots!")

    -- Continuation
    if ZHFarmingCore.module.continuation() then
        ZHFarmingCore:createWaterAction(self.character, plantSq, plotCount)
    end

    --local waterCan = ZHUtils.invWaterCan(self.character)
    --local plant = ZHUtils.getPlantSquareAt(plantSq);
    --self.plant = plant;
    --local singleMissingWaterUse = (100 - plant.waterLvl) / 5;
    --local use = math.ceil(singleMissingWaterUse * plotCount);
    ---- lets say 20x can
    ---- 1 / 0.00125 = 800 * 5 = 4000
    --local maxWaterUse = ((waterCan:getUsedDelta() / waterCan:getUseDelta()) * 5);
    ---- use the max water can if required is above water can capacity
    --if (use > maxWaterUse) then
    --    use = maxWaterUse;
    --end
    --ISTimedActionQueue.add(ISWaterPlantAction:new(self.character, waterCan, 5 , plantSq, 25 * plotCount));

    --local waterCan = ZHUtils.invWaterCan(self.character)
    --if waterCan ~= nil then
    --    --self.character:setPrimaryHandItem(waterCan)
    --    --local handItem = ISWorldObjectContextMenu.equip(self.character, self.character:getPrimaryHandItem(), "CompostBag", true)
    --    local handItem = self.character:getPrimaryHandItem()
    --    if handItem ~= waterCan then
    --        self.character:Say("Try to use waterCan")
    --        ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, waterCan, 50, true));
    --        --ISBaseTimedAction.perform(self);
    --        self.character:Say("watercan used")
    --    end
    --
    --    --ISBaseTimedAction.perform(self);
    --end

    -- █▀▀ █▀▀ █▀█ ▀█▀ █ █░░ █ ▀█ █ █▄░█ █▀▀
    -- █▀░ ██▄ █▀▄ ░█░ █ █▄▄ █ █▄ █ █░▀█ █▄█
    --if not enableFertilizing then return; end
    --local compostBag = ZHUtils.invCompostBag(self.character)
    --if compostBag ~= nil then
    --    self.character:Say("El Vero Fertilizing 術~!")
    --    local handitem = ISWorldObjectContextMenu.equip(self.character, self.character:getPrimaryHandItem(), "CompostBag", true)
    --    ISTimedActionQueue.add(ISFertilizeAction:new(self.character, handitem, plantSq,40*plotCount));
    --end

    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "seed");
end
