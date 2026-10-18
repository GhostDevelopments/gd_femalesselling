-- Despawn seller
RegisterNetEvent("selltech:client:despawnSellTech", function()
    if GdSellTech.activeSellTech then
        local seller = GdSellTech.activeSellTech
        GdSellTech.activeSellTech = nil -- Clear reference immediately so interaction stops
        
        GdSellTech.debugLog("SellTech transaction complete. Walking away before despawn.")
        
        -- Remove ox_target interaction immediately
        exports.ox_target:removeLocalEntity(seller, "sell_items")
        
        -- Update GdSellTech.lastSellTime on successful transaction
        GdSellTech.lastSellTime = GetGameTimer()
        
        -- Stop any current tasks and walk away
        ClearPedTasks(seller)
        SetPedKeepTask(seller, true)
        TaskWanderStandard(seller, 10.0, 10)
        
        -- Timer before they vanish
        SetTimeout(10000, function()
            if DoesEntityExist(seller) then
                DeleteEntity(seller)
                GdSellTech.debugLog("SellTech despawned successfully after walking away.")
            end
        end)
    end
end)

-- Remove entity from client (called from server)
RegisterNetEvent("selltech:client:removeTable", function(netId)
    if NetworkDoesNetworkIdExist(netId) then
        local entity = NetToObj(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
            GdSellTech.debugLog("Table removed. NetID: " .. netId)
        end
    end
end)

-- Sell Process with custom Tailwind UI
local function startSellingProcess()
    if not GdSellTech.activeSellTech then return end
    
    local ped = PlayerPedId()
    
    -- Check for sellable items
    local sellableItems = {}
    for itemName, config in pairs(Config.SellItems) do
        local count = exports.ox_inventory:GetItemCount(itemName)
        if count > 0 then
            local label = ""
            for _, v in ipairs(Config.CraftableItems) do
                if v.name == itemName then
                    label = v.label
                    break
                end
            end
            table.insert(sellableItems, { name = itemName, label = label, count = count })
        end
    end

    if #sellableItems == 0 then
        lib.notify({
            title = "SellTech",
            description = "You don't have any products to show them!",
            type = "error"
        })
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openSell",
        sellItems = sellableItems
    })
end

-- New flow for selling: Select item -> Offer -> Accept/Decline
RegisterNUICallback("selectItemToSell", function(data, cb)
    local itemName = data.itemName
    local ped = PlayerPedId()
    
    if not GdSellTech.activeSellTech or not DoesEntityExist(GdSellTech.activeSellTech) then
        cb("error")
        return
    end

    local count = exports.ox_inventory:GetItemCount(itemName)
    local label = ""
    for _, v in ipairs(Config.CraftableItems) do
        if v.name == itemName then
            label = v.label
            break
        end
    end

    -- Calculate price (randomized for flavor)
    local itemConfig = Config.SellItems[itemName]
    local finalPrice = 100
    if itemConfig then
        finalPrice = math.random(itemConfig.priceMin, itemConfig.priceMax)
    end

    -- Show the Offer UI
    SendNUIMessage({
        action = "showOffer",
        price = finalPrice,
        count = count,
        label = label,
        itemName = itemName
    })
    
    cb("ok")
end)

RegisterNUICallback("acceptOffer", function(data, cb)
    local itemName = data.itemName
    local ped = PlayerPedId()
    
    if not GdSellTech.activeSellTech or not DoesEntityExist(GdSellTech.activeSellTech) then
        cb("error")
        return
    end

    SetNuiFocus(false, false)

    local label = ""
    for _, v in ipairs(Config.CraftableItems) do
        if v.name == itemName then
            label = v.label
            break
        end
    end

    -- Face each other
    TaskTurnPedToFaceEntity(ped, GdSellTech.activeSellTech, 1000)
    TaskTurnPedToFaceEntity(GdSellTech.activeSellTech, ped, 1000)
    Wait(1000)

    lib.requestAnimDict("mp_common")
    
    -- Make the buyer start animation
    TaskPlayAnim(GdSellTech.activeSellTech, "mp_common", "givetake1_a", 8.0, -8.0, 3000, 49, 0, false, false, false)

    if lib.progressCircle({
        duration = 3000,
        label = "Finalizing Deal...",
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, mouse = false, combat = true },
        anim = { 
            dict = "mp_common",
            clip = "givetake1_a",
            flag = 49
        }
    }) then
        TriggerServerEvent("selltech:server:sellItems", itemName, data.price)
    else
        ClearPedTasks(GdSellTech.activeSellTech)
        GdSellTech.debugLog("Selling cancelled.")
    end
    RemoveAnimDict("mp_common")
    cb("ok")
end)

RegisterNUICallback("declineOffer", function(_, cb)
    SetNuiFocus(false, false)
    if GdSellTech.activeSellTech then
        local seller = GdSellTech.activeSellTech
        GdSellTech.activeSellTech = nil
        
        -- Update cooldown after decline
        GdSellTech.lastSellTime = GetGameTimer()
        
        -- Remove target immediately
        exports.ox_target:removeLocalEntity(seller, "sell_items")
        
        ClearPedTasks(seller)
        SetPedKeepTask(seller, true)
        TaskWanderStandard(seller, 10.0, 10)
        lib.notify({
            title = "SellTech",
            description = "The buyer walked away disappointed.",
            type = "info"
        })
        -- Clean up seller
        SetTimeout(10000, function()
            if DoesEntityExist(seller) then DeleteEntity(seller) end
        end)
    end
    cb("ok")
end)

-- Old sellItem callback removed
RegisterNUICallback("sellItem", function(data, cb)
    cb("ok")
end)

-- Command to spawn seller
RegisterCommand("selltech", function()
    if GdSellTech.isCalling then return end
    
    local currentTime = GetGameTimer()
    
    -- Check cooldown (Only after a completed/declined sale)
    if GdSellTech.lastSellTime ~= 0 and (currentTime - GdSellTech.lastSellTime < (Config.SellCooldown or 60000)) then
        local remaining = math.ceil(((Config.SellCooldown or 60000) - (currentTime - GdSellTech.lastSellTime)) / 1000)
        lib.notify({
            title = "SellTech Cooldown",
            description = "You must wait " .. remaining .. "s before calling again.",
            type = "error"
        })
        return
    end

    -- Check if player has any sellable items before spawning
    local hasItems = lib.callback.await("selltech:server:hasAnySellableItems", false)
    if not hasItems then
        lib.notify({
            title = "SellTech",
            description = "You don't have anything to sell!",
            type = "error"
        })
        return
    end

    if GdSellTech.activeSellTech then
        DeleteEntity(GdSellTech.activeSellTech)
        GdSellTech.activeSellTech = nil
    end

    GdSellTech.isCalling = true
    local playerPed = PlayerPedId()

    -- Start phone call animation
    lib.requestAnimDict("cellphone@")
    local phoneModel = joaat("prop_npc_phone_02")
    lib.requestModel(phoneModel)
    
    local phoneObj = CreateObject(phoneModel, 0.0, 0.0, 0.0, true, true, false)
    local boneIndex = GetPedBoneIndex(playerPed, 57005) -- Right Hand
    AttachEntityToEntity(phoneObj, playerPed, boneIndex, 0.12, 0.02, -0.03, -80.0, 0.0, 0.0, true, true, false, true, 1, true)

    if lib.progressCircle({
        duration = 5000,
        label = "Calling buyer...",
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = true, mouse = false, combat = true },
        anim = {
            dict = "cellphone@",
            clip = "cellphone_call_listen_base",
            flag = 49
        }
    }) then
        -- Success: Continue to spawn ped
        DeleteEntity(phoneObj)
        StopAnimTask(playerPed, "cellphone@", "cellphone_call_listen_base", 1.0)
        
        GdSellTech.isCalling = false
        local coords = GetEntityCoords(playerPed)
        local forward = GetEntityForwardVector(playerPed)
        local spawnPos = coords + (forward * 20.0) -- Spawn slightly further away for immersion
        local model = Config.SellerModels[math.random(#Config.SellerModels)]

        lib.requestModel(model)
        GdSellTech.activeSellTech = CreatePed(0, joaat(model), spawnPos.x, spawnPos.y, spawnPos.z - 1.0, 0.0, true, false)
        
        SetEntityInvincible(GdSellTech.activeSellTech, true)
        SetBlockingOfNonTemporaryEvents(GdSellTech.activeSellTech, true)
        SetPedKeepTask(GdSellTech.activeSellTech, true)
        
        -- Improved arrival logic: Follow with dynamic distance
        TaskFollowToOffsetOfEntity(GdSellTech.activeSellTech, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
        SetPedKeepTask(GdSellTech.activeSellTech, true)

        exports.ox_target:addLocalEntity(GdSellTech.activeSellTech, {
            {
                name = "sell_items",
                icon = "fa-solid fa-hand-holding-dollar",
                label = "Sell Goods",
                onSelect = function()
                    startSellingProcess()
                end
            }
        })

        GdSellTech.debugLog("SellTech spawned. Model: " .. model)

        -- Auto despawn logic (walk away after 90 seconds if no interaction)
        SetTimeout(90000, function()
            if GdSellTech.activeSellTech and DoesEntityExist(GdSellTech.activeSellTech) then
                local seller = GdSellTech.activeSellTech
                GdSellTech.activeSellTech = nil
                GdSellTech.debugLog("SellTech session timed out. Walking away.")
                
                -- Ensure target is removed
                exports.ox_target:removeLocalEntity(seller, "sell_items")
                
                ClearPedTasks(seller)
                SetPedKeepTask(seller, true)
                TaskWanderStandard(seller, 10.0, 10)
                SetTimeout(10000, function()
                    if DoesEntityExist(seller) then
                        DeleteEntity(seller)
                    end
                end)
            end
        end)
    else
        -- Cancelled
        GdSellTech.isCalling = false
        DeleteEntity(phoneObj)
        StopAnimTask(playerPed, "cellphone@", "cellphone_call_listen_base", 1.0)
        GdSellTech.debugLog("Call cancelled.")
    end
    
    RemoveAnimDict("cellphone@")
    SetModelAsNoLongerNeeded(phoneModel)
end, false)

RegisterCommand("stopselltech", function()
    if GdSellTech.isCalling then
        GdSellTech.isCalling = false
    end

    if not GdSellTech.activeSellTech then return end

    local seller = GdSellTech.activeSellTech
    GdSellTech.activeSellTech = nil
    exports.ox_target:removeLocalEntity(seller, "sell_items")
    ClearPedTasks(seller)
    SetPedKeepTask(seller, true)
    TaskWanderStandard(seller, 10.0, 10)
    lib.notify({
        title = "SellTech",
        description = "The console buyer has been dismissed.",
        type = "info"
    })

    SetTimeout(10000, function()
        if DoesEntityExist(seller) then
            DeleteEntity(seller)
        end
    end)
end, false)

-- Distance check for seller
CreateThread(function()
    while true do
        Wait(1500)
        if GdSellTech.activeSellTech and DoesEntityExist(GdSellTech.activeSellTech) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local sellerCoords = GetEntityCoords(GdSellTech.activeSellTech)
            local dist = #(playerCoords - sellerCoords)
            
            -- Keep ped moving towards player if they move away, but stop when close
            if dist > 3.0 and dist < 50.0 then
                -- Check if ped is already following/moving
                if GetEntitySpeed(GdSellTech.activeSellTech) < 0.2 then
                    GdSellTech.debugLog("SellTech stopped too far, restarting follow.")
                    TaskFollowToOffsetOfEntity(GdSellTech.activeSellTech, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
                end
            elseif dist <= 3.0 then
                -- Close enough, just face player
                if GetEntitySpeed(GdSellTech.activeSellTech) < 0.1 then
                    TaskTurnPedToFaceEntity(GdSellTech.activeSellTech, playerPed, 1000)
                end
            elseif dist >= 50.0 then
                GdSellTech.debugLog("SellTech lost (dist: " .. dist .. "), cleaning up.")
                local seller = GdSellTech.activeSellTech
                GdSellTech.activeSellTech = nil
                exports.ox_target:removeLocalEntity(seller, "sell_items")
                DeleteEntity(seller)
            end
        end
    end
end)
