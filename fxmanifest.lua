fx_version 'cerulean'
game 'gta5'

name 'hampus-crafting'
author 'Hampus Resources'
description 'Standalone crafting for ESX Legacy & qbx_core using ox_lib, ox_target, ox_inventory'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/crafting_recipes.lua',
    'shared/framework.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
