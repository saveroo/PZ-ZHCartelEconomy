--[[
░██╗░░░░░░░██╗░█████╗░████████╗███████╗██████╗░██╗███╗░░██╗░██████╗░
░██║░░██╗░░██║██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██║████╗░██║██╔════╝░
░╚██╗████╗██╔╝███████║░░░██║░░░█████╗░░██████╔╝██║██╔██╗██║██║░░██╗░
░░████╔═████║░██╔══██║░░░██║░░░██╔══╝░░██╔══██╗██║██║╚████║██║░░╚██╗
░░╚██╔╝░╚██╔╝░██║░░██║░░░██║░░░███████╗██║░░██║██║██║░╚███║╚██████╔╝
░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

require 'ZHFarming_CoreAction'
require 'ZHFarming_Utils'
require 'ZHFarming_VanillaTimedAction'


-- planting at tiles
local function wateringAt(__self, sq)
    local _self = __self

    if not _self.item:getContainer() then return end
    _self.item:getContainer():setDrawDirty(true);
    _self.item:setJobDelta(0.0);

    if _self.sound and _self.sound ~= 0 then
        _self.character:getEmitter():stopOrTriggerSound(_self.sound)
    end

    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), uses = _self.uses }
    local plant = ZHUtils.getPlantAt(args.x, args.y, args.z)
    if plant and plant.waterLvl < 100 then
        -- Send command to server
        CFarmingSystem.instance:sendCommand(_self.character, 'water', args)
        -- if fertilized can is used
        --for i = 1, #ZHUtils.fertilizedCans do
        --    local primaryItem = _self.character:getPrimaryHandItem()
        --    if primaryItem and primaryItem:getType() == fertilizedCans[i] then
        --        fertilizePlant(plant, _self.character, args)
        --    end
        --end
        -- set local var
        --waterUse = waterUse + 1
        --wateredPlants[plant] = plant
        -- Check if plant is watered, then use source
        --local plt = CFarmingSystem.instance:getLuaObjectOnSquare(ZHUtils.fakeSq(x,y,z))
        --if plt then
        --
        --end
        local waterLvl = plant.waterLvl
        for i=1,_self.uses do
            if(waterLvl < 100) then
                if _self.item:getUsedDelta() > 0 then
                    _self.item:Use()
                end
                waterLvl = waterLvl + 5
                if(waterLvl > 100) then
                    waterLvl = 100
                end
            end
        end

        local leftUses = math.floor(_self.item:getUsedDelta()/_self.item:getUseDelta())
        -- 0.25 / 0.00125 = 800 * 0.00125 = 1
        _self.item:setUsedDelta(leftUses * _self.item:getUseDelta())
        --if ISFarmingMenu.walkToPlant(getPlayer(), ZHUtils.fakeSq(args.x, args.y, args.z)) then
        --    ISTimedActionQueue.add(ISWaterPlantAction:new(getSpecificPlayer(0), _self.character:getPrimaryHandItem(), leftUses,
        --            ZHUtils.fakeSq(args.x, args.y, args.z)
        --    , 20 + (6 * leftUses)));
        --end
    end
    ISBaseTimedAction.perform(_self)
end

local vanillaWaterPlantAction = ISWaterPlantAction.perform
function ISWaterPlantAction:perform()
    --Do Vanilla
    if not ZHFarmingCore.module.water() then
        return vanillaWaterPlantAction(self)
    end

    -- Should use special water can
    if not ZHUtils.IsSpecialCan(self.character) then
        return vanillaWaterPlantAction(self)
    end

    -- [1] Plot count
    local plots = ZHFarmingCore:plotSchema(plotTypes.water, ZHUtils.fakeSq(self.sq:getX(), self.sq:getY(), self.sq:getZ()))
    if not plots then return; end

    local plotCount = 0
    plotCount = ZHFarmingCore:tilesCount(plots)
    -- count plots
    --for i=1,#plots do
    --    local plot = plots[i]
    --    if plot then
    --        plotCount = plotCount + 1
    --    end
    --end

    if plotCount == 0 then return; end
    for _,sq in pairs(plots) do
        wateringAt(self, sq);
    end
    self.character:Say("I just watering "..plotCount.." plants!")

    -- [2] Fertilizing
    --if not ZHFarmingCore.module.fertilize() then return ISBaseTimedAction.perform(self); end
    --
    --plots = ZHFarmingCore.plotSchema(plotTypes.fertilize, ZHUtils.fakeSq(self.sq:getX(), self.sq:getY(), self.sq:getZ()))
    --if not plots then return; end
    --
    --local compostBag = ZHUtils.invCompostBag(self.character)
    --if not compostBag then self.character:Say("Seems i don't have enough compost") return; end
    --local handItem = ISWorldObjectContextMenu.equip(self.character, self.character:getPrimaryHandItem(), "CompostBag", true)
    --if compostBag then
    --    local plant = ZHUtils.getPlantAt(x,y,z)
    --    if plant then
    --        ISTimedActionQueue.add(ISFertilizeAction:new(self.character, handItem, plant,40*count));
    --    end
    --end

    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "water")
end
