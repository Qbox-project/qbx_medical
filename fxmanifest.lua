fx_version 'cerulean'
game 'gta5'

description 'QBX_Medical'
repository 'https://github.com/Qbox-project/qbx_medical'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    'shared/**/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/**/*.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'qbx_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
