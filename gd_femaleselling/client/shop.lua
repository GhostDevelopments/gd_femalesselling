-- Blip reference
local shopBlip = nil
local shopPed = nil

-- Update shop blip visibility based on gender
function GdSellTech.updateShopBlip()
    if not shopBlip and Config.UseBlip then
        shopBlip = AddBlipForCoord(Config.ShopLocation)
        SetBlipSprite(shopBlip, Config.ShopBlip.sprite)
        SetBlipDisplay(shopBlip, 4)
        SetBlipScale(shopBlip, Config.ShopBlip.scale)
        SetBlipColour(shopBlip, Config.ShopBlip.color)
        SetBlipAsShortRange(shopBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.ShopBlip.label)
        EndTextCommandSetBlipName(shopBlip)
        GdSellTech.debugLog("Shop blip created")
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
        TriggerServerEvent("selltech:server:buyItem", itemName, amount)
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
                    name = "selltech_shop",
                    icon = "fa-solid fa-store",
                    label = "Open Console Supply Shop",
                    onSelect = function()
                        openShopMenu()
                    end,
                    canInteract = function()
                        return true
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
        GdSellTech.updateShopBlip()
        Wait(5000) -- Check every 5 seconds
    end
end)

