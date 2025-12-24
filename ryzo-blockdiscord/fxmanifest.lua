fx_version 'cerulean'
game 'gta5'

author 'Ryzo'
name 'Ryzo'
description 'Discord ID Blocker for FiveM'
version '1.0.0'

lua54 'yes'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

files {
    'data/banned_discord.json'
}
