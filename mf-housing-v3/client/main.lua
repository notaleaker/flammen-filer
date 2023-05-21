Housing = {}

--
-- INIT/SETUP
--
Housing.Init = function()
  if Protected.Continue then
    local start = GetGameTimer()

    DoScreenFadeIn(0)

    Housing.InitNui()

    Utils.InitESX(function()
      Housing.Ready = true

      local now = GetGameTimer()
      local diff = now - start

      if diff > 0 then
        Wait(math.min(100,2000 - diff))
      end

      Utils.TriggerServerEvent("PlayerConnected")
    end)
  end
end

Housing.InitNui = function()
  while not Housing.NuiReady do
    SendNUIMessage({
      type = "Config",
      data = {
        minMortgageRepayments = Config.MinMortgageRepayments,
        maxRealtorCommission = Config.MaxRealtorCommission,
        maxResalePercent = Config.MaxResalePercent,
        resourceName = Protected.ResourceName
      }
    })
    Wait(1000)
  end
end

--
-- UPDATE/THREAD
--
Housing.Update = function()
  local lastWeatherCheck = 0

  while true do
    local waitTime = 1000
    
    if Housing.InsideInterior then
      Housing.HandleWeather()
    end

    Wait(waitTime)
  end
end

--
-- INTERACT CALLBACKS
--
Housing.OnInteract = function(name,optionName,vars)
  if vars.houseId then
    local houseData = Housing.Houses[vars.houseId]
    if houseData then
      Housing.InteractingHouse = houseData
      if optionName == "enter_house" then
        Housing.EnterInterior(houseData,true)
      elseif optionName == "knock_on_door" then
        Housing.KnockOnDoor(houseData)
      elseif optionName == "houseid" then
        SendNUIMessage({
          type = "Copy",
          text = houseData.houseId
        })
      elseif optionName == "leave_house" then
        Housing.ExitInterior(houseData,true)
      elseif optionName == "lock_door" or optionName == "unlock_door" then
        Utils.TriggerServerEvent("ToggleDoorLock",houseData.houseId,not houseData.locked)
      elseif optionName == "add_garage" then
        Housing.AddGarage(houseData)
      elseif optionName == "remove_garage" then
        Utils.TriggerServerEvent("RemoveGarage",houseData.houseId,name)
      elseif optionName == "set_wardrobe" then
        Housing.SetWardrobe()
      elseif optionName == "set_inventory" then
        Housing.SetInventory()
      elseif optionName == "sell_house" then
        Housing.SellHouse(houseData)
      elseif optionName == "use_inventory" then
        Housing.OpenInventory(houseData,vars.invId)
      elseif optionName == "use_wardrobe" then
        Housing.OpenWardrobe()
      elseif optionName == "store_vehicle" then
        Housing.StoreVehicle(houseData)
      elseif optionName == "open_garage" then
        Housing.OpenGarage(houseData,vars.location)
      elseif optionName == "pay_mortgage" then
        Housing.PayMortgage(houseData)
      --elseif optionName == "view_contract" then
      --elseif optionName == "configure_contract" then
      end
    end
  else
    if optionName == "open_locksmith" then
      Housing.OpenLocksmith()
    elseif optionName == "use_inventory" then
      Housing.OpenInventory(false,vars.invId)
    elseif optionName == "use_wardrobe" then
      Housing.OpenWardrobe()
    end
  end
end

--
-- SETUP HOUSE & LOCKSMITH
--
Housing.SetupLocksmith = function()
  local blipData = Utils.TableCopy(Config.BlipData.locksmith)
  blipData.location = Config.LocksmithLocation
  Utils.CreateBlip(blipData)
  Housing.CreateTargetPoint("housing_locksmith","locksmith","locksmith",Config.LocksmithLocation,{})
end

Housing.RefreshHouse = function(houseData)
  for k,v in ipairs(houseData.locations) do
    if v.typeof == "entry" then
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:entryLocked:%i",houseData.houseId,k))
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:entryUnlocked:%i",houseData.houseId,k))

      if v.blip then
        Utils.RemoveBlip(v.blip)
      end
    elseif v.typeof == "exit" then
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:exitLocked:%i",houseData.houseId,k))
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:exitUnlocked:%i",houseData.houseId,k))
    elseif v.typeof == "backDoor" then
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:backDoorLocked:%i",houseData.houseId,k))
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:backDoorUnlocked:%i",houseData.houseId,k))
    else
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:%s:%i",houseData.houseId,v.typeof,k))
    end
  end  

  if houseData.polyzone then
    exports["fivem-target"]:RemoveTargetPoint(Housing.GetHouseAddressLabel(houseData))
    houseData.polyzone:destroy()
  end
end

Housing.SetupHouse = function(houseData)
  Housing.SetupBlip(houseData)
  Housing.SetupLocationTargets(houseData)

  if houseData.polyZone.usePolyZone then
    Housing.SetupPolyZone(houseData)
  end
end

Housing.HasKeys = function(houseData)
  for _,v in ipairs(houseData.keys) do
    if v.identifier == Housing.PlayerIdentifier then
      return true
    end
  end
  
  return false
end

Housing.CanRaid = function()
  local job = ESX.GetPlayerData().job
  
  if Config.PoliceJobs[job.name] and Config.PoliceJobs[job.name] <= job.grade then
    return true
  end

  return false
end

Housing.SetupPolyZone = function(houseData)
  local targetOption = ((houseData.ownerInfo.identifier == Housing.PlayerIdentifier and "owner") or (Housing.HasKeys(houseData) and "keys") or (Housing.CanRaid() and "keys") or "guest")
  local targetIndex = (houseData.shell and houseData.shell.useShell and "polyZoneWithShell" or "polyZoneWithoutShell")
  if houseData.salesInfo.isFinanced then
    targetIndex = string.format("%s%s",targetIndex,"Financed")
  end

  local polyZone = Housing.CreateTargetPoly(
    houseData.polyZone.points,
    {
      name=Housing.GetHouseAddressLabel(houseData),
      minZ=houseData.polyZone.minZ,
      maxZ=houseData.polyZone.maxZ,
      debugGrid=Config.Debug or false,
      gridDivisions=25
    },
    targetOption,
    targetIndex,
    {
      houseId = houseData.houseId
    },
    function(polyZone,vars)
      Housing.EnterPolyZone(houseData)
    end,
    function(polyZone,vars)
      Housing.LeavePolyZone(houseData)
    end
  )

  houseData.polyzone = polyZone  
end

Housing.SetupLocationTargets = function(houseData)
  for k,v in ipairs(houseData.locations) do
    local _k
    if v.typeof == "entry" or v.typeof == "backDoor" or v.typeof == "exit" or v.typeof == "backDoorExit" then
      if houseData.locked then
        _k = string.format("%sLocked",v.typeof)
      else
        _k = string.format("%sUnlocked",v.typeof)
      end
    else
      _k = v.typeof
    end

    local name = string.format("%s:%s:%i",houseData.houseId,_k,k)
    if houseData.ownerInfo.identifier == Housing.PlayerIdentifier then
      Housing.CreateTargetPoint(name,"owner",_k,v.position,{houseId = houseData.houseId,location = v})
    elseif Housing.HasKeys(houseData) or Housing.CanRaid() then
      Housing.CreateTargetPoint(name,"keys",_k,v.position,{houseId = houseData.houseId,location = v})
    else
      Housing.CreateTargetPoint(name,"guest",_k,v.position,{houseId = houseData.houseId,location = v})
    end
  end
end

Housing.SetupBlip = function(houseData)
  for k,v in ipairs(houseData.locations) do
    if v.typeof == "entry" then
      local blipData

      if houseData.ownerInfo.identifier == Housing.PlayerIdentifier or Housing.HasKeys(houseData) then
        if Config.ShowBlips.owned then
          blipData = Utils.TableCopy(Config.BlipData.owned)
        end
      else
        if Config.ShowBlips.others then
          blipData = Utils.TableCopy(Config.BlipData.others)
        end
      end

      if blipData then
        blipData.text = Housing.GetBlipText(houseData)
        blipData.location = v.position
        v.blip = Utils.CreateBlip(blipData)
      end
    end
  end
end

--
-- FIVEM-TARGET SETUP
--
Housing.CreateTargetPoint = function(name,targetOption,targetIndex,position,vars)
  if Config.TargetOptions[targetOption] and Config.TargetOptions[targetOption][targetIndex] then
    exports["fivem-target"]:AddTargetPoint({
      name = name,
      label = Config.TargetOptions[targetOption][targetIndex].label,
      icon = Config.TargetOptions[targetOption][targetIndex].icon,
      point = position,
      interactDist = 2.5,
      onInteract = Housing.OnInteract,
      options = Config.TargetOptions[targetOption][targetIndex].options,
      vars = vars
    })
  end
end

Housing.CreateTargetPoly = function(points,opts,targetOption,targetIndex,vars,onEnter,onLeave)
  if Config.TargetOptions[targetOption] and Config.TargetOptions[targetOption][targetIndex] then
    local polyZone = PolyZone:Create(points,opts)
    local setInside

    if #Config.TargetOptions[targetOption][targetIndex].options > 0 then
      setInside = exports["fivem-target"]:AddPolyZone({
        name = opts.name,
        label = Config.TargetOptions[targetOption][targetIndex].label,
        icon = Config.TargetOptions[targetOption][targetIndex].icon,
        inside = false,
        onInteract = Housing.OnInteract,
        options = Config.TargetOptions[targetOption][targetIndex].options,
        vars = vars
      })
    end

    polyZone:onPointInOut(PolyZone.getPlayerPosition,function(inside)
      if setInside then
        setInside(inside)
      end

      if inside then
        onEnter(polyZone,vars)
      else
        onLeave(polyZone,vars)
      end
    end)

    return polyZone
  end
end

Housing.CreateTargetModel = function(name,targetOption,targetIndex,model,vars)
  if Config.TargetOptions[targetOption] and Config.TargetOptions[targetOption][targetIndex] then
    exports["fivem-target"]:AddTargetModel({
      name = name,
      label = Config.TargetOptions[targetOption][targetIndex].label,
      icon = Config.TargetOptions[targetOption][targetIndex].icon,
      model = model,
      interactDist = 2.5,
      onInteract = Housing.OnInteract,
      options = Config.TargetOptions[targetOption][targetIndex].options,
      vars = vars
    })
  end
end

Housing.CreateTargetEntity = function(name,targetOption,targetIndex,ent,vars)
  if Config.TargetOptions[targetOption] and Config.TargetOptions[targetOption][targetIndex] then
    exports["fivem-target"]:AddTargetLocalEntity({
      name = name,
      label = Config.TargetOptions[targetOption][targetIndex].label,
      icon = Config.TargetOptions[targetOption][targetIndex].icon,
      entId = ent,
      interactDist = 2.5,
      onInteract = Housing.OnInteract,
      options = Config.TargetOptions[targetOption][targetIndex].options,
      vars = vars
    })
  end
end

--
-- HELPER FUNCTIONS
--
Housing.GetHouseAddressLabel = function(houseData)
  return string.format("%i %s, %s %i",houseData.houseInfo.streetNumber,houseData.houseInfo.streetName,houseData.houseInfo.suburb,houseData.houseInfo.postCode) 
end

Housing.GetBlipText = function(houseData)
  if Config.ShowHouseDataOnBlipText then
    return Housing.GetHouseAddressLabel(houseData)
  end

  if houseData.ownerInfo.identifier == Housing.PlayerIdentifier or Housing.HasKeys(houseData) or Housing.CanRaid() then
    return Config.BlipData.owned.text
  end

  return Config.BlipData.others.text
end

Housing.GetClosestHouse = function(pos)
  if Housing.InsideProperty then
    return Housing.InsideProperty
  elseif Housing.InsideInterior then
    return Housing.InsideInterior
  else
    local closest,closestDist
    for k,v in pairs(Housing.Houses) do
      for i,loc in ipairs(Housing.locations) do
        local dist = #(loc.position - pos)
        if not closestDist or dist < closestDist then
          closestDist = dist
          closest = k
        end
      end
    end
    return closest
  end
end

RegisterCommand("zoneScum", function(source, args)
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  local zone = GetZoneAtCoords(coords.x,coords.y,coords.z)
  local zonescum = GetZoneScumminess(zone)
  ESX.ShowNotification("Scumminess: "..zonescum)
end)

Housing.GetHouseInfo = function(pos,houseNumber)  
  local nameHash = GetStreetNameAtCoord(pos.x,pos.y,pos.z)
  local zone = GetZoneAtCoords(pos.x,pos.y,pos.z)
  local zoneScumminess = GetZoneScumminess(zone)

  return {
    streetNumber = (houseNumber or -1),
    streetName = GetStreetNameFromHashKey(nameHash),
    postCode = zone,
    suburb = GetLabelText(GetNameOfZone(pos.x,pos.y,pos.z)),
    scumminess = zoneScumminess,
    modifier = Config.ScumminessPriceModifier[zoneScumminess]
  }
end

Housing.ShowMenuHelpText = function()
  Utils.Thread(function()
    local startTime = GetGameTimer()
    while GetGameTimer() - startTime < 5000 and (Housing.InsideInterior or Housing.InsideProperty) do
      Utils.ShowHelpNotification(Config.InteractControls.houseMenu.label)
      Wait(0)
    end
  end)
end

Housing.ToggleWeatherSync = function(enabled)
  TriggerEvent("vSync:toggle", false)
end

Housing.HandleWeather = function()
  NetworkOverrideClockTime(12, 1, 1)
  SetRainLevel(0.0)
end

--
-- LOADER HANDLERS
--



GoToDoor = function(p)
  local dist = 999
  local tick = 0
  while dist > 0.5 and tick < 10000 do
    local pPos = GetEntityCoords(plyPed)
    dist = Vdist(pPos.x,pPos.y,pPos.z, p.x,p.y,p.z)
    tick = tick + 1
    Citizen.Wait(100)  
  end
  ClearPedTasksImmediately(plyPed)
end

FaceCoordinate = function(pos)
  local plyPed = GetPlayerPed(-1)
  TaskTurnPedToFaceCoord(plyPed, pos.x,pos.y,pos.z, -1)
  Wait(1500)
  ClearPedTasks(plyPed)
end

Housing.GetHouseEntry = function(house)
  for k,v in ipairs(house.locations) do
    if v.typeof == "entry" then
      return v
    end
  end
end

Housing.KnockOnDoor = function(houseData)
  local plyPed = GetPlayerPed(-1)
  local entry = Housing.GetHouseEntry(houseData)

  TaskGoStraightToCoord(plyPed,entry.position.x,entry.position.y,entry.position.z+1.0, 10.0, 10, entry.heading, 0.5)
  Wait(100)

  while true do
    if #(GetEntityCoords(plyPed) - entry.position) <= 0.65
    or GetEntityVelocity(plyPed) == vector3(0,0,0)
    then
      break
    end

    Wait(100)
  end

  ClearPedTasksImmediately(plyPed)  
  TaskTurnPedToFaceCoord(plyPed, entry.position.x,entry.position.y,entry.position.z, -1)
  Wait(1500)

  ClearPedTasks(plyPed)

  local ad,anim = "timetable@jimmy@doorknock@","knockdoor_idle"

  while not HasAnimDictLoaded(ad) do 
    RequestAnimDict(ad)
    Wait(0)
  end

  TaskPlayAnim(plyPed,ad,anim,8.0,8.0,-1,4,0,0,0,0)     
  Wait(100)

  while IsEntityPlayingAnim(plyPed,ad,anim,3) do 
    Wait(0)
  end 

  RemoveAnimDict(ad)

  Utils.TriggerServerEvent("KnockOnDoor",houseData.houseId)
end

Housing.EnterPolyZone = function(houseData)
  for k,v in ipairs(houseData.furniture.outside) do
    local hash = GetHashKey(v.model)
    Utils.LoadModel(hash)

    v.object = CreateObject(hash, v.position.x, v.position.y, v.position.z, false, false)
    SetEntityRotation(v.object,v.rotation.x,v.rotation.y,v.rotation.z,2)
    SetEntityCoords(v.object,v.position.x,v.position.y,v.position.z)
    FreezeEntityPosition(v.object,true)

--[[    if Config.SaleSigns[v.model] and houseData.salesInfo.saleBySign then
      if Housing.PlayerIdentifier == houseData.ownerInfo.identifier then
        Housing.CreateTargetEntity("forsalesign_"..v.object,"salesign","owner",v.object,{houseId = houseData.houseId})
      else
        Housing.CreateTargetEntity("forsalesign_"..v.object,"salesign","default",v.object,{houseId = houseData.houseId})
      end
    end--]]

    local pos = v.position

    if v.isInventory then
      if houseData.ownerInfo.identifier == Housing.PlayerIdentifier 
      or Housing.HasKeys(houseData)
      or Housing.CanRaid()
      then
        local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
        Housing.CreateTargetPoint(newInvId,"owner","inventory",pos,{invId = newInvId})
      end
    elseif v.isWardrobe then
      local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
      Housing.CreateTargetPoint(newWardId,"owner","wardrobe",pos,{})
    end

    SetModelAsNoLongerNeeded(hash)
  end  

  Housing.InsideProperty = houseData  

  TriggerEvent("mf-housing-v3:enterPolyzone",houseData)
  Utils.TriggerServerEvent("EnterPolyzone",houseData.houseId)
end

Housing.LeavePolyZone = function(houseData)
  if not Housing.InsideProperty or Housing.InsideProperty.houseId ~= houseData.houseId then
    return
  end

  for k,v in ipairs(houseData.furniture.outside) do
    SetEntityAsMissionEntity(v.object,true,true)
    DeleteObject(v.object)
    v.object = nil

    local pos = v.position

    if v.isInventory then
      if houseData.ownerInfo.identifier == Housing.PlayerIdentifier 
      or Housing.HasKeys(houseData)
      or Housing.CanRaid()
      then
        local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
        exports["fivem-target"]:RemoveTargetPoint(newInvId)
      end
    elseif v.isWardrobe then
      local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
      exports["fivem-target"]:RemoveTargetPoint(newWardId)
    end
  end

  Housing.InsideProperty = nil

  TriggerEvent("mf-housing-v3:exitPolyzone",houseData)
end

Housing.EnterInterior = function(houseData,doSave)
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Wait(0) end

  Housing.LoadInterior(houseData)
  Housing.HandleWeather()

  local ped = PlayerPedId()
  FreezeEntityPosition(ped,true)
  SetEntityVelocity(ped,0.0,0.0,0.0)

  local exit
  for k,v in ipairs(houseData.locations) do
    if v.typeof == "exit" then
      exit = v
    end
  end

  SetEntityCoordsNoOffset(ped,exit.position)  
  SetEntityHeading(ped,exit.heading)
  FreezeEntityPosition(ped,false)

  Housing.InsideInterior = houseData  

  local targetOption = houseData.ownerInfo.identifier == Housing.PlayerIdentifier and "owner" or (Housing.HasKeys(houseData) or Housing.CanRaid()) and "keys" or "guest"
  local targetIndex = "shell"
  if houseData.salesInfo.isFinanced then
    targetIndex = "shellFinanced"
  end

  local min,max = GetModelDimensions(GetEntityModel(houseData.shellobject))
  local points = Utils.Get2DEntityBoundingBox(houseData.shellobject)
  local realPos = GetEntityCoords(houseData.shellobject)

  local poly = Housing.CreateTargetPoly(
    points,
    {
      name=string.format("%s:%s",houseData.houseId,"shell"),
      minZ=houseData.shell.position.z + (min.z),
      maxZ=houseData.shell.position.z + (max.z*2),
      debugGrid=Config.Debug or false,
      gridDivisions=25
    },
    targetOption,
    targetIndex,
    {
      houseId = houseData.houseId
    },
    function(polyZone,vars)
    end,
    function(polyZone,vars)
      polyZone:destroy()
      exports["fivem-target"]:RemoveTargetPoint(string.format("%s:%s",houseData.houseId,"shell"))
    end
  )

  local pedPool = GetGamePool("CPed")
  for i=1,#pedPool do
    if  pedPool[i] > 0 
    and DoesEntityExist(pedPool[i]) 
    and not IsPedAPlayer(pedPool[i]) 
    and poly:isPointInside(GetEntityCoords(pedPool[i]))
    then
      DeleteEntity(pedPool[i])
    end
  end

  Housing.ToggleWeatherSync(false)

  Wait(100)
  DoScreenFadeIn(500)

  TriggerEvent("mf-housing-v3:enterInterior",houseData)

  if doSave then
    Utils.TriggerServerEvent("EnterInterior",houseData.houseId)
  end
end

Housing.LoadInterior = function(houseData)
  local hash = GetHashKey(houseData.shell.model)
  Utils.LoadModel(hash)

  houseData.shellobject = CreateObject(hash, houseData.shell.position.x, houseData.shell.position.y, houseData.shell.position.z, false, false)

  SetEntityRotation(houseData.shellobject,0.0,0.0,houseData.shell.heading,2)
  SetEntityCoords(houseData.shellobject,houseData.shell.position.x,houseData.shell.position.y,houseData.shell.position.z)
  FreezeEntityPosition(houseData.shellobject,true)
  SetEntityAsMissionEntity(houseData.shellobject,true,true)

  while not DoesEntityExist(houseData.shellobject) do
    Wait(0)
  end

  for k,v in ipairs(houseData.furniture.inside) do
    hash = GetHashKey(v.model)

    if IsModelValid(hash) then
      Utils.LoadModel(hash)

      v.object = CreateObject(hash, v.position.x, v.position.y, v.position.z, false, false)
      SetEntityRotation(v.object,v.rotation.x,v.rotation.y,v.rotation.z,2)
      SetEntityCoords(v.object,v.position.x,v.position.y,v.position.z)
      FreezeEntityPosition(v.object,true)
      SetEntityAsMissionEntity(v.object,true,true)
    end

    local pos = v.position

    if v.isInventory then
      if houseData.ownerInfo.identifier == Housing.PlayerIdentifier 
      or Housing.HasKeys(houseData)
      or Housing.CanRaid()
      then
        local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
        Housing.CreateTargetPoint(newInvId,"owner","inventory",pos,{invId = newInvId})
      end
    elseif v.catName == 'wardrobe' then
      local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
      Housing.CreateTargetPoint(newWardId,"owner","wardrobe",pos,{})
    end
  end
end

Housing.ExitInterior = function(houseData,doSave)
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Wait(0) end

  Housing.UnloadInterior(houseData)

  local ped = PlayerPedId()
  FreezeEntityPosition(ped,true)
  SetEntityVelocity(ped,0.0,0.0,0.0)
  Wait(100)

  local entry
  for k,v in ipairs(houseData.locations) do
    if v.typeof == "entry" then
      entry = v
    end
  end

  SetEntityCoordsNoOffset(ped,entry.position)  
  SetEntityHeading(ped,entry.heading)  
  FreezeEntityPosition(ped,false)

  Housing.InsideInterior = nil
  Housing.ToggleWeatherSync(true)
  
  Wait(100)  
  DoScreenFadeIn(500)
  TriggerEvent("mf-housing-v3:exitInterior",houseData)

  if doSave then
    Utils.TriggerServerEvent("ExitInterior",houseData.houseId)
  end
end

Housing.UnloadInterior = function(houseData)
  SetEntityAsMissionEntity(houseData.shellobject,true,true)
  DeleteObject(houseData.shellobject)

  for k,v in ipairs(houseData.furniture.inside) do
    SetEntityAsMissionEntity(v.object,true,true)
    DeleteObject(v.object)
    v.object = nil

    local pos = v.position

    if v.isInventory then
      if houseData.ownerInfo.identifier == Housing.PlayerIdentifier 
      or Housing.HasKeys(houseData)
      or Housing.CanRaid()
      then
        local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
        exports["fivem-target"]:RemoveTargetPoint(newInvId)
      end
    elseif v.isWardrobe then
      local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
      exports["fivem-target"]:RemoveTargetPoint(newWardId)
    end
  end

  houseData.shellobject = nil
end

--
-- LOCKSMITH
--
Housing.OpenLocksmith = function()
  local data = {}
  for k,v in pairs(Housing.Houses) do
    if v.ownerInfo.identifier == Housing.PlayerIdentifier then
      table.insert(data,v)
    end
  end

  SendNUIMessage({
    type = "ShowLocksmithPanel",
    data = data
  })

  SetNuiFocus(true,true)
end

--
--  HOUSE CREATION
--
Housing.SetShellLocation = function(spawnLocation)
  local shellName,v = (Config.ShellModels.playerhouse_hotel and "playerhouse_hotel" or next(Config.ShellModels))
  local hash = GetHashKey(shellName)

  Utils.LoadModel(hash)

  local min,max = GetModelDimensions(hash)
  local avg = vector3(math.abs(min.x) + math.abs(max.x), math.abs(min.y) + math.abs(max.y), math.abs(min.z) + math.abs(max.z))/2
  local shellPosition = spawnLocation + (Config.ShellSpawnOffset or vec3(0,0,0))
  local shellRotation = vector3(0.0,0.0,0.0)
  local camOffset = vector3(max.x*2,max.y*2,max.z*1.5)
  local camOffsetDist = #camOffset

  local shell = CreateObject(hash,shellPosition.x,shellPosition.y,shellPosition.z,false,false)

  FreezeEntityPosition(shell,true)
  SetEntityCollision(shell,false,false)

  local camera = Utils.CreateCamera("DEFAULT_SCRIPTED_CAMERA",shellPosition + camOffset, vector3(0.0,0.0,0.0), true)
  local controls = Utils.GetControls("done","up","right","forward","rotate_z","change_shell","mod_z_shell")
  local sf = Utils.CreateInstructional(controls)

  Utils.ShowNotification("Set the shell position.")

  while true do
    if IsDisabledControlJustPressed(0,Config.ActionControls.done.codes[1]) then
      EnableAllControlActions(0)
      Utils.DestroyFlyCam(camera)
      DeleteObject(shell)
      return shellPosition,shellRotation.z,shellName
    end

    DisableAllControlActions(0)
    camPos,camRot = Utils.HandleFlyCam(camera)   
    local right,fwd,up,pos = GetCamMatrix(camera)    

    shellPosition = camPos + (fwd * camOffsetDist)
    SetEntityCoords(shell,shellPosition)

    local frameTime = GetFrameTime()
    if IsDisabledControlPressed(0,Config.ActionControls.rotate_z.codes[1]) then
      shellRotation = vector3(shellRotation.x,shellRotation.y,shellRotation.z + (Config.CameraOptions.rotateSpeed * frameTime))
      SetEntityRotation(shell,shellRotation.x,shellRotation.y,shellRotation.z,2)
    elseif IsDisabledControlPressed(0,Config.ActionControls.rotate_z.codes[2]) then
      shellRotation = vector3(shellRotation.x,shellRotation.y,shellRotation.z - (Config.CameraOptions.rotateSpeed * frameTime))
      SetEntityRotation(shell,shellRotation.x,shellRotation.y,shellRotation.z,2)
    end

    if IsDisabledControlPressed(0,Config.ActionControls.mod_z_shell.codes[1])
    or IsDisabledControlJustPressed(0,Config.ActionControls.mod_z_shell.codes[1])
    then
      SetCamCoord(camera,camPos + vector3(0,0,(Config.ShellZModifier or 1.0 * frameTime)))
    end

    if IsDisabledControlPressed(0,Config.ActionControls.mod_z_shell.codes[2]) 
    or IsDisabledControlJustPressed(0,Config.ActionControls.mod_z_shell.codes[2])
    then
      SetCamCoord(camera,camPos - vector3(0,0,(Config.ShellZModifier or 1.0 * frameTime)))
    end

    if IsDisabledControlJustPressed(0,Config.ActionControls.change_shell.codes[1]) then
      local k,v = next(Config.ShellModels,shellName)
      if k == nil then
        shellName = next(Config.ShellModels)
      else
        shellName = k
      end

      DeleteObject(shell)

      hash = GetHashKey(shellName)
      Utils.LoadModel(hash)

      min,max = GetModelDimensions(hash)
      camOffset = vector3(max.x*2,max.y*2,max.z*1.5)
      camOffsetDist = #camOffset

      shell = CreateObject(hash,shellPosition.x,shellPosition.y,shellPosition.z,false,false)
      FreezeEntityPosition(shell,true)
      SetEntityCollision(shell,false,false)

      SetCamCoord(camera,shellPosition + camOffset)
    end

    local rotStr = string.format('x:%.1f, y:%.1f, z:%.1f',shellRotation.x,shellRotation.y,shellRotation.z)
    local posStr = string.format('x:%.1f, y:%.1f, z:%.1f',shellPosition.x,shellPosition.y,shellPosition.z)

    Utils.ShowHelpNotification("Shell: " .. shellName .. "\nRot: (" .. rotStr .. ")\nPos: ("..posStr..")")
    Utils.DrawEntityBoundingBox(shell,0,255,0,50)
    Utils.DrawScaleform(sf)

    Wait(0)
  end
end

Housing.SetupPolyPoints = function(points)
  points = points or {}

  local plyPed = PlayerPedId()
  local fwd,right,up,plyPos = GetEntityMatrix(plyPed)
  local camPos = plyPos + (up*2)
  local camRot = vector3(-35.0,0.0,0.0)

  local polyZone
  local camera = Utils.CreateCamera("DEFAULT_SCRIPTED_CAMERA",camPos,camRot, true)

  local controls = Utils.GetControls("done","add_point","undo_point","up","right","forward","increase_z","decrease_z")
  local sf = Utils.CreateInstructional(controls)

  while true do
    Wait(0)

    if IsDisabledControlJustPressed(0,Config.ActionControls.done.codes[1]) then
      EnableAllControlActions(0)
      Utils.DestroyFlyCam(camera)
      polyZone:destroy()
      return points,polyZone.minZ,polyZone.maxZ
    end

    DisableAllControlActions(0)
    camPos,camRot = Utils.HandleFlyCam(camera)    

    local frameTime = GetFrameTime()
    local right,fwd,up,pos = GetCamMatrix(camera)    

    local rayHit = StartExpensiveSynchronousShapeTestLosProbe(pos.x,pos.y,pos.z, pos.x+(fwd.x*100.0),pos.y+(fwd.y*100.0),pos.z+(fwd.z*100.0), 1, PlayerPedId(), 4)
    local retval,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHit)  

    if polyZone then
      if IsDisabledControlPressed(0,Config.ActionControls.increase_z.codes[2]) then
        if IsDisabledControlPressed(0,Config.ActionControls.decrease_z.codes[1]) then
          polyZone.minZ = polyZone.minZ + (15.0 * frameTime)
        else
          polyZone.maxZ = polyZone.maxZ + (15.0 * frameTime)
        end
      elseif IsDisabledControlPressed(0,Config.ActionControls.increase_z.codes[1]) then
        if IsDisabledControlPressed(0,Config.ActionControls.decrease_z.codes[1]) then
          polyZone.minZ = polyZone.minZ - (15.0 * frameTime)
        else
          polyZone.maxZ = polyZone.maxZ - (15.0 * frameTime)
        end
      end
    end

    if IsDisabledControlJustPressed(0,Config.ActionControls.add_point.codes[1]) then
      local endPos = vector2(endCoords.x,endCoords.y)
      table.insert(points,endPos)
      if not polyZone then
        polyZone = PolyZone:Create(points,{
          name="setup_poly_points",
          minZ=endCoords.z-2.0,
          maxZ=endCoords.z+10.0,
          debugGrid=true,
          gridDivisions=25
        })
      else
        polyZone.points = points
        if polyZone.minZ > (endCoords.z-2.0) then
          polyZone.minZ = endCoords.z-2.0
        end
      end
    end

    if IsDisabledControlJustPressed(0,Config.ActionControls.undo_point.codes[1]) then
      if #points > 0 then
        table.remove(points,#points)
        polyZone.points = points
      end
    end

    DrawLine(endCoords.x,endCoords.y,endCoords.z, endCoords.x,endCoords.y,endCoords.z+10.0, 255,0,0,255)  
    Utils.DrawScaleform(sf)
  end
end

Housing.SetLocation = function(polyPoints,minZ,maxZ)
  local polyZone = PolyZone:Create(polyPoints,{
    name="setup_entry_poly",
    minZ=minZ,
    maxZ=maxZ,
    debugGrid=true,
    gridDivisions=25
  })

  local plyPed = PlayerPedId()
  local fwd,right,up,plyPos = GetEntityMatrix(plyPed)
  local plyHead = GetEntityHeading(plyPed)

  local camera = Utils.CreateCamera("DEFAULT_SCRIPTED_CAMERA",plyPos + (up*2),vector3(-35.0,0.0,plyHead), true)
  local controls = Utils.GetControls("set_position","up","right","forward","rotate_z_scroll")
  local sf = Utils.CreateInstructional(controls)

  local markerHeading = 0.0

  local isInside = false
  local endPos = plyPos

  polyZone:onPointInOut(function()
    return endPos
  end,function(inside)
    isInside = inside
  end,100)

  Utils.ShowNotification("Set the shell entry position.")

  while true do
    Wait(0)

    DisableAllControlActions(0)

    Utils.HandleFlyCam(camera)  

    local right,fwd,up,pos = GetCamMatrix(camera)  
    local rayHit = StartExpensiveSynchronousShapeTestLosProbe(pos.x,pos.y,pos.z, pos.x+(fwd.x*100.0),pos.y+(fwd.y*100.0),pos.z+(fwd.z*100.0), 1, PlayerPedId(), 4)
    local retval,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHit)  

    endPos = endCoords

    if #(pos - plyPos) > 50.0 then
      EnableAllControlActions(0)
      Utils.DestroyFlyCam(camera)
      polyZone:destroy()
      return 
    end  

    if IsDisabledControlJustPressed(0,Config.ActionControls.set_position.codes[1]) then
      if isInside then
        Utils.DestroyFlyCam(camera)
        polyZone:destroy()
        return endCoords,markerHeading
      else
        Utils.ShowNotification("Point must be inside PolyZone.")
      end
    end

    if IsDisabledControlPressed(0,Config.ActionControls.rotate_z_scroll.codes[1]) then
      markerHeading = markerHeading + (500.0 * GetFrameTime())
    elseif IsDisabledControlPressed(0,Config.ActionControls.rotate_z_scroll.codes[2]) then
      markerHeading = markerHeading - (500.0 * GetFrameTime())
    end  

    DrawMarker(1, endCoords.x,endCoords.y,endCoords.z, 0.0,0.0,0.0, 0.0,0.0,0.0, 1.0,1.0,1.0, (isInside and 0 or 255),(isInside and 255 or 0),0,100, false,true,2)
    DrawMarker(3, endCoords.x,endCoords.y,endCoords.z+1.0, 0.0,0.0,0.0, markerHeading,90.0,90.0, 0.5,0.5,0.5, (isInside and 0 or 255),(isInside and 255 or 0),0,100, false,false,2)
    Utils.DrawScaleform(sf)
  end
end

Housing.AddGarage = function(houseData)
  local plyPed = PlayerPedId()
  local fwd,right,up,plyPos = GetEntityMatrix(plyPed)
  local plyHead = GetEntityHeading(plyPed)

  local camPos = plyPos + (up*2)
  local camRot = vector3(-35.0,0.0,plyHead)
  local camera = Utils.CreateCamera("DEFAULT_SCRIPTED_CAMERA",camPos,camRot, true)

  local controls = Utils.GetControls("done","add_garage","up","right","forward","rotate_z_scroll")
  local sf = Utils.CreateInstructional(controls)

  local vehHead = 0.0
  local model = GetHashKey('dubsta')
  Utils.LoadModel(model)

  local createLocalVehicle = function(model,pos,head)
    local veh = CreateVehicle(model,pos.x,pos.y,pos.z,head,false,false)
    SetEntityAlpha(veh,105,true)
    SetEntityCompletelyDisableCollision(veh,false,false)
    return veh
  end

  local veh = createLocalVehicle(model,plyPos + fwd * 2.0,vehHead)
  local vehicles = {veh}

  for k,v in ipairs(houseData.locations) do
    if v.typeof == "garage" then
      local _veh = createLocalVehicle(model,v.position,v.heading)
      FreezeEntityPosition(_veh,true)
      table.insert(vehicles,_veh)
    end
  end

  local polyZone = PolyZone:Create(houseData.polyZone.points,{
    name="setup_garage",
    minZ=houseData.polyZone.minZ,
    maxZ=houseData.polyZone.maxZ,
    debugGrid=true,
    gridDivisions=25
  })

  while true do
    DisableAllControlActions(0)

    camPos,camRot = Utils.HandleFlyCam(camera)   
    if #(camPos - plyPos) > 50.0 then
      EnableAllControlActions(0)
      Utils.DestroyFlyCam(camera)
      polyZone:destroy()

      for k,v in ipairs(vehicles) do
        DeleteVehicle(v)
      end

      return 
    end

    local frameTime = GetFrameTime()
    local right,fwd,up,pos = GetCamMatrix(camera)    

    local rayHit = StartExpensiveSynchronousShapeTestLosProbe(pos.x,pos.y,pos.z, pos.x+(fwd.x*100.0),pos.y+(fwd.y*100.0),pos.z+(fwd.z*100.0), 1, PlayerPedId(), 4)
    local retval,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHit)  

    if IsDisabledControlJustPressed(0,Config.ActionControls.done.codes[1]) then
      Utils.DestroyFlyCam(camera)
      polyZone:destroy()

      for k,v in ipairs(vehicles) do
        DeleteVehicle(v)
      end

      return 
    elseif IsDisabledControlJustPressed(0,Config.ActionControls.add_garage.codes[1]) then
      local pos = GetEntityCoords(veh)
      if polyZone:isPointInside(pos) then
        local pos = GetEntityCoords(veh)
        FreezeEntityPosition(veh,true)

        veh = createLocalVehicle(model,endCoords,vehHead)
        table.insert(vehicles,veh)

        Utils.TriggerServerEvent("AddGarage",houseData.houseId,pos,vehHead)
      else
        Utils.ShowNotification("Point must be inside PolyZone.")
      end
    end

    if IsDisabledControlPressed(0,Config.ActionControls.rotate_z_scroll.codes[1]) then
      vehHead = vehHead + (500.0 * GetFrameTime())
    elseif IsDisabledControlPressed(0,Config.ActionControls.rotate_z_scroll.codes[2]) then
      vehHead = vehHead - (500.0 * GetFrameTime())
    end   

    SetEntityCoords(veh,endCoords)
    SetVehicleOnGroundProperly(veh)

    SetEntityHeading(veh,vehHead)

    Utils.DrawScaleform(sf)

    Wait(0)
  end
end

Housing.CreateDoors = function(houseData,cb,count)
  local elements = {
    [1] = {label = "New Door",value = "new"},
    [2] = {label = "Done",value="done"}
  }
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), "create_house_doors",{
      title    = 'Doors',
      align    = 'center',
      elements = elements,
    }, 
    function(data,menu)
      menu.close()
      if data.current.value == "done" then
        cb(count or 0)
      else
        Wait(500)
        TriggerEvent("Doors:CreateDoors",function(creation)
          if creation then
            count = (count or 0) + 1
            table.insert(houseData.doors,creation)
          end
          Housing.CreateDoors(houseData,cb,count)
        end)        
      end
    end
  )
end

Housing.SetInventory = function()
  local targetZone
  local polyPoints
  local lowerZ,upperZ

  if Housing.InsideInterior then
    targetZone = Housing.InsideInterior
    polyPoints = Utils.Get2DEntityBoundingBox(Housing.InsideInterior.shellobject)

    local min,max = GetModelDimensions(Housing.InsideInterior.shell.model)
    local upper = GetOffsetFromEntityInWorldCoords(Housing.InsideInterior.shellobject, 0.0, 0.0, max.z)
    local lower = GetOffsetFromEntityInWorldCoords(Housing.InsideInterior.shellobject, 0.0, 0.0, min.z)

    upperZ = upper.z
    lowerZ = lower.z
  else
    targetZone = Housing.InsideProperty
    polyPoints = Housing.InsideProperty.polyZone.points
    upperZ     = Housing.InsideProperty.polyZone.maxZ
    lowerZ     = Housing.InsideProperty.polyZone.minZ
  end

  local pos,head = Housing.SetLocation(polyPoints,lowerZ,upperZ)
  Utils.TriggerServerEvent("SetInventory",targetZone.houseId,pos,head)
end

Housing.SetWardrobe = function()
  local targetZone
  local polyPoints
  local lowerZ,upperZ

  if Housing.InsideInterior then
    targetZone = Housing.InsideInterior
    polyPoints = Utils.Get2DEntityBoundingBox(Housing.InsideInterior.shellobject)

    local min,max = GetModelDimensions(Housing.InsideInterior.shell.model)
    local upper = GetOffsetFromEntityInWorldCoords(Housing.InsideInterior.shellobject, 0.0, 0.0, max.z)
    local lower = GetOffsetFromEntityInWorldCoords(Housing.InsideInterior.shellobject, 0.0, 0.0, min.z)

    upperZ = upper.z
    lowerZ = lower.z
  else
    targetZone = Housing.InsideProperty
    polyPoints = Housing.InsideProperty.polyZone.points
    upperZ     = Housing.InsideProperty.polyZone.maxZ
    lowerZ     = Housing.InsideProperty.polyZone.minZ
  end

  local pos,head = Housing.SetLocation(polyPoints,lowerZ,upperZ)
  Utils.TriggerServerEvent("SetWardrobe",targetZone.houseId,pos,head)
end

--
-- INTERACTIONS
--
Housing.SellHouse = function(houseData,cb)
  if houseData.salesInfo.isFinanced then
    Utils.ShowNotification("You can't sell a financed house until you finish paying off your debt.")
  else
    SendNUIMessage({
      type = "ShowSalesPanel",
      data = houseData
    })

    SetNuiFocus(true,true)

    Housing.SellHouseCb = cb
  end
end

Housing.OpenInventory = function(houseData,invId)
  if invId then
    exports['mf-inventory']:openOtherInventory(invId)
  else
    exports["mf-inventory"]:openOtherInventory(string.format("mf_housing_v3:%s",houseData.houseId))
  end
end

Housing.OpenWardrobe = function()
    if true then
      local id = source
      TriggerEvent(
        "nh-context:sendMenu",
        {
            {
                id = 1,
                header = "Åben klædeskab",
                txt = "",
                params = {
                    event = "fivem-appearance:pickHouseNewOutfit",
                    args = {
                        number = 1,
                        id = 2
                    }
                }
            },
            {
                id = 2,
                header = "Gem dit outfit til klædeskabet",
                txt = "",
                params = {
                    event = "fivem-appearance:saveOutfit"
                }
            }
        }
    ) 
  end 
end

Housing.StoreVehicle = function(houseData)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped)
  if veh > 0 then
    if GetPedInVehicleSeat(veh,-1) ~= ped then
      Utils.ShowNotification("You must be in the drivers seat.")
      return
    end
  else
    local pos = GetEntityCoords(ped)    
    local vehicles = Utils.GetAllVehicles()
    local closest,dist
    for i=1,#vehicles,1 do
      local d = #(GetEntityCoords(vehicles[i]) - pos)
      if not dist or d < dist then
        closest = vehicles[i]
        dist = d
      end
    end
    veh = closest
  end

  if veh and veh > 0 then
    --local plate = Utils.GetVehiclePlate(veh)
    local props = ESX.Game.GetVehicleProperties(veh)
    Utils.TriggerServerEvent("TryStoreVehicle",props,houseData.houseId,veh)
  end
end

Housing.OpenGarage = function(houseData,location)
  Utils.TriggerServerEvent("OpenGarage",houseData.houseId,location)
end

Housing.PayMortgage = function(houseData)
  SendNUIMessage({
    type = "ShowMortgagePanel",
    data = houseData
  })

  SetNuiFocus(true,true)
end

--
-- MAIN THREAD
--
Utils.Thread(Housing.Init)

--
-- NUI CALLBACKS
--
Utils.NuiCallback("configured",function()
  Housing.NuiReady = true
end)

Utils.NuiCallback("cancelCreation",function(data)
  SetNuiFocus(false,false)
  Housing.CreatingHouse = nil
end)

Utils.NuiCallback("closeLocksmith",function(data)
  SetNuiFocus(false,false)
end)

Utils.NuiCallback("closeMortgage",function(data)
  SetNuiFocus(false,false)
end)

Utils.NuiCallback("payMortgage",function(data)
  SetNuiFocus(false,false)

  Utils.TriggerServerEvent("PayMortgage",Housing.InteractingHouse.houseId,data.payment)
end)

Utils.NuiCallback("closeSale",function(data)
  SetNuiFocus(false,false)
end)

Utils.NuiCallback("finishSale",function(data)
  SetNuiFocus(false,false)

  if Housing.SellHouseCb then
    Housing.SellHouseCb(Housing.InteractingHouse.houseId,data)
  else
    local targetPlayer = Utils.SelectPlayer()

    if targetPlayer then
      Utils.TriggerServerEvent("SellHouseToTarget",GetPlayerServerId(targetPlayer),Housing.InteractingHouse.houseId,data.price,data.commission,data.canFinance,data.minDeposit,data.minRepayments)
    end
  end
end)

Utils.NuiCallback("newKey",function(data)
  SetNuiFocus(false,false)

  local targetPlayer = Utils.SelectPlayer()
  local serverId = GetPlayerServerId(targetPlayer)
  
  Utils.ShowNotification("You gave a pair of keys to the target player.")
  Utils.TriggerServerEvent("GiveKey",data.houseId,serverId)
end)

Utils.NuiCallback("resetLocks",function(data)
  SetNuiFocus(false,false)

  Utils.TriggerServerEvent("ResetLocks",data.houseId)
  Utils.ShowNotification("You have reset the house locks for your house.")
end)

Utils.NuiCallback("declinePurchase",function(data)
  SetNuiFocus(false,false)

  Utils.TriggerServerEvent("SalesContractDeclined",Housing.SalesContract.targetId,Housing.SalesContract.houseId)
end)

Utils.NuiCallback("acceptPurchase",function(data)
  SetNuiFocus(false,false)

  Utils.TriggerServerEvent("SalesContractConfirmed",Housing.SalesContract.targetId,Housing.SalesContract.houseId)
end)

Utils.NuiCallback("acceptFinance",function(data)
  SetNuiFocus(false,false)

  Utils.TriggerServerEvent("SalesContractConfirmed",Housing.SalesContract.targetId,Housing.SalesContract.houseId,true,data.downpayment)
end)

Utils.NuiCallback("finishCreation",function(data)
  SetNuiFocus(false,false)

  local house = {
    houseInfo = Housing.GetHouseInfo(GetEntityCoords(PlayerPedId()),data.streetNumber),
    salesInfo = {},
    polyZone = Housing.CreatingHouse.polyZone,
    shell = Housing.CreatingHouse.shell,
    doors = Housing.CreatingHouse.doors or {},
    locations = Housing.CreatingHouse.locations
  }

  if house.polyZone then
    Utils.TriggerServerEvent("CreateHouse",house)
  else
    Utils.ShowNotification("You must set up the PolyZone before creating a house.")
  end
end)

Utils.NuiCallback("setupPolyZone",function(data)
  SetNuiFocus(false,false)

  Utils.ShowNotification("Set up the house yard/polyzone.")

  local polyPoints,minZ,maxZ = Housing.SetupPolyPoints()
  Housing.CreatingHouse.polyZone = {
    usePolyZone = true,
    points = polyPoints,
    minZ = minZ,
    maxZ = maxZ
  }

  if Housing.CreatingHouse.shell then
    Housing.CreatingHouse.price = (Config.PolyZonePrice * Housing.CreatingHouse.modifier) + (Config.ShellModels[Housing.CreatingHouse.shell.model] * Housing.CreatingHouse.modifier)
  else
    Housing.CreatingHouse.price = (Config.PolyZonePrice * Housing.CreatingHouse.modifier)
  end
  
  Housing.OpenCreationUI(Housing.CreatingHouse)
end)

Utils.NuiCallback("setupDoors",function(data)
  SetNuiFocus(false,false)

  if not Housing.CreatingHouse.polyZone then
    Utils.ShowNotification("You must set up a PolyZone before creating doors.")
    Housing.OpenCreationUI(Housing.CreatingHouse)
  else
    Housing.CreatingHouse.doors = {}
    Housing.CreateDoors(Housing.CreatingHouse,function()
      Housing.OpenCreationUI(Housing.CreatingHouse)
    end)
  end  
end)

Utils.NuiCallback("setupShell",function(data)
  SetNuiFocus(false,false)

  if not Housing.CreatingHouse.polyZone then
    Utils.ShowNotification("You must set up a PolyZone before creating a shell.")
  else
    local entryPos,entryHead = Housing.SetLocation(Housing.CreatingHouse.polyZone.points,Housing.CreatingHouse.polyZone.minZ,Housing.CreatingHouse.polyZone.maxZ)
    local shellPosition,shellHeading,shellModel = Housing.SetShellLocation(entryPos,shell)

    Housing.CreatingHouse.locations = {
      {
        typeof = "entry",
        position = entryPos,
        heading = entryHead
      }
    }

    Housing.CreatingHouse.shell = {
      useShell = true,
      position = shellPosition,
      heading = shellHeading,
      model = shellModel,
      furniture = "none"
    }

    Housing.CreatingHouse.price = (Config.PolyZonePrice * Housing.CreatingHouse.modifier) + (Config.ShellModels[shellModel].price * Housing.CreatingHouse.modifier)
  end

  Housing.OpenCreationUI(Housing.CreatingHouse)
end)

Utils.NuiCallback("setCommission",function(data)
  Housing.CreatingHouse.commission = data.commission
end)

Utils.NuiCallback("setStreetNumber",function(data)
  Housing.CreatingHouse.streetNumber = data.streetNumber
end)

Housing.OpenCreationUI = function(data)
  SendNUIMessage({
    type = "ShowCreationPanel",
    data = data
  })

  SetNuiFocus(true,true)
end

exports('CanAccessDoor',function(houseId)
  local house = Housing.Houses[houseId]

  if house and (house.ownerInfo.identifier == Housing.PlayerIdentifier or Housing.HasKeys(house) or Housing.CanRaid()) then
    return true
  end

  return false
end)

exports('GetHouseData',function(houseId,cb)
  if cb then
    return cb(Housing.Houses[houseId])
  end

  return Housing.Houses[houseId]
end)

exports('Copy',function(str)
  SendNUIMessage({
    type = "Copy",
    text = str
  })
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob",function(job)
  for k,v in pairs(Housing.Houses) do
    Housing.RefreshHouse(v)
    Housing.SetupHouse(v)
  end
end)