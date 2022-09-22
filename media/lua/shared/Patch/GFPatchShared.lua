if getActivatedMods():contains("jiggasGreenfireMod") then
    ItemTimeTrackerMod = ItemTimeTrackerMod or require('Timed/GFtimetracker_definitions') or {}

    function GFloadItem(item)
        -- Remove Legacy
        if item and item:hasModData() and ItemTimeTrackerMod[item:getType()] ~= nil and item:getModData()['StartYear'] then
            item:getModData().StartYear = nil;
            item:getModData().StartMonth = nil;
            item:getModData().StartDay = nil;
            item:getModData().StartHour = nil;
        end

        if item and ItemTimeTrackerMod[item:getType()] ~= nil then
            item:getModData().Life = ItemTimeTrackerMod[item:getType()]["Life"];
            item:getModData().TurnInto = ItemTimeTrackerMod[item:getType()]["TurnInto"];

            if item:getModData().StartTime == nil then
                item:getModData().StartTime = getGameTime():getWorldAgeHours();
            end

            if item:getModData().DryTime == nil then
                item:getModData().DryTime = getGameTime():getWorldAgeHours() + ItemTimeTrackerMod[item:getType()]["Life"];
            end

            if item:getModData().Remaining == nil then
                local remaining = item:getModData().DryTime - getGameTime():getWorldAgeHours();
                item:getModData().Remaining = remaining;
            end

            if item:getModData().ShouldDry == nil then
                if(item:getModData().DryTime - getGameTime():getWorldAgeHours() <= 0) then
                    item:getModData().ShouldDry = true;
                else
                    item:getModData().ShouldDry = false;
                end
            end

            return true;
        else
            return false
        end
    end
end
