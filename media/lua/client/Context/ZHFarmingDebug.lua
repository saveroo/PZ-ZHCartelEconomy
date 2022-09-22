--function PATCH_Greenfire_progressbar()
--    local freshUntrimmed = getPlayer():getInventory():getItemsFromType("FreshUnCanna")
--    local freshTrimmed = getPlayer():getInventory():getItemsFromType("FreshTCanna")
--    -- loop
--    for i=0,freshUntrimmed:size()-1 do
--        --- @type InventoryItem item
--        local item = freshUntrimmed:get(i)
--        if item:hasModData() then
--            getPlayer():Say("has mod data")
--            if item:getModData()['Life'] then
--                getPlayer():Say("life")
--                item:setTooltip("Life: "..item:getModData()['Life'])
--                --item: = "Fresh Untrimmed Canna\nLife: "..item:getModData()['Life'].."%"
--            end
--        end
--    end
--
--    for i=0,freshTrimmed:size()-1 do
--        --- @type InventoryItem item
--        local item = freshTrimmed:get(i)
--        if item:hasModData() then
--            if item:getModData()['Life'] then
--                local tooltip = ISWorldObjectContextMenu.addToolTip()
--                tooltip:setName(item:getName())
--                --getPlayerInventory(self.player).inventoryPane.toolRender
--                tooltip.description = getText("IGUI_RemainingPercent", luautils.round(math.ceil(item:getModData()['Life']),0))
--                --item:setTooltip(getText("IGUI_RemainingPercent", luautils.round(math.ceil(item:getModData()['Life']),0)))
--                item.tooltip = tooltip
--                --item: = "Fresh Untrimmed Canna\nLife: "..item:getModData()['Life'].."%"
--            end
--        end
--    end
--    --drawTextAndProgressBar(text, item:getUsedDelta(), xoff, top, fgText, fgBar)
--end

if getDebug() then
    Events.OnCustomUIKey.Add(function(key)
        ---@type IsoPlayer | IsoGameCharacter | IsoGameCharacter | IsoLivingCharacter | IsoMovingObject player
        --local player = getSpecificPlayer(0)
        --local UI = FarmingPlanUI or {}
        --local Utils = ZHUtils or {}
        if key == Keyboard.KEY_F5 then
            if getPlayer() then
                getPlayer():Say("F5")
            end
            PATCH_GFItemCheck();
            --local s = require("Patch/GFPatchShared");
            --if(s) then
            --end
            --local item = getPlayer():getInventory():getItemFromType("ZHFarming_farming_plan");
            --item:setTooltip("Life: \n100\n"..round(0.5*100,0))
            --local toolRender = ISToolTipInv:new(item);
            --toolRender:setName(item:getName())
            --toolRender.description = string.format("%s: <SETX:%d> %d / %d",
            --        getText("ContextMenu_WaterName"), tx, 1, 1.0 / 1.0 + 0.0001)
            --toolRender:initialise()
            --toolRender:addToUIManager()
            --toolRender:setVisible(true)
            --toolRender:setCharacter(getSpecificPlayer(0))
            --toolRender:setTexture(item:getTexture())
            --local r = require("GFtimetracker")
            --if r then
            --    GFItemCheck()
            --end
            --WeedProgressBarPatch()

            --local s = Utils.getItem("ZHFarming_farming_plan")
            --UI.instance.dbg(s)
            --FarmingPlanUI = ISPanel:derive("FarmingPlanUI");
            --getPlayer():Say("FarmingPlanUI = nil")
        end
    end)
end
