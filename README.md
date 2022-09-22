### Introduction

A farming action overhaul of Project Zomboid vanilla 1 plot farming system. This mod adds a new farming system alike of Stardew valley/harvest moon series. to be used with Jiggasgreenfire (as for now), this was originally created for the server I'm playing at, might be separated into a standalone mod in the future.

### Mods Requirements
As for now the mod are merged with several ideation, which require few mods in order to activate.
- [jiggasGreenfire](https://steamcommunity.com/sharedfiles/filedetails/?id=1703604612)
- [MVM](https://steamcommunity.com/sharedfiles/filedetails/?id=2356682893)

### What's included?
Below are the prefix for every ideation that will be separated in later phase of the development.
- ZHFarming (overhaul of vanilla farming system)
- ZHCartelEconomy (added new economy progression system)
- GFPatch (patch for jiggasGreenfire, overhauling drying mechanism, seamless integration, you can just load it right away and it will replace the base legacy drying system)

### Added Items:
- ZHFarming 
  - El Vero Farming Magazine
  - El Vero Fertilizer (20 uses) (can be crafted from reading El Vero Farming Magazine)
  - Watering Can Size Variant (2x,4x,8x,16x,20x) (can be bought in [ZH] Farming shop)
  - Farming Plan Book
  - 8 Module Book
- ZHCartelEconomy
  - New Access Card (RS/WP/LV/KNOX)
  - Legal Card (20 uses)
  - Customer Receipts (WP/LV/KNOX)

### JiggasGreenfire Patch
- Check for any Legacy Drying Data and replace with this patch approach
- Overhaul of drying time calculation
- Added extra tooltip and progress bar to show the drying time.

### Farming Plan Mechanism
- Can be enabled with 2 ways, either by creating plan module item or by using the farming plan book.
- There are 8 modules in form of book item (plot/plow/seed/harvest/water/fertilize/remove/continuation)
  - Each module must be hold within the player main inventory to activate the new mechanism for certain action
    - [Module] Plot
        - Activate the plot module, This must be activated in order for other module to works.
        - plotting module will make the player to able create 3x3 (9 tiles) of plot in 1 action. 
    - [Module] Plow
      - Activate the plowing module.
    - [Module] Seed
      - Will activate the seeding module.
      - It has set seed context menu, to set the desired seeds, for continuation purpose.
      - So if continuation is turned on, it will automatically sowing the seed after plowing if seeds are available.
    - [Module] Water
      - Activate the water module.
      - Special can (2x/4x/8x/16x/20x) must be used in order for it to works.
      - has the continuation system of fertilize after watering action
    - [Module] Fertilize
      - Activate the fertilize module.
    - [Module] Harvest
      - Activate the harvest module.
    - [Module] Remove
      - Activate the remove module.
    - [Module] Continuation
      - Activate the Continuation module.
      - it will make every other module action, if performed will perform next possible step, such as watering after seeding.
- If you had only the modules, either holding it or drop it to activate the mods
- To create a Farming Plan Book you need to have all those modules, and combine it into single book
- The book have Set Plan which will render a Custom UI to activate the modules
- The book have extra tooltips to show the current module status and your farming action statistic.

### Cartel Economy Progression Flow
There are 4 Town Progression to be unlocked by the player. Each progression will unlock new available item, selling price and BlackMarket access, also a discounted price.

- Town Progression 1: RS (Rosewood) Cartel
  - Available to access by having [RS Cartel Contact Card]
- Town Progression 2: WP (Westpoint) Cartel
  - Available to access by having [RS Cartel Contact Card]
  - Available to access by having [WP Cartel Contact Card]
- Town Progression 3: LV (Louisville) Cartel
  - Available to access by having [RS Cartel Contact Card]
  - Available to access by having [WP Cartel Contact Card]
  - Available to access by having [LV Cartel Contact Card]
- Town Progression 4: KNOX (KNOX)
  - Available to access by having [Legal Document], [Cartel ID Card]

### License and Copyright
<img src="https://mirrors.creativecommons.org/presskit/buttons/80x15/png/cc-zero.png" data-canonical-src="https://mirrors.creativecommons.org/presskit/buttons/80x15/png/cc-zero.png" width="80" height="15" />

[ZHCartelEconomy](https://github.com/saveroo/ZHCartelEconomy) by [saveroo](https://github.com/saveroo)

To the extent possible under law, the person who associated CC0 with
[ZHCartelEconomy](https://github.com/saveroo/ZHCartelEconomy) has waived all copyright and related or neighboring rights
to [ZHCartelEconomy](https://github.com/saveroo/ZHCartelEconomy).

The person who associated a work with this deed has dedicated the work to the public domain by waiving all of his or her rights to the work worldwide under copyright law, including all related and neighboring rights, to the extent allowed by law.

You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission. See Other Information below.

- In no way are the patent or trademark rights of any person affected by CC0, nor are the rights that other persons may have in the work or in how the work is used, such as publicity or privacy rights.
- Unless expressly stated otherwise, the person who associated a work with this deed makes no warranties about the work, and disclaims liability for all uses of the work, to the fullest extent permitted by applicable law.
- When using or citing the work, you should not imply endorsement by the author or the affirmer.
