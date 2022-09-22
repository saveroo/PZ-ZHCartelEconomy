require "ISUI/ISToolTipInv"
require "ISUI/ISInventoryPaneContextMenu"
require 'ZHFarmingContext_main'
ZHFarmingContext = ZHFarmingContext or {}
local farmingPlan = {}

function farmingPlan.OnClick(item, player, context, module, state)

end

function farmingPlan.setModState(item, player, context, module, state)
    if item:hasModData() then
        local data = item:getModData()
        data.modules[module].state = state
        item:setName("[Farming Plan] "..data.modules[module].state.." "..module)
        --context:removeFromUIManager()
    end
end

function farmingPlan:addContext(player, context, item)
        local addOption = true;
        if addOption then
            context:addOption("Set My Plan", item, function() FarmingPlanUI.OnOpenPanel(item) end)
            ZHFarmingContext.seedingModule:createSeedContextMenu("Select Seed", context, item, false)
        end
    --local PLANNING_PAGES = context:addOption("Planning")
    --local MODULE_PAGES = context:getNew(context)
    --local OPTION_PAGES = context:getNew(context)
    --context:addSubMenu(PLANNING_PAGES, MODULE_PAGES)
    --
    ---- [1] Planning > Module Submenu
    ----local MODULE_PAGE_PLOT = MODULE_PAGES:addOption("Plot")
    ----local modulePageSeed = MODULE_PAGES:addOption("Seed")
    ----local modulePagePlow = MODULE_PAGES:addOption("Plow")
    --
    ---- [2] Planning > Module > Option Submenu
    ----local OPTION_SEED_STATE = context:getNew(context)
    ----OPTION_SEED_STATE:addOption("Turn on/off")
    ----MODULE_PAGES:addSubMenu(modulePageSeed, OPTION_SEED_STATE)
    --
    ----local ss = context:getNew(context)
    ----ss:addOption("Turn ewqeon/off")
    ----MODULE_PAGES:addSubMenu(MODULE_PAGE_PLOT, ss)
    --
    --if item:hasModData() and item:getModData().modules then
    --    local modules = item:getModData().modules
    --
    --    if modules.plot then
    --        for k, v in pairs(modules) do
    --            if v.state then
    --                local state = v
    --                local module = k
    --                local option = MODULE_PAGES:addOption(module)
    --                local optionState = context:getNew(context)
    --                if(state.state == "on") then
    --                    optionState:addOption("Turn off", item, farmingPlan.setModState, player, context, module, "off")
    --                else
    --                    optionState:addOption("Turn on", item, farmingPlan.setModState, player, context, module, "on")
    --                end
    --                MODULE_PAGES:addSubMenu(option, optionState)
    --            end
    --            --local module = v
    --            --local page = context:getNew(context)
    --            --page:addOption("Key:"..k.. " Value:"..v, farmingPlan.setModState, item, player, context, "plot", v)
    --            --MODULE_PAGES:addSubMenu(MODULE_PAGE_PLOT, page)
    --        end
    --        -- Set
    --        --local plot = modules.plot
    --        --local plotSchema = plot.schema
    --        --local plotPage = context:getNew(context)
    --        --plotPage:addOption(plotSchema)
    --        --MODULE_PAGES:addSubMenu(MODULE_PAGE_PLOT, plotPage)
    --    end
    --end

end
-- so i not forgot
-- [SUBPAGE]:addSubMenu([SUBPAGE][ID], contet:getNew(context):addOption)

ZHFarmingContext.farmingPlan = farmingPlan

--local PLANNING_PAGES = context:addOption("Planning")
--local MODULE_PAGES = context:getNew(context)
--local OPTION_PAGES = context:getNew(context)
--context:addSubMenu(PLANNING_PAGES, MODULE_PAGES)
--context:addSubMenu(MODULE_PAGES, OPTION_PAGES)
--
---- [1] Planning > Module Submenu
--local modulePagePlot = MODULE_PAGES:addOption("Plot")
--local modulePagePlow = MODULE_PAGES:addOption("Plow")
--local modulePageSeed = MODULE_PAGES:addOption("Seed")
--
--context:addSubMenu(MODULE_PAGES, modulePagePlot)
--context:addSubMenu(MODULE_PAGES, modulePagePlow)
--context:addSubMenu(MODULE_PAGES, modulePageSeed)
--
---- [2] Planning > Module > Option Submenu
--local OPTION_PLOT = OPTION_PAGES:addOption("Turn on/off")
--local OPTION_PLOW = OPTION_PAGES:addOption("Turn on/off")
--local OPTION_SEED = OPTION_PAGES:addOption("Turn on/off")
--
--context:addSubMenu(OPTION_PAGES, OPTION_PLOT)
--context:addSubMenu(OPTION_PAGES, OPTION_PLOW)
--context:addSubMenu(OPTION_PAGES, OPTION_SEED)

--local Vanilla_ISToolTipInv = ISToolTipInv.render
--function ISToolTipInv:render()
--    if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
--        local itemObj = self.item
--        if itemObj and itemObj:getType() == "SkillRecoveryJournal" then
--
--            local tooltipStart, skillsRecord = SRJ.generateTooltip(itemObj)
--
--            local font = getCore():getOptionTooltipFont()
--            local fontType = fontDict[font] or UIFont.Medium
--            local textWidth = math.max(getTextManager():MeasureStringX(fontType, tooltipStart),getTextManager():MeasureStringX(fontType, skillsRecord))
--            local textHeight = getTextManager():MeasureStringY(fontType, tooltipStart)
--
--            if skillsRecord then textHeight=textHeight+getTextManager():MeasureStringY(fontType, skillsRecord)+8 end
--
--            local journalTooltipWidth = textWidth+fontBounds[font]
--            ISToolTipInv_render_Override(self,journalTooltipWidth)
--
--            local tooltipY = self.tooltip:getHeight()-1
--
--            self:setX(self.tooltip:getX() - 11)
--            if self.x > 1 and self.y > 1 then
--                local yoff = tooltipY + 8
--                local bgColor = self.backgroundColor
--                local bdrColor = self.borderColor
--
--                self:drawRect(0, tooltipY, journalTooltipWidth, textHeight + 8, math.min(1,bgColor.a+0.4), bgColor.r, bgColor.g, bgColor.b)
--                self:drawRectBorder(0, tooltipY, journalTooltipWidth, textHeight + 8, bdrColor.a, bdrColor.r, bdrColor.g, bdrColor.b)
--                drawDetailsTooltip(self, tooltipStart, skillsRecord, 15, yoff, fontType)
--                yoff = yoff + 12
--            end
--        else
--            Vanilla_ISToolTipInv(self)
--        end
--    end
--end
