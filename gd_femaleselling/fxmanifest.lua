fx_version 'cerulean'
game 'gta5'

author 'Ghost Developments'
description 'Cali Stories Female Selling V2'
version '1.0.0'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'server.lua'
}