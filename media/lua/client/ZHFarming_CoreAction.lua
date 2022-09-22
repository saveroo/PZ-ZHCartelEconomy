-- TODO: make it concise, D.R.Y and S.O.L.I.D, less tight coupled

require 'ZHFarming_Utils'

ZHUtils = ZHUtils or {}
ZHFarmingCore = {}

-- Fertilized cans
local fertilizedCans = {
    'ZHFarming_FertilizedCanFull_16x',
    'ZHFarming_FertilizedCanFull_20x'
}

local enablePlot = function() return ZHUtils.moduleCheck("plot") end
local enableWatering = function() return ZHUtils.moduleCheck("water") end
local enableSeeding = function() return ZHUtils.moduleCheck("seed") end
local enableFertilizing = function() return ZHUtils.moduleCheck("fertilize") end
local enablePlowing = function() return ZHUtils.moduleCheck("plow") end
local enableRemoving = function() return ZHUtils.moduleCheck("remove") end
local enableHarvesting = function() return ZHUtils.moduleCheck("harvest") end
local enableContinuation = function() return ZHUtils.moduleCheck("continuation") end

ZHFarmingCore.enablePlot = enablePlot
ZHFarmingCore.enableWatering = enableWatering
ZHFarmingCore.enableSeeding = enableSeeding
ZHFarmingCore.enableFertilizing = enableFertilizing
ZHFarmingCore.enablePlowing = enablePlowing
ZHFarmingCore.enableHarvesting = enableHarvesting
ZHFarmingCore.enableRemoving = enableRemoving

plotTypes = {
    fertilize = "fertilize",
    plow = "plow",
    remove = "remove",
    harvest = "harvest",
    water = "water",
    seed = "seed"
}

if not ZHFarmingCore.module then ZHFarmingCore.module = {} end
ZHFarmingCore.module = {
    water = function() return enableWatering() and enablePlot() end,
    seed = function() return enableSeeding() and enablePlot() end,
    fertilize = function() return enableFertilizing() and enablePlot() end,
    plow = function() return enablePlowing() and enablePlot() end,
    remove = function() return enableRemoving() and enablePlot() end,
    harvest = function() return enableHarvesting() and enablePlot() end,
    continuation = function() return enableContinuation() and enablePlot() end,
}

function ZHFarmingCore:createWaterAction(playerObj, plotSquare, plotCount)
    local waterCan = ZHUtils.invWaterCan(playerObj)
    if not waterCan then ZHUtils.debugSay(playerObj, "I've got no water can to do continuation");
        return
    end

    local plant = ZHUtils.getPlantAt(plotSquare:getX(), plotSquare:getY(), plotSquare:getZ())
    if not plant then
        ZHUtils.debugSay(playerObj, "Something went wrong with watering technique..");
        return
    end

    local singleMissingWaterUse = (100 - plant.waterLvl) / 5;
    local use = math.ceil(singleMissingWaterUse * plotCount);
    -- lets say 20x can
    -- 1 / 0.00125 = 800 * 5 = 4000
    local maxWaterUse = ((waterCan:getUsedDelta() / waterCan:getUseDelta()) * 5);
    -- use the max water can if required is above water can capacity
    if (use > maxWaterUse) then
        use = maxWaterUse;
    end
    -- debug
    --ZHUtils.debugSay(playerObj, "Watering " .. plotCount .. " plots with " .. use .. " water use")
    if playerObj:getPrimaryHandItem() ~= waterCan then
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, waterCan, 50, true));
        ISTimedActionQueue.add(ISWaterPlantAction:new(playerObj, waterCan, 20, plotSquare, 40 * plotCount));
        ISBaseTimedAction.perform(self);
    end
end

local function createSeedsTable(seedPropsData, qty, playerObj)
    if not playerObj then return end
    local props = farming_vegetableconf.props[seedPropsData.typeOfSeed]
    if not props then return end
    local items = getPlayer():getInventory():getSomeTypeRecurse(props.seedName, props.seedsRequired*qty)
    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, items)
    local seedsTable = {}
    for i=1,items:size() do
        local item = items:get(i-1)
        table.insert(seedsTable, item)
    end
    return seedsTable, props.seedsRequired*qty, items:size()
end

function ZHFarmingCore:createSeedAction(playerObj, plotSquare, plotCount)
    if not ZHFarmingCore.module.seed() then return ISBaseTimedAction.perform(self); end

    local seedModule = ZHUtils.getItem("ZHFarming_module_seeding");
    if seedModule then
        local seedData = seedModule:getModData();
        if not seedModule:hasModData() or seedModule:getModData()["typeOfSeed"] == "none" then
            playerObj:Say("I need to choose seed on my [Module] seeding first..") return;
        end
        --if playerObj:getInventory():containsTypeRecurse(seedData.seedName, seedData.seedsRequired*plotCount) then
        --    local seeds, seedsRequired, seedsCount = createSeedsTable(seedModule, plotCount, self)
        --    if seedsCount < plotCount then
        --        ZHUtils.debugSay(playerObj, "I've got not enough seeds to do continuation");
        --        return
        --    end
        --    local seed = seeds[1]
        --    if playerObj:getPrimaryHandItem() ~= seed then
        --        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, seed, 50, true));
        --    end
        --    ISTimedActionQueue.add(ISSeedPlotAction:new(playerObj, seed, 20, plotSquare, 40 * plotCount));
        --    ISBaseTimedAction.perform(self);
        --end
        --for k,v in pairs(farming_vegetableconf.props) do
        --
        --end


        local seeds, nbOfSeed, seedsTblCount = createSeedsTable(seedData, plotCount, playerObj)
        if not seeds then
            ZHUtils.debugSay(playerObj, "I've got not enough seeds to do continuation");
            return
        end
        --local plant = ZHUtils.getPlantAt(plotSquare:getX(), plotSquare:getY(), plotSquare:getZ())
        --if playerObj:getPrimaryHandItem() ~= seeds[1] then
        --    ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, seeds[1], 50, true));
        --ISBaseTimedAction.perform(_self)
        --end
        --ISTimedActionQueue.add(ISSeedPlotAction:new(playerObj, seed, 20, plotSquare, 40 * plotCount));
        --ISFarmingMenu.cursor = ISFarmingCursorMouse:new(playerObj, ISFarmingMenu.onSeedSquareSelected, ISFarmingMenu.isSeedValid)
        --getCell():setDrag(ISFarmingMenu.cursor, playerObj:getPlayerNum())
        --ISFarmingMenu.cursor.typeOfSeed = seedData.typeOfSeed;
        --ZHUtils.debugSay(playerObj, plotSquare:getX().." [3]".. plotSquare:getY());
        local newPlot = ZHFarmingCore:plotSchema("continuation_seed", plotSquare)
        local count = 0
        count = ZHFarmingCore:tilesCount(newPlot)
        ZHUtils.debugSay(playerObj, "Seed after plow: ".. count);

        if not newPlot then return end
        for _, v in pairs(newPlot) do
            if v then
                ZHUtils.debugSay(playerObj, "Seed after plow: ");
                ISTimedActionQueue.add(ISSeedAction:new(playerObj, seeds, nbOfSeed, seedData.typeOfSeed,
                        v, 40*plotCount))
                ISBaseTimedAction.perform(playerObj);
            end
        end
        --ISTimedActionQueue.add(ISSeedAction:new(playerObj, seeds, nbOfSeed, seedData.typeOfSeed,
        --        ZHUtils.getPlantSquareAt(seedAfterPlow), 40*plotCount))
        --if plant then
        --    ZHUtils.debugSay(playerObj, "Let's seed these as well");
        --end
    end
end


function ZHFarmingCore:isModuleEnabled(plotType)
    return self.module[plotType]()
end

-- Decrease Endurance upon succeeded action
function ZHFarmingCore.executeOnSucceed(playerObj, plotCount, action)
    if not playerObj then return end
    if not plotCount then return end
    if plotCount == 0 then return end

    if ZHUtils.getFarmingPlanModule(action) ~= nil and ZHUtils.getFarmingPlanModule(action).total then
        ZHUtils.getFarmingPlanModule(action).total = ZHUtils.getFarmingPlanModule(action).total + plotCount
    end

    CFarmingSystem:changePlayer(playerObj)
    local endurance = playerObj:getStats():getEndurance() - (plotCount * 0.0025)
    playerObj:getStats():setFatigue(playerObj:getStats():getFatigue() + (plotCount * 0.0025))
    playerObj:getStats():setEndurance(endurance);
end

--[[
██████╗░██╗░░░░░░█████╗░████████╗████████╗██╗███╗░░██╗░██████╗░
██╔══██╗██║░░░░░██╔══██╗╚══██╔══╝╚══██╔══╝██║████╗░██║██╔════╝░
██████╔╝██║░░░░░██║░░██║░░░██║░░░░░░██║░░░██║██╔██╗██║██║░░██╗░
██╔═══╝░██║░░░░░██║░░██║░░░██║░░░░░░██║░░░██║██║╚████║██║░░╚██╗
██║░░░░░███████╗╚█████╔╝░░░██║░░░░░░██║░░░██║██║░╚███║╚██████╔╝
╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--]]
local plotTiles = {}
local function createTilesID(sq)
    local tileID = sq:getX() .. sq:getY() .. sq:getZ()
    return tileID
end
local function registerPlotTiles(type, sq)
    local x,y,z = sq:getX(),sq:getY(),sq:getZ()
    local plant = ZHUtils.getPlantAt(x, y, z)
    if type == "water" then
        if plant and plant.waterLvl < 100 then
            plotTiles[createTilesID(sq)] = sq
        end
    elseif type == "seed" then
        if plant and plant.state == 'plow' then
            plotTiles[createTilesID(sq)] = sq
        end
    elseif type == "harvest" then
        if plant and plant.canHarvest then
            plotTiles[createTilesID(sq)] = sq
        end
    elseif type == "fertilize" then
        if plant and plant.state == 'seeded' then
            if (plant.fertilizer == 4) then return; end
            plotTiles[createTilesID(sq)] = sq
        end
    elseif type == "remove" then
        if plant then
            plotTiles[createTilesID(sq)] = sq
        end
    elseif type == "plow" then
        local plowSq = getWorld():getCell():getGridSquare(x, y, z)
        if plowSq and not (plowSq.state == 'seeded' or plowSq.state == 'plow') then
            for i = 0, plowSq:getObjects():size() - 1 do
                local item = plowSq:getObjects():get(i);
                -- IsoRaindrop and IsoRainSplash have no sprite/texture
                if item:getTextureName() and (luautils.stringStarts(item:getTextureName(), "floors_exterior_natural") or
                        luautils.stringStarts(item:getTextureName(), "blends_natural_01")) then
                    if not plant then
                        plotTiles[createTilesID(sq)] = sq
                    end
                end
            end
        end
    elseif type == "continuation_seed" then
        local plowSq = getWorld():getCell():getGridSquare(x, y, z)
        if plowSq then
            for i = 0, plowSq:getObjects():size() - 1 do
                local item = plowSq:getObjects():get(i);
                -- IsoRaindrop and IsoRainSplash have no sprite/texture
                if item:getTextureName() and (luautils.stringStarts(item:getTextureName(), "vegetation_farming_01_1")) then
                    plotTiles[createTilesID(sq)] = sq
                end
            end
        end
    end
end
function ZHFarmingCore:tilesCount(tiles)
    local count = 0
    for _,tile in pairs(tiles) do
        if tile then count = count + 1 end
    end
    return count
end
function ZHFarmingCore:plotSchema(type, sq)
    plotTiles = {}
    -- 3x3
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            registerPlotTiles(type, ZHUtils.fakeSq(sq:getX() + i, sq:getY() + j, sq:getZ()))
        end
    end
    return plotTiles
end

-- Plotting iteration 2

local avlSchemas = {
    ['3x3'] = {

    }
}


-- TEST
--require "ISUI/ISInventoryPaneContextMenu"
--
--function ZHFarming_setModuleSeeds(itemObj, tos)
--    itemObj.modData["typeOfSeed"] = tos
--    local dataTOS = itemObj:getModData()["typeOfSeed"]
--    itemObj:setName("[Module] Seeding ("..dataTOS..")")
--end

--function ZHFarming_doSeedMenu(context, playerObj)
--    local seedOption = context:addOption("Set Seed", nil, nil)
--    local subMenu = context:getNew(context)
--    context:addSubMenu(seedOption, subMenu)
--
--    -- Sort seed types by display name.
--    local typeOfSeedList = {}
--    for typeOfSeed,props in pairs(farming_vegetableconf.props) do
--        table.insert(typeOfSeedList, { typeOfSeed = typeOfSeed, props = props, text = getText("Farming_" .. typeOfSeed) })
--    end
--    table.sort(typeOfSeedList, function(a,b) return not string.sort(a.text, b.text) end)
--
--    for _,tos in ipairs(typeOfSeedList) do
--        subMenu:addOption(tos.typeOfSeed, item, ZHFarming_setModuleSeeds, tos.typeOfSeed)
--        --local nbOfSeed = playerObj:getInventory():getCountTypeRecurse(tos.props.seedName)
--        --ISFarmingMenu.canPlow(nbOfSeed, typeOfSeed, option)
--    end
--end

--function ZHFarming_module_seeding_addContext(player, context, items)
--    for _, v in ipairs(items) do
--        local item = v
--        if not instanceof(v, "InventoryItem") then
--            item = v.items[1]
--        end
--
--        if item:getType() == "ZHFarming_module_seeding" then
--            --context:addOption("Set Seed", item, ZHFarming_setModuleSeeds, player)
--            context:addOption("Set Seed", nil, nil)
--            local seedOfChoiceMenu = context:getNew(context)
--            context:addSubMenu(seedOption, seedOfChoiceMenu)
--
--            local typeOfSeedList = {}
--            for typeOfSeed,props in pairs(farming_vegetableconf.props) do
--                table.insert(typeOfSeedList, { typeOfSeed = typeOfSeed, props = props, text = getText("Farming_" .. typeOfSeed) })
--            end
--            table.sort(typeOfSeedList, function(a,b) return not string.sort(a.text, b.text) end)
--
--            for _,tos in ipairs(typeOfSeedList) do
--                local typeOfSeed = tos.typeOfSeed
--                seedOfChoiceMenu:addOption(tos.typeOfSeed, item, ZHFarming_setModuleSeeds, typeOfSeed)
--                --subMenu:addOption(tos.typeOfSeed, playerObj, ZHFarming_setModuleSeeds, typeOfSeed)
--                --local nbOfSeed = playerObj:getInventory():getCountTypeRecurse(tos.props.seedName)
--                --ISFarmingMenu.canPlow(nbOfSeed, typeOfSeed, option)
--            end
--
--            ---- add the submenus
--            --context:addSubMenu(seedOption, seedOfChoiceMenu)
--
--
--            --local addOption = true
--            --if player and player.getSteamID then
--            --    local modData = item:getModData()
--            --    local JMD = modData["typeOfSeed"]
--            --    local pSteamID = player:getSteamID()
--            --    if (not JMD) then
--            --        addOption = false
--            --    elseif pSteamID ~= 0 then
--            --        JMD["ID"] = JMD["ID"] or {}
--            --        local journalID = JMD["ID"]
--            --        if journalID["steamID"] and (journalID["steamID"] ~= pSteamID) then
--            --            addOption = false
--            --        end
--            --    end
--            --end
--            --
--            --if addOption then
--            --    context:addOption("Set Seed", item, SRJ.onRenameJournal, player)
--            --    local subMenu = context:getNew(context)
--            --    context:addSubMenu(seedOption, subMenu)
--            --    break
--            --end
--        end
--    end
--end

--Events.OnFillWorldObjectContextMenu.Add(ISBlacksmithMenu.doSeedMenu);
--Events.OnFillWorldObjectContextMenu.Add(ZHFarming_module_seeding_addContext)
