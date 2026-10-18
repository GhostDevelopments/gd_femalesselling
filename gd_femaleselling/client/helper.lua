GdFemaleSelling = GdFemaleSelling or {}
GdFemaleSelling.activeSeller = nil
GdFemaleSelling.lastSellTime = 0
GdFemaleSelling.isCalling = false

-- Debug Logger
function GdFemaleSelling.debugLog(msg)
    if Config.Debug then
        print("^5[FemaleCrafting Debug]^7 " .. tostring(msg))
    end
end

-- Check if player is female (Specifically mp_f_freemode_01)
function GdFemaleSelling.isFemale()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local isFemalePed = model == joaat("mp_f_freemode_01")
    GdFemaleSelling.debugLog("Gender check (mp_f_freemode_01): " .. tostring(isFemalePed))
    return isFemalePed
end

