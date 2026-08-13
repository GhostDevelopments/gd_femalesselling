local activeSeller = nil
local lastSellTime = 0
local isCalling = false

-- Debug Logger
local function debugLog(msg)
    if Config.Debug then
        print("^5[FemaleCrafting Debug]^7 " .. tostring(msg))
    end
end

-- Check if player is female (Specifically mp_f_freemode_01)
local function isFemale()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local isFemalePed = model == joaat("mp_f_freemode_01")
    debugLog("Gender check (mp_f_freemode_01): " .. tostring(isFemalePed))
    return isFemalePed
end

-- NUI Callbacks
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("craftItem", function(data, cb)
    if not isFemale() then
        print("Only females can craft these items!")
        cb("error")
        return
    end
    
    local craftData = nil
    for _, v in ipairs(Config.CraftableItems) do
        if v.name == data.itemName then
            craftData = v
            break
        end
    end

    if craftData then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" }) -- Hide the UI immediately
        
        local amount = data.amount or 1

        -- Explicitly request anim dict to ensure it plays
        lib.requestAnimDict("mini@repair")

        if lib.progressCircle({
            duration = (craftData.craftTime or 5000) * amount,
            label = ("Crafting %s %s..."):format(amount, craftData.label),
            position = "bottom",
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true },
            anim = { 
                dict = "mini@repair",
                clip = "fixing_a_player",
                flag = 1
            }
        }) then
            TriggerServerEvent("femalecraft:server:craft", data.itemName, amount)
        else
            openCraftingMenu()
        end
        RemoveAnimDict("mini@repair")
    end
    cb("ok")
end)

-- Open UI
local function openCraftingMenu()
    if not isFemale() then
        debugLog("Male ped attempted to open female-only menu.")
        return
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        items = Config.CraftableItems
    })
end

-- Blip reference
local shopBlip = nil
local shopPed = nil

-- Update shop blip visibility based on gender
local function updateShopBlip()
    local isFemalePed = isFemale()
    
    if isFemalePed and not shopBlip and Config.UseBlip then
        shopBlip = AddBlipForCoord(Config.ShopLocation)
        SetBlipSprite(shopBlip, Config.ShopBlip.sprite)
        SetBlipDisplay(shopBlip, 4)
        SetBlipScale(shopBlip, Config.ShopBlip.scale)
        SetBlipColour(shopBlip, Config.ShopBlip.color)
        SetBlipAsShortRange(shopBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.ShopBlip.label)
        EndTextCommandSetBlipName(shopBlip)
        debugLog("Shop blip created (Female only)")
    elseif not isFemalePed and shopBlip then
        RemoveBlip(shopBlip)
        shopBlip = nil
        debugLog("Shop blip removed (Not female)")
    end
end

-- Function to open the shop menu
local function openShopMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openShop",
        shopItems = Config.ShopItems
    })
end

RegisterNUICallback("buyItem", function(data, cb)
    local itemName = data.itemName
    local amount = data.amount or 1
    local itemData = nil
    
    for _, v in ipairs(Config.ShopItems) do
        if v.name == itemName then
            itemData = v
            break
        end
    end

    if itemData then
        TriggerServerEvent("femalecraft:server:buyItem", itemName, amount)
    end
    cb("ok")
end)

-- Shop Ped Persistence
CreateThread(function()
    local point = lib.points.new({
        coords = Config.ShopPed.coords.xyz,
        distance = 30,
    })

    function point:onEnter()
        if not shopPed or not DoesEntityExist(shopPed) then
            local model = Config.ShopPed.model
            lib.requestModel(model)
            shopPed = CreatePed(0, joaat(model), Config.ShopPed.coords.x, Config.ShopPed.coords.y, Config.ShopPed.coords.z, Config.ShopPed.coords.w, false, false)
            SetEntityInvincible(shopPed, true)
            SetBlockingOfNonTemporaryEvents(shopPed, true)
            FreezeEntityPosition(shopPed, true)
            
            exports.ox_target:addLocalEntity(shopPed, {
                {
                    name = "glamour_shop",
                    icon = "fa-solid fa-store",
                    label = "Open Glamour Studio Shop",
                    onSelect = function()
                        openShopMenu()
                    end,
                    canInteract = function()
                        return isFemale()
                    end
                }
            })
        end
    end

    function point:onExit()
        if shopPed and DoesEntityExist(shopPed) then
            DeleteEntity(shopPed)
            shopPed = nil
        end
    end
end)

-- Monitor model changes for blip visibility
CreateThread(function()
    while true do
        updateShopBlip()
        Wait(5000) -- Check every 5 seconds
    end
end)

-- ox_target setup for crafting table
CreateThread(function()
    -- Initial blip check
    updateShopBlip()

    exports.ox_target:addModel(Config.CraftingObject, {
        {
            name = "female_crafting",
            icon = "fa-solid fa-wand-sparkles",
            label = "Craft Female Items",
            onSelect = function(data)
                openCraftingMenu()
            end,
            canInteract = function()
                return isFemale()
            end
        },
        {
            name = "pickup_table",
            icon = "fa-solid fa-hand-holding",
            label = "Pick Up Table",
            onSelect = function(data)
                local entity = data.entity
                if DoesEntityExist(entity) then
                    lib.requestAnimDict("pickup_object")
                    if lib.progressCircle({
                        duration = 1500,
                        label = "Picking up table...",
                        position = "bottom",
                        useWhileDead = false,
                        canCancel = true,
                        disable = { move = true, car = true, mouse = false, combat = true },
                        anim = { dict = "pickup_object", clip = "pickup_low", flag = 16 }
                    }) then
                        TriggerServerEvent("femalecraft:server:pickupTable", NetworkGetNetworkIdFromEntity(entity))
                    end
                    RemoveAnimDict("pickup_object")
                end
            end
        }
    })
end)

-- Use item to place table
RegisterNetEvent("femalecraft:client:placeTable", function()
    local playerPed = PlayerPedId()
    debugLog("placeTable event triggered")
    
    if not isFemale() then
        lib.notify({
            title = "Female Only",
            description = "Only females can place this table!",
            type = "error"
        })
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnCoords = playerCoords + (forward * 1.5)
    local heading = GetEntityHeading(playerPed)

    debugLog("Requesting model: " .. Config.CraftingObject)
    
    if not lib.requestModel(Config.CraftingObject, 10000) then
        lib.notify({
            title = "Error",
            description = "Could not load table model: " .. Config.CraftingObject,
            type = "error"
        })
        return
    end

    lib.requestAnimDict("pickup_object")
    if lib.progressCircle({
        duration = 2000,
        label = "Placing crafting table...",
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, mouse = false, combat = true },
        anim = { dict = "pickup_object", clip = "pickup_low", flag = 16 }
    }) then
        -- Spawn the object (isNetwork = true)
        local obj = CreateObject(joaat(Config.CraftingObject), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, false)
        
        if DoesEntityExist(obj) then
            SetEntityHeading(obj, heading)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)

            -- Network sync
            local netId = NetworkGetNetworkIdFromEntity(obj)
            SetNetworkIdCanMigrate(netId, true)
            Entity(obj).state.isCraftingTable = true

            TriggerServerEvent("femalecraft:server:confirmPlacement")
            debugLog("Table placed successfully. NetID: " .. netId)
        else
            debugLog("FAILED to spawn table object. CreateObject returned nil.")
            lib.notify({
                title = "Error",
                description = "Failed to spawn the object. Check F8 console.",
                type = "error"
            })
        end
    end
    
    SetModelAsNoLongerNeeded(joaat(Config.CraftingObject))
end)

-- Despawn seller
RegisterNetEvent("femalecraft:client:despawnSeller", function()
    if activeSeller then
        local seller = activeSeller
        activeSeller = nil -- Clear reference immediately so interaction stops
        
        debugLog("Seller transaction complete. Walking away before despawn.")
        
        -- Remove ox_target interaction immediately
        exports.ox_target:removeLocalEntity(seller, "sell_items")
        
        -- Update lastSellTime on successful transaction
        lastSellTime = GetGameTimer()
        
        -- Stop any current tasks and walk away
        ClearPedTasks(seller)
        SetPedKeepTask(seller, true)
        TaskWanderStandard(seller, 10.0, 10)
        
        -- Timer before they vanish
        SetTimeout(10000, function()
            if DoesEntityExist(seller) then
                DeleteEntity(seller)
                debugLog("Seller despawned successfully after walking away.")
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
            debugLog("Table removed. NetID: " .. netId)
        end
    end
end)

-- Sell Process with custom Tailwind UI
local function startSellingProcess()
    if not activeSeller then return end
    
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
    
    if not activeSeller or not DoesEntityExist(activeSeller) then
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
    
    if not activeSeller or not DoesEntityExist(activeSeller) then
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
    TaskTurnPedToFaceEntity(ped, activeSeller, 1000)
    TaskTurnPedToFaceEntity(activeSeller, ped, 1000)
    Wait(1000)

    lib.requestAnimDict("mp_common")
    
    -- Make the buyer start animation
    TaskPlayAnim(activeSeller, "mp_common", "givetake1_a", 8.0, -8.0, 3000, 49, 0, false, false, false)

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
        ClearPedTasks(activeSeller)
        debugLog("Selling cancelled.")
    end
    RemoveAnimDict("mp_common")
    cb("ok")
end)

RegisterNUICallback("declineOffer", function(_, cb)
    SetNuiFocus(false, false)
    if activeSeller then
        local seller = activeSeller
        activeSeller = nil
        
        -- Update cooldown after decline
        lastSellTime = GetGameTimer()
        
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
    if isCalling then return end
    
    local currentTime = GetGameTimer()
    
    -- Check cooldown (Only after a completed/declined sale)
    if lastSellTime ~= 0 and (currentTime - lastSellTime < (Config.SellCooldown or 60000)) then
        local remaining = math.ceil(((Config.SellCooldown or 60000) - (currentTime - lastSellTime)) / 1000)
        lib.notify({
            title = "Cooldown",
            description = "You must wait " .. remaining .. "s before calling again.",
            type = "error"
        })
        return
    end

    if not isFemale() then
        debugLog("Male ped attempted to spawn seller.")
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

    if activeSeller then
        DeleteEntity(activeSeller)
        activeSeller = nil
    end

    isCalling = true
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
        
        isCalling = false
        local coords = GetEntityCoords(playerPed)
        local forward = GetEntityForwardVector(playerPed)
        local spawnPos = coords + (forward * 20.0) -- Spawn slightly further away for immersion
        local model = Config.SellerModels[math.random(#Config.SellerModels)]

        lib.requestModel(model)
        activeSeller = CreatePed(0, joaat(model), spawnPos.x, spawnPos.y, spawnPos.z - 1.0, 0.0, true, false)
        
        SetEntityInvincible(activeSeller, true)
        SetBlockingOfNonTemporaryEvents(activeSeller, true)
        SetPedKeepTask(activeSeller, true)
        
        -- Improved arrival logic: Follow with dynamic distance
        TaskFollowToOffsetOfEntity(activeSeller, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
        SetPedKeepTask(activeSeller, true)

        exports.ox_target:addLocalEntity(activeSeller, {
            {
                name = "sell_items",
                icon = "fa-solid fa-hand-holding-dollar",
                label = "Sell Goods",
                onSelect = function()
                    startSellingProcess()
                end
            }
        })

        debugLog("Seller spawned. Model: " .. model)

        -- Auto despawn logic (walk away after 90 seconds if no interaction)
        SetTimeout(90000, function()
            if activeSeller and DoesEntityExist(activeSeller) then
                local seller = activeSeller
                activeSeller = nil
                debugLog("Seller session timed out. Walking away.")
                
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
        isCalling = false
        DeleteEntity(phoneObj)
        StopAnimTask(playerPed, "cellphone@", "cellphone_call_listen_base", 1.0)
        debugLog("Call cancelled.")
    end
    
    RemoveAnimDict("cellphone@")
    SetModelAsNoLongerNeeded(phoneModel)
end, false)

-- Distance check for seller
CreateThread(function()
    while true do
        Wait(1500)
        if activeSeller and DoesEntityExist(activeSeller) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local sellerCoords = GetEntityCoords(activeSeller)
            local dist = #(playerCoords - sellerCoords)
            
            -- Keep ped moving towards player if they move away, but stop when close
            if dist > 3.0 and dist < 50.0 then
                -- Check if ped is already following/moving
                if GetEntitySpeed(activeSeller) < 0.2 then
                    debugLog("Seller stopped too far, restarting follow.")
                    TaskFollowToOffsetOfEntity(activeSeller, playerPed, 0.0, 0.0, 0.0, 1.2, -1, 1.0, true)
                end
            elseif dist <= 3.0 then
                -- Close enough, just face player
                if GetEntitySpeed(activeSeller) < 0.1 then
                    TaskTurnPedToFaceEntity(activeSeller, playerPed, 1000)
                end
            elseif dist >= 50.0 then
                debugLog("Seller lost (dist: " .. dist .. "), cleaning up.")
                local seller = activeSeller
                activeSeller = nil
                exports.ox_target:removeLocalEntity(seller, "sell_items")
                DeleteEntity(seller)
            end
        end
    end
end)