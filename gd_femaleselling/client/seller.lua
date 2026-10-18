-- Despawn seller
RegisterNetEvent("femalecraft:client:despawnSeller", function()
    if GdFemaleSelling.activeSeller then
        local seller = GdFemaleSelling.activeSeller
        GdFemaleSelling.activeSeller = nil -- Clear reference immediately so interaction stops
        
        GdFemaleSelling.debugLog("Seller transaction complete. Walking away before despawn.")
        
        -- Remove ox_target interaction immediately
        exports.ox_target:removeLocalEntity(seller, "sell_items")
        
        -- Update GdFemaleSelling.lastSellTime on successful transaction
        GdFemaleSelling.lastSellTime = GetGameTimer()
        
        -- Stop any current tasks and walk away
        ClearPedTasks(seller)
        SetPedKeepTask(seller, true)
        TaskWanderStandard(seller, 10.0, 10)
        
        -- Timer before they vanish
        SetTimeout(10000, function()
            if DoesEntityExist(seller) then
                DeleteEntity(seller)
                GdFemaleSelling.debugLog("Seller despawned successfully after walking away.")
            end
        end)
    end
end)

-- Remove entity from client (called from server)
RegisterNetEvent("femalecraft:client:removeTable", function(netId)
    if NetworkDoesNetworkIdExist(netId) then
        local entity = NetToObj(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
            GdFemaleSelling.debugLog("Table removed. NetID: " .. netId)
        end
    end
end)

-- Sell Process with custom Tailwind UI
local function startSellingProcess()
    if not GdFemaleSelling.activeSeller then return end
    
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
            title = "Seller",
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
    
    if not GdFemaleSelling.activeSeller or not DoesEntityExist(GdFemaleSelling.activeSeller) then
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
    
    if not GdFemaleSelling.activeSeller or not DoesEntityExist(GdFemaleSelling.activeSeller) then
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
    TaskTurnPedToFaceEntity(ped, GdFemaleSelling.activeSeller, 1000)
    TaskTurnPedToFaceEntity(GdFemaleSelling.activeSeller, ped, 1000)
    Wait(1000)

    lib.requestAnimDict("mp_common")
    
    -- Make the buyer start animation
    TaskPlayAnim(GdFemaleSelling.activeSeller, "mp_common", "givetake1_a", 8.0, -8.0, 3000, 49, 0, false, false, false)

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
        TriggerServerEvent("femalecraft:server:sellItems", itemName, data.price)
    else
        ClearPedTasks(GdFemaleSelling.activeSeller)
        GdFemaleSelling.debugLog("Selling cancelled.")
    end
    RemoveAnimDict("mp_common")
    cb("ok")
end)

RegisterNUICallback("declineOffer", function(_, cb)
    SetNuiFocus(false, false)
    if GdFemaleSelling.activeSeller then
        local seller = GdFemaleSelling.activeSeller
        GdFemaleSelling.activeSeller = nil
        
        -- Update cooldown after decline
        GdFemaleSelling.lastSellTime = GetGameTimer()
        
        -- Remove target immediately
        exports.ox_target:removeLocalEntity(seller, "sell_items")
        
        ClearPedTasks(seller)
        SetPedKeepTask(seller, true)
        TaskWanderStandard(seller, 10.0, 10)
        lib.notify({
            title = "Seller",
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
RegisterCommand("sellfemaleitems", function()
    if GdFemaleSelling.isCalling then return end
    
    local currentTime = GetGameTimer()
    
    -- Check cooldown (Only after a completed/declined sale)
    if GdFemaleSelling.lastSellTime ~= 0 and (currentTime - GdFemaleSelling.lastSellTime < (Config.SellCooldown or 60000)) then
        local remaining = math.ceil(((Config.SellCooldown or 60000) - (currentTime - GdFemaleSelling.lastSellTime)) / 1000)
        lib.notify({
            title = "Cooldown",
            description = "You must wait " .. remaining .. "s before calling again.",
            type = "error"
        })
        return
    end

    if not GdFemaleSelling.isFemale() then
        GdFemaleSelling.debugLog("Male ped attempted to spawn seller.")
        return
    end

    -- Check if player has any sellable items before spawning
    local hasItems = lib.callback.await("femalecraft:server:hasAnySellableItems", false)
    if not hasItems then
        lib.notify({
            title = "Seller",
            description = "You don't have anything to sell!",
            type = "error"
        })
        return
    end

    if GdFemaleSelling.activeSeller then
        DeleteEntity(GdFemaleSelling.activeSeller)
        GdFemaleSelling.activeSeller = nil
    end

    GdFemaleSelling.isCalling = true
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
        
        GdFemaleSelling.isCalling = false
        local coords = GetEntityCoords(playerPed)
        local forward = GetEntityForwardVector(playerPed)
        local spawnPos = coords + (forward * 20.0) -- Spawn slightly further away for immersion
        local model = Config.SellerModels[math.random(#Config.SellerModels)]

        lib.requestModel(model)
        GdFemaleSelling.activeSeller = CreatePed(0, joaat(model), spawnPos.x, spawnPos.y, spawnPos.z - 1.0, 0.0, true, false)
        
        SetEntityInvincible(GdFemaleSelling.activeSeller, true)
        SetBlockingOfNonTemporaryEvents(GdFemaleSelling.activeSeller, true)
        SetPedKeepTask(GdFemaleSelling.activeSeller, true)
        
        -- Improved arrival logic: Follow with dynamic distance
        TaskFollowToOffsetOfEntity(GdFemaleSelling.activeSeller, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
        SetPedKeepTask(GdFemaleSelling.activeSeller, true)

        exports.ox_target:addLocalEntity(GdFemaleSelling.activeSeller, {
            {
                name = "sell_items",
                icon = "fa-solid fa-hand-holding-dollar",
                label = "Sell Goods",
                onSelect = function()
                    startSellingProcess()
                end
            }
        })

        GdFemaleSelling.debugLog("Seller spawned. Model: " .. model)

        -- Auto despawn logic (walk away after 90 seconds if no interaction)
        SetTimeout(90000, function()
            if GdFemaleSelling.activeSeller and DoesEntityExist(GdFemaleSelling.activeSeller) then
                local seller = GdFemaleSelling.activeSeller
                GdFemaleSelling.activeSeller = nil
                GdFemaleSelling.debugLog("Seller session timed out. Walking away.")
                
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
        GdFemaleSelling.isCalling = false
        DeleteEntity(phoneObj)
        StopAnimTask(playerPed, "cellphone@", "cellphone_call_listen_base", 1.0)
        GdFemaleSelling.debugLog("Call cancelled.")
    end
    
    RemoveAnimDict("cellphone@")
    SetModelAsNoLongerNeeded(phoneModel)
end, false)

-- Distance check for seller
CreateThread(function()
    while true do
        Wait(1500)
        if GdFemaleSelling.activeSeller and DoesEntityExist(GdFemaleSelling.activeSeller) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local sellerCoords = GetEntityCoords(GdFemaleSelling.activeSeller)
            local dist = #(playerCoords - sellerCoords)
            
            -- Keep ped moving towards player if they move away, but stop when close
            if dist > 3.0 and dist < 50.0 then
                -- Check if ped is already following/moving
                if GetEntitySpeed(GdFemaleSelling.activeSeller) < 0.2 then
                    GdFemaleSelling.debugLog("Seller stopped too far, restarting follow.")
                    TaskFollowToOffsetOfEntity(GdFemaleSelling.activeSeller, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
                end
            elseif dist <= 3.0 then
                -- Close enough, just face player
                if GetEntitySpeed(GdFemaleSelling.activeSeller) < 0.1 then
                    TaskTurnPedToFaceEntity(GdFemaleSelling.activeSeller, playerPed, 1000)
                end
            elseif dist >= 50.0 then
                GdFemaleSelling.debugLog("Seller lost (dist: " .. dist .. "), cleaning up.")
                local seller = GdFemaleSelling.activeSeller
                GdFemaleSelling.activeSeller = nil
                exports.ox_target:removeLocalEntity(seller, "sell_items")
                DeleteEntity(seller)
            end
        end
    end
end)
