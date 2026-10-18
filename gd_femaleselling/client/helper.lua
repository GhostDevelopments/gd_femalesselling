GdSellTech = GdSellTech or {}
GdSellTech.activeSellTech = nil
GdSellTech.lastSellTime = 0
GdSellTech.isCalling = false

-- Debug Logger
function GdSellTech.debugLog(msg)
    if Config.Debug then
        print("^5[SellTech Debug]^7 " .. tostring(msg))
    end
end

-- Kept as a compatibility helper for existing interaction checks; every player model is allowed.
function GdSellTech.isFemale()
    return true
end

