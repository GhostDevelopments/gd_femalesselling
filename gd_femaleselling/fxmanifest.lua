fx_version "cerulean"
game "gta5"
lua54 "yes"

author "SwisserAI"
description "SellTech Console Crafting and Selling - Generated with SwisserAI - https://ai.swisser.dev"
version "1.0.2"

dependencies {
    "ox_lib",
    "ox_target",
    "ox_inventory"
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/style.css",
    "html/script.js",
    "html/tailwind.css"
}

shared_scripts {
    "@ox_lib/init.lua",
    "config/*.lua",
    "shared/*.lua"
}

client_scripts {
    "client/helper.lua",
    "client/shop.lua",
    "client/crafting.lua",
    "client/seller.lua",
    "client/main.lua"
}

server_scripts {
    "@ox_lib/init.lua",
    "config/*.lua",
    "server/*.lua"
}