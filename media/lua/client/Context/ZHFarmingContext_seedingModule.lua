require "ISUI/ISInventoryPaneContextMenu"
require 'ZHFarmingContext_main'
ZHFarmingContext = ZHFarmingContext or {}
local seedingModule = {}

function seedingModule.OnClick(item, tos, player)
    local dataTOS = item:getModData()
    if item:hasModData() then
        if item:getType() == "ZHFarming_farming_plan" then
            dataTOS.modules['seed'].selectedSeed = tos.typeOfSeed
            dataTOS.modules['seed'].props = tos.props
        end
        if item:getType() == "ZHFarming_module_seeding" then
            dataTOS.typeOfSeed = tos.typeOfSeed;
            dataTOS.seedName = tos.props.seedName;
            dataTOS.seedsRequired = tos.props.seedsRequired;
            item:setName("[Seeding Module] "..dataTOS.typeOfSeed.." "..dataTOS.seedName)
        end
    end
end
function seedingModule.addTooltips(seedAvailable, typeOfSeed, option)
    local tooltip = ISToolTip:new();
    tooltip:initialise();
    tooltip:setVisible(false);
    option.toolTip = tooltip;
    tooltip:setName(getText("Farming_" .. typeOfSeed));
    local result = true;
    tooltip.description = getText("Farming_Tooltip_MinWater") .. farming_vegetableconf.props[typeOfSeed].waterLvl .. "";
    if farming_vegetableconf.props[typeOfSeed].waterLvlMax then
        tooltip.description = tooltip.description .. " <LINE> " .. getText("Farming_Tooltip_MaxWater") .. farming_vegetableconf.props[typeOfSeed].waterLvlMax;
    end
    tooltip.description = tooltip.description .. " <LINE> " .. getText("Farming_Tooltip_TimeOfGrow") .. math.floor((farming_vegetableconf.props[typeOfSeed].timeToGrow * 7) / 24) .. " " .. getText("IGUI_Gametime_days");
    local waterPlus = "";
    if farming_vegetableconf.props[typeOfSeed].waterLvlMax then
        waterPlus = "-" .. farming_vegetableconf.props[typeOfSeed].waterLvlMax;
    end
    tooltip.description = tooltip.description .. " <LINE> " .. getText("Farming_Tooltip_AverageWater") .. farming_vegetableconf.props[typeOfSeed].waterLvl .. waterPlus;
    local rgb = "";
    if seedAvailable < farming_vegetableconf.props[typeOfSeed].seedsRequired then
        result = false;
        rgb = "<RGB:1,0,0>";
    end
    tooltip.description = tooltip.description .. " <LINE> " .. rgb .. getText("Farming_Tooltip_RequiredSeeds") .. seedAvailable .. "/" .. farming_vegetableconf.props[typeOfSeed].seedsRequired;
    tooltip:setTexture(farming_vegetableconf.props[typeOfSeed].texture);
    if not result then
        option.onSelect = nil;
        option.notAvailable = true;
    end
    tooltip:setWidth(170);
end

function seedingModule:createSeedContextMenu(text, context, item)
    local seedOption = context:addOption(text)
    local seedOfChoiceMenu = context:getNew(context)
    context:addSubMenu(seedOption, seedOfChoiceMenu)

    local typeOfSeedList = {}
    for typeOfSeed, props in pairs(farming_vegetableconf.props) do
        table.insert(typeOfSeedList, {
            typeOfSeed = typeOfSeed,
            seedName = props.seedName,
            props = props,
            text = getText("Farming_" .. typeOfSeed) })
    end
    table.sort(typeOfSeedList, function(a, b)
        return not string.sort(a.text, b.text)
    end)
    for _, tos in ipairs(typeOfSeedList) do
        local seedsOwned = getPlayer():getInventory():getCountTypeRecurse(tos.props.seedName)
        if seedsOwned then
            local menus = seedOfChoiceMenu:addOption(tos.text .. "(" .. seedsOwned .. ")", item, seedingModule.OnClick, tos, player)
            seedingModule.addTooltips(seedsOwned, tos.typeOfSeed, menus)
        end
    end
end

function seedingModule:addContext(player, context, item)
    local addOption = true;
    if addOption and context and item then
        self:createSeedContextMenu("Set Seed", context, item)
    end
end

ZHFarmingContext.seedingModule = seedingModule

--
--function initFarmingPlan(item)
--    local data = item:getModData()
--    data.modules = data.modules or {}
--    data.modules.plot = data.modules.plot or {}
--    data.modules.plow = data.modules.plow or {}
--    data.modules.seed = data.modules.seed or {}
--    data.modules.water = data.modules.water or {}
--    data.modules.fertilize = data.modules.fertilize or {}
--    data.modules.harvest = data.modules.harvest or {}
--    data.modules.remove = data.modules.remove or {}
--    data.modules.continuation = data.modules.continuation or {}
--    --data.owner = data.owner or player:getUsername()
--    data.modules['plot'] = data.modules['plot'] or {}
--    data.modules['plot'].state = 'off'
--    data.modules['plot'].schema = '3x3'
--
--    data.modules['plow'] = data.modules['plow'] or {}
--    data.modules['plow'].state = 'off'
--    data.modules['plow'].total = 0
--
--    data.modules['seed'] = data.modules['seed'] or {}
--    data.modules['seed'].state = 'off'
--    data.modules['seed'].selectedSeed = 'none'
--    data.modules['seed'].total = 0
--
--    data.modules['water'] = data.modules['water'] or {}
--    data.modules['water'].state = 'off'
--    data.modules['water'].selectedCan = 'ZHFarming_WateringCanFull_16x'
--    data.modules['water'].afterSeed = 'off'
--    data.modules['water'].total = 0
--
--    data.modules['fertilize'] = data.modules['fertilize'] or {}
--    data.modules['fertilize'].state = 'off'
--    data.modules['fertilize'].afterWater = 'off'
--    data.modules['fertilize'].max = 4
--
--    data.modules['harvest'] = data.modules['harvest'] or {}
--    data.modules['harvest'].state = 'off'
--    data.modules['harvest'].total = 0
--
--    data.modules['harvest'] = data.modules['harvest'] or {}
--    data.modules['remove'].state = 'off'
--    data.modules['continuation'] = data.modules['continuation'] or {}
--    data.modules['continuation'].state = 'off'
--end
