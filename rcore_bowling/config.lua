Config = {
	Framework = 1, --[ 1 = ESX / 2 = QBCore / 3 = Other ] Choose your framework

	FrameworkTriggers = {
		notify = 'esx:showNotification', -- [ ESX = 'esx:showNotification' / QBCore = 'QBCore:Notify' ] Set the notification event, if left blank, default will be used
		object = 'esx:getSharedObject', --[ ESX = 'esx:getSharedObject' / QBCore = 'QBCore:GetObject' ] Set the shared object event, if left blank, default will be used (deprecated for QBCore)
		resourceName = 'es_extended', -- [ ESX = 'es_extended' / QBCore = 'qb-core' ] Set the resource name, if left blank, automatic detection will be performed
	},

	--[[
		This automatically adds a help point to Burton bowling alley,
		helping players get to the bowling alley and teaches them the basic rules
		and physics.

		This feature requires https://store.rcore.cz/package/5041989, but bowling works great without it.
	]]
	EnableGuidebookIntegration = false,

	--[[
		Further blip configuration (scale, sprite, color)
		can be made directly in client/blip.lua
	]]
	Blips = {
		vector3(-149.44, -258.21, 44.14), -- breze bowling map
		vector3(749.92, -776.68, 26.33), -- gabz bowling map
	},

	EnabledMaps = {
		BREZE_BOWLING = true,
		GABZ_BOWLING = true,
		YBN_MILO_RICHARDS_BOWLING = false,
		YBN_MILO_SANDY_SHORES = false,
		MAP4ALL_BOWLING = false,
		GND_BOWLING = false,
		TLUX_BOWLING = false,
	},

	AllowWager = true,
	ScoreboardCommand = 'bowling',
	Text = {
		BLIP = 'Bowling',

		REGISTER_LANE = '~INPUT_PICKUP~ Opret nyt spil~n~~INPUT_SPRINT~ + ~INPUT_PICKUP~ Opret nyt holdspil',
		JOIN_LANE = '~INPUT_PICKUP~ Deltag i spil',
		PLAY = '~INPUT_PICKUP~ Spil',
		OPEN = '~INPUT_PICKUP~ Åben',
		TAKE_BALL = '~INPUT_PICKUP~ Tag Bowlingkuglen',

		NOT_IN_GAME = 'Du spiller i øjeblikket ikke bowling.',
		NOT_ENOUGH_MONEY = 'Du har ikke penge nok til at betale indsats.',
		INPUT_POSITION = 'Vælg initial ~y~bowlingkuglens position~s~',
		INPUT_ROTATION = 'Vælg bowlingkugle ~y~spin~s~',
		INPUT_ANGLE = 'Vælg ~y~kaste vinkel~s~',
		INPUT_POWER = 'Vælg ~y~kaste kraft~s~',
		
        TOTAL = "Total",
        MATCH_END = "Kampen ender i {0} sekunder",
		MATCH_WHO_WON = "{0} vandt DKK{1}",

		START = "Start",
		CLOSE = "Luk",
		JOIN = "Tilslutte",
		REGISTER = "Tilmeld",
		WAGER = "Væddemål",
		WAGER_SET_TO = "Indsatsen er sat til <b>DKK{0}</b>",
		INPUT_CONFIRM = "~INPUT_ATTACK~ Bekræft",
		ROUND_COUNT = "Rundetælling",
		TEAM = "Hold",
		PLAYER = "Spiller",
		TEAM_NAME = 'Hold Navn',
		YOUR_NAME = 'Dit navn',
		LEFT_LANE = 'Du forlod spillet.'
	},
	ThrowWait = 1800,
}

POINTS_BREZE = {
    LEFT = {
        {vector3(0.0, 0.0, 0.0), 3.0, 0.0},
        {vector3(0.05000305, 0.1100159, 0.4399986), 3.0, 0.0},
        {vector3(0.2600098, 0.7700195, 0.579998), 1.0, -90.0},
        {vector3(0.2600098, 0.7700195, 0.5599976), 1.0, -90.0}, 
        {vector3(0.480011, 0.6900024, 0.5599976), 1.0, -90.0},
        {vector3(1.059998, 2.340012, 0.5599976), 1.0, 0.0}
    },
    RIGHT = {
        {vector3(0, 0, 0), 3.0, 0.0},
        {vector3(0.05000305, 0.1100159, 0.4399986), 3.0, 0.0},
        {vector3(0.2600098, 0.7700195, 0.579998), 1.0, -90.0},
        {vector3(0.2600098, 0.7700195, 0.5599976), 1.0, -90.0}, 
        {vector3(0.08000183, 0.8400269, 0.5599976), 1.0, -90.0},
        {vector3(0.6500092, 2.490021, 0.5599976), 1.0, 0.0}
    }
}

POINTS_GABZ = {
    RIGHT = {
		{vector3(0, 0, 0), 6.0, 270.0},
		{vector3(0.1600342, 0, -0.2099991), 6.0, 270.0},
		{vector3(0.2999878, 0, -0.3500004), 6.0, 270.0},
		{vector3(0.460022, 0, -0.4599991), 6.0, 270.0},
        {vector3(0.7000122, 0, -0.5100002), 6.0, 270.0},
        {vector3(17.04004, 0.01000977, -0.4599991), 5.5, 270.0},
        {vector3(17.23004, 0.01000977, -0.4300003), 4.0, 270.0},
		{vector3(17.40002, 0.01000977, -0.2999992), 3.5, 270.0},
        {vector3(17.64001, 0.01000977, -0.07999992), 3.0, 270.0},
        {vector3(17.71002, 0.01000977, -0.02999878), 2.5, 270.0},
        {vector3(17.85004, 0.01000977, 0.04000092), 2.0, 270.0},
        {vector3(18.13, 0.01000977, 0.06999969), 1.5, 270.0},
        {vector3(18.39001, 0.01000977, 0.06999969), 1.0, 270.0},
        {vector3(18.85999, 0.01000977, 0.06999969), 1.0, 270.0},
    },
    LEFT = {
		{vector3(0, 0, 0), 6.0, 270.0},
		{vector3(0.1600342, 0, -0.2099991), 6.0, 270.0},
		{vector3(0.2999878, 0, -0.3500004), 6.0, 270.0},
		{vector3(0.460022, 0, -0.4599991), 6.0, 270.0},
        {vector3(0.7000122, 0, -0.5100002), 6.0, 270.0},
        {vector3(17.04004, 0.01000977, -0.4599991), 5.5, 270.0},
        {vector3(17.23004, 0.01000977, -0.4300003), 4.0, 270.0},
		{vector3(17.40002, 0.01000977, -0.2999992), 3.5, 270.0},
        {vector3(17.64001, 0.01000977, -0.07999992), 3.0, 270.0},
        {vector3(17.71002, 0.01000977, -0.02999878), 2.5, 270.0},
        {vector3(17.85004, 0.01000977, 0.04000092), 2.0, 270.0},
        {vector3(18.13, 0.01000977, 0.06999969), 1.5, 270.0},
        {vector3(18.39001, 0.01000977, 0.06999969), 1.0, 270.0},
        {vector3(18.85999, 0.01000977, 0.06999969), 1.0, 270.0},
    },
}


POINTS_MILO = {
    LEFT = {
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
		{vector3(0.109985, -0.179993, -0.059999), 1.0, 0.0},
		{vector3(0.289917, -0.000046, -0.059999), 1.0, 0.0}, 
		{vector3(1.250000, -1.200049, -0.059999), 1.0, 225.0}
    },
    RIGHT = {
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
		{vector3(0.109985, -0.179993, -0.059999), 1.0, 0.0},
		{vector3(-0.050049, -0.360046, -0.059999), 1.0, 0.0}, 
		{vector3(0.880005, -1.600039, -0.059999), 1.0, 225.0}
    }
}

POINTS_M4A = {
    LEFT = {
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
    },
    RIGHT = {
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
		{vector3(0.000000, 0.000000, 0.000000),	3.0, 0.0},
    }
}

POINTS_GND = {
    LEFT = {
		{vector3(0.000000, 0.000000, 0.000000),	1.0, 180.0},
		{vector3(-0.300018, -0.830002, 0.000000), 1.0, 180.0},
    },
    RIGHT = {
		{vector3(0.000000, 0.000000, 0.000000),	1.0, 180.0},
		{vector3(-0.300018, -0.830002, 0.000000), 1.0, 180.0},
    }
}

Lanes = {
}

if Config.EnabledMaps.BREZE_BOWLING then
    Lanes.BREZE_1 = {
		Place = 'Burton',
		IsClosestToDoor = true,
		Start = vector3(-146.5671, -261.9492, 43.16),
		End = vector3(-152.9371, -280.0592 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-147.37, -259.4, 43.2),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}

    Lanes.BREZE_2 = {
		Place = 'Burton',
		Start = vector3(-149.55, -260.9, 43.16),
		End = vector3(-155.92, -279.01 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-147.37, -259.4, 43.2),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}

    Lanes.BREZE_3 = {
		Place = 'Burton',
		Start = vector3(-152.2102, -259.9643, 43.16),
		End = vector3(-158.5802, -278.0743 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-153.02, -257.42, 43.2),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}
    
    Lanes.BREZE_4 = {
		Place = 'Burton',
		Start = vector3(-155.1931, -258.9151, 43.16),
		End = vector3(-161.5631, -277.0251 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-153.02, -257.42, 43.2),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}

    Lanes.BREZE_5 = {
		Place = 'Burton',
		Start = vector3(-159.0136, -257.5713, 43.16),
		End = vector3(-165.3836, -275.6813 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-159.81, -255.03, 43.19),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}
    
    Lanes.BREZE_6 = {
		Place = 'Burton',
		Start = vector3(-161.9965, -256.5221, 43.16),
		End = vector3(-168.3665, -274.6321 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-159.81, -255.03, 43.19),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}
    
    Lanes.BREZE_7 = {
		Place = 'Burton',
		Start = vector3(-164.6483, -255.5894, 43.16),
		End = vector3(-171.0182, -273.6994 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-165.44, -253.04, 43.19),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}
    
    Lanes.BREZE_8 = {
		Place = 'Burton',
		Start = vector3(-167.633, -254.5395, 43.16),
		End = vector3(-174.003, -272.6495 - 0.0148, 43.17),
		Width = 0.64,
		GutterWidth = 0.8,
		GutterDepth = 0.17,
		PinDistance = 17.5,
		PinSideSpace = 0.375,
		SourcePoints = POINTS_BREZE,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-165.44, -253.04, 43.19),
		BallPickupOffsetMultiplier = 0.6,
		BallPickupZOffset = 0.0,
	}
end

if Config.EnabledMaps.GABZ_BOWLING then
    Lanes.GABZ_1 = {
		Place = 'LMESA',
		IsClosestToDoor = true,
		Start = vector3(746.89, -781.84, 25.45),
		End = vector3(728.26, -781.84, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(728.61, -780.8, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(18.88999 + 0.075, 0.01000977, 0.06999969),
	}
    
    Lanes.GABZ_2 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.085, 25.45),
		End = vector3(728.26, -781.84 + 2.085, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'LEFT',
		SourceRoot = vector3(728.61, -780.8, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(18.88999 + 0.075, 0.01000977, 0.06999969),
	}
    
    Lanes.GABZ_3 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.087 * 2, 25.45),
		End = vector3(728.26, -781.84 + 2.087 * 2, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(728.61, -780.8 + 4.17, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(18.53599 + 0.075, 0.01000977, 0.06999969),
	}
    Lanes.GABZ_4 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.0875 * 3, 25.45),
		End = vector3(728.26, -781.84 + 2.0875 * 3, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'LEFT',
		SourceRoot = vector3(728.61, -780.8 + 4.17, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(18.53599 + 0.075, 0.01000977, 0.06999969),
	}
    
    Lanes.GABZ_5 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.0875 * 4, 25.45),
		End = vector3(728.26, -781.84 + 2.0875 * 4, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(728.61, -780.8 + 4.17*2, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(19.120999 + 0.075, 0.01000977, 0.06999969),
	}
    Lanes.GABZ_6 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.0875 * 5, 25.45),
		End = vector3(728.26, -781.84 + 2.0875 * 5, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'LEFT',
		SourceRoot = vector3(728.61, -780.8 + 4.17*2, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(19.120999 + 0.075, 0.01000977, 0.06999969),
	}
    Lanes.GABZ_7 = {
		Place = 'LMESA',
		Start = vector3(746.89, -781.84 + 2.0875 * 7, 25.45),
		End = vector3(728.26, -781.84 + 2.0875 * 7, 25.45),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 17.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GABZ,
		SourceSide = 'LEFT',
		SourceRoot = vector3(728.61, -780.8 + 4.175*3, 26.06),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		LastRackBallPos = vector3(18.83199 + 0.075, 0.01000977, 0.06999969),
	}
end
    

if Config.EnabledMaps.YBN_MILO_RICHARDS_BOWLING then
    Lanes.MILO_1 = {
		Place = 'RICHARDS',
		IsClosestToDoor = true,
		Start = vector3(-1282.23, -675.63, 23.75),
		End = vector3(-1293.05, -661.75, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1282.7, -677.98, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_2 = {
		Place = 'RICHARDS',
		Start = vector3(-1279.74, -673.68, 23.74),
		End = vector3(-1290.64, -659.7, 23.74),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1277.94, -673.63, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_3 = {
		Place = 'RICHARDS',
		Start = vector3(-1277.53, -671.94, 23.75),
		End = vector3(-1288.42, -657.97, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1277.94, -673.63, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_4 = {
		Place = 'RICHARDS',
		Start = vector3(-1275.04, -669.99, 23.75),
		End = vector3(-1285.81, -656.17, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1272.66, -669.5, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_5 = {
		Place = 'RICHARDS',
		Start = vector3(-1271.85, -667.51, 23.75),
		End = vector3(-1282.66, -653.62, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1272.66, -669.5, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_6 = {
		Place = 'RICHARDS',
		Start = vector3(-1269.35, -665.56, 23.75),
		End = vector3(-1280.19, -651.64, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1267.53, -665.52, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
    Lanes.MILO_7 = {
		Place = 'RICHARDS',
		Start = vector3(-1267.14, -663.81, 23.75),
		End = vector3(-1277.99, -649.9, 23.75),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_MILO,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1267.53, -665.52, 24.42),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
	}
end


if Config.EnabledMaps.MAP4ALL_BOWLING then
    Lanes.M4A_1 = {
		Place = 'DELPERRO',
		IsClosestToDoor = true,
		Start = vector3(-1661.19, -1067.15, 12.07),
		End = vector3(-1649.39, -1077.05, 12.06),
		Width = 0.643,
		GutterWidth = 0.85,
		GutterDepth = 0.1,
		PinDistance = 13.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1663.7, -1066.49, 12.59),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		AngleOffset = 180.0,
	}

    Lanes.M4A_2 = {
		Place = 'DELPERRO',
		Start = vector3(-1662.87, -1069.13, 12.07),
		End = vector3(-1651.09, -1079.0, 12.06),
		Width = 0.643,
		GutterWidth = 0.85,
		GutterDepth = 0.1,
		PinDistance = 13.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1663.97, -1066.77, 12.51),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		AngleOffset = 180.0,
	}

    Lanes.M4A_3 = {
		Place = 'DELPERRO',
		Start = vector3(-1664.22, -1070.72, 12.07),
		End = vector3(-1652.45, -1080.6, 12.06),
		Width = 0.643,
		GutterWidth = 0.85,
		GutterDepth = 0.1,
		PinDistance = 13.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1666.84, -1069.97, 12.51),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		AngleOffset = 180.0,
	}

    Lanes.M4A_4 = {
		Place = 'DELPERRO',
		Start = vector3(-1665.87, -1072.72, 12.07),
		End = vector3(-1654.14, -1082.57, 12.06),
		Width = 0.643,
		GutterWidth = 0.85,
		GutterDepth = 0.1,
		PinDistance = 13.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1666.89, -1070.4, 12.51),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.6,
		AngleOffset = 180.0,
	}
end
	

if Config.EnabledMaps.GND_BOWLING then
    Lanes.GND_1 = {
		Place = 'DTV',
		Start = vector3(299.39, 236.29, 103.32),
		End = vector3(299.39, 236.29, 103.32) + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(301.32, 236.05, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}
	
    Lanes.GND_2 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32),
		End = vector3(302.955, 235.02, 103.32) + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(304.85, 234.73, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_3 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 1.013,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 1.013 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(308.4, 233.35, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_4 = {
		Place = 'DTV',
		IsClosestToDoor = true,
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 2.026,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 2.026 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(311.97, 232.1, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_5 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 3.039,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 3.039 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(315.53, 230.84, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_6 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 4.05200,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 4.05200 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(319.08, 229.56, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_7 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 5.06500,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 5.06500 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'LEFT',
		SourceRoot = vector3(322.61, 228.15, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}

    Lanes.GND_8 = {
		Place = 'DTV',
		Start = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 6.07800,
		End = vector3(302.955, 235.02, 103.32) + vec3(3.514984, -1.269989, 0.000000) * 6.07800 + vec3(6.690002, 18.380005, 0.000000),
		Width = 1.15,
		GutterWidth = 1.3,
		GutterDepth = 0.1,
		PinDistance = 17.5,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_GND,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(322.61, 228.15, 103.67),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.3,
		AngleOffset = 180.0,
	}
end

if Config.EnabledMaps.YBN_MILO_SANDY_SHORES then
    Lanes.MILO_SANDY_1 = {
		IsClosestToDoor = true,
		Place = 'Sandy Shores',
		Start = vector3(2712.85, 3473.66, 56.62),
		End = vector3(2705.99, 3457.5599999999, 56.6),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(2711.81, 3475.15, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_2 = {
		Place = 'Sandy Shores',
		Start = vector3(2709.94, 3474.87, 56.64),
		End = vector3(2703.12, 3458.89, 56.61),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(2711.43, 3475.39, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_3 = {
		Place = 'Sandy Shores',
		Start = vector3(2707.33, 3475.96, 56.62),
		End = vector3(2700.5, 3459.94, 56.61),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(2706.63, 3477.69, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_4 = {
		Place = 'Sandy Shores',
		Start = vector3(2704.41, 3477.21, 56.62),
		End = vector3(2697.59, 3461.18, 56.6),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(2706.19, 3477.75, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_5 = {
		Place = 'Sandy Shores',
		Start = vector3(2700.69, 3478.77, 56.62),
		End = vector3(2693.86, 3462.75, 56.6),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(2699.84, 3480.69, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_6 = {
		Place = 'Sandy Shores',
		Start = vector3(2697.77, 3480.03, 56.6),
		End = vector3(2690.94, 3463.98, 56.6),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(2699.41, 3480.82, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
    Lanes.MILO_SANDY_7 = {
		Place = 'Sandy Shores',
		Start = vector3(2695.18, 3481.11, 56.61),
		End = vector3(2688.37, 3465.09, 56.61),
		Width = 0.624,
		GutterWidth = 0.75,
		GutterDepth = 0.05,
		PinDistance = 16.1,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(2694.44, 3482.93, 57.25),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}
end


if Config.EnabledMaps.TLUX_BOWLING then
    Lanes.TLUX_1 = {
		IsClosestToDoor = true,
		Place = 'Vespucci Canals',
		Start = vector3(-1197.25, -1311.81, -1.94),
		End = vector3(-1202.7, -1299.99, -1.95),
		Width = 0.93,
		GutterWidth = 1.05,
		GutterDepth = 0.05,
		PinDistance = 11.0,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1194.98, -1313.77, -1.45),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}

    Lanes.TLUX_2 = {
		IsClosestToDoor = true,
		Place = 'Vespucci Canals',
		Start = vector3(-1194.72, -1310.63, -1.96),
		End = vector3(-1200.25, -1298.67, -1.95),
		Width = 0.93,
		GutterWidth = 1.05,
		GutterDepth = 0.05,
		PinDistance = 11.0,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1194.98, -1313.77, -1.45),
		BallPickupOffsetMultiplier = -0.8,
		BallPickupZOffset = -0.7,
	}

    Lanes.TLUX_3 = {
		IsClosestToDoor = true,
		Place = 'Vespucci Canals',
		Start = vector3(-1192.25, -1309.39, -1.96),
		End = vector3(-1197.7, -1297.52, -1.95),
		Width = 0.93,
		GutterWidth = 1.05,
		GutterDepth = 0.05,
		PinDistance = 11.0,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'RIGHT',
		SourceRoot = vector3(-1189.8, -1311.62, -1.5),
		BallPickupOffsetMultiplier = -0.6,
		BallPickupZOffset = -0.7,
	}

    Lanes.TLUX_4 = {
		IsClosestToDoor = true,
		Place = 'Vespucci Canals',
		Start = vector3(-1189.7, -1308.17, -1.94),
		End = vector3(-1195.2, -1296.29, -1.95),
		Width = 0.93,
		GutterWidth = 1.05,
		GutterDepth = 0.05,
		PinDistance = 11.0,
		PinSideSpace = 0.34,
		SourcePoints = POINTS_M4A,
		SourceSide = 'LEFT',
		SourceRoot = vector3(-1189.8, -1311.62, -1.5),
		BallPickupOffsetMultiplier = -0.8,
		BallPickupZOffset = -0.7,
	}
	
	
end