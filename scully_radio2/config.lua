Scully = {
    Framework = 'es_extended', -- Server Core = scully_core, ESX = es_extended, QBCore = qb-core, Standalone = none
    KVPHandle = 'Flammen', -- Change this to something unique such as your server name.
    RadioColour = 'default', -- Options are default, blue, brown, cherry, coral, cyan, green, mint, orange, pink, purple, red, white and yellow
    AllowColours = true, -- Disable if you don't want people to be able to change their radio colour in-game
    ColourCommand = 'rcolor', -- Set to '' if you don't want to allow changing with a command, command is /rcolour 1-11
    EnableList = false, -- Set to false to disable the player list
    HideListCommand = 'rlist', -- Set to '' if you don't want to allow hiding the list with a command, command is /rlist
    ShowSelf = true, -- Enable if you want your own name to be shown on the radio list
    EnableEditing = true, -- Disable if you don't want to allow players to change their names and callsigns on the radio, keep in mind if this is enabled they need to manually change the name back unless you update the KVPHandle above.
    MicClicks = true, -- Disable if you don't want mic clicks
    RadioAnims = true, -- Disable if you don't want to use radio animations for holding and talking on the radio
    UseItem = true, -- Enable if you want to use the radio as an item, will only work for QBCore and ESX
    UseItemColours = true, -- Enable if you want to use different items for each colour, this will disable the command also
    UseKeybind = 'y', -- Set to '' if you don't want to use the radio as a keybind, can be changed here for first use only or in your fivem keybind settings
    UseCustomChannelNames = false, -- Enable if you want custom channel names to be displayed on the radio
    ChannelNames = { -- Channel names have a limit of 7 characters or they won't display
        [10] = 'Eg 1',
        [10.01] = 'Eg 2'
    },
    WhitelistedAccess = { -- What channels should be whitelisted and what jobs should have access to them?
        [1] = {
            ['police'] = true,
            ['ambulance'] = true
        },
        [2] = {
            ['police'] = true,
            ['ambulance'] = true
        },
        [112] = {
            ['police'] = true,
            ['ambulance'] = true
        }
    },
    AcePerms = { -- Not needed unless Framework is set to 'none'
        'police',
        'ambulance'
    },
    RadioColours = {
        [1] = 'default',
        [2] = 'blue',
        [3] = 'brown',
        [4] = 'cherry',
        [5] = 'coral',
        [6] = 'cyan',
        [7] = 'green',
        [8] = 'mint',
        [9] = 'orange',
        [10] = 'pink',
        [11] = 'purple',
        [12] = 'red',
        [13] = 'yellow',
        [14] = 'white'
    },
    Language = {
        Frequency = 'Frekvens:',
        Channel = 'Kanal:',
        None = 'Ingen',
        NotAllowedJoin = '~r~Du har ikke tilladelse til at deltage i denne frekvens!',
        ChangedTo = '~g~Din radio er blevet ændret til',
        NoRadio = '~r~Du har ikke en radio!',
        Command = '',
        CommandLabel = 'Åben Radio',
        UpdatedYour = '~g~Du Opdateret din',
        To = 'til',
        You = '(Dig)'
    }

}