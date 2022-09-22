if getActivatedMods():contains("jiggasGreenfireMod") then
    require "HarvestCode";

    function commandWrap(item)
        sendServerCommand("PATCH_Greenfire_clientModule", "ItemCheck", {
            player = getPlayer(),
            item = item,
        });
    end

    local PATCH_Greenfire_serverModule = PATCH_Greenfire_serverModule or {}
    function PATCH_Greenfire_serverModule.onClientCommand(module, command, args)
        if module ~= "PATCH_Greenfire_serverModule" then return; end
        if(command == "AddItem") then
            if args and args.player and args.item ~= nil then
                args.player:getInventory():AddItem(args.item);
            end
        end
    end

    function TrimFresh(items, result, char)
        local times = ZombRand(2,3);
        for i=1, times do
            local item1 = InventoryItemFactory.CreateItem("Greenfire.FreshCannabisFanLeaf");
            if(item1) then
                commandWrap(item1);
                char:getInventory():AddItem(item1);
            end
        end
        times = ZombRand(3,5);
        for i=1, times do
            local item2 = InventoryItemFactory.CreateItem("Greenfire.FreshCannabisSugarLeaf");
            if(item2) then
                commandWrap(item2);
                char:getInventory():AddItem(item2);
            end
        end
        if result and (ItemTimeTrackerMod[result:getType()] ~= nil) then
            -- Replace Legacy code
            if result and result:hasModData() and ItemTimeTrackerMod[result:getType()] ~= nil and result:getModData()['StartYear'] then
                result:getModData().StartYear = nil;
                result:getModData().StartMonth = nil;
                result:getModData().StartDay = nil;
                result:getModData().StartHour = nil;
            end

            result:getModData().Life = ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().TurnInto = ItemTimeTrackerMod[result:getType()]["TurnInto"];

            -- Patch Savero
            result:getModData().StartTime = getGameTime():getWorldAgeHours();
            result:getModData().DryTime = getGameTime():getWorldAgeHours() + ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().Remaining = result:getModData().DryTime - getGameTime():getWorldAgeHours();
            if result:getModData().ShouldDry == nil then
                if(result:getModData().DryTime - getGameTime():getWorldAgeHours() <= 0) then
                    result:getModData().ShouldDry = true;
                else
                    result:getModData().ShouldDry = false;
                end
            end
            for i=0, (items:size()-1) do
                local item = items:get(i);

                -- Initialize modData for untrimmed required, before being trimmed.
                if item:getType() == "FreshUnCanna" then
                    if item:getModData().StartTime == nil then
                        items:get(i):getModData().Life = ItemTimeTrackerMod[items:get(i):getType()]["Life"];
                        items:get(i):getModData().TurnInto = ItemTimeTrackerMod[items:get(i):getType()]["TurnInto"];

                        -- Patch Savero
                        items:get(i):getModData().StartTime = getGameTime():getWorldAgeHours();
                        items:get(i):getModData().DryTime = getGameTime():getWorldAgeHours() + ItemTimeTrackerMod[items:get(i):getType()]["Life"];
                        items:get(i):getModData().Remaining = items:get(i):getModData().DryTime - getGameTime():getWorldAgeHours();
                        if item:getModData().ShouldDry == nil then
                            if(item:getModData().DryTime - getGameTime():getWorldAgeHours() <= 0) then
                                item:getModData().ShouldDry = true;
                            else
                                item:getModData().ShouldDry = false;
                            end
                        end
                    end
                end

                -- For trimmed item
                -- TODO: Should calculate based on Trimmed Cannabis time
                if item:getType() == "FreshUnCanna" then
                    if result:getModData().Life > (items:get(i):getModData().Life - items:get(i):getModData().Remaining) then
                        result:getModData().Life = items:get(i):getModData().Life;

                        --	Patch Savero
                        result:getModData().StartTime = items:get(i):getModData().StartTime;
                        result:getModData().DryTime = items:get(i):getModData().DryTime;
                        result:getModData().Remaining = items:get(i):getModData().Remaining;
                        result:getModData().ShouldDry = items:get(i):getModData().ShouldDry;
                    end
                end
            end
        end
    end

    function TrimDry(items, result, char)
        local times = ZombRand(2,3);
        for i=1, times do
            char:getInventory():AddItem("Greenfire.CannabisShake");
        end
    end

    function RollCigar(items, result, char)
        if (ItemTimeTrackerMod[result:getType()] ~= nil) then
            result:getModData().Life = ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().TurnInto = ItemTimeTrackerMod[result:getType()]["TurnInto"];

            -- Patch Savero
            result:getModData().StartTime = getGameTime():getWorldAgeHours();
            result:getModData().DryTime = getGameTime():getWorldAgeHours() + ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().Remaining = result:getModData().DryTime - getGameTime():getWorldAgeHours();
            result:getModData().ShouldDry = result:getModData().DryTime - getGameTime():getWorldAgeHours() <= 0;
        end
    end

    function JarCanna(items, result, char)
        if (ItemTimeTrackerMod[result:getType()] ~= nil) then
            result:getModData().Life = ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().TurnInto = ItemTimeTrackerMod[result:getType()]["TurnInto"];

            --	patch savero
            result:getModData().StartTime = getGameTime():getWorldAgeHours();
            result:getModData().DryTime = getGameTime():getWorldAgeHours() + ItemTimeTrackerMod[result:getType()]["Life"];
            result:getModData().Remaining = result:getModData().DryTime - getGameTime():getWorldAgeHours();
            result:getModData().ShouldDry = result:getModData().DryTime - getGameTime():getWorldAgeHours() <= 0;
        end
    end

    function OpenCannaJar(items, result, char)
        char:getInventory():AddItem("Base.EmptyJar", 1);
        char:getInventory():AddItem("Base.JarLid", 1);
    end

    function MakeShake(items, result, char)
        local ceiling = 20;
        local seedtype = "Greenfire.CannabisSeed";
        if char:HasTrait("Lucky") then
            ceiling = 12;
        elseif char:HasTrait("Unlucky") then
            ceiling = 100;
        end
        for i=0, (items:size() - 1) do
            if items:get(i):getType() == "HCHempbudcured" then
                seedtype = "Hydrocraft.HCHempseeds";
            end
        end
        local diceroll = ZombRand(1,ceiling);
        if diceroll == 1 then
            char:Say(getText("UI_speech_seed1"));
            char:getInventory():AddItem(seedtype);
            if char:HasTrait("Lucky") then
                diceroll = ZombRand(1,20);
                if diceroll == 20 then
                    char:getInventory():AddItem(seedtype);
                end
            end
        end
    end

    function SiftShake(items, result, char)
        local ceiling = 100;
        if char:HasTrait("Lucky") then
            ceiling = 20;
        elseif char:HasTrait("Unlucky") then
            ceiling = 200;
        end
        local diceroll = ZombRand(1,ceiling);
        if diceroll == 1 then
            char:Say(getText("UI_speech_seed2"));
            char:getInventory():AddItem("Greenfire.CannabisSeed");
            diceroll = ZombRand(1,20);
            if diceroll == 20 then
                char:getInventory():AddItem("Greenfire.CannabisSeed");
            end
        end
    end

    function MakeWrap(items, result, char)
        local times = 2;
        for i=1, times do
            char:getInventory():AddItem("Greenfire.Tobacco");
        end
    end

    function CutTobacco(items, result, char)
        local times = ZombRand(3,6);
        for i=1, times do
            char:getInventory():AddItem("Greenfire.CigarLeaf");
        end
    end

--
    Events.OnClientCommand.Add(PATCH_Greenfire_serverModule.onClientCommand);
end
