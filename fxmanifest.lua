fx_version 'cerulean'
game {'gta5'}

author 'freech_dev'

description 'A simple open source FiveM duty script'

shared_script 'config/config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}
