Utils.RegisterNetEvent("PlayerConnected",function(houses,identifier,lastHouse)
  Housing.PlayerIdentifier = identifier
  Housing.Houses = houses

  for k,v in pairs(Housing.Houses) do
    Housing.SetupHouse(v)
  end
  
  Housing.SetupLocksmith()

  if lastHouse then
    Housing.EnterInterior(Housing.Houses[lastHouse])
  end

  Housing.Update()
end)

Utils.RegisterNetEvent("DeleteHouse",function(houseId)
  if Housing.Houses[houseId] then
    Housing.RefreshHouse(Housing.Houses[houseId])
  end

  Housing.Houses[houseId] = nil
end)

Utils.RegisterNetEvent("ReceivedSalesContract",function(targetId,house)
  Housing.SalesContract = {
    targetId = targetId,
    houseId  = house.houseId
  }

  SendNUIMessage({
    type = "ShowPurchasePanel",
    data = house
  })

  SetNuiFocus(true,true)
end)

Utils.RegisterNetEvent("SyncToClients",function(house)
  if Housing.Houses[house.houseId] then
    Housing.RefreshHouse(Housing.Houses[house.houseId])
  end

  Housing.Houses[house.houseId] = house
  Housing.SetupHouse(house)
end)

Utils.RegisterNetEvent("KnockedOnDoor",function(houseId,name)
  if Housing.InsideInterior and Housing.InsideInterior.houseId == houseId then
    Utils.ShowNotification("Someone is knocking at your door.")
  end
end)

Utils.RegisterNetEvent("SyncOptsToClients",function(houseId,key,value)
  if Housing.Houses[houseId] then
    Housing.RefreshHouse(Housing.Houses[houseId])
    Housing.Houses[houseId][key] = value
  end

  Housing.SetupHouse(Housing.Houses[houseId])
end)

Utils.RegisterNetEvent("OpenWardrobe",function(outfits)
  Housing.OpeningWardrobe = false
  if #outfits > 0 then
    local index = 1
    local controls = Utils.GetControls("done","change_outfit","delete_outfit")
    local sf = Utils.CreateInstructional(controls)
    while true do
      local outfitSwapped
      if IsControlJustPressed(0,Config.ActionControls.change_outfit.codes[1]) then
        index = index + 1
        if index > #outfits then
          index = 1
        end
        outfitSwapped = true
      elseif IsControlJustPressed(0,Config.ActionControls.change_outfit.codes[2]) then
        index = index - 1
        if index < 1 then
          index = #outfits
        end
        outfitSwapped = true
      end

      if IsControlJustPressed(0,Config.ActionControls.delete_outfit.codes[1]) then
        Utils.TriggerServerEvent("RemoveOutfit",index)
        table.remove(outfits,index)
        if #outfits > 0 then
          index = 1
          outfitSwapped = true
        else
          return
        end
      end

      if IsControlJustPressed(0,Config.ActionControls.done.codes[1]) then
        return
      end

      if outfitSwapped then
        local clothes = outfits[index].skin
        TriggerEvent('skinchanger:getSkin', function(skin)
          TriggerEvent('skinchanger:loadClothes', skin, clothes)
          TriggerEvent('esx_skin:setLastSkin', skin)

          TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
          end)
        end)
      end

      Utils.DrawScaleform(sf)
      Wait(0)
    end
  else
    Utils.ShowNotification("You don't have any outfits saved.")
  end
end)

Utils.RegisterNetEvent("TryStoreVehicle",function(canStore,entId)
  if canStore then
    TaskEveryoneLeaveVehicle(entId)
    TaskLeaveVehicle(PlayerPedId(),entId,16)
    Wait(0)
    SetEntityAsMissionEntity(entId,true,true)
    DeleteVehicle(entId)
  end
end)

Utils.RegisterNetEvent("OpenGarage",function(vehicles,houseId,location)
  if #vehicles > 0 then
    local index = 1
    local controls = Utils.GetControls("select_vehicle","spawn_vehicle","cancel")
    local sf = Utils.CreateInstructional(controls)

    local function createVehicle(props,pos,head,networked)
      local hash = type(props.model) == "number" and props.model or GetHashKey(model)

      RequestModel(hash)
      while not HasModelLoaded(hash) do Wait(0) end

      local veh = CreateVehicle(hash,pos.x,pos.y,pos.z,head,networked,networked)
      if not networked then
        SetVehicleUndriveable(veh,true)
        SetEntityCompletelyDisableCollision(veh,false,false)
        FreezeEntityPosition(veh,true)
      end

      SetEntityAsMissionEntity(veh,true,true)
      ESX.Game.SetVehicleProperties(veh,props)

      SetModelAsNoLongerNeeded(hash)

      return veh
    end

    local veh = createVehicle(vehicles[index],location.position,location.heading)

    while true do
      if IsControlJustPressed(0,Config.ActionControls.select_vehicle.codes[1]) then
        DeleteVehicle(veh)
        index = index + 1
        if index > #vehicles then
          index = 1
        end
        veh = createVehicle(vehicles[index],location.position,location.heading)
      elseif IsControlJustPressed(0,Config.ActionControls.select_vehicle.codes[2]) then
        DeleteVehicle(veh)
        index = index - 1
        if index < 1 then
          index = #vehicles
        end
        veh = createVehicle(vehicles[index],location.position,location.heading)
      end

      if IsControlJustPressed(0,Config.ActionControls.spawn_vehicle.codes[1]) then
        DeleteVehicle(veh)
        veh = createVehicle(vehicles[index],location.position,location.heading,true)
        TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1)
        Utils.TriggerServerEvent("VehicleSpawned",vehicles[index].plate)
        return
      end

      if IsControlJustPressed(0,Config.ActionControls.cancel.codes[1]) then
        DeleteVehicle(veh)
        return
      end

      Utils.DrawScaleform(sf)
      Wait(0)
    end
  else
    Utils.ShowNotification("You don't have any vehicles stored here.")
  end
end)

Utils.RegisterNetEvent("FurnitureAdded",function(houseId,furniTarget,furni,addForSale)
  if not Housing.Houses then
    return
  end

  local house = Housing.Houses[houseId]

  if not house then
    return
  end

  table.insert(house.furniture[furniTarget],furni)
  local v = house.furniture[furniTarget][#house.furniture[furniTarget]]
  local pos = v.position

  if v.isInventory then
    if house.ownerInfo.identifier == Housing.PlayerIdentifier 
    or Housing.HasKeys(house)
    or Housing.CanRaid()
    then
      local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
      Housing.CreateTargetPoint(newInvId,"owner","inventory",pos,{invId = newInvId})
    end
  elseif v.isWardrobe then
    local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)
    Housing.CreateTargetPoint(newWardId,"owner","wardrobe",pos,{})
  end

  if Housing.InsideInterior and furniTarget == "inside" or Housing.InsideProperty and furniTarget == "outside" then
    hash = GetHashKey(v.model)
    Utils.LoadModel(hash)

    v.object = CreateObject(hash, v.position.x, v.position.y, v.position.z, false, false)
    SetEntityRotation(v.object,v.rotation.x,v.rotation.y,v.rotation.z,2)
    SetEntityCoords(v.object,v.position.x,v.position.y,v.position.z)
    FreezeEntityPosition(v.object,true)
    SetEntityAsMissionEntity(v.object,true,true)

    -- if addForSale then
    --   if Housing.PlayerIdentifier == house.ownerInfo.identifier then
    --     Housing.CreateTargetEntity("forsalesign_"..v.object,"salesign","owner",v.object,{houseId = house.houseId})
    --   else
    --     Housing.CreateTargetEntity("forsalesign_"..v.object,"salesign","default",v.object,{houseId = house.houseId})
    --   end
    -- end
  end

  TriggerEvent("mf-housing-v3:syncFurniture",house)
end)

Utils.RegisterNetEvent("FurnitureRemoved",function(houseId,furniTarget,furniIndex)
  if not Housing.Houses then
    return
  end

  local house = Housing.Houses[houseId]

  if not house then
    return
  end

  local target = house.furniture[furniTarget][furniIndex]

  if target then
    if target.isInventory then
      local prevInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',target.position.x,target.position.y,target.position.z)
      exports["fivem-target"]:RemoveTargetPoint(prevInvId)      
    elseif target.isWardrobe then
      local prevWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',target.position.x,target.position.y,target.position.z)
      exports["fivem-target"]:RemoveTargetPoint(prevWardId)
    end

    if target.object then
      DeleteObject(target.object)
    end

    table.remove(house.furniture[furniTarget],furniIndex)

    TriggerEvent("mf-housing-v3:syncFurniture",house)
  end
end)

Utils.RegisterNetEvent("FurnitureEdited",function(houseId,furniTarget,furniIndex,pos,rot)
  if not Housing.Houses then
    return
  end

  local house = Housing.Houses[houseId]

  if not house then
    return
  end

  local target = house.furniture[furniTarget][furniIndex]

  if target then
    if target.isInventory then
      local prevInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',target.position.x,target.position.y,target.position.z)
      local newInvId = 'hv3:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)

      exports["fivem-target"]:RemoveTargetPoint(prevInvId)      

      if house.ownerInfo.identifier == Housing.PlayerIdentifier 
      or Housing.HasKeys(house)
      or Housing.CanRaid()
      then
        Housing.CreateTargetPoint(newInvId,"owner","inventory",pos,{invId = newInvId})
      end
    elseif target.isWardrobe then
      local prevWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',target.position.x,target.position.y,target.position.z)
      local newWardId = 'hv3_w:' .. string.format('%.2f,%.2f,%.2f',pos.x,pos.y,pos.z)

      exports["fivem-target"]:RemoveTargetPoint(prevWardId)
      Housing.CreateTargetPoint(newWardId,"owner","wardrobe",pos,{})
    end

    target.position = pos
    target.rotation = rot

    if target.object then
      SetEntityRotation(target.object,rot.x,rot.y,rot.z)
      SetEntityCoords(target.object,pos.x,pos.y,pos.z)
    end

    TriggerEvent("mf-housing-v3:syncFurniture",house)
  end
end)