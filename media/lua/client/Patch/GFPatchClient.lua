if getActivatedMods():contains("jiggasGreenfireMod") then
    --require "Timed/GFTimeTracker";

    -- redefine event sub
    Events.OnGameStart.Remove(GFItemCheck);
    Events.EveryDays.Remove(GFItemCheck);
    -- Defs
    ItemTimeTrackerMod = ItemTimeTrackerMod or require('ItemTimeTrackerMod') or {}

    -- Overriding jiggas
    if ProceduralDistributions ~= nil then
        if isClient() then
            return
        end
    end
    --Modified by AiweLeliaThamm
    require "NDRecipeActions.lua"

    local function checkModData(item, key)
        if item and ItemTimeTrackerMod[item:getType()] and item:getModData()[key] ~= nil then
            return true
        end
        return false
    end

    local function PATCH_migrateModData(item)
        if item and item:hasModData() and ItemTimeTrackerMod[item:getType()] ~= nil and item:getModData()['StartYear'] then
            item:getModData().StartYear = nil;
            item:getModData().StartMonth = nil;
            item:getModData().StartDay = nil;
            item:getModData().StartHour = nil;
        end
    end

    function PATCH_GFloadItem(item)
        GFloadItem(item)
    end

    function GFShouldReplace(item)
        local shouldDry = false;

        if checkModData(item, 'ShouldDry') then
            -- load if not exist
            if not item:getModData().Life and not item:getModData().StartTime then
                PATCH_GFloadItem(item)
            end

            -- check if should dry
            if checkModData(item, 'DryTime') then
                local remaining = item:getModData().DryTime - getGameTime():getWorldAgeHours();
                --getPlayer():Say("Remaining: " .. remaining)

                if remaining <= 0 then
                    item:getModData().Remaining = remaining;
                    item:getModData().ShouldDry = true;
                end

                if remaining > 0 then
                    item:getModData().Remaining = remaining;
                    item:getModData().ShouldDry = false;
                end

                shouldDry = item:getModData().ShouldDry;
            end
        end

        return shouldDry;
    end

    function PATCH_GFreplaceItem(container, item)
        PATCH_migrateModData(item)
        --getPlayer():Say("Trying to replace")
        local shouldDry = GFShouldReplace(item);
        if shouldDry == false then
            --local __sub = function () return item:getModData()['DryTime'] - getGameTime():getWorldAgeHours(); end
            --item:getModData()['Remaining'] = 205
        else
            --getPlayer():Say("WE TRIED TO RPLACE")
            --print(getPlayer():getInventory():getSomeTypeEvalRecurse("FreshTCanna", function(item) return item:getModData()['Remaining']; end, 0))
            --item:getModData().Remaining = item:getModData().DryTime - getGameTime():getWorldAgeHours();
            --item:getModData().Remaining = 210
            if(item:getModData().Remaining <= 0) then
                    -- add item if its gonna turn
                --local temp = nil
                if item:getModData().TurnInto and item:getModData().TurnInto ~= "" then
                    --temp = InventoryItemFactory:CreateItem(item:getModData().TurnInto);
                    temp = container:AddItem(item:getModData().TurnInto);
                    if temp ~= nil then
                        PATCH_GFloadItem(temp)
                        dataCheck(item, temp)
                        --container:AddItem(temp);
                    end
                end
                -- Remove item if its supposed to dry.
                ISRemoveItemTool.removeItem(item, getPlayer());
            end
        end
    end
    function GFreplaceItem(container, item)
        PATCH_GFreplaceItem(container, item)
    end

    function PATCH_dataCheck(item, temp)
        if item == nil or temp == nil then
            return;
        end
        --������B �����Q��� �E�Q���D��
        if (item:getCategory() == "Container") and (temp:getCategory() == "Container") then
            temp:getInventory():setItems(item:getInventory():getItems())
            --��F���D�G�E���� �E�Q���D��E											--��J�C�Z�E�������� �E����E�E�E����E�E��E"��E��E
            if string.find(item:getModData().TurnInto, "hungry") then
                temp:setName("hungry " .. item:getName());
            else
                temp:setName(item:getName());
            end
        elseif (item:getCategory() == "Literature") and (temp:getCategory() == "Literature") then
            --������B ���������B�E���I�M��
            recipe_saveOldPages(item, temp, getPlayer())
        end
    end
    dataCheck = PATCH_dataCheck

    function PATCH_GFContainerHandle(container)
        local items = container:getItems();
        if (items ~= nil) then
            for i = 0, items:size() - 1 do
                if (items:get(i) ~= nil) then
                    local item = items:get(i);
                    if (item:getCategory() == "Container") then
                        PATCH_GFContainerHandle(item:getItemContainer());
                        PATCH_GFreplaceItem(container, item)
                    else
                        if not checkModData(item, 'DryTime') then
                            PATCH_GFloadItem(item);
                        else
                            PATCH_GFreplaceItem(container, item)
                        end
                    end
                end
            end
        end
    end
    GFContainerHandle = PATCH_GFContainerHandle

    function PATCH_GFWorldItemReplace(item, square)
        PATCH_migrateModData(item)
        local shouldDry = GFShouldReplace(item);
        if shouldDry then
            local WI = item:getWorldItem();
            if (WI) ~= nil then
                if(item:getModData().Remaining <= 0) then
                    -- add item if its gonna turn
                    local temp = nil
                    if item:getModData().TurnInto and item:getModData().TurnInto ~= "" then
                        temp = instanceItem(item:getModData().TurnInto);
                        if temp ~= nil then
                            PATCH_GFloadItem(temp)
                            dataCheck(item, temp)
                            square:AddWorldInventoryItem(temp, 0.5, 0.5, 0, true);
                        end
                    end
                    -- Remove item if its supposed to dry.
                    WI:getSquare():transmitRemoveItemFromSquare(WI);
                    WI:removeFromWorld();
                    WI:removeFromSquare();
                    WI:setSquare(nil);
                end
            end
            --WI:removeFromSquare();
            --if item:getModData().TurnInto ~= "" or item:getModData().TurnInto ~= "out" then
            --    local temp = instanceItem(item:getModData().TurnInto);
            --    --local temp = InventoryItemFactory.CreateItem(self, item:getModData().TurnInto);
            --    if (temp) then
            --        PATCH_GFloadItem(temp)
            --        PATCH_dataCheck(item, temp)
            --        getPlayer():Say("WR: " .. item:getName() .. " with " .. temp:getName())
            --    end
            --    square:AddWorldInventoryItem(temp, 0.5, 0.5, 0, true);
            --    --print("item:getModData().TurnInto",item:getModData().TurnInto)
            --end
        end

        -- [Patch] savero, added this to add counter.
        --if(item:getModData().Remaining ~= nil) then
        --    item:getModData().Remaining = item:getModData().DryTime - item:getModData().StartTime;
        --end
    end
    GFWorldItemReplace = PATCH_GFWorldItemReplace

    function PATCH_GFWorldItemHandle(item, square)

        -- if (item:getCategory() == "Container") then
        --        GFContainerHandle(item:getItemContainer()) ;
        --
        --        GFreplaceItem(container,item)
        -- else

        if (item:getModData().Life == nil) then
            PATCH_GFloadItem(item);
        else

            if (item:getCategory() == "Container") then
                PATCH_GFContainerHandle(item:getItemContainer());
            end
            --getPlayer():Say(tostring(item:getType()));
            --item:getModData().Life = item:getModData().Life - (getGameTime():getWorldAgeHours() - item:getModData().Life);
            PATCH_GFWorldItemReplace(item, square)
        end
        -- end
    end
    GFWorldItemHandle = PATCH_GFWorldItemHandle

    function PATCH_GFItemCheck()
        if getPlayer() ~= nil then
            PATCH_GFContainerHandle(getPlayer():getInventory());
        end
        local cell = getWorld():getCell();
        if cell ~= nil then
            for x = (cell:getMinX() + 10), (cell:getMaxX() - 10) do
                for y = (cell:getMinY() + 10), (cell:getMaxY() - 10) do
                    for z = (cell:getMinZ()), (cell:getMaxZ()) do

                        local sq = cell:getGridSquare(x, y, z);
                        if (sq ~= nil) then
                            local items = sq:getObjects();
                            for j = 0, items:size() - 1 do
                                if (items:get(j):getContainer() ~= nil) then
                                    PATCH_GFContainerHandle(items:get(j):getContainer());
                                end
                            end
                            local items = sq:getWorldObjects();
                            for j = 0, items:size() - 1 do
                                if (items:get(j) and items:get(j):getItem()) then
                                    PATCH_GFWorldItemHandle(items:get(j):getItem(), sq);
                                end
                            end
                        end

                    end
                end
            end
        end
    end
    function GFItemCheck()
        PATCH_GFItemCheck()
    end

    --function PATCH_GFItemCheck()
    --    getPlayer():Say("Should load GFItemCheck");
    --    GFItemCheck()
    --end

    -- TOOLTIPS Section
    local function PATCH_Greenfire_tooltips(item)
        --   Extended Tooltips
        --    local freshUntrimmed = getPlayer():getInventory():getItemsFromType("FreshUnCanna")
        --    local freshTrimmed = getPlayer():getInventory():getItemsFromType("FreshTCanna")
        if ItemTimeTrackerMod and ItemTimeTrackerMod[item:getType()] then
            if item:hasModData() then
                local desc = "----Patch Greenfire by saveroo----\n"
                for k, v in pairs(item:getModData()) do
                    if k == 'Life' then
                        desc = desc .. "Life: " .. string.format("%.2f", v) .. " Hours\n"
                    elseif k == "StartTime" then
                        desc = desc .. "StartTime: " .. string.format("%.2f", v) .. "\n"
                    elseif k == "DryTime" then
                        desc = desc .. "DryTime: " .. string.format("%.2f", v) .. "\n"
                    elseif k == 'Remaining' then
                        desc = desc .. "Remaining: " .. string.format("%.2f", v) .. " Hours Left\n"
                        --if math.ceil(v) > 0 then
                        --local calc =
                        --(math.ceil(item:getModData()['DryTime'] - getGameTime():getWorldAgeHours() / item:getModData()['Life'])) * 100;
                        --desc = desc .. "Remaining: " .. string.format("%.2f",calc) .. "% Before dry\n";
                        --desc = desc .. "Remaining: " .. math.ceil(item:getModData()['Remaining']) .. " Hours Left\n"
                        --else
                        --    desc = desc .. "Remaining: Should be dry now.. \n"
                        --end
                    else
                        desc = desc .. tostring(k) .. ": " .. tostring(v) .. "\n"
                    end
                end
                item:setTooltip(desc)
            else
                --PATCH_GFloadItem(item);
                item:setTooltip("----Patch Greenfire----\nNo ModData found, (this could be a bug)\n or just wait till next tick")
            end
        end
    end
    -- Intercept tooltip setter
    local vanillaISToolTipInv = ISToolTipInv.setItem
    function ISToolTipInv:setItem(item)
        --getPlayer():Say("Should load tooltip");
        PATCH_Greenfire_tooltips(item)
        vanillaISToolTipInv(self, item)
    end

    -- intercept when details render
    local vanillaDrawItemDetails = ISInventoryPane.drawItemDetails
    --- @param item InventoryItem
    function ISInventoryPane:drawItemDetails(item, y, xoff, yoff, red)
        if item == nil then
            return ;
        end
        if ItemTimeTrackerMod[item:getType()] ~= nil then
            if item and item:hasModData() and item:getModData()['Remaining'] then
                local hdrHgt = self.headerHgt
                local top = hdrHgt + y * self.itemHgt + yoff
                local fgBar = { r = 0.0, g = 0.6, b = 0.0, a = 0.7 }
                local fgText = { r = 0.6, g = 0.8, b = 0.5, a = 0.6 }
                if red then
                    fgText = { r = 0.0, g = 0.0, b = 0.5, a = 0.7 }
                end
                self:drawTextAndProgressBar("Dry Time: ", (item:getModData()['DryTime'] - getGameTime():getWorldAgeHours()) / item:getModData()['Life'], xoff, top, fgText, fgBar)
            end
        else
            return vanillaDrawItemDetails(self, item, y, xoff, yoff, red)
        end
    end

    function PATCH_Greenfire_apply()
        PATCH_GFItemCheck()
    end

    local PATCH_Greenfire_every5hour = 0
    function PATCH_Greenfire_watcher()
        if PATCH_Greenfire_every5hour < 2 then
            PATCH_Greenfire_every5hour = PATCH_Greenfire_every5hour + 1
            return;
        end

        PATCH_Greenfire_apply()
        PATCH_Greenfire_every5hour = 0
    end

    -- Added
    local PATCH_Greenfire_clientModule = PATCH_Greenfire_clientModule or {}
    --- @param item InventoryItem
    function PATCH_Greenfire_clientModule.ItemCheck(item)
        if item ~= nil then
            PATCH_migrateModData(item);
            return PATCH_GFloadItem(item)
        end
        return false;
    end

    function PATCH_Greenfire_clientModule.onServerCommand(module, command, args)
        if module ~= "PATCH_Greenfire_clientModule" then return; end
        if(command == "ItemCheck") then
            --getPlayer():Say("ItemCheck")
            if args and args.item ~= nil then
                if PATCH_Greenfire_clientModule.ItemCheck(args.item) then
                    --getPlayer():Say("ItemCheck: " .. args.item:getType() .. " - " .. args.item:getModData().Life)
                    sendServerCommand("PATCH_Greenfire_serverModule", "AddItem", {
                        player = args.player or getPlayer(),
                        item = args.item
                    })
                end
            end
        end
    end
    Events.OnServerCommand.Add(PATCH_Greenfire_clientModule.onServerCommand)
    Events.OnGameStart.Add(PATCH_Greenfire_apply);
    Events.EveryHours.Add(PATCH_Greenfire_watcher);

    -- Add context option
    local function PATCH_Greenfire_checkSelected(item, itemType, player)
        --local items = getPlayerInventory(0):getItemsFromType(itemType)
        --for k,v in pairs(items) do
        --    if v:getModData()['Remaining'] then
        --        if v:getModData()['Remaining'] <= 0 then
        --            return true
        --        end
        --    end
        --end
        --return false
    end

    local function PATCH_Greenfire_context(player, context, items)
        for _, v in ipairs(items) do
            local item = v;
            if not instanceof(v, "InventoryItem") then
                item = v.items[1];
            end

            if item and ItemTimeTrackerMod[item:getType()] then
                context:addOption("Check Dry Level", player, PATCH_GFItemCheck, item)
            end
        end
    end
    Events.OnPreFillInventoryObjectContextMenu.Add(PATCH_Greenfire_context)

end
