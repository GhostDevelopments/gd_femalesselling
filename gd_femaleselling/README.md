# Glamour Studio V2

A luxury standalone crafting and selling system for FiveM, designed for high-end cosmetic items. This resource features a custom Tailwind-powered UI and utilizes **ox_inventory**, **ox_lib**, and **ox_target**.

## Features
- **Studio Shop**: Purchase materials and equipment from a dedicated shop NPC.
- **Luxury Crafting**: High-end NUI for creating professional cosmetics.
- **Selling System**: Offer products to NPCs on the street with a custom "Offer/Accept/Decline" UI.
- **Placement System**: Place your Makeup Station anywhere to start crafting.
- **Gender Restricted**: Studio blip only visible to female characters.

## Requirements
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Copy the `cs-femalesellingV2` folder into your resources directory.
2. Add `ensure cs-femalesellingV2` to your `server.cfg`.
3. Add the items below to your `ox_inventory/data/items.lua`.
4. Ensure item images are placed in `ox_inventory/web/images/`.

## Ox Inventory Item Setup

Add these items to your `@ox_inventory/data/items.lua` file:

```lua
-- Equipment
['makeup_station'] = {
    label = 'Makeup Station',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A portable professional makeup station.'
},

['makeup_chair'] = {
    label = 'Makeup Chair',
    weight = 3000,
    stack = false,
    close = true,
    description = 'A luxury chair for your studio.'
},

-- Materials
['cosmetic_pigments'] = {
    label = 'Cosmetic Pigments',
    weight = 50,
    stack = true,
    description = 'Fine pigments for professional makeup.'
},

['cream_base'] = {
    label = 'Cream Base',
    weight = 100,
    stack = true,
    description = 'A smooth base for all cream products.'
},

['mixing_oils'] = {
    label = 'Mixing Oils',
    weight = 100,
    stack = true,
    description = 'High-grade oils for blending.'
},

['empty_container'] = {
    label = 'Empty Container',
    weight = 20,
    stack = true,
    description = 'A clean container for your products.'
},

-- Finished Products
['velvet_lipstick'] = {
    label = 'Velvet Matte Lipstick',
    weight = 100,
    stack = true,
    description = 'A high-quality matte finish lipstick.'
},

['rose_lipgloss'] = {
    label = 'Rose Lip Gloss',
    weight = 100,
    stack = true,
    description = 'Luxury high-shine lip gloss.'
},

['tinted_lipbalm'] = {
    label = 'Tinted Lip Balm',
    weight = 100,
    stack = true,
    description = 'Hydrating lip balm with a hint of color.'
},

['glow_foundation'] = {
    label = 'Glow Foundation',
    weight = 150,
    stack = true,
    description = 'Radiant finish foundation.'
},

['silk_concealer'] = {
    label = 'Silk Concealer',
    weight = 120,
    stack = true,
    description = 'Full coverage silk finish concealer.'
},
```

## How to Use

### Studio Shop
1. Visit the **Glamour Studio Shop** (Blip visible to females only).
2. Talk to the shop assistant to purchase materials and the **Makeup Station**.

### Crafting
1. Use the **Makeup Station** from your inventory to place it.
2. Interact with the station to open the **Glamour Studio** interface.
3. Select a product to craft. You must have the required materials.

### Selling
1. Stand near NPCs and use the command `/sellfemaleitems` (or your configured command).
2. Approach an NPC and interact to offer them products.
3. A selection UI will appear at the bottom. Choose the product you want to sell.
4. The customer will make an offer. You can **Accept** or **Decline**.

## Configuration
Edit `config/config.lua` to adjust:
- Shop locations and Ped models.
- Crafting recipes and durations.
- Selling prices (min/max) and quantities.
- Allowed NPC models for selling.
