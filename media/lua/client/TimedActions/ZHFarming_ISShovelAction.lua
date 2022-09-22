--[[
██████╗░███████╗███╗░░░███╗░█████╗░██╗░░░██╗██╗███╗░░██╗░██████╗░
██╔══██╗██╔════╝████╗░████║██╔══██╗██║░░░██║██║████╗░██║██╔════╝░
██████╔╝█████╗░░██╔████╔██║██║░░██║╚██╗░██╔╝██║██╔██╗██║██║░░██╗░
██╔══██╗██╔══╝░░██║╚██╔╝██║██║░░██║░╚████╔╝░██║██║╚████║██║░░╚██╗
██║░░██║███████╗██║░╚═╝░██║╚█████╔╝░░╚██╔╝░░██║██║░╚███║╚██████╔╝
╚═╝░░╚═╝╚══════╝╚═╝░░░░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--]]

-- This file is part of Farming Mechanism.
require 'ZHFarming_CoreAction'
require 'ZHFarming_Utils'
require 'ZHFarming_VanillaTimedAction'

local function removeAt(sq, __self)
    local _self = __self
    self = _self
    if self.sound and self.sound:isPlaying() then
        self.sound:stop();
    end
    self.item:getContainer():setDrawDirty(true);
    self.item:setJobDelta(0.0);
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
    CFarmingSystem.instance:sendCommand(_self.character, 'removePlant', args)
    ISBaseTimedAction.perform(_self)
end

local vanillaShovelAction = ISShovelAction.perform
function ISShovelAction:perform()
    if not ZHFarmingCore.module.remove() then
        -- Vanilla
        return vanillaShovelAction(self)
    end

    --local sq = self.plant:getSquare()
    plots = ZHFarmingCore:plotSchema(plotTypes.remove, self.plant:getSquare())
    if not plots then
        ZHUtils.debugSay(self.character, "No plots to remove~!")
        return
    end
    local plotCount = 0;
    plotCount = ZHFarmingCore:tilesCount(plots)

    if plotCount == 0 then return ISBaseTimedAction.perform(self); end
    self:adjustMaxTime(self.maxTime * plotCount)
    for _,v in pairs(plots) do
        removeAt(v, self)
    end
    self.character:Say("I just removing "..plotCount.." plots!")

    ZHFarmingCore.executeOnSucceed(self.character, plotCount, "remove")
end
