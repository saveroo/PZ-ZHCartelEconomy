-- Language: lua
-- Path: media\lua\client\Context\ZHFarmingContext_farmingPlan.lua
-- Compare this snippet from media\lua\client\Context\ZHFarmingContext_seedingModule.lua:

-- UI
FarmingPlanUI = ISPanel:derive("FarmingPlanUI");
FarmingPlanUI.instance = nil
FarmingPlanUI.itemInstance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

FarmingPlanUI.cheatTooltips = {}
FarmingPlanUI.cheatTooltips["Fast Move"] = "Fast move:\nMove - arrow keys\nFloor Up/Down - PageUp/PageDown keys"
FarmingPlanUI.cheatTooltips["LootZed"] = "Show distribution list\nClick on container icon in loot menu to show"

function FarmingPlanUI.OnOpenPanel(item)
    if item == nil then
        getPlayer():Say("I don't have the book")
        return;
    end
    if item and item:getType() == "ZHFarming_farming_plan" then
        if not item:hasModData() then
            FarmingPlanUI.initModData(item)
        end

        if FarmingPlanUI.instance == nil then
            FarmingPlanUI.instance = FarmingPlanUI:new (50, 200, 212, 350, getPlayer(), item);
            FarmingPlanUI.instance:initialise();
            --ISCheatPanelUI.instance:removeFromUIManager()
            --ISCheatPanelUI.instance = nil
        end

        if FarmingPlanUI.itemInstance == nil then
            FarmingPlanUI.itemInstance = item:getID()
        end

        if FarmingPlanUI.instance and item:getID() ~= FarmingPlanUI.itemInstance then
            getPlayer():Say("Different Instance")
            FarmingPlanUI.instance = nil;
            FarmingPlanUI.instance = FarmingPlanUI:new (50, 200, 212, 350, getPlayer(), item);
            FarmingPlanUI.instance:initialise();
            FarmingPlanUI.itemInstance = item:getID()
            FarmingPlanUI.instance.item = item
        end

        --if FarmingPlanUI==nil then
        --end
        FarmingPlanUI.instance:addToUIManager();
        FarmingPlanUI.instance:setVisible(true);

        return FarmingPlanUI.instance;
    end
end

--************************************************************************--
--** FarmingPlanUI:initialise
--**
--************************************************************************--

function FarmingPlanUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 70
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_RadioSave"), self, FarmingPlanUI.onClick);
    self.ok.internal = "SAVE";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    self.close = ISButton:new(self.ok:getRight()+10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "Close", self, FarmingPlanUI.onClick);
    self.close.internal = "CANCEL";
    self.close.anchorTop = false
    self.close.anchorBottom = true
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);

    self.tickBox = ISTickBox:new(30, 50, 100, FONT_HGT_SMALL + 5, "Your Farming Plan", self, self.onTicked)
    self.tickBox.choicesColor = {r=1, g=1, b=1, a=1}
    self.tickBox.leftMargin = 2
    self.tickBox:setFont(UIFont.Small)
    self:addChild(self.tickBox);

    self:showOptions()

    -- Plot
    self.lblPlot = ISLabel:new(self.tickBox:getX(), self.tickBox:getBottom(), FONT_HGT_SMALL + 5, "Plot", 1, 1, 1, 1, UIFont.Small, true);
    self:addChild(self.lblPlot);
    self.cbPlot = ISComboBox:new(self.lblPlot:getX()+40, self.tickBox:getBottom(), 60, FONT_HGT_SMALL + 5, self, self.onComboChange)
    self.cbPlot.leftMargin = 40
    self:addChild(self.cbPlot);

    self.lblSelectedSeed = ISLabel:new(self.tickBox:getX(), self.tickBox:getBottom()+20, FONT_HGT_SMALL + 5, "Selected Seed: (none)", 1, 2, 1, 1, UIFont.Small, true);
    self.lblSelectedSeed:initialise();
    self.lblSelectedSeed:instantiate();
    self:addChild(self.lblSelectedSeed);
    ----Seed
    --self.lblSeed = ISLabel:new(self.tickBox:getX(), self.tickBox:getBottom()+20, FONT_HGT_SMALL + 5, "Seed", 1, 1, 1, 1, UIFont.Small, true);
    --self:addChild(self.lblSeed);
    --self.cbSeed = ISComboBox:new(self.lblSeed:getX()+40, self.tickBox:getBottom()+20, 100, FONT_HGT_SMALL + 5, self, self.onComboChange)
    --self.cbSeed.leftMargin = 40
    --self:addChild(self.cbSeed);

    self:showOptionsCombo()
end

function FarmingPlanUI.initModData(item)
    if not item:hasModData() then
        local data = item:getModData()
        data.modules = {}
        data.owner = getPlayer():getUsername()
        data.modules.plot = data.modules.plot or {}
        data.modules.plow = data.modules.plow or {}
        data.modules.seed = data.modules.seed or {}
        data.modules.water = data.modules.water or {}
        data.modules.fertilize = data.modules.fertilize or {}
        data.modules.harvest = data.modules.harvest or {}
        data.modules.remove = data.modules.remove or {}
        data.modules.continuation = data.modules.continuation or {}

        data.modules['plot'].state = false
        data.modules['plot'].schema = '3x3'
        data.modules['plot'].options = {
            '3x3',
            '1x3',
        }
        --X,Y, loopTimes
        data.modules['plot'].schemas = {
            ['3x3'] = {
                {-1,-1,3},
                {-1,0,3},
                {-1,1,3},
            },
            ['1x3'] = {
                {0,0,3}
            },
        }

        data.modules['plow'].state = false
        data.modules['plow'].total = 0

        data.modules['seed'].state = false
        data.modules['seed'].selectedSeed = 'none'
        data.modules['seed'].props = nil
        data.modules['seed'].total = 0

        data.modules['water'].state = false
        data.modules['water'].afterSeed = false
        data.modules['water'].total = 0

        data.modules['fertilize'].state = false
        data.modules['fertilize'].afterWater = false
        data.modules['fertilize'].max = 4
        data.modules['fertilize'].total = 0

        data.modules['harvest'].state = false
        data.modules['harvest'].total = 0

        data.modules['remove'].state = false
        data.modules['continuation'].state = false
    end
end

function FarmingPlanUI:getModData(moduleName)
    if not self.item:hasModData() then
        FarmingPlanUI.initModData(self.item)
    end

    local data = self.item:getModData()
    return data.modules[moduleName]
end

function FarmingPlanUI:setModData(moduleName, selected)
    if not self.item:hasModData() then
        FarmingPlanUI.initModData(self.item)
    end

    local data = self.item:getModData()
    data.modules[moduleName] = selected
end

-- Plot Selection
function FarmingPlanUI:showOptionsCombo()
    self.setComboPlotFunction = {}

    -- Guard
    local plots = self:getModData('plot')
    if not plots then
        self.player:Say("I can't read the plan");
        return;
    end

    for k, v in pairs(plots.options) do
        self:addComboPlotOption(v, plots.schemas[v], function(self, selected)
            self:getModData('plot').schema = selected
            self:transmitModData()
        end)
    end

    if self:getModData('seed').selectedSeed ~= nil then
        self.lblSelectedSeed:setName("Selected Seed: ("..self:getModData('seed').selectedSeed..")")
    end

    --local typeOfSeedList = {}
    --local count = 0;
    --for typeOfSeed, props in pairs(farming_vegetableconf.props) do
    --    table.insert(typeOfSeedList, {
    --        id = count + 1,
    --        typeOfSeed = typeOfSeed,
    --        seedName = props.seedName,
    --        props = props,
    --        text = getText("Farming_" .. typeOfSeed)
    --    })
    --end
    --table.sort(typeOfSeedList, function(a, b) return not string.sort(a.text, b.text) end)
    --
    --for _, tos in ipairs(typeOfSeedList) do
    --    local seedsOwned = self.player:getInventory():getCountTypeRecurse(tos.props.seedName)
    --    self:addComboSeedOption(tos.text, tos, self:getModData('seed').selectedSeed, function(self, selected)
    --        self:getModData('seed').selectedSeed = selected.typeOfSeed
    --        self:getModData('seed').props = selected
    --        self:transmitModData()
    --    end)
    --    --self.addTooltips(seedsOwned, tos.typeOfSeed, self.cbSeed)
    --    --self.cbSeed:getOptionTooltip(tos.id-1)
    --    --if seedsOwned then
    --    --    local menus = seedOfChoiceMenu:addOption(tos.text .. "(" .. seedsOwned .. ")", item, self.OnClick, tos, self.player)
    --    --    self.addTooltips(seedsOwned, tos.typeOfSeed, menus)
    --    --end
    --end
end

function FarmingPlanUI:showOptions()
    self.setFunction = {}
    --self.player:Say(" < item?")
    --self.player:Say(self.item == nil.." < item?")
    --self.player:Say(self.item ~= nil.." < item?")

    local data = self.item:getModData()
    if not data then self.initModData(self.item) end
    self.player:Say("Hmm...")
    local modules = data.modules
    --
    for k, v in pairs(modules) do
        --self.player:Say(k)
        if v.state ~= nil then
            self:addOption("Enable "..k, self:getModData(k).state, function(self, selected)
                self:getModData(k).state = selected
            end)
        end
    end

    self.tickBox:setWidthToFit()
    self:setHeight(self.instance.tickBox:getBottom() + 40 + 20 + self.ok:getHeight() + 10)
end

function FarmingPlanUI:addComboPlotOption(text, selected, setFunction)
    --local n = self.cbPlot:addOption(text)
    --self:getModData("plot").schema = selected
    if not self.setComboPlotFunction then
        self.setComboPlotFunction = {}
    end
    self.cbPlot:addOptionWithData(text, selected)
    self.setComboPlotFunction[text] = setFunction
end

function FarmingPlanUI:addComboSeedOption(text, selected, setFunction)
    if not self.setComboSeedFunction then
        self.setComboSeedFunction = {}
    end
    self.cbSeed:addOptionWithData(text, selected);
    self.cbSeed.onChange = function(self, selected)
        self:getModData('seed').selectedSeed = selected.typeOfSeed
        self:getModData('seed').props = selected
    end
    local tooltipMap = {}
    tooltipMap[selected.typeOfSeed] = selected.props.seedsRequired*9 .. " seeds"
    self.cbSeed:setToolTipMap(tooltipMap)
    local nbOfSeed = getNbOfSeed(selected.props.seedsRequired*9, text.."Seed", self.player:getInventory())
    if nbOfSeed < selected.props.seedsRequired*9 then
        self.instance.lblSeed:setColor(2, 0,0 )
    else
        self.instance.lblSeed:setColor(1, 1, 1)
    end
    self.setComboSeedFunction[text] = setFunction
end

function FarmingPlanUI:addOption(text, selected, setFunction)
    local n = self.tickBox:addOption(text)
    self.tickBox:setSelected(n, selected)
    self.setFunction[n] = setFunction
end

function FarmingPlanUI:onTicked(index, selected)
end
---@param option ISComboBox
function FarmingPlanUI.addTooltips(seedAvailable, typeOfSeed, option)
    if option:isMouseOver() then
        local tooltip = ISToolTip:new();
        tooltip:initialise();
        tooltip:setVisible(false);
        if not option.tooltipUI then
            option.tooltipUI = tooltip;
            option.tooltipUI:setOwner(option)
            option.tooltipUI:setVisible(false)
            option.tooltipUI:setAlwaysOnTop(true)
        end
        if not option.tooltipUI:getIsVisible() then
            if string.contains(text, "\n") then
                option.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                option.tooltipUI.maxLineWidth = 300
            end
            option.tooltipUI:addToUIManager()
            option.tooltipUI:setVisible(true)
        end
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
    else
        if option.tooltipUI and option.tooltipUI:getIsVisible() then
            option.tooltipUI:setVisible(false)
            option.tooltipUI:removeFromUIManager()
        end
    end
end

function FarmingPlanUI:render()
    if self.tickBox:isMouseOver() and FarmingPlanUI.cheatTooltips[self.tickBox.optionsIndex[self.tickBox.mouseOverOption]] ~= nil then
        local text = FarmingPlanUI.cheatTooltips[self.tickBox.optionsIndex[self.tickBox.mouseOverOption]]
        if not self.tickBox.tooltipUI then
            self.tickBox.tooltipUI = ISToolTip:new()
            self.tickBox.tooltipUI:setOwner(self.tickBox)
            self.tickBox.tooltipUI:setVisible(false)
            self.tickBox.tooltipUI:setAlwaysOnTop(true)
        end
        if not self.tickBox.tooltipUI:getIsVisible() then
            if string.contains(text, "\n") then
                self.tickBox.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                self.tickBox.tooltipUI.maxLineWidth = 300
            end
            self.tickBox.tooltipUI:addToUIManager()
            self.tickBox.tooltipUI:setVisible(true)
        end
        self.tickBox.tooltipUI.description = text
        self.tickBox.tooltipUI:setX(self.tickBox:getMouseX() + 23)
        self.tickBox.tooltipUI:setY(self.tickBox:getMouseY() + 23)
    else
        if self.tickBox.tooltipUI and self.tickBox.tooltipUI:getIsVisible() then
            self.tickBox.tooltipUI:setVisible(false)
            self.tickBox.tooltipUI:removeFromUIManager()
        end
    end
end

function FarmingPlanUI:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText("Farming Plan",
            self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, " Farming Plan") / 2),
            z,
            1,1,1,1,
            UIFont.Small);
end

function FarmingPlanUI:onComboChange(button)
    if button.internal == "SAVE" then
        --self.player:Say("Farming Plan: " )
        --for i, v in ipairs(self.cbSeed.options) do
        --    if self.cbSeed.options[i].selected then
        --        self.setComboSeedFunction[i](self, self.cbSeed.options[i].selected)
        --        --self:getModData("seed").selectedSeed = self.cbSeed.optionsIndex[self.cbSeed.selectedOption]
        --    end
        --    --if self.cbPlot:getOptionData() then
        --    --    self.setComboSeedFunction[k](self, self.cbSeed.optionsIndex[self.cbSeed.selectedOption])
        --    --end
        --    --self.cbSeed:setSelected(i, self.cbSeed:isSelected(i))
        --end
        --for i, v in ipairs(self.cbPlot.options) do
        --    if self.cbPlot.options[i].selected then
        --        self.setComboPlotFunction[i](self, self.cbPlot.options[i].selected)
        --    end
        --    --self.setComboPlotFunction[k](self, self.cbPlot:isSelected(k))
        --    --self:getModData("plot").schema = k
        --end
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function FarmingPlanUI:onClick(button)
    if button.internal == "SAVE" then
        if not self.player:isDead() then
            for i=1,#self.tickBox.options do
                self.setFunction[i](self, self.tickBox:isSelected(i))
            end
        end
        --for i, v in ipairs(self.cbSeed.options) do
        --    if self.cbSeed.options[i].selected then
        --        self.setComboSeedFunction[i](self, self.cbSeed.options[i].selected)
        --        --self:getModData("seed").selectedSeed = self.cbSeed.optionsIndex[self.cbSeed.selectedOption]
        --    end
        --    --if self.cbPlot:getOptionData() then
        --    --    self.setComboSeedFunction[k](self, self.cbSeed.optionsIndex[self.cbSeed.selectedOption])
        --    --end
        --    --self.cbSeed:setSelected(i, self.cbSeed:isSelected(i))
        --end
        for i, v in ipairs(self.cbPlot.options) do
            if self.cbPlot.options[i].selected then
                self.setComboPlotFunction[i](self, self.cbPlot.options[i].selected)
            end
            --self.setComboPlotFunction[k](self, self.cbPlot:isSelected(k))
            --self:getModData("plot").schema = k
        end
        self:setVisible(false);
        self:removeFromUIManager();
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
    --self:removeFromUIManager();
end

--************************************************************************--
--** FarmingPlanUI:new
--************************************************************************--
function FarmingPlanUI:new(x, y, width, height, player, item)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.player = player;
    o.item = item;
    o.itemID = item:getID();
    o.moveWithMouse = true;
    o.instance = o;
    return o;
end
--************************************************************************--
--** FarmingPlanUI:initialise **-
--************************************************************************--
-- Tooltip addition
local function ZHFarming_farming_plan_tooltip(item)
    if item and item:getType() == "ZHFarming_farming_plan" then
        if not item:hasModData() then
            return;
        end
        local modData = item:getModData();
        if modData and (modData.modules) then
            local desc = "--Your Farming Plan--\n"
            desc = desc .. "Selected Seed: " .. modData.modules['seed'].selectedSeed .. "\n"
            desc = desc .. "Selected Plot Schema: " .. modData.modules['plot'].schema .. "\n"

            -- Farming plan State
            desc = desc.."\n--[State]: \n"
            for k, v in pairs(modData.modules) do
                if v.state then
                    desc = desc .. tostring(k)..": " .. "ON" .. "\n"
                else
                    desc = desc .. tostring(k)..": " .. "OFF" .. "\n"
                end
            end

            -- Farming Statistic
            desc = desc.."\n--[Statistics]: \n"
            for k, v in pairs(modData.modules) do
                if v.total ~= nil then
                    desc = desc .. tostring(k)..": " .. v.total .. "\n"
                end
            end

            --for k, v in pairs(modData.modules) do
            --    for i, j in pairs(v) do
            --        if type(j) ~= "table" then
            --            if(j == true) then
            --                desc = desc .. tostring(k).." " .. i .. ": " .. "ON" .. "\n"
            --            elseif(j == false) then
            --                desc = desc ..tostring(k).." " .. i .. ": " .. "OFF" .. "\n"
            --            else
            --                desc = desc..tostring(k).." "..i.. ": "..tostring(j).."\n"
            --            end
            --        end
            --    end
            --    --if(type(v) ~= "table") then
            --    --end
            --end
            item:setTooltip(desc);
        else
            item:setTooltip("--No Plan--");
        end
    end
end

local vanillaISToolTipInv = ISToolTipInv.setItem
function ISToolTipInv:setItem(item)
    ZHFarming_farming_plan_tooltip(item)
    vanillaISToolTipInv(self, item)
end
