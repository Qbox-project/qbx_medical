fx_version 'cerulean'
game 'gta5'

description 'https://github.com/Qbox-project'
version '1.0.0'

shared_scripts {
	'@qbx-core/shared/locale.lua',
	'@qbx-core/import.lua',
	'locales/en.lua',
	'locales/*.lua',
	'config.lua',
	'@ox_lib/init.lua',
}

server_scripts {
	'server/main.lua',
}

modules {
	'qbx-core:core'
}

dependencies {
	'ox_lib',
	'qbx-core',
}

lua54 'yes'
