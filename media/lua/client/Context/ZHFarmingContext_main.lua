require "ISUI/ISInventoryPaneContextMenu"
require 'ZHFarmingContext_farmingPlan'
require 'ZHFarmingContext_seedingModule'

ZHFarmingContext = ZHFarmingContext or {}
--ZHFarmingContext.farmingPlan = ZHFarmingContext.farmingPlan or {}
--seedingModule = ZHFarmingContext['seedingModule'] or {}

function ZHFarmingContext.wrapper(player, context, items)
    for _, v in ipairs(items) do
        local item = v;
        if not instanceof(v, "InventoryItem") then
            item = v.items[1];
        end

        --ZHFarmingContext.farmingPlan:addContext(player, context, item)
        if item:getType() == "ZHFarming_module_seeding" then
            local ctx = context
            ZHFarmingContext.seedingModule:addContext(getSpecificPlayer(player), ctx, item)
        elseif item:getType() == "ZHFarming_farming_plan" then
            local ctx = context
            ZHFarmingContext.farmingPlan:addContext(getSpecificPlayer(player), ctx, item)
            break;
            --local ttip = item:getModData()
            --if ttip.hasTooltip then
            --    ttip.hasTooltip = true
            --end
            --local s = ISToolTipInv:new()
            --s.description = "TEST tooltips"
            --item.toolTip = s
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(ZHFarmingContext.wrapper)
