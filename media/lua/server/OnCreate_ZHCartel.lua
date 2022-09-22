-- local function addExistingItemType(scriptItems, type)
-- 	local all = getScriptManager():getItemsByType(type)
-- 	for i=1,all:size() do
-- 		local scriptItem = all:get(i-1)
-- 		if not scriptItems:contains(scriptItem) then
-- 			scriptItems:add(scriptItem)
-- 		end
-- 	end
-- end

-- Create RS Customer Receipt
function ZHCartel_RS_OnCreate(items, result, player)
    player:Say("Don't tell anyone eh...")
    player:getInventory():AddItem("ZHCartel.ZH_Cartel_RSCustomer")
end

-- Create WP Customer Receipt
function ZHCartel_WP_OnCreate(items, result, player)
    player:Say("Don't tell anyone eh...")
    player:getInventory():AddItem("ZHCartel.ZH_Cartel_WPCustomer")
end

-- Create LV Customer Receipt
function ZHCartel_LV_OnCreate(items, result, player)
    player:Say("Don't tell anyone eh...")
    player:getInventory():AddItem("ZHCartel.ZH_Cartel_LVCustomer")
end

-- Create KNOX Customer Receipt
function ZHCartel_KNOX_OnCreate(items, result, player)
    player:Say("Don't tell anyone eh...")
    player:getInventory():AddItem("ZHCartel.ZH_Cartel_KNOXCustomer")
end

-- Create Pinkslip Insurance
function ZHCartel_BlackMarket_OnCreate(items, result, player)
    player:Say("Ah.. i feel assured")
    if result:getType() == "M113X_APCWAR" then
        player:getInventory():AddItem("ZHCartel.ZH_Cartel_Blackmarket_M113X_APCWAR_Ownership")
    elseif result:getType() == "Rhino" then
        player:getInventory():AddItem("ZHCartel.ZH_Cartel_Blackmarket_Rhino_Ownership")
    end
end

-- Chcking legal card are 0 or below 5 unit
function ZHCartel_Renew_Document_OnTest(item)
    if item:getType() == "ZHCartel.ZH_Cartel_Legal_Card" then
        if item:getUsedDelta() < 0.25 then return true; end
    end
    return true
end

function ZHCartel_Renew_Document_OnCreate(items, result, player)
    local legalCard = nil
    for i=0, items:size()-1 do
        if items:get(i):getType() == "ZHCartel.ZH_Cartel_Legal_Card" then
            legalCard = items:get(i);
        end
     end
     if legalCard ~= nil then
        legalCard:setUseDelta(0.05);
     end
end
