fx_version('cerulean')
games({ 'gta5' })

shared_script {"@es_extended/imports.lua", "config.lua"}

server_scripts({
    "@es_extended/locale.lua",
    "server.lua",
    "@mysql-async/lib/MySQL.lua"
});

client_scripts({
    "@es_extended/locale.lua",
    "dependencies/pmenu.lua",
    "client.lua"
});