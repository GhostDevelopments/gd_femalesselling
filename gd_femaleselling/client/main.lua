-- NUI Callbacks
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("craftItem", function(data, cb)
    if not GdFemaleSelling.isFemale() then
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
            GdFemaleSelling.openCraftingMenu()
        end
        RemoveAnimDict("mini@repair")
    end
    cb("ok")
end)

-- Open UI
function GdFemaleSelling.openCraftingMenu()
    if not GdFemaleSelling.isFemale() then
        GdFemaleSelling.debugLog("Male ped attempted to open female-only menu.")
        return
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        items = Config.CraftableItems
    })
end

