Config                            = {}
Config.DrawDistance               = 25.0
Config.MarkerColor2	              = {r = 120, g = 120, b = 240}
Config.EnablePlayerManagement     = true -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.ResellPercentage           = 50
Config.MarkerSize = {x = 1.1, y = 1.1, z = 0.9}
Config.MarkerType =  21
Config.MarkerColor = {r = 102, g = 102, b = 204, a = 255}

Config.Locale                     = 'da'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LL NNNNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 2
Config.PlateNumbers  = 5
Config.PlateUseSpace = true

Config.MinPriceProcent = 0.5 -- 40% af den opringelige pris kan den sælges til minimum. Fx bilen koster 250K minimum pris = 100K
Config.ShowPriceInShowcase = false -- Skal prisen vises i kataloget?

Config.Blip = vector3(-1179.8242, -3454.8220, 20.3034)

Config.Zones = {

	ShopEntering = {
		Pos   = {
			vector3(-1240.0026, -3001.9119, -42.8680)
		}, -- Hvor du sælger køretøjerne
		Size  = {x = 0.7, y = 0.7, z = 0.7},
		Type  = 1
	},

	ShopInside = {
		Pos     = vector3(-1271.5742, -3381.0918, 13.9402), -- Hvor den viser bilerne for bossen
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = -20.0,
		Type    = -1
	},

	VehSpawn = {
		Pos     = {
			vector3(-1104.5485, -3399.9478, 13.9451),
			vector3(-1649.8519, -3138.7356, 13.9901),
			
		},  -- Hvor den spawner den købte bil
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = {
			60.05,
			331.09
			
		},
		Type    = -1
	},

	BossActions = {
		Pos   = vector3(-1236.1735, -3003.8152, -42.8679), -- Boss Menu
		Size  = {x = 1.0, y = 1.0, z = 1.0},
		Type  = -1
	},

	ResellVehicle = {
		Pos   = vector3(-1279.0154, -3084.1353, 370.1427),--vector3(122.6390, -1102.4984, 35.6614), -- Sælg dit køretøj
		Size  = {x = 1.0, y = 1.0, z = 1.0},
		Type  = 29
	},

    ShowcaseZone = {
        Pos     = vector3(-1272.6364, -3383.1147, 13.9402), -- Hvor kunden kan se bilerne
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 219.45,
		Type    = -1
    },

    ShowCaseMarker = {
        Pos   = vector3(-1235.7103, -3010.7000, -43.87), -- Zonen du aktivere for at showcase
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Type  = 25
    },

	
}
Config.Shops = {
	ShopChute = {
		Items = {
			{
				name = "gadget_parachute",
				label = "Faldskærm",
				price = 2000
			},
		},
		Pos = {
			vector3(-1295.8149, -3007.0630, -44.0865),
		},
		Size = 0.8,
		Type = 40,
		Color = 25,
		ShowBlip = true,
		ShowMarker = true,
	},
}

Config.DemoZones = {
    OpenMenu = {
        Pos = {
			vector3(-1280.0273, -3048.7791, -48.4963),
		}, -- Menu til at vise biler frem som sælgeren bruger
        Size = {x = 0.8, y = 0.8, z = 0.8},
        Type = 33
    },
    
    SpawnVehicle = {
        Pos = {
			vector3(-1267.2612, -3011.8821, -48.4902),
		}, -- Hvor bilen spawner
        Heading = {
			2.0
		}
    },
    
    DeleteVehicle = {
        Pos = {
			vector3(-1266.9863, -3013.0332, -49.502),
		}, --Hvor du deleter bilen
        Size = {x = 3, y = 3, z = 4},
        Type = 25
    }
}
