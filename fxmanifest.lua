fx_version 'cerulean'
games { 'gta5' }
author 'Luman Studio'
version '1.1.2'
lua54 'yes'
this_is_a_map 'yes'

dependencies {
    '/onesync',
    'luman-bridge',
    'PolyZone',
}

shared_scripts {
    'shared/variables.lua',
    'shared/events.lua',
    'shared/statebags.lua',
    'shared/commands.lua',

    'shared/utils.lua',

    'config.lua',
    'locale.lua',
    'locales/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/BoxZone.lua',

    'client/utils.lua',
    'client/framework.lua',
    'client/main.lua',
    'client/timer.lua',
    'client/startPoint.lua',
    'client/countdown.lua',
    'client/skin.lua',
    'client/skinData.lua',
    'client/cutscene.lua',
    'client/freezePlayer.lua',

    'client/nui.lua',


    'client/minigame.lua',
    'client/npc.lua',
    'client/decals.lua',

    'client/manualMode.lua',
}

server_scripts {
    'server/utils.lua',
    'server/framework.lua',
    'server/main.lua',
    'server/playersCounter.lua',
    'server/startPoint.lua',
    'server/commands.lua',
    'server/reward.lua',
    'server/minigame.lua',
}

ui_page 'ui/index.html'
files {
    'ui/*.js',
    'ui/*.css',
    'ui/*.html',
    'ui/*.mp3',
    'ui/*.wav',
}

-- Sounds
file 'audio/data/dalgona_sounds.dat54.rel'
data_file 'AUDIO_SOUNDDATA' 'audio/data/dalgona_sounds.dat'
file 'audio/audiodirectory/dalgonagame_audiobank.awc'
data_file 'AUDIO_WAVEPACK' 'audio/audiodirectory'

-- Prop
file 'stream/props/dalgona_candies.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/props/dalgona_candies.ytyp'

escrow_ignore {
    "**/*",
     "*"
}