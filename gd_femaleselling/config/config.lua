Config = {}
Config.Debug = false

-- The item name used in inventory to place the table
Config.CraftingItem = "crafting_table"

-- Model used for the crafting table object
Config.CraftingObject = "prop_table_03"

-- Shop Location (Where players can buy materials)
Config.ShopLocation = vector3(-191.38, -370.03, 31.3) -- Example: Near a store or studio
Config.ShopPed = {
    model = "s_f_y_shop_low",
    coords = vector4(-191.38, -370.03, 31.3, 213.82) -- Adjust heading as needed
}
Config.UseBlip = true
Config.ShopBlip = {
    sprite = 617,
    color = 48,
    scale = 0.8,
    label = "Glamour Studio Shop"
}

-- Items available for purchase in the studio shop
Config.ShopItems = {
    {
        name = "cosmetic_pigments",
        label = "Cosmetic Pigments",
        price = 100,
        description = "Fine pigments for professional makeup."
    },
    {
        name = "cream_base",
        label = "Cream Base",
        price = 20,
        description = "A smooth base for all cream products."
    },
    {
        name = "mixing_oils",
        label = "Mixing Oils",
        price = 30,
        description = "High-grade oils for blending."
    },
    {
        name = "glass_bottle",
        label = "Empty Cosmetic Container",
        price = 10,
        description = "A clean container for your products."
    },
    {
        name = "clothe_materials",
        label = "Cloth",
        price = 5,
        description = "Cloth For Crafting"
    },
    {
        name = "crafting_table",
        label = "Female Crafting Table",
        price = 100,
        description = "Your portable crafting station."
    }
}

-- List of items that can be crafted
Config.CraftableItems = {
    {
        name = "velvet_lipstick",
        label = "Velvet Matte Lipstick",
        description = "UV Cosmetic Pigments, 2x Cream Base, 1x Mixing Oils",
        ingredients = {
            { item = "cosmetic_pigments", label = "Pigments", amount = 1 },
            { item = "cream_base", label = "Cream Base", amount = 2 },
            { item = "mixing_oils", label = "Mixing Oils", amount = 1 }
        },
        craftTime = 5000
    },
    {
        name = "rose_lipgloss",
        label = "Rose Lip Gloss",
        description = "UV Cosmetic Pigments, 1x Cream Base, 1x Mixing Oils",
        ingredients = {
            { item = "cosmetic_pigments", label = "Pigments", amount = 1 },
            { item = "cream_base", label = "Cream Base", amount = 1 },
            { item = "mixing_oils", label = "Mixing Oils", amount = 1 }
        },
        craftTime = 6000
    },
    {
        name = "tinted_lipbalm",
        label = "Tinted Lip Balm",
        description = "2x Cream Base, 1x Mixing Oils",
        ingredients = {
            { item = "cream_base", label = "Cream Base", amount = 2 },
            { item = "mixing_oils", label = "Mixing Oils", amount = 1 }
        },
        craftTime = 4000
    },
    {
        name = "glow_foundation",
        label = "Glow Foundation",
        description = "UV Cosmetic Pigments, 2x Cream Base, 1x Mixing Oils",
        ingredients = {
            { item = "cosmetic_pigments", label = "Pigments", amount = 1 },
            { item = "cream_base", label = "Cream Base", amount = 2 },
            { item = "mixing_oils", label = "Mixing Oils", amount = 1 }
        },
        craftTime = 8000
    },
    {
        name = "silk_concealer",
        label = "Silk Concealer",
        description = "UV Cosmetic Pigments, 2x Cream Base, 1x Mixing Oils",
        ingredients = {
            { item = "cosmetic_pigments", label = "Pigments", amount = 1 },
            { item = "cream_base", label = "Cream Base", amount = 2 },
            { item = "mixing_oils", label = "Mixing Oils", amount = 1 }
        },
        craftTime = 7000
    }
}

-- Selling Configuration (End-consumer buyers)
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
    ["velvet_lipstick"] = { priceMin = 45, priceMax = 50, buyAmountMin = 1, buyAmountMax = 5 },
    ["rose_lipgloss"] = { priceMin = 60, priceMax = 75, buyAmountMin = 1, buyAmountMax = 4 },
    ["tinted_lipbalm"] = { priceMin = 35, priceMax = 45, buyAmountMin = 1, buyAmountMax = 6 },
    ["glow_foundation"] = { priceMin = 25, priceMax = 40, buyAmountMin = 1, buyAmountMax = 3 },
    ["silk_concealer"] = { priceMin = 50, priceMax = 60, buyAmountMin = 1, buyAmountMax = 3 }
}

Config.SellCooldown = 10000 -- 10 Seconds By Default
