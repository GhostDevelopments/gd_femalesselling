Config = {}
Config.Debug = false

-- The item name used in inventory to place the table
Config.CraftingItem = "console_workbench"

-- Model used for the crafting table object
Config.CraftingObject = "prop_table_03"

-- Shop location where players can buy console components
Config.ShopLocation = vector3(-191.38, -370.03, 31.3)
Config.ShopPed = {
    model = "s_f_y_shop_low",
    coords = vector4(-191.38, -370.03, 31.3, 213.82)
}
Config.UseBlip = true
Config.ShopBlip = {
    sprite = 617,
    color = 48,
    scale = 0.8,
    label = "Console Supply Shop"
}

-- Items available for purchase in the console supply shop
Config.ShopItems = {
    {
        name = "circuit_board",
        label = "Circuit Board",
        price = 100,
        description = "A populated board for console assembly."
    },
    {
        name = "microchip",
        label = "Microchip",
        price = 75,
        description = "A high-performance console processor."
    },
    {
        name = "copper_wire",
        label = "Copper Wire",
        price = 30,
        description = "Insulated wiring for electronic builds."
    },
    {
        name = "plastic_casing",
        label = "Plastic Casing",
        price = 45,
        description = "A durable shell for a console device."
    },
    {
        name = "thermal_paste",
        label = "Thermal Paste",
        price = 20,
        description = "Thermal compound for console cooling."
    },
    {
        name = "console_workbench",
        label = "Console Workbench",
        price = 100,
        description = "Your portable console assembly station."
    }
}

-- List of console products that can be crafted
Config.CraftableItems = {
    {
        name = "handheld_console",
        label = "Handheld Console",
        description = "1x Circuit Board, 1x Microchip, 1x Copper Wire, 1x Plastic Casing",
        ingredients = {
            { item = "circuit_board", label = "Circuit Board", amount = 1 },
            { item = "microchip", label = "Microchip", amount = 1 },
            { item = "copper_wire", label = "Copper Wire", amount = 1 },
            { item = "plastic_casing", label = "Plastic Casing", amount = 1 }
        },
        craftTime = 5000
    },
    {
        name = "retro_console",
        label = "Retro Console",
        description = "1x Circuit Board, 1x Microchip, 2x Copper Wire, 1x Plastic Casing",
        ingredients = {
            { item = "circuit_board", label = "Circuit Board", amount = 1 },
            { item = "microchip", label = "Microchip", amount = 1 },
            { item = "copper_wire", label = "Copper Wire", amount = 2 },
            { item = "plastic_casing", label = "Plastic Casing", amount = 1 }
        },
        craftTime = 6000
    },
    {
        name = "gaming_console",
        label = "Gaming Console",
        description = "2x Circuit Board, 2x Microchip, 2x Copper Wire, 1x Thermal Paste",
        ingredients = {
            { item = "circuit_board", label = "Circuit Board", amount = 2 },
            { item = "microchip", label = "Microchip", amount = 2 },
            { item = "copper_wire", label = "Copper Wire", amount = 2 },
            { item = "thermal_paste", label = "Thermal Paste", amount = 1 }
        },
        craftTime = 8000
    },
    {
        name = "portable_console",
        label = "Portable Console",
        description = "1x Circuit Board, 2x Microchip, 1x Copper Wire, 1x Plastic Casing",
        ingredients = {
            { item = "circuit_board", label = "Circuit Board", amount = 1 },
            { item = "microchip", label = "Microchip", amount = 2 },
            { item = "copper_wire", label = "Copper Wire", amount = 1 },
            { item = "plastic_casing", label = "Plastic Casing", amount = 1 }
        },
        craftTime = 7000
    },
    {
        name = "pro_console",
        label = "Pro Console",
        description = "2x Circuit Board, 2x Microchip, 3x Copper Wire, 1x Plastic Casing, 1x Thermal Paste",
        ingredients = {
            { item = "circuit_board", label = "Circuit Board", amount = 2 },
            { item = "microchip", label = "Microchip", amount = 2 },
            { item = "copper_wire", label = "Copper Wire", amount = 3 },
            { item = "plastic_casing", label = "Plastic Casing", amount = 1 },
            { item = "thermal_paste", label = "Thermal Paste", amount = 1 }
        },
        craftTime = 9000
    }
}

-- NPC models that can buy console products
Config.SellerModels = {
    "ig_abigail", "csb_abigail", "u_m_y_abner", "a_m_m_afriamer_01", "ig_mp_agent14",
    "csb_mp_agent14", "csb_agent", "s_f_y_airhostess_01", "s_m_y_airworker", "u_m_m_aldinapoli",
    "ig_amandatownley", "cs_amandatownley", "s_m_y_ammucity_01", "s_m_m_ammucountry",
    "ig_andreas", "cs_andreas", "csb_anita", "u_m_y_antonb", "csb_anton",
    "g_m_m_armboss_01", "g_m_m_armgoon_01", "g_m_y_armgoon_02", "g_m_m_armlieut_01",
    "mp_s_m_armoured_01", "s_m_m_armoured_01", "s_m_m_armoured_02", "s_m_y_armymech_01",
    "ig_ashley", "cs_ashley", "s_m_y_autopsy_01", "s_m_m_autoshop_01", "s_m_m_autoshop_02",
    "ig_money", "csb_money", "g_m_y_azteca_01", "u_m_y_babyd", "g_m_y_ballaeast_01",
    "g_m_y_ballaorig_01", "g_f_y_ballas_01", "ig_ballasog", "csb_ballasog",
    "g_m_y_ballasout_01", "u_m_m_bankman", "ig_bankman", "cs_bankman", "s_m_y_barman_01"
}

Config.SellItems = {
    ["handheld_console"] = { priceMin = 120, priceMax = 150, buyAmountMin = 1, buyAmountMax = 5 },
    ["retro_console"] = { priceMin = 180, priceMax = 225, buyAmountMin = 1, buyAmountMax = 4 },
    ["gaming_console"] = { priceMin = 260, priceMax = 320, buyAmountMin = 1, buyAmountMax = 3 },
    ["portable_console"] = { priceMin = 220, priceMax = 280, buyAmountMin = 1, buyAmountMax = 3 },
    ["pro_console"] = { priceMin = 350, priceMax = 425, buyAmountMin = 1, buyAmountMax = 3 }
}

Config.SellCooldown = 10000 -- 10 seconds by default
