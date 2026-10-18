# SellTech V2

SellTech is a standalone console crafting and street-selling system for FiveM. It keeps the existing portable table, user interface layout, interaction flow, and animations while replacing the previous cosmetics theme with console components and products. It uses **ox_inventory**, **ox_lib**, and **ox_target**.

## Features

- **Console Supply Shop**: Buy electronic components and the portable Console Workbench from the shop NPC.
- **Console Crafting**: Assemble finished consoles using the placed table.
- **Street Selling**: Call an NPC buyer and sell crafted consoles through the existing Offer/Accept/Decline interface.
- **All Player Models**: Female-only restrictions have been removed. Any player model can shop, place the table, craft, and sell.
- **Existing Animations**: The phone call, table placement, crafting, pickup, and deal animations are unchanged.

## Requirements

- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Copy the `gd_femaleselling` folder into your resources directory.
2. Add `ensure gd_femaleselling` to `server.cfg`.
3. Add the inventory items below to `ox_inventory/data/items.lua`.
4. Add matching item images to `ox_inventory/web/images/` if your server uses custom images.
5. Restart or refresh the resource after installation.

## Ox Inventory Items

Add these entries to `ox_inventory/data/items.lua`:

```lua
["console_workbench"] = {
    label = "Console Workbench",
    weight = 5000,
    stack = false,
    close = true,
    description = "A portable workbench for assembling consoles."
},

["circuit_board"] = {
    label = "Circuit Board",
    weight = 100,
    stack = true,
    description = "A populated circuit board for console assembly."
},

["microchip"] = {
    label = "Microchip",
    weight = 50,
    stack = true,
    description = "A high-performance console microchip."
},

["copper_wire"] = {
    label = "Copper Wire",
    weight = 25,
    stack = true,
    description = "Insulated wiring for electronic builds."
},

["plastic_casing"] = {
    label = "Plastic Casing",
    weight = 150,
    stack = true,
    description = "A durable shell for a console device."
},

["thermal_paste"] = {
    label = "Thermal Paste",
    weight = 20,
    stack = true,
    description = "Thermal compound for console cooling."
},

["handheld_console"] = {
    label = "Handheld Console",
    weight = 700,
    stack = true,
    description = "A compact portable gaming console."
},

["retro_console"] = {
    label = "Retro Console",
    weight = 1200,
    stack = true,
    description = "A classic console with modern internals."
},

["gaming_console"] = {
    label = "Gaming Console",
    weight = 1500,
    stack = true,
    description = "A powerful home gaming console."
},

["portable_console"] = {
    label = "Portable Console",
    weight = 900,
    stack = true,
    description = "A premium portable entertainment system."
},

["pro_console"] = {
    label = "Pro Console",
    weight = 1800,
    stack = true,
    description = "A high-end console built for serious players."
},
```

The resource uses the existing `money` ox_inventory item for shop purchases and sales payouts.

## Commands

- `/selltech`: Call a buyer after you have at least one sellable console.
- `/stopselltech`: Dismiss the active buyer and end the current selling interaction.

## How to Use

1. Visit the **Console Supply Shop** and buy components plus a **Console Workbench**.
2. Use the workbench item from your inventory to place the existing table.
3. Target the table and choose **Craft Consoles**.
4. Select a console and choose the quantity. The required components are shown in the UI.
5. Use `/selltech` to call a buyer, approach them, and target them with **Sell Goods**.
6. Select a console, then accept or decline the customer offer.

## Configuration

Edit `config/config.lua` to change:

- Shop location, shop ped, and blip.
- Console component prices.
- Console recipes and crafting durations.
- Sell prices and buyer quantities.
- NPC models that can arrive as buyers.
- Selling cooldown.

The table model remains `prop_table_03`, and the existing animation dictionaries are intentionally unchanged.
