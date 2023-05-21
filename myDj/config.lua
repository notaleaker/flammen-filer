Config = {}
Translation = {}

Translation = {
    ['de'] = {
        ['DJ_interact'] = 'Drücke ~g~E~s~, um auf das DJ Pult zuzugreifen',
        ['title_does_not_exist'] = '~r~Dieser Titel existiert nicht!',
    },

    ['en'] = {
        ['DJ_interact'] = 'Press ~g~E~s~, to access the DJ desk',
        ['title_does_not_exist'] = '~r~This title does not exist!',
    }
}

Config.Locale = 'en'

Config.useESX = true -- can not be disabled without changing the callbacks
Config.enableCommand = false

Config.enableMarker = true -- purple marker at the DJ stations

Config.DJPositions = {
    {
        name = 'Mirror1',
        pos = vector3(-1297.3298, -1037.0187, 13.1606),
        requiredJob = 'mr', 
        range = 25.0, 
        volume = 1.0 --[[ do not touch the volume! --]]
    },

}