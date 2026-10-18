-- ox_target setup for crafting table
CreateThread(function()
    -- Initial blip check
    GdFemaleSelling.updateShopBlip()

    exports.ox_target:addModel(Config.CraftingObject, {
        {
            name = "female_crafting",
            icon = "fa-solid fa-wand-sparkles",
            label = "Craft Female Items",
            onSelect = function(data)
                GdFemaleSelling.openCraftingMenu()
            end,
            canInteract = function()
                return GdFemaleSelling.isFemale()
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
    GdFemaleSelling.debugLog("placeTable event triggered")
    
    if not GdFemaleSelling.isFemale() then
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

    GdFemaleSelling.debugLog("Requesting model: " .. Config.CraftingObject)
    
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
            GdFemaleSelling.debugLog("Table placed successfully. NetID: " .. netId)
        else
            GdFemaleSelling.debugLog("FAILED to spawn table object. CreateObject returned nil.")
            lib.notify({
                title = "Error",
                description = "Failed to spawn the object. Check F8 console.",
                type = "error"
            })
        end
    end
    
    SetModelAsNoLongerNeeded(joaat(Config.CraftingObject))
end)
