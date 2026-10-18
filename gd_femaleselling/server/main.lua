-- Basic helper to check for items (Standalone using ox_inventory exports)
local function hasItems(src, ingredients)
    for _, data in ipairs(ingredients) do
        local count = exports.ox_inventory:GetItemCount(src, data.item)
        if count < data.amount then return false end
    end
    return true
end

-- Check if player has any sellable items
lib.callback.register("selltech:server:hasAnySellableItems", function(source)
    for itemName, _ in pairs(Config.SellItems) do
        local count = exports.ox_inventory:GetItemCount(source, itemName)
        if count > 0 then
            return true
        end
    end
    return false
end)

-- Handle shop purchases
RegisterNetEvent("selltech:server:buyItem", function(itemName, amount)
    local src = source
    local itemData = nil
    
    for _, item in ipairs(Config.ShopItems) do
        if item.name == itemName then
            itemData = item
            break
        end
    end

    if not itemData then return end

    local totalPrice = itemData.price * amount
    local moneyCount = exports.ox_inventory:GetItemCount(src, "money")

    if moneyCount >= totalPrice then
        if exports.ox_inventory:CanCarryItem(src, itemName, amount) then
            exports.ox_inventory:RemoveItem(src, "money", totalPrice)
            exports.ox_inventory:AddItem(src, itemName, amount)
            TriggerClientEvent("ox_lib:notify", src, {
                title = "SellTech",
                description = "Purchased " .. amount .. "x " .. itemData.label,
                type = "success"
            })
        else
            TriggerClientEvent("ox_lib:notify", src, {
                title = "SellTech",
                description = "You cannot carry this many items!",
                type = "error"
            })
        end
    else
        TriggerClientEvent("ox_lib:notify", src, {
            title = "SellTech",
            description = "You don't have enough money!",
            type = "error"
        })
    end
end)

-- Handle placing the table via item usage event
AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if name == Config.CraftingItem then
        TriggerClientEvent("selltech:client:placeTable", playerId)
    end
end)

-- Remove the item only after successful placement confirmation from client
RegisterNetEvent("selltech:server:confirmPlacement", function()
    local src = source
    if not src then return end
    exports.ox_inventory:RemoveItem(src, Config.CraftingItem, 1)
end)

-- Handle picking up the table
RegisterNetEvent("selltech:server:pickupTable", function(netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        TriggerClientEvent("selltech:client:removeTable", -1, netId)
        exports.ox_inventory:AddItem(src, Config.CraftingItem, 1)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Console Workbench",
            description = "You picked up the crafting table.",
            type = "info"
        })
    end
end)

RegisterNetEvent("selltech:server:craft", function(itemName, amount)
    local src = source
    local craftData = nil
    amount = amount or 1

    for _, v in ipairs(Config.CraftableItems) do
        if v.name == itemName then
            craftData = v
            break
        end
    end

    if not craftData then return end

    -- Multiply ingredients by amount
    local scaledIngredients = {}
    for _, ing in ipairs(craftData.ingredients) do
        table.insert(scaledIngredients, { item = ing.item, amount = ing.amount * amount })
    end

    if hasItems(src, scaledIngredients) then
        -- Check carry weight
        if not exports.ox_inventory:CanCarryItem(src, craftData.name, amount) then
             TriggerClientEvent("ox_lib:notify", src, {
                title = "Error",
                description = "You cannot carry this much!",
                type = "error"
            })
            return
        end

        -- Remove ingredients
        for _, data in ipairs(scaledIngredients) do
            exports.ox_inventory:RemoveItem(src, data.item, data.amount)
        end

        -- Give result
        exports.ox_inventory:AddItem(src, craftData.name, amount)
        
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Success",
            description = "You crafted " .. amount .. "x " .. craftData.label,
            type = "success"
        })
    else
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Error",
            description = "You don't have enough materials!",
            type = "error"
        })
    end
end)

RegisterNetEvent("selltech:server:sellItems", function(selectedItem, pricePerItem)
    local src = source
    local config = Config.SellItems[selectedItem]
    if not config then return end

    local playerCount = exports.ox_inventory:GetItemCount(src, selectedItem)
    if playerCount > 0 then
        -- Use the price sent from client if provided, otherwise fallback to config
        local finalPricePerItem = pricePerItem or math.random(config.priceMin, config.priceMax)
        
        -- Determine how many the ped wants to buy
        local wantToBuy = math.random(config.buyAmountMin, config.buyAmountMax)
        local actualAmount = math.min(playerCount, wantToBuy)

        if actualAmount > 0 then
            local payout = actualAmount * finalPricePerItem
            
            if exports.ox_inventory:RemoveItem(src, selectedItem, actualAmount) then
                exports.ox_inventory:AddItem(src, "money", payout)
                
                TriggerClientEvent("selltech:client:despawnSellTech", src)
                TriggerClientEvent("ox_lib:notify", src, {
                    title = "SellTech",
                    description = "Perfect! Here is $" .. payout .. " for the " .. actualAmount .. "x items.",
                    type = "success"
                })
            end
        end
    else
        TriggerClientEvent("ox_lib:notify", src, {
            title = "SellTech",
            description = "You don't have that product on you anymore.",
            type = "error"
        })
    end
end)
