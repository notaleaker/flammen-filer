-- Edit all things in the Config table.
Config = {
  -- Set to false after setup.
  Debug = false,

  -- Supports: {1.2, 1.3}
  -- 1.3 = V1 Final
  EsxVersion = 1.3,

  -- Locksmith location, for creating new house keys and replacing house locks.
  LocksmithLocation = vector3(172.8291, -1800.9177, 29.2499),

  -- Inventory defaults.
  InventoryMaxWeight = 300.0,
  InventoryMaxSlots = 50,

  -- bump shell by this value on Z axis when placing
  ShellZModifier = 5.0,
  ShellSpawnOffset = vector3(0,0,-10.0),

  -- categorized inventory defaults
  CategorizedInventoryDefaults = {
    fridge_inventory = {
      labelName = "fridge",
      maxWeight = 50.0,
      maxSlots = 10
    }
  },

  -- The event name for your esx:getObject events.
  EsxEvents = {
    getClient = "esx:getSharedObject",
    getServer = "esx:getSharedObject"
  },

  -- Account names for xPlayer table
  AccountNames = {
    cash = "money",
    bank = "bank"
  },

  -- Show house blips?
  ShowBlips = {
    owned   = true,
    others  = false
  },

  -- Show house number and address as blip name?
  ShowHouseDataOnBlipText = true,

  -- Blip Settings
  BlipData = {
    owned = {
      sprite = 40,
      color = 0,
      scale = 1.0,
      display = 2,
      shortRange = false,
      highDetail = true,
      text = "Player House"
    },
    others = {
      sprite = 40,
      color = 68,
      scale = 1.0,
      display = 2,
      shortRange = false,
      highDetail = true,
      text = "Bolig"
    },
    locksmith = {
      sprite = 134,
      color = 0,
      scale = 1.0,
      display = 2,
      shortRange = false,
      highDetail = true,
      text = "Låsesmed"
    },
  },

  -- Shell Info
  ShellModels = {
    shell_warehouse1 = {
      offsets = {
        exit = vector3(8.920532, 0.02319336, 0.9492531)
      },
      label = "Medium Warehouse",
      price = 1
    },
    shell_warehouse2 = {
      offsets = {
        exit = vector3(-12.43237, -0.2268066, 2.059021)
      },
      label = "Large Warehouse",
      price = 1
    },
    shell_warehouse3 = {
      offsets = {
        exit = vector3(-2.486694, 1.531982, 0.9428577)
      },
      label = "Small Warehouse",
      price = 1
    },
    shell_apartment1 = {
      offsets = {
        exit = vector3(2.218384, -8.897339, -3.202154)
      },
      label = "Luxuryapartment 1",
      price = 1
    },
    shell_apartment2 = {
      offsets = {
        exit = vector3(2.151001, -8.952881, -3.202152)
      },
      label = "Luxuryapartment  2",
      price = 1
    },
    shell_apartment3 = {
      offsets = {
        exit = vector3(-11.52808, -4.538818, -2.009697)
      },
      label = "Luxuryapartment 3",
      price = 1
    },
    classichouse_shell = { 
      offsets = {
        exit = vector3(-4.991127, -1.533936, 3.384643)
      },
      label = "Classic 1",
      price = 100000
    },

    classichouse2_shell = { 
      offsets = {
        exit = vector3(-4.743669, 2.227539, 3.384644)
      },
      label = "Classic 2",
      price = 100000
    },

    classichouse3_shell = {
      offsets = {
        exit = vector3(-4.521332, -1.799561, 3.384649)
      },
      label = "Classic 3",
      price = 100000
    },
    playerhouse_hotel = {
      offsets = {
        exit = vector3(1.005783, 3.520264, -1.000021),
      },
      label = "Hotel Room",
      price = 5000
    },
    playerhouse_tier1 = {
      offsets = {
        exit = vector3(-3.6,15.4,-1.34)
      },
      label = "Apartment",
      price = 10000
    }
  },

  -- Price to add a polyZone to a house (*scumminessPriceModifier)
  PolyZonePrice = 5000,

  -- Price of house based on zone scumminess modifier (https://docs.fivem.net/natives/?_0x5F7B268D15BA0739)
  ScumminessPriceModifier = {
    [0] = 6.0,
    [1] = 5.0,
    [2] = 4.0,
    [3] = 3.0,
    [4] = 2.0,
    [5] = 1.0
  },

  -- Mortgage info
  MinMortgageRepayments = 500,
  MaxRealtorCommission = 10000000,
  MaxResalePercent = 10,
  MaxDaysToRepayMortgage = 60,--(1 / 24 / 60),
  
  -- Fly cam settings
  CameraOptions = {
    lookSpeedX = 500.0,
    lookSpeedY = 500.0,
    moveSpeed = 10.0,
    climbSpeed = 10.0,
    rotateSpeed = 50.0,
  },

  -- Realtor jobs and society names.
  RealtorJobs = {
    realestateagent = {
      minRank = 0,
      societyAccountName = "society_realestateagent"
    }
  },

  -- Police jobs, for raiding.
  -- job name = min rank for raiding.
  PoliceJobs = {
    police = 9,
  },

  --[[
  -- for sale signs, if these objects are placed by using furni in the yard of the house by the owner,
  -- the owner will then be able to assign a contract to the sign for anybody to purchase the house from.
  -- NOTE: Incomplete/unused.
  SaleSigns = {
    'prop_forsale_lrg_03'
  },
  --]]

  -- Change label and controls accordingly. Don't edit key/index.
  -- NOTE: For scaleforms.
  ActionControls = {
    forward = {
      label = "Fremad +/-",
      codes = {33,32}
    },
    right = {
      label = "Højre +/-",
      codes = {35,34}
    },
    up = {
      label = "Op +/-",
      codes = {52,51}
    },
    add_point = {
      label = "Tilføj punkt",
      codes = {24}
    },
    undo_point = {
      label = "Fortryd sidst",
      codes = {25}
    },
    set_position = {
      label = "Angiv placering",
      codes = {24}
    },
    add_garage = {
      label = "Tilføj en garage",
      codes = {24}
    },
    rotate_z = {
      label = "RotereZ +/-",
      codes = {20,73}
    },
    rotate_z_scroll = {
      label = "RotereZ +/-",
      codes = {17,16}
    },
    mod_z_shell = {
      label = "Z Axis +/-",
      codes = {180,181}
    },
    increase_z = {
      label = "Z Grænse +/-",
      codes = {180,181}
    },
    decrease_z = {
      label = "Z Grænse +/-",
      codes = {21,180,181}
    },
    change_shell = {
      label = "Næste Shell-model",
      codes = {217}
    },
    done = {
      label = "Færdig",
      codes = {194}
    },
    change_player = {
      label = "Spiller +/-",
      codes = {82,81}
    },
    select_player = {
      label = "Vælg afspiller",
      codes = {191}
    },
    cancel = {
      label = "Fortyd",
      codes = {194}
    },
    change_outfit = {
      label = "Outfit +/-",
      codes = {82,81}
    },
    delete_outfit = {
      label = "Slet Outfit",
      codes = {178}
    },
    select_vehicle = {
      label = "Bil +/-",
      codes = {82,81}
    },
    spawn_vehicle = {
      label = "Spawn bil",
      codes = {191}
    },
  },

  -- Options for fivem-target
  TargetOptions = {
    owner = {
      entryLocked = {
        icon = "fas fa-door-open",
        label = "dør",
        options = {
          {
            label = "Gå ind i huset",
            name  = "enter_house"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          },
          {
            label = "Unlock Door",
            name  = "unlock_door"
          },
        }
      },
      entryUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Gå ind i huset",
            name  = "enter_house"
          },
          {
            label = "Lås Døren",
            name  = "lock_door"
          },
        }
      },
      backDoorLocked = {
        icon = "fas fa-door-open",
        label = "Bagdørr",
        options = {
          {
            label = "Gå ind i huset",
            name  = "enter_backDoor"
          },
          {
            label = "Lås døren op",
            name  = "unlock_door"
          },
        }
      },
      backDoorUnlocked = {
        icon = "fas fa-door-open",
        label = "Bag Døren",
        options = {
          {
            label = "Gå ind",
            name  = "enter_backDoor"
          },
          {
            label = "Lock Door",
            name  = "lock_door"
          },
        }
      },
      exitLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          },
          {
            label = "Unlock Door",
            name  = "unlock_door"
          },
        }
      },
      exitUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          },
          {
            label = "Lock Door",
            name  = "lock_door"
          },
        }
      },
      backDoorExitLocked = {
        icon = "fas fa-door-open",
        label = "Back Door",
        options = {
          {
            label = "Leave",
            name  = "leave_backDoor"
          },
          {
            label = "Unlock Door",
            name  = "unlock_door"
          },
        }
      },
      backDoorExitUnlocked = {
        icon = "fas fa-door-open",
        label = "Bag dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_backDoor"
          },
          {
            label = "lock Door",
            name  = "lock_door"
          },
        }
      },
      polyZoneWithShellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
          {
            label = "Tilføj en garage",
            name  = "add_garage"
          },
          {
            label = "Betal realkreditlån",
            name  = "pay_mortgage"
          }
        }        
      },
      polyZoneWithShell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
          {
            label = "Tilføj en garage",
            name  = "add_garage"
          },
          {
            label = "Sælg hus",
            name  = "sell_house"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          }
        }        
      },
      polyZoneWithoutShellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
          {
            label = "Tilføj en garage",
            name  = "add_garage"
          },
          -- {
          --   label = "Placer klædeskab",
          --   name  = "set_wardrobe"
          -- },
          -- {
          --   label = "Placer Inventory",
          --   name  = "set_inventory"
          -- },
          {
            label = "Betal realkreditlån",
            name  = "pay_mortgage"
          }
        }        
      },
      polyZoneWithoutShell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
          {
            label = "Tilføj en garage",
            name  = "add_garage"
          },
          -- {
          --   label = "Placer klædeskab",
          --   name  = "set_wardrobe"
          -- },
          -- {
          --   label = "Placer Inventory",
          --   name  = "set_inventory"
          -- },
          {
            label = "Sælg hus",
            name  = "sell_house"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          },
        }        
      },
      shellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
          {
            label = "Placer klædeskab",
            name  = "set_wardrobe"
          },
          {
            label = "Placer Inventory",
            name  = "set_inventory"
          },
          {
            label = "Betal realkreditlån",
            name  = "pay_mortgage"
          }
        }  
      },
      shell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {
        {
         label = "Tilføj en gadarobe",
          name  = "set_wardrobe"
          },
          {
           label = "Tilføj et Lager",
            name  = "set_inventory"
         },
          {
            label = "Sælg hus",
            name  = "sell_house"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          },
        }  
      },
      wardrobe = {
        icon = "fas fa-home",
        label = "Gaderobe",
        options = {
          {
            label = "Use Wardrobe",
            name  = "use_wardrobe"
          }
        } 
      },
      inventory = {
        icon = "fas fa-home",
        label = "Lager",
        options = {
          {
            label = "Use Inventory",
            name  = "use_inventory"
          }
        } 
      },
      garage = {
        icon = "fas fa-warehouse",
        label = "Garage",
        options = {
          {
            label = "Åben garage",
            name = "open_garage"
          },
          {
            label = "Lager dit køretøj",
            name = "store_vehicle"
          },
          {
            label = "Fjern din garage",
            name = "remove_garage"
          },
        }
      },
    },
    keys = {
      entryLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Enter",
            name  = "enter_house"
          },
          {
            label = "Lås døren op",
            name  = "unlock_door"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          },
        }
      },
      entryUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Enter",
            name  = "enter_house"
          },
          {
            label = "Lås døren op",
            name  = "lock_door"
          },
        }
      },
      backDoorLocked = {
        icon = "fas fa-door-open",
        label = "Bag døren",
        options = {
          {
            label = "Enter",
            name  = "enter_backDoor"
          },
          {
            label = "Lås døren op",
            name  = "unlock_door"
          },
        }
      },
      backDoorUnlocked = {
        icon = "fas fa-door-open",
        label = "Bag dør",
        options = {
          {
            label = "Enter",
            name  = "enter_backDoor"
          },
          {
            label = "Lås døren",
            name  = "lock_door"
          },
        }
      },
      exitLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          },
          {
            label = "Lås døren op",
            name  = "unlock_door"
          },
        }
      },
      exitUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          },
          {
            label = "Lås døren",
            name  = "lock_door"
          },
        }
      },
      backDoorExitLocked = {
        icon = "fas fa-door-open",
        label = "Bag dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_backDoor"
          },
          {
            label = "Lås døren op",
            name  = "unlock_door"
          },
        }
      },
      backDoorExitUnlocked = {
        icon = "fas fa-door-open",
        label = "Bag dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_backDoor"
          },
          {
            label = "Lås døren",
            name  = "lock_door"
          },
        }
      },
      polyZoneWithShellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}        
      },
      polyZoneWithShell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}        
      },
      polyZoneWithoutShellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}        
      },
      polyZoneWithoutShell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}        
      },
      shellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}  
      },
      shell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}  
      },
      wardrobe = {
        icon = "fas fa-home",
        label = "Gaderobe",
        options = {
          {
            label = "Brug gaderobe",
            name  = "use_wardrobe"
          }
        } 
      },
      inventory = {
        icon = "fas fa-home",
        label = "Lager",
        options = {
          {
            label = "Brug dit lager",
            name  = "use_inventory"
          }
        } 
      },
      garage = {
        icon = "fas fa-warehouse",
        label = "Garage",
        options = {
          {
            label = "Åben garage",
            name = "open_garage"
          },
          {
            label = "Indsæt dit køretøj",
            name = "store_vehicle"
          }
        }
      },
    },
    guest = {
      entryLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Bank på døren!",
            name  = "knock_on_door"
          },
          {
            label = "Se hus id",
            name  = "houseid"
          }
        }
      },
      entryUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Gå ind",
            name  = "enter_house"
          }
        }
      },
      exitLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          }
        }
      },
      exitUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          }
        }
      },
      shellFinanced = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}  
      },
      shell = {
        icon = "fas fa-home",
        label = "Hus",
        options = {}  
      },
    },
    police = {
      entryLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Bank på døren!",
            name  = "knock_on_door"
          }
        }
      },
      entryUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Enter",
            name  = "enter_house"
          }
        }
      },
      exitLocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          }
        }
      },
      exitUnlocked = {
        icon = "fas fa-door-open",
        label = "Dør",
        options = {
          {
            label = "Forlad",
            name  = "leave_house"
          }
        }
      },
    },
    locksmith = {
      locksmith = {
        icon = "fas fa-key",
        label = "Låsesmed",
        options = {
          {
            label = "Åbn butik",
            name  = "open_locksmith"
          },
        }
      }
    },
    --[[    
    salesign = {
      owner = {
        icon = "fas fa-key",
        label = "Sign",
        options = {
          {
            label = "Configure Contract",
            name  = "configure_contract"
          },
        }
      },
      default = {
        icon = "fas fa-key",
        label = "Sign",
        options = {
          {
            label = "View Contract",
            name  = "view_contract"
          },
        }
      }
    }
    --]]
  },
}

-- Don't touch below this line.
Protected = {
  ResourceName = GetCurrentResourceName(),
  Continue = true,
  CompatibleEsxVersions = {
    1.2,
    1.3
  }
}

--[[
local __saleSigns = {}
for k,v in ipairs(Config.SaleSigns) do
  __saleSigns[v] = v
end

Config.SaleSigns = __saleSigns
__saleSigns = nil

exports('getConfig',function(k)
  if k then
    return Config[k]
  end

  return Config
end)
--]]

if type(Config.EsxVersion) ~= "number" then
  error("Config.EsxVersion doesn't exist or is not the correct type (requires number).",2)
  Protected.Continue = false
else
  for k,v in ipairs(Protected.CompatibleEsxVersions) do
    if v == Config.EsxVersion then
      return
    end
  end

  error("Config.EsxVersion doesn't match a required version.",2)
  Protected.Continue = false
end