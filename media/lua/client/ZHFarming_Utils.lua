-- Allowed cans
local allowedCans = {
    'ZHFarming_WateredCanFull_2x',
    'ZHFarming_WateredCanFull_4x',
    'ZHFarming_WateredCanFull_8x',
    'ZHFarming_WateredCanFull_16x',
    'ZHFarming_WateredCanFull_20x'
}

-- Fertilized cans
local fertilizedCans = {
    'ZHFarming_FertilizedCanFull_16x',
    'ZHFarming_FertilizedCanFull_20x'
}

local allowedShovel = {
    'CamoShovel'
}

local allowedCompost = {
    'CompostBag'
}

-- new fp
local function getFarmingPlanModule(modName)
    local player = getSpecificPlayer(0);
    if not player then return nil; end
    local fPlan = player:getInventory():getItemFromType("ZHFarming_farming_plan")
    if not fPlan or fPlan:hasModData() == false then return nil end
    return fPlan:getModData().modules[modName];
end

-- Check recipes
local knowRecipe = function(char)
    return char:isRecipeKnown("El Vero Watering Technique")
            or char:isRecipeKnown("El Vero Seeding Technique")
end

-- Check if the player has the guidebook in the inventory
local holdGuidebook = function(char)
    if not char then return false end
    local inv = char:getInventory()
    for i=0,inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        if item:getType() == "ZHFarming_AdvancedFarmingMag1" then
            return true
        end
    end
    return false
end

-- Check if the player has the specific module in the inventory
function moduleCheck(moduleName)
    --local fPlan = getFarmingPlanModule()
    local moduleList = {
        plot = 'ZHFarming_module_plot_3x3',
        water = 'ZHFarming_module_watering',
        seed = 'ZHFarming_module_seeding',
        fertilize = 'ZHFarming_module_fertilizing',
        plow = 'ZHFarming_module_plowing',
        remove = 'ZHFarming_module_removing',
        harvest = 'ZHFarming_module_harvesting'
    }
    if not getPlayer() or not getSpecificPlayer(0) then return; end
    local item = getPlayer():getInventory():getItemFromType('ZHFarming_farming_plan');
    local item2 = getPlayer():getInventory():getItemFromType(moduleList[moduleName])
    if item2 then
        return true
    elseif item and ZHUtils.getFarmingPlanModule(moduleName).state then
        return true
    end
    return false;
    --local inv = getPlayer():getInventory();
    --for i=0,inv:getItems():size()-1 do
    --    local item = inv:getItems():get(i)
    --    if item:getType() == moduleList[moduleName] or getFarmingPlanModule(moduleName).state then
    --        return true
    --    end
    --end
    --return false
end

local getItem = function(itemType)
    if not getPlayer() or not getSpecificPlayer(0) then return; end
    local inv = getPlayer():getInventory()
    for i=0,inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        if item:getType() == itemType then
            return item
        end
    end
    return nil
end

local checkItemFromList = function(itemType, list)
    for i=1,#list do
        if itemType == list[i] then
            return true
        end
    end
    return false
end

local getPrimaryHandItem = function(char)
    if not char then return nil end
    local item = char:getPrimaryHandItem()
    if item then
        return item
    end
    return nil
end

local setPrimaryHandItem = function(char, item)
    if not char then return; end
    if getItem(item) then
        char:setPrimaryHandItem(getItem(item))
    end
end

-- return the watercan in inventory
local invWaterCan = function(char)
    if not char then return; end;
    local inv = char:getInventory()
    if not inv then return; end
    for i=0,inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        for i = 1, #allowedCans do
            if item and item:getType() == allowedCans[i] then
                if item:getUsedDelta() > 0 then
                    return item
                end
            end
        end
    end
    return nil
end

local invCompostBag = function(char)
    if not char then return; end
    local inv = char:getInventory()
    if not inv then return; end
    for i=0,inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        for i = 1, #allowedCompost do
            if item and item:getType() == allowedCompost[i] then
                if item:getUsedDelta() > 0 then
                    return item
                end
            end
        end
    end
    return nil
end

-- check if primary contains in allowedCans
local function IsSpecialCan(char)
    if not char then return false end
    local primaryItem = char:getPrimaryHandItem()
    for i=1, #allowedCans do
        if primaryItem and primaryItem:getType() == allowedCans[i] then
            return true
        end
    end
    for i=1, #fertilizedCans do
        if primaryItem and primaryItem:getType() == fertilizedCans[i] then
            return true
        end
    end
    return false
end

-- Check plant at tiles
local function getPlantAt(x, y, z)
    return CFarmingSystem.instance:getLuaObjectAt(x, y, z)
end

local function getPlantSquareAt(sq)
    return CFarmingSystem.instance:getLuaObjectOnSquare(sq)
end

-- Mock Square
local function fakeSq(x, y, z)
    return {
        getX = function() return x end,
        getY = function() return y end,
        getZ = function() return z end
    }
end

--local function getOrCreateModData()
--
--end


ZHUtils = {}
ZHUtils.getFarmingPlanModule = getFarmingPlanModule
ZHUtils.knowRecipe = knowRecipe
ZHUtils.moduleCheck = moduleCheck
ZHUtils.invWaterCan = invWaterCan
ZHUtils.invCompostBag = invCompostBag
ZHUtils.fakeSq = fakeSq
ZHUtils.getPlantAt = getPlantAt
ZHUtils.getPlantSquareAt = getPlantSquareAt
ZHUtils.IsSpecialCan = IsSpecialCan
ZHUtils.holdGuidebook = holdGuidebook
ZHUtils.fertilizedCans = fertilizedCans
ZHUtils.allowedCans = allowedCans
ZHUtils.allowCans = checkItemFromList(getItem('CamoShovel'), allowedCans)
ZHUtils.allowedShovel = allowedShovel
ZHUtils.allowShovel = checkItemFromList(getItem('CamoShovel'), allowedShovel)
ZHUtils.allowedCompost = allowedCompost
ZHUtils.allowCompost = checkItemFromList(getItem('CompostBag'), allowedCompost)
ZHUtils.getItem = getItem
ZHUtils.getPrimaryHandItem = getPrimaryHandItem
ZHUtils.setPrimaryHandItem = setPrimaryHandItem
ZHUtils.debug = true
function ZHUtils.debugSay(player, text)
    if ZHUtils.debug then
        if player then
            player:Say(text)
        end
        print(text)
    end
end
