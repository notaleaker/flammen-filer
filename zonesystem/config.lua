-- Crucial for scenes.
mLibs = exports["meta_libs"]

Config = {
  Lang              = 'en',           -- Currently only supports en.
  Debug             = false,           -- Remove after testing.
  ShowDebugText     = false,           -- Display drawtext for zone? Mostly used for debugging.

  InteractControl   = 47,             -- Control code to interact with most things.
  SlingDrugsControl = 47,             -- Hotkey to sling drugs.
  SlingByHotkey     = true,           -- If false must use /slingdrugs command
  InteractDist      = 2.0,            -- Distance to interact with things.
  InfluenceInHouse  = false,          -- Gain influence inside playerhousing?

  InfluenceTick     = 5000,           -- how long between influence gain/loss tick?

  DisplayZoneForAll  = true,         -- Display territory zone blips for all?
  DrugProcessBlip    = true,          -- Display drug process blip for gang members?

  MaxPlayerCount    = 128,             -- Change if using onesync I guess?
  UseProgBars       = true,          -- Using ProgBars? (should be included inside mod folder)
  StartEvent        = 'Thread',       -- If you don't want to start the mod by Citizen.CreateThread, change from "Thread" to your event name.
                                      -- NOTE: Must be client event/non-networked event.

  DrugSellDist      = 10.0,           -- Distance peds will buy drugs from
  DrugBuyChance     = 50,             -- % Chance for ped to buy drugs from a player.
  SalesReportChance = 1,              -- % Chance for ped to report player to police if they didn't buy the drugs.
  SellDrugsTimer    = 5000,           -- How long does the drug deal take? (MS)
  MinSellAmount     = 1,              -- Minimum amount of drugs to sell
  MaxSellAmount     = 20,             -- Max amount of drugs to sell
  SellDrugsTime     = 3,
  DrugSaleCooldown  = 3,						-- Cooldown between each selling in seconds.	
  CallPoliceChance  = 3,				-- 2 means 50%, 3 means 33%, 4 means 25% and etc

  DirtyReward       = true,           -- For drug deals. If false, receive clean money.
  DirtyAccount      = 'black_money',  -- For many things. Make sure you set this properly.

  SetJobEvent       = 'esx:setJob',   -- Probably don't change this if you're using ESX.
  SetJob2Event      = 'esx:setJob2',  -- If youre using job2...

  UsingItemLimit    = false,  -- if using esx item limits
  UsingWeightLimit  = false, -- if using esx item weight

  SqlSaveTimer      = 1, -- minutes for zone influence to save to database

  SmackCheaters     = true,

  -- Set sell prices here. Remember, values are multiplied with 10, so 11 means $110, 7 means $70 and etc. etc.
  CokeSale = {
    min = 70,
    max = 75
  },
  MethSale = {
    min = 90,
    max = 95
  },
  WeedSale = {
    min = 60,
    max = 65
  },
  LSDSale = {
    min = 10,
    max = 20
  },
  HeroinSale = {
    min = 80,
    max = 85
  },
  

CokeDrug = "coke",						-- item name in database 				
MethDrug = "methbag",					-- item name in database 
WeedDrug = "marijuana",						-- item name in database			         	-- item name in database
heroinDrug = "heroin",


  PoliceJobs = {
    'police',                         -- The police job names.
  },

  GangJobs = {                        -- List all jobs that are able to contest for and control territories here.                       -- NOTE: Don't need to include police. Thats taken from PoliceJobs table above.
    "brothas",
    "ltb",
    "cc",
    "sa26",
    "shqiptare",
    "lorenzo",
    "sft",
    "sg86",
    "schultz",
    "sg18",
    "jr",
    "tbf",
    "mcartel",
    "raza",
    "ba",
    "deadly",
    "satudarah",
    "cds",
    "shottaz",
    "tenebre",
    "cm",
    "irish",
    "dp",
    "ltf",
    "bandidos",
    "cosanostra",
    "cdm",
    "lf",
    "nnv",
    "ndr",
    "pb",
    "bratva",
    "nr",
    "mg",
    "vg",
    "lv",
    "ns",
    "pacific",
    "vl",
    "ms13"
  }
}

-- Drug sale prices, while slinging drugs inside a territory.
DrugPrices = {
  ['marijuana']    = 855,
  ['coke'] = 800,
  ['heroin']    = 850,
  ['methbag']    = 980,
}

-- The color for the blip when gang/job is controlling zone.
BlipColors = {
  police  = 0,
  unemployed  = 1,
}


-- Config.maxCap = 9999999								-- max amount of drugs to be sold per server restart, to disable do not set to 0, instead set to 999999
-- Config.DrugSaleCooldown = 1						-- Cooldown between each selling in seconds.
-- Config.SellDrugsBarText = "Sægler Stoffer"		-- Progress Bar Text for selling drugs
-- Config.SellDrugsTime = 3						-- time taken to negotiate with NPC in seconds
-- Config.Enable3DTextToSell = true				-- true = 3D text | false = HelpNotification
-- Config.ReceiveDirtyCash = true					-- true = dirty cash | false = normal cash
-- Config.CokeDrug = "coke"						-- item name in database 				
-- Config.MethDrug = "meth"						-- item name in database 
-- Config.WeedDrug = "marijuana"						-- item name in database
-- Config.LSDDrug = "lsd" 				         	-- item name in database
-- Config.heroinDrug = "heroin"					-- item name in database
-- Config.CallPoliceChance = 5				-- 2 means 50%, 3 means 33%, 4 means 25% and etc


-- Colors for drawtext.
TextColors = {
  brothas  = "white", 
  ltb = "cyan",         
  nnv = "whitesmoke",    
  cc   = "green",
  sa26  = "purple",
  shqiptare  = "red",
  lorenzo = "orange",
  sft = "blue",
  sg86 = "black",
  schultz = "brown",
  sg18 = "burlywood",
  ltf = "chocolate",
  mcartel = "bisque",
  raza = "darkgreen",
  deadly = "chartreuse",
  satudarah = "darkkhaki",
  dp = "whitesmoke",
  ba = "fuchsia",
  shottaz = "darkmagenta",
  cds = "deeppink",
  irish = "darkturquoise",
  tenebre = "deeppink",
  ns = "lightskyblue",
  bandidos = "cadetblue",
  cosanostra = "darksalmon",
  pb = "firebrick",
  cdm = "coral",
  lf = "gold",
  jr = "salmon",
  nr = "lightslategray",
  bratva = "dimgray",
  ndr = "darkslategray",
  vg = "navy",
  lv = "powderblue",
  mg = "magenta",
  vl = "plum",
  pacific = "lightgray",
  cm = "beige",
  ms13 = "lightsalmon"
}
-- Don't touch.
_U = Langs[Config.Lang]  

Territories = {
  ["East V"] = {
    openzone    = false,                                  -- Allow all players to use this drug production facility and sling drugs in this zone?
    control     = "police",                               -- The default control for this zone belongs to this job.
    influence   = 100.0,                                  -- The default influence for this zone.
    zone        = "EAST_V",                               -- Probably don't change this unless you intend on moving the zones around.

    canSell = false,                                      -- Can sell drugs in this zone? If false, no drugs can be sold here.
                                                          -- Check other examples on how to sell drugs in a zone.

    areas = {                                             -- Areas are responsible for the large square blips on the map.

    },

    blipData = false,

    -- MONEY LAUNDRY HOUSE
  
  },

  ["Los Santos International Airport"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "AIRP",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Vinewood Racetrack"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "HORS",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Burton"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "BURTON",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Richman"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "RICHM",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Del Perro"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "DELPE",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Richards Majestic"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "MOVIE",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Vespucci Canals"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "VCANA",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Morningwood"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "MORN",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Rockford Hills"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "ROCKF",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["West Vinewood"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "WVINE",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Hawick"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "HAWICK",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Alta"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "ALTA",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Downtown Vinewood"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "DTVINE",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Mirror Park"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "MIRR",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Terminal"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "TERMINA",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Murrieta Heights"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "MURRI",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["La Mesa"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "LMESA",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Cypress Flats"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "CYPRE",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Pacific Bluffs"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "PBLUFF",

    canSell   = {
      'weed',
    },

    areas = {
    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Banning"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "BANNING",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Maze Bank Arena"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "STAD",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Del Perro Beach"] = {
    openzone  = true,
    control   = "pf9",
    influence = 100.0,
    zone      = "DELBE",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Vespucci Beach"] = {
    openzone  = true,
    control   = "pf9",
    influence = 100.0,
    zone      = "BEACH",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["La Puerta"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "LOSPUER",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Pillbox Hill"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "PBOX",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Downtown"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "DOWNT",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Vinewood"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "VINE",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Little Seoul"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "KOREAT",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

    ["Strawberry"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "STRAW",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["La Puerta"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "DELSOL",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Legion Square"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "LEGSQU",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Mission Row"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "SKID",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Textile City"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "TEXTI",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Sandy Shores"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "SANDY",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  ["Elysian Island"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "ELYSIAN",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

    -- WEED GROW HOUSE
  },

  -- DAVIS
  ["Davis"] = {
    openzone  = true,
    control   = "police",
    influence = 100.0,
    zone      = "DAVIS",

    canSell   = {
      'weed',
    },

    areas = {

    },

    blipData = false,

  },

  -- CHAMBERLAIN HILLS
  ["ChamberlainHills"] = {
    openzone  = false,
    control   = "ballas",
    influence = 100.0,
    zone      = "CHAMH",

    canSell   = {
      'meth_packaged',
    },

    areas = {

    },

    blipData = false,
  },

  -- RANCHO
  ["Rancho"] = {
    openzone  = false,
    control   = "vagos",
    influence = 100.0,
    zone      = "RANCHO",

    canSell   = {
      'cocaine_packaged',
    },

    areas = {
  
    },

    blipData = false,

    -- COCAINE FACTORY
  },

  -- PALETO
  -- Empty area, containing no actions.
  ["Paleto"] = {
    openzone  = true,
    control   = "raza",
    influence = 0.0,
    zone      = "PALETO",

    canSell   = {
      'cocaine_packaged',
    },

    areas = {

    },

    blipData  = false,
    actions   = false,
  },
} 
-- Animation dicts for scenes.
SceneDicts = {
  Cocaine = {
    [1] = 'anim@amb@business@coc@coc_unpack_cut_left@',
    [2] = 'anim@amb@business@coc@coc_packing_hi@',
  },
  Meth = {
    [1] = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@',
    [2] = 'anim@amb@business@meth@meth_smash_weight_check@',
  },
  Weed = {
    [1] = 'anim@amb@business@weed@weed_inspecting_lo_med_hi@',
    [2] = 'anim@amb@business@weed@weed_sorting_seated@',
  }, 
  Money = {
    [1] = 'anim@amb@business@cfm@cfm_counting_notes@',
    [2] = 'anim@amb@business@cfm@cfm_cut_sheets@',
    [3] = 'anim@amb@business@cfm@cfm_drying_notes@',
  }
}

-- Animation for player within scenes.
PlayerAnims = {
  Cocaine = {
    [1] = 'coke_cut_v5_coccutter',
    [2] = 'full_cycle_v3_pressoperator'
  },
  Meth = {
    [1] = 'chemical_pour_short_cooker',
    [2] = 'break_weigh_v3_char01',
  },
  Weed = {
    [1] = 'weed_spraybottle_crouch_spraying_02_inspector',
    [2] = "sorter_right_sort_v3_sorter02",
  }, 
  Money = {
    [1] = 'note_counting_v2_counter',
    [2] = 'extended_load_tune_cut_billcutter',
    [3] = 'loading_v3_worker',
  }
}

-- Animation for entities within scenes.
SceneAnims = {
  Cocaine = {
    [1] = {
      bakingsoda  = 'coke_cut_v5_bakingsoda',
      creditcard1 = 'coke_cut_v5_creditcard',
      creditcard2 = 'coke_cut_v5_creditcard^1',     
    },
    [2] = {
      scoop     = 'full_cycle_v3_scoop',
      box1      = 'full_cycle_v3_FoldedBox',
      dollmold  = 'full_cycle_v3_dollmould',
      dollcast1 = 'full_cycle_v3_dollcast',
      dollcast2 = 'full_cycle_v3_dollCast^1',
      dollcast3 = 'full_cycle_v3_dollCast^2',
      dollcast4 = 'full_cycle_v3_dollCast^3',
      press     = 'full_cycle_v3_cokePress',
      doll      = 'full_cycle_v3_cocdoll',
      bowl      = 'full_cycle_v3_cocbowl',
      boxed     = 'full_cycle_v3_boxedDoll',
    },
  },
  Meth = {
    [1] = {
      ammonia   = 'chemical_pour_short_ammonia',
      clipboard = 'chemical_pour_short_clipboard',
      pencil    = 'chemical_pour_short_pencil',
      sacid     = 'chemical_pour_short_sacid',
    },
    [2] = {
      box1      = 'break_weigh_v3_box01',
      box2      = 'break_weigh_v3_box01^1',
      clipboard = 'break_weigh_v3_clipboard',
      methbag1  = 'break_weigh_v3_methbag01',
      methbag2  = 'break_weigh_v3_methbag01^1',
      methbag3  = 'break_weigh_v3_methbag01^2',
      methbag4  = 'break_weigh_v3_methbag01^3',
      methbag5  = 'break_weigh_v3_methbag01^4',
      methbag6  = 'break_weigh_v3_methbag01^5',
      methbag7  = 'break_weigh_v3_methbag01^6',
      pen       = 'break_weigh_v3_pen',
      scale     = 'break_weigh_v3_scale',
      scoop     = 'break_weigh_v3_scoop',     
    },
  },
  Weed = {
    [1] = {},
    [2] = {
      weeddry1  = 'sorter_right_sort_v3_weeddry01a',
      weeddry2  = 'sorter_right_sort_v3_weeddry01a^1',
      weedleaf1 = 'sorter_right_sort_v3_weedleaf01a',
      weedleaf2 = 'sorter_right_sort_v3_weedleaf01a^1',
      weedbag   = 'sorter_right_sort_v3_weedbag01a',
      weedbud1a = 'sorter_right_sort_v3_weedbud02b',
      weedbud2a = 'sorter_right_sort_v3_weedbud02b^1',
      weedbud3a = 'sorter_right_sort_v3_weedbud02b^2',
      weedbud4a = 'sorter_right_sort_v3_weedbud02b^3',
      weedbud5a = 'sorter_right_sort_v3_weedbud02b^4',
      weedbud6a = 'sorter_right_sort_v3_weedbud02b^5',
      weedbud1b = 'sorter_right_sort_v3_weedbud02a',
      weedbud2b = 'sorter_right_sort_v3_weedbud02a^1',
      weedbud3b = 'sorter_right_sort_v3_weedbud02a^2',
      bagpile   = 'sorter_right_sort_v3_weedbagpile01a',
      weedbuck  = 'sorter_right_sort_v3_bucket01a',
      weedbuck  = 'sorter_right_sort_v3_bucket01a^1',
    },
  },
  Money = {
    [1] = {
      binmoney  = 'note_counting_v2_binmoney',
      moneybin  = 'note_counting_v2_moneybin',
      money1    = 'note_counting_v2_moneyunsorted',
      money2    = 'note_counting_v2_moneyunsorted^1',
      wrap1     = 'note_counting_v2_moneywrap',
      wrap2     = 'note_counting_v2_moneywrap^1',
    },
    [2] = {
      cutter    = 'extended_load_tune_cut_papercutter',
      singlep1  = 'extended_load_tune_cut_singlemoneypage',
      singlep2  = 'extended_load_tune_cut_singlemoneypage^1',
      singlep3  = 'extended_load_tune_cut_singlemoneypage^2',
      table     = 'extended_load_tune_cut_table',
      stack     = 'extended_load_tune_cut_moneystack',
      strip1    = 'extended_load_tune_cut_singlemoneystrip',
      strip2    = 'extended_load_tune_cut_singlemoneystrip^1',
      strip3    = 'extended_load_tune_cut_singlemoneystrip^2',
      strip4    = 'extended_load_tune_cut_singlemoneystrip^3',
      strip5    = 'extended_load_tune_cut_singlemoneystrip^4',
      sinstack  = 'extended_load_tune_cut_singlestack',
    },
    [3] = {
      bucket    = 'loading_v3_bucket',
      money1    = 'loading_v3_money01',
      money2    = 'loading_v3_money01^1',
    }
  },
}

-- Objects for entities within scenes.
SceneItems = {
  Cocaine = {
    [1] = {
      bakingsoda  = 'bkr_prop_coke_bakingsoda_o',
      creditcard1 = 'prop_cs_credit_card',
      creditcard2 = 'prop_cs_credit_card',
    },
    [2] = {
      scoop     = 'bkr_prop_coke_fullscoop_01a',
      doll      = 'bkr_prop_coke_doll',
      boxed     = 'bkr_prop_coke_boxedDoll',
      dollcast1 = 'bkr_prop_coke_dollCast',
      dollcast2 = 'bkr_prop_coke_dollCast',
      dollcast3 = 'bkr_prop_coke_dollCast',
      dollcast4 = 'bkr_prop_coke_dollCast',
      dollmold  = 'bkr_prop_coke_dollmould',
      bowl      = 'bkr_prop_coke_fullmetalbowl_02',
      press     = 'bkr_prop_coke_press_01b',      
      box1      = 'bkr_prop_coke_dollboxfolded',
    },
  },
  Meth = {
    [1] = {
      ammonia   = 'bkr_prop_meth_ammonia',
      clipboard = 'bkr_prop_fakeid_clipboard_01a',
      pencil    = 'bkr_prop_fakeid_penclipboard',
      sacid     = 'bkr_prop_meth_sacid',
    },
    [2] = {
      box1      = 'bkr_prop_meth_bigbag_04a',
      box2      = 'bkr_prop_meth_bigbag_03a',
      clipboard = 'bkr_prop_fakeid_clipboard_01a',
      methbag1  = 'bkr_prop_meth_openbag_02',
      methbag2  = 'bkr_prop_meth_openbag_02',
      methbag3  = 'bkr_prop_meth_openbag_02',
      methbag4  = 'bkr_prop_meth_openbag_02',
      methbag5  = 'bkr_prop_meth_openbag_02',
      methbag6  = 'bkr_prop_meth_openbag_02',
      methbag7  = 'bkr_prop_meth_openbag_02',
      pen       = 'bkr_prop_fakeid_penclipboard',
      scale     = 'bkr_prop_coke_scale_01',
      scoop     = 'bkr_prop_meth_scoop_01a',     
    },
  },
  Weed = {
    [1] = {},
    [2] = {
      weeddry1  = 'bkr_prop_weed_dry_01a',
      weeddry2  = 'bkr_prop_weed_dry_01a',
      weedleaf1 = 'bkr_prop_weed_leaf_01a',
      weedleaf2 = 'bkr_prop_weed_leaf_01a',
      weedbag   = 'bkr_prop_weed_bag_01a',
      weedbud1a = 'bkr_prop_weed_bud_02b',
      weedbud2a = 'bkr_prop_weed_bud_02b',
      weedbud3a = 'bkr_prop_weed_bud_02b',
      weedbud4a = 'bkr_prop_weed_bud_02b',
      weedbud5a = 'bkr_prop_weed_bud_02b',
      weedbud6a = 'bkr_prop_weed_bud_02b',
      weedbud1b = 'bkr_prop_weed_bud_02a',
      weedbud2b = 'bkr_prop_weed_bud_02a',
      weedbud3b = 'bkr_prop_weed_bud_02a',
      bagpile   = 'bkr_prop_weed_bag_pile_01a',
      weedbuck  = 'bkr_prop_weed_bucket_open_01a',
      weedbuck  = 'bkr_prop_weed_bucket_open_01a',
    },
  },
  Money = {
    [1] = {
      binmoney  = 'bkr_prop_coke_tin_01',
      moneybin  = 'bkr_prop_tin_cash_01a',
      money1    = 'bkr_prop_money_unsorted_01',
      money2    = 'bkr_prop_money_unsorted_01',
      wrap1     = 'bkr_prop_money_wrapped_01',
      wrap2     = 'bkr_prop_money_wrapped_01',
    },
    [2] = {
      cutter    = 'bkr_prop_fakeid_papercutter',
      singlep1  = 'bkr_prop_cutter_moneypage',
      singlep2  = 'bkr_prop_cutter_moneypage',
      singlep3  = 'bkr_prop_cutter_moneypage',
      table     = 'bkr_prop_fakeid_table',
      stack     = 'bkr_prop_cutter_moneystack_01a',
      strip1    = 'bkr_prop_cutter_moneystrip',
      strip2    = 'bkr_prop_cutter_moneystrip',
      strip3    = 'bkr_prop_cutter_moneystrip',
      strip4    = 'bkr_prop_cutter_moneystrip',
      strip5    = 'bkr_prop_cutter_moneystrip',
      sinstack  = 'bkr_prop_cutter_singlestack_01a',
    },
    [3] = {
      bucket    = 'bkr_prop_money_pokerbucket',
      money1    = 'bkr_prop_money_unsorted_01',
      money2    = 'bkr_prop_money_unsorted_01',
    }
  },
}

-- Ignore me. Don't touch.
GangLookup = {}
for k, v in pairs(Config.GangJobs) do
    GangLookup[v] = true
end
PoliceLookup = {}; for k,v in pairs(Config.PoliceJobs) do PoliceLookup[v] = true; end; 

-- Get ESX. No support for other frameworks.
FrameworkStart = function()
  while not ESX do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end)
    Wait(0)
  end
end

-- Start 'er up.
Citizen.CreateThread(FrameworkStart)