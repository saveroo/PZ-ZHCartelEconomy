function ZHFarming_OnCreate_CompostBag(items, result, player)
    if  result:getType() == "CompostBag" then
        result:setName("El Vero Fertilizer (20 Uses)")
        result:setUseDelta(0.050)
    end
end

function ZHFarming_OnCreate_FertilizerWateringCan(items, result, player)
    if  result:getType() == "ZHFarming_FertilizedCanFull_16x"
    or result:getType() == "ZHFarming_FertilizedCanFull_20x"
    then
        result:setUsedDelta(1)
    end
end

function ZHFarming_OnCreate_FarmingPlan(items, result, player)
    --local data = result:getModData()
    --data.modules = {}
    --data.owner = player:getUsername()
    --data.modules.plot = {}
    --data.modules.plow = {}
    --data.modules.seed = {}
    --data.modules.water = {}
    --data.modules.fertilize = {}
    --data.modules.harvest = {}
    --data.modules.remove = {}
    --data.modules.continuation = {}
    --
    --data.modules['plot'].state = false
    --data.modules['plot'].schema = '3x3'
    --
    --data.modules['plow'].state = false
    --data.modules['plow'].total = 0
    --
    --data.modules['seed'].state = false
    --data.modules['seed'].selectedSeed = 'none'
    --data.modules['seed'].total = 0
    --
    --data.modules['water'].state = false
    --data.modules['water'].selectedCan = 'ZHFarming_WateringCanFull_16x'
    --data.modules['water'].afterSeed = false
    --data.modules['water'].total = 0
    --
    --data.modules['fertilize'].state = false
    --data.modules['fertilize'].afterWater = false
    --data.modules['fertilize'].max = 4
    --
    --data.modules['harvest'].state = false
    --data.modules['harvest'].total = 0
    --
    --data.modules['remove'].state = false
    --data.modules['continuation'].state = false

--    Add multiline tooltip to item
--    result:setTooltip("Farming Planx")
--    result:setTooltip("TEST")

    --     create tooltip
    --local ttDesc = ""
    --local line = "<LINE>"
    --ttDesc = ttDesc.." <LINE> ".."Farming Plan"
    --ttDesc = ttDesc.." <LINE> ".."Owner: " .. data.owner
    --ttDesc = ttDesc.." <LINE> ".."Plot: " .. data.modules['plot'].state
    --ttDesc = ttDesc.." <LINE> ".."Plow: " .. data.modules['plow'].state
    --ttDesc = ttDesc.." <LINE> ".."Seed: " .. data.modules['seed'].state
    --ttDesc = ttDesc.." <LINE> ".."Water: " .. data.modules['water'].state
    --ttDesc = ttDesc.." <LINE> ".."Fertilize: " .. data.modules['fertilize'].state
    --ttDesc = ttDesc.." <LINE> ".."Harvest: " .. data.modules['harvest'].state
    --ttDesc = ttDesc.." <LINE> ".."Remove: " .. data.modules['remove'].state
    --ttDesc = ttDesc.." <LINE> ".."Continuation: " .. data.modules['continuation'].state

    --local tt = ISToolTipInv:derive('ISToolTipInv')
    --tt.initialise()
    --tt:setCharacter(player)
    --tt.description = ttDesc
    --result:DoTooltip(tt)
    --
    ----local tt = ISToolTipInv:new()
    ----tt.description = ttDesc
    ----tt.setName("Farming Plan")
    ----result.toolTip = ttDesc
    --result:addTooltips(ttDesc)
end

function ZHFarming_OnCreate_SeedingModule(items, result, player)
    if  result:getType() == "ZHFarming_module_seeding" then
        if result:hasModData() then
            if dataTOS then
                result:setName("[Module] Seeding ("..dataTOS..")")
            end
        end
        if not result:hasModData() then
            result:setName("[Module] Seeding (Empty)")
            local data = result:getModData()
            if player and player:getUsername() then
                data.owner = player:getUsername()
            end
            data.typeOfSeed = "none"
        end

        --
        --
        --if result:hasModData() then
        --    local dataTOS = result:getModData()["typeOfSeed"]
        --    if dataTOS then
        --        result:setName("[Module] Seeding ("..dataTOS..")")
        --    end
        --end
        --if not result:hasModData() then
        --    result:setName("[Module] Seeding (Empty)")
        --end
        --result:getModData()["steamID"] = player:getSteamID()
        --result.getModData()["typeOfSeed"] = "none"
        --result:setName("[Module] Seeding (".. result:getModData()['typeOfSeed'].. ")")
        --result.modData["typeOfSeed"] = "Corn"
        --if player:getInventory():containsTypeRecurse("ZHFarming_module_seeding") then
            --    for k, prop in pairs(farming_vegetableconf.props) do
            --        if player:getInventory():containsTypeRecurse(k) then
            --            result.modData[k] = prop
            --            result:setName("[Module] Seeding".. " ("..k..")")
            --            return
            --        end
            --    end
            --    local option = context:addOption("Use", worldobjects, ZHFarming_setModuleSeeds, result)
            --else
            --    result:setName("Seeding Module")
            --end
            --player:Say(result:seePage(1))
        --end
    end
end
