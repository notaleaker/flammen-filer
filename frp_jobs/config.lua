transportVehicle = nil
Config = {}

Config.Framework = "esx" -- esx or qbcore

Config.Blips = {
    ["Miner"] = {
        Mining = { enabled = true, coords = vector3(2953.28, 2787.98, 41.52), sprite = 618, color = 5, scale = 0.9, name = "Stengrav" },
        Washing = { enabled = true, coords = vector3(1901.76, 252.56, 161.27), sprite = 618, color = 5, scale = 0.9, name = "Vaskning" },
        Smelting = { enabled = true, coords = vector3(1110.0, -2008.18, 31.06), sprite = 618, color = 5, scale = 0.9, name = "Smeltningsfabrik" },
        Selling = { enabled = true, coords = vector3(412.16, 314.97, 103.13), sprite = 618, color = 5, scale = 0.9, name = "Malm Salg" },
    },
    ["Lumberjack"] = {
        Cutting = { enabled = true, coords = vector3(-577.61, 5427.71, 59.1), sprite = 68, color = 10, scale = 0.9, name = "Skov" },
        Clearing = { enabled = true, coords = vector3(-552.07, 5328.25, 73.64), sprite = 68, color = 10, scale = 0.9, name = "Træfabrik" },
        Packing = { enabled = true, coords = vector3(-494.57, 5294.97, 80.61), sprite = 68, color = 10, scale = 0.9, name = "Træforarbejdning" },
        Selling = { enabled = true, coords = vector3(-567.67, 5253.13, 70.49), sprite = 68, color = 10, scale = 0.9, name = "Træ Salg" },
    },
    ["Butcher"] = {
        Catching = { enabled = true, coords = vector3(2297.05, 4941.75, 41.44), sprite = 89, color = 17, scale = 0.9, name = "Kyllinge farm" },
        Slaughtering = { enabled = true, coords = vector3(-95.63, 6207.09, 31.03), sprite = 89, color = 17, scale = 0.9, name = "Slagterfabrik" },
        Selling = { enabled = true, coords = vector3(-67.65, 6254.1, 31.09), sprite = 89, color = 17, scale = 0.9, name = "Hønse salg" },
    },
    ["Tailor"] = {
        Delivery = { enabled = true, coords = vector3(2313.27, 4888.41, 41.81), sprite = 366, color = 13, scale = 0.9, name = "Uld levering" },
        Sewing = { enabled = true, coords = vector3(714.82, -967.99, 30.4), sprite = 366, color = 13, scale = 0.9, name = "Syhus" },
        Selling = { enabled = true, coords = vector3(707.3, -966.97, 30.41), sprite = 366, color = 13, scale = 0.9, name = "Tøj Salg" },
    },
    ["Garbage"] = {
        --Garbage = { enabled = true, coords = vector3(-322.22, -1545.9, 31.02), sprite = 365, color = 25, scale = 0.9, name = "Dump Factory" },
    },
}

Config.MinerJob = {
    jobRequired = true,
    jobName = "miner",
    hitCount = 3,
    stoneGive = 1,
    MiningCoords = {
       vector4(2972.13, 2798.44, 42.22, 314.08),
       vector4(2979.02, 2790.76, 41.57, 327.36),
       vector4(2969.14, 2775.8, 39.68, 202.17),
       vector4(2951.66, 2768.3, 39.85, 214.73),
    },
    stoneRemove = 3,
    washedGive = 1,
    WashingCoords = {
        vector4(1901.76, 252.56, 161.27, 214.48),
        vector4(1904.73, 257.02, 161.41, 241.72),
        vector4(1904.69, 261.86, 161.71, 276.01),
    },
    washedRemove = 1,
    smeltingGive = 1,
    SmeltingCoords = {
        vector4(1110.0, -2008.18, 31.06, 242.78)
    },
    SellingCoords = vector3(412.16, 314.97, 103.13),
    Price = 500, -- one item price
}

Config.LumberjackJob = {
    jobRequired = true,
    jobName = "lumberjack",
    hitCount = 3,
    woodGive = 1,
    WoodCoords = {
       vector4(-577.61, 5427.71, 59.1, 120.38),
       vector4(-585.75, 5447.78, 60.37, 123.33),
       vector4(-597.14, 5473.1, 56.49, 36.35),
       vector4(-583.25, 5490.26, 55.92, 32.82),
       vector4(-590.23, 5493.5, 54.29, 336.89),
    },
    woodRemove = 3,
    cleanedGive = 1,
    CuttingCoords = {
        vector4(-552.07, 5328.25, 73.64, 339.33)
    },
    plankHitCount = 5,
    cleanedRemove = 1,
    packedGive = 1,
    PlankCoords = {
        vector4(-494.57, 5294.97, 80.61, 74.11)
    }, 
    SellingCoords = vector3(-567.67, 5253.13, 70.49), 
    Price = 1300, -- one item price
    TransportVehicle = "packer",
    TransportTrailer = "trailers2",
    ForkliftModel = "forklift",
    VehicleSpawnCoords = vector4(-600.71, 5294.01, 70.21, 189.98),
    TrailerSpawnCoords = vector4(-602.28, 5302.26, 70.21, 196.5),
    ForkliftSpawnCoords = vector4(-601.37, 5316.34, 70.4, 214.74),
    PackageModel = "prop_boxpile_06a",
    PackageCoords = {
        { handle = nil, coords = vector3(-593.13, 5310.53, 70.21) },
        { handle = nil, coords = vector3(-591.02, 5305.06, 70.21) },
        { handle = nil, coords = vector3(-590.46, 5299.32, 70.21) },
    },
    TransportCoords = {
        vector3(2679.62, 1600.6, 24.49),
        vector3(1713.03, -1454.75, 112.8),
    },
    FinishCoords = vector3(-602.82, 5314.39, 70.39),
}

Config.ButcherJob = {
    jobRequired = true,
    jobName = "butcher",
    chickenGive = 1,
    ChickenCoords = {
        { handle = nil, coords = vector3(2297.05, 4941.75, 41.44) },
        { handle = nil, coords = vector3(2300.62, 4944.68, 41.44) },
        { handle = nil, coords = vector3(2304.71, 4942.65, 41.39) },
        { handle = nil, coords = vector3(2301.58, 4939.40, 41.42) },
    },
    chickenRemove = 1,
    slaughteredGive = 1,
    CuttingCoords = {
        { coords = vector4(-95.63, 6207.09, 31.03, 309.72), chickenCoords = vector3(-94.87, 6207.008, 30.08), rotation = vector3(90.0, 0.0, 45.0) },
        { coords = vector4(-98.62, 6205.05, 31.03, 45.05), chickenCoords = vector3(-99.5, 6205.1, 30.1), rotation = vector3(90.0, 0.0, -45.0) },
    },
    PackageWait = 5, -- 5 seconds
    slaughteredRemove = 1,
    packagedGive = 1,
    PackageCoords = {
        vector4(-106.21, 6204.58, 31.03, 40.73),
        vector4(-103.98, 6206.79, 31.03, 40.73),
        vector4(-102.21, 6208.68, 31.03, 40.73),
        vector4(-99.96, 6210.83, 31.03, 40.73),
    },
    SellingCoords = vector3(-67.65, 6254.1, 31.09), 
    Price = 1500, -- one item price
    TransportVehicle = "burrito3",
    VehicleSpawnCoords = {
        vector4(-64.28, 6280.08, 31.2, 115.13),
        vector4(-56.93, 6272.74, 31.2, 33.88),
    },
    TransportCount = 2,
    TransportCoords = {
        vector3(-299.98, 6256.03, 31.52),
        vector3(162.16, 6636.57, 31.56),
        vector3(2455.53, 4058.46, 38.06),
        vector3(1391.82, 3604.7, 34.98),
    },
    FinishCoords = vector3(-80.73, 6271.39, 31.2),
}

Config.TailorJob = {
    jobRequired = true,
    jobName = "tailor",
    PedModel = "a_m_m_farmer_01",
    PedCoords = vector4(2313.27, 4888.41, 41.81, 47.78),
    WoolPrice = 500,
    woolGive = 10,
    woolRemove = 3,
    clothesGive = 1,
    SewingCoords = {
        { coords = vector4(714.82, -967.99, 30.4, 92.97), anim = "sewing_idle_01_character_b" },
        { coords = vector4(714.86, -970.18, 30.4, 92.97), anim = "sewing_idle_01_character_b" },
        { coords = vector4(714.77, -972.41, 30.4, 92.97), anim = "sewing_idle_01_character_b" },
        
        { coords = vector4(713.74, -960.02, 30.4, 182.88), anim = "sewing_idle_02_character_c" },
        { coords = vector4(716.36, -960.08, 30.4, 182.88), anim = "sewing_idle_02_character_c" },
    },
    PackageWait = 5, -- 5 seconds
    clothesRemove = 1,
    packagedGive = 1,
    PackageCoords = {
        vector4(711.74, -968.06, 30.4, 266.64),
        vector4(711.67, -970.78, 30.4, 266.64),
    },
    SellingCoords = vector3(707.3, -966.97, 30.41), 
    Price = 1000, -- one item price
    TransportVehicle = "burrito3",
    VehicleSpawnCoords = {
        vector4(702.14, -980.07, 24.14, 225.48),
        vector4(706.56, -979.63, 24.14, 223.95),
        vector4(711.08, -979.54, 24.11, 218.83),
    },
    TransportCount = 2,
    TransportCoords = {
        vector3(72.254, -1399.102, 28.376),
        vector3(-703.776, -152.258, 36.415),
        vector3(-167.863, -298.969, 38.733),
        vector3(428.694, -800.106, 28.491),
        vector3(-829.413, -1073.710, 10.328),
        vector3(-1447.797, -242.461, 48.820),
        vector3(11.632, 6514.224, 30.877),
        vector3(123.646, -219.440, 53.557),
        vector3(1696.291, 4829.312, 41.063),
        vector3(618.093, 2759.629, 41.088),
        vector3(1190.550, 2713.441, 37.222),
        vector3(-1193.429, -772.262, 16.324),
        vector3(-3172.496, 1048.133, 19.863),
        vector3(-1108.441, 2708.923, 18.107),
    },
    FinishCoords = vector3(701.87, -992.19, 23.92),
}

Config.GarbageJob = {
  --[[  jobRequired = false,
    jobName = "garbage",
    Reward = 500, -- total money
    PedModel = "s_m_y_garbage",
    PedCoords = vector4(-322.22, -1545.9, 31.02, 314.52),  
    VehicleModel = "trash2",
    VehicleSpawnCoords = {
        vector4(-311.1, -1518.59, 27.41, 242.69),
    },
    CollectionCount = 2,
    CollectionCoords = {
        vector3(-1459.99, -627.87, 32.18),
        vector3(-9.58, -1564.48, 30.73),
        vector3(157.83, -1819.43, 29.44),
        vector3(156.31, -1818.01, 29.43),
        vector3(354.64, -1810.63, 30.35),
        vector3(359.34, -1811.09, 30.35),
        vector3(489.35, -1281.98, 30.77),
        vector3(489.36, -1283.99, 30.76),
        vector3(128.18, -1053.57, 30.58),
        vector3(130.29, -1054.0, 30.60),
        vector3(-1609.42, -506.11, 37.49),
        vector3(379.83, -900.07, 30.81),
        vector3(50.08, -1044.20, 30.95),
        vector3(-1460.23, -627.74, 32.07),
        vector3(449.56, -573.41, 30.31),
        vector3(-1250.43, -1280.66, 5.41),
        vector3(-1230.48, -1218.29, 8.42),
        vector3(-1226.39, -1217.47, 8.43),
        vector3(-34.37, -87.70, 58.62),
        vector3(276.82, -168.34, 61.43),
        vector3(-360.72, -1864.39, 22.47),
        vector3(-1236.27, -1399.40, 5.59),
    },
    FinishCoords = vector3(-349.24, -1530.76, 27.71)]]
}

Strings = {
    -- General --
    ["sold_item"] = "Du tjente DKK%s",
    ["spawn_area_full"] = "Køretøjes spawn zone er fuld!",
    ["dont_have_money"] = "Du har ikke nok penge",
    ["open_trunk"] = "Tryk ~INPUT_CONTEXT~ for at åbne baggagerummet.",
    ["vehicle_not_found"] = "Du er ikke i firma køretøjet!",

    -- Miner --
    ["start_mining"] = "Tryk ~INPUT_CONTEXT~ for at mine",
    ["start_washing"] = "Tryk ~INPUT_CONTEXT~ for at vaske stenene",
    ["start_smelting"] = "Tryk ~INPUT_CONTEXT~ for at smelte stenene",
    ["start_selling_ores"] = "Tryk ~INPUT_CONTEXT~ for at sælge malme",
    ["dont_have_stones"] = "Du har ikke nok sten",
    ["dont_have_washed_stones"] = "Du har ikke nok vaskede sten",
    ["dont_have_processed_ore"] = "Du har ikke nok forarbejdet malm",
    ["miner_mining"] = "Du miner...",
    ["miner_washing"] = "Du vasker stenene...",
    ["miner_smelting"] = "Du smelter de vaskede sten...",
    ["miner_gave_stone"] = "Du fandt 1x sten",
    ["miner_gave_washed_stone"] = "Du vaskede stenene og du får x1 vasket sten",
    ["miner_gave_processed_ore"] = "Du smeltede vaskede sten, og du får x1 forarbejdet malm",

    -- LumberJack --
    ["start_cutting"] = "Tryk ~INPUT_CONTEXT~ for at begynde at hugge træ",
    ["start_cleaning"] = "Tryk ~INPUT_CONTEXT~ for at begynde at rense træ",
    ["start_pruning"] = "Tryk ~INPUT_CONTEXT~ for at begynde at beskære træet",
    ["start_selling_planks"] = "Tryk ~INPUT_CONTEXT~ for at sælge plankerne",
    ["dont_have_wood"] = "Du har ikke træ nok",
    ["dont_have_cleaned_wood"] = "Du har ikke nok renset træ",
    ["dont_have_planks"] = "Du har ikke nok planker",
    ["lumberjack_cutting"] = "Du hugger træet...",
    ["lumberjack_cleaning"] = "Du renser træet...",
    ["lumberjack_pruning"] = "Du beskærer træet...",
    ["lumberjack_gave_wood"] = "Du skærer x1 træ",
    ["lumberjack_gave_cleaned_wood"] = "Du rensede træet og du får x1 renset træ",
    ["lumberjack_gave_plank"] = "Du beskærer træet og du får x1 planke",
    ["lumberjack_deliver_planks"] = "Tryk ~INPUT_CONTEXT~ for at levere plankerne",
    ["lumberjack_deliver_truck"] = "Tryk ~INPUT_CONTEXT~ for at levere lastbilen",
    ["lumberjack_load_vehicle"] = "Tryk ~INPUT_CONTEXT~ for at læsse pallen i køretøjet",
    ["lumberjack_start_loading"] = "Indlæs paller i køretøjet",
    ["lumberjack_start_transport"] = "Sæt dig ind i køretøjet og start leveringen",
    ["lumberjack_back_factory"] = "Tilbage til træfabrikken",

    -- Tailor --
    ["delivery_take"] = "Tryk ~INPUT_CONTEXT~ for at få uldpakken.\nPris : ~g~DKK%s~s~",
    ["start_sewing"] = "Tryk ~INPUT_CONTEXT~ for at begynde at sy ulden",
    ["start_package_clothes"] = "Tryk ~INPUT_CONTEXT~ for at begynde at pakke tøjet",
    ["start_selling_clothes"] = "Tryk ~INPUT_CONTEXT~ for at begynde at sælge tøjet",
    ["dont_have_wool"] = "Du har ikke nok uld",
    ["dont_have_clothes"] = "Du har ikke nok tøj",
    ["dont_have_packaged_clothes"] = "Du har ikke nok pakket tøj",
    ["tailor_buyed_wool"] = "Du købte 10 uld",
    ["tailor_sewing"] = "Du syr tøj...",
    ["tailor_gave_clothes"] = "Du har lavet x1 tøj",
    ["tailor_start_packing"] = "Du pakker tøjet",
    ["tailor_gave_packaged_clothes"] = "Du har pakket tøjet og du får x1 pakket tøj",
    ["tailor_start_transport"] = "Sæt dig ind i køretøjet og start leveringen",
    ["tailor_back_factory"] = "Tilbage til tøjfabrikken",
    ["tailor_deliver_package"] = "Tryk ~INPUT_CONTEXT~ at levere pakken",
    ["tailor_deliver_van"] = "Tryk ~INPUT_CONTEXT~ at levere varevognen",
    ["tailor_deliver_next"] = "Sæt dig ind i bilen og gå til den næste tøjbutik",

    -- Butcher --
    ["start_catching"] = "Tryk ~INPUT_CONTEXT~ for at fange kyllingen",
    ["start_cutting_chicken"] = "Tryk ~INPUT_CONTEXT~ for at begynde at skære kylling",
    ["start_packing_chicken"] = "Tryk ~INPUT_CONTEXT~ at begynde at pakke kyllingerne",
    ["dont_have_chicken"] = "Du har ikke nok levende kylling",
    ["dont_have_slaughtered_chicken"] = "Du har ikke nok slagtet kylling",
    ["dont_have_packaged_chicken"] = "Du har ikke nok pakket kylling",
    ["butcher_start_slaughtered"] = "Du slagter kyllingen...",
    ["butcher_gave_chicken"] = "Du fangede 1 kylling",
    ["butcher_fail_chicken"] = "Kyllingen slap ud af deres hænder!",
    ["butcher_gave_slaughtered_chicken"] = "Du har slagtet kyllingen, og du får x1 slagtet kylling",
    ["butcher_start_packing"] = "Du pakker de slagtede kyllinger",
    ["butcher_gave_packaged_chicken"] = "Du har pakket kyllingen, og du får x1 pakket kylling",
    ["butcher_deliver_chicken"] = "Tryk ~INPUT_CONTEXT~ for at levere den pakkede kylling",
    ["butcher_deliver_package"] = "Tryk ~INPUT_CONTEXT~ for at levere pakken.",
    ["butcher_back_factory"] = "Tilbage til slagteriet",
    ["butcher_deliver_van"] = "Tryk ~INPUT_CONTEXT~ for at levere varevognen",
    ["butcher_deliver_next"] = "Sæt dig ind i bilen og gå til det næste sted",

    -- Garbage --
    ["start_garbage"] = "Tryk ~INPUT_CONTEXT~ for at starte affaldsindsamling",
    ["garbage_get_in_car"] = "Sæt dig ind i skraldebilen og start missionen",
    ["cancel_garbage"] = "Tryk ~INPUT_CONTEXT~ for at annullere affaldsindsamling",
    ["canceled_garbage"] = "Mission aflyst",
    ["search_dump"] = "Tryk ~INPUT_CONTEXT~ for at søge dump",
    ["finish_garbage"] = "Tryk ~INPUT_CONTEXT~ at afslutte jobbet",
    ["put_dump"] = "Tryk ~INPUT_CONTEXT~ for at lægge skraldepose i bagagerummet",
    ["garbage_back_factory"] = "Tilbage til skraldefabrikken",
    ["garbage_next_station"] = "Sæt dig ind i bilen og gå til det næste sted",
}

ShowHelpNotification = function(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

ShowNotification = function(message, flash)
	BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(flash, 1)
end

SpawnVehicle = function(model, coords)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
    transportVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleOnGroundProperly(transportVehicle)
    SetVehicleHasBeenOwnedByPlayer(transportVehicle, true)
    SetVehicleNeedsToBeHotwired(transportVehicle, false)
    SetModelAsNoLongerNeeded(model)
    return transportVehicle
end

IsSpawnPointClear = function(coords)
    for k,v in pairs(coords) do
        local retval = IsAnyVehicleNearPoint(v.x, v.y, v.z, 1.0)
        if not retval then
            return v
        end
    end
    return false
end

RequestAndWaitModel = function(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
    return
end