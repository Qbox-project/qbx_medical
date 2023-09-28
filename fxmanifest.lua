fx_version 'cerulean'
game 'gta5'

description 'https://github.com/Qbox-project'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    '@qbx_core/import.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/**/*.lua',
}

modules {
    'qbx_core:playerdata',
    'qbx_core:utils'
}

dependencies {
    'ox_lib',
    'qbx_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
