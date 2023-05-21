local mLibs         = exports["meta_libs"]
local progBar       = (Config.UseProgBars and exports["progbars"] or false)
local Vector        = mLibs:Vector()
local Scenes        = mLibs:SynchronisedScene()
local sceneObjects  = {}
local SlingNextFrame = false
local MarketAccess   = false
local StopInfluence  = false
local streetName
local _

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local pos = GetEntityCoords(PlayerPedId(-1), false)
		streetName,_ = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)

vDist = function(v1,v2)  
  if not v1 or not v2 or not v1.x or not v2.x or not v1.z or not v2.z then return 0; end
  return math.sqrt( ((v1.x - v2.x)*(v1.x-v2.x)) + ((v1.y - v2.y)*(v1.y-v2.y)) + ((v1.z-v2.z)*(v1.z-v2.z)) ) 
end

HelpNotification = function(msg)
  AddTextEntry('TerritoriesHelp', msg)
  BeginTextCommandDisplayHelp('TerritoriesHelp')
  EndTextCommandDisplayHelp(0, false, true, -1)
end

ShowNotification = function(msg)
  AddTextEntry('TerritoriesNotify', msg)
  SetNotificationTextEntry('TerritoriesNotify')
  DrawNotification(false, true)
end

Start = function()
  GetFramework()
  PlayerData = GetPlayerData()
  Wait(5000)
  TriggerServerEvent('Territories:PlayerLogin')
  while not ModStart do Wait(0); end
  for k,v in pairs(Territories) do
    local count = 0
    Territories[k].blips = {}
    for _,area in pairs(Territories[k].areas) do
      local blipHandle = mLibs:AddAreaBlip(area.location.x,area.location.y,area.location.z,area.height,area.width,area.heading,BlipColors[v.control],math.floor(v.influence),true,area.display)
      local blip = TableCopy(mLibs:GetBlip(blipHandle))
      Territories[k].blips[blipHandle] = blip
    end
  end
  Update()
end

TableCopy = function(tab)
  local r = {}
  for k,v in pairs(tab) do
    if type(v) == "table" then
      r[k] = TableCopy(v)
    else
      r[k] = v
    end
  end
  return r
end

local SoldList = {}

Citizen.CreateThread(function()
    while true do
        Wait(10000)
        SoldList = {}
    end
end)


Update = function()
  if Config.ShowDebugText then    
    testText =  Utils.drawTextTemplate()
    testText.x = 0.95
    testText.y = 0.90
  end

  while true do
    local closest = GetClosestZone()
    local area = Territories[closest]
    if not dead then
      CheckLocation(closest)
      UpdateBlips()     

      if Config.ShowDebugText and area then
        testText.colour1 = colorsRGB[TextColors[area.control]][1]
        testText.colour2 = colorsRGB[TextColors[area.control]][2]
        testText.colour3 = colorsRGB[TextColors[area.control]][3]
        testText.colour4 = math.floor(230)
        testText.text = "Zone: "..closest.."\nControl: "..area.control:sub(1,1):upper()..area.control:sub(2).."\nInfluence point: "..math.floor(area.influence)
        Utils.drawText(testText)
      end
    else
      if lastZone then
        if PlayerData.job and PlayerData.job.name and GangLookup[PlayerData.job.name] then
          TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job.name)
          lastZone = false
        elseif PlayerData.job2 and PlayerData.job2.name and GangLookup[PlayerData.job2.name] then
          TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job2.name)
          lastZone = false
        end  
      end 
    end

    Wait(0)
  end
end

local GetKeyUp = function(key) return IsControlJustReleased(0,key); end

CheckLocation = function(closest)
  local area   = Territories[closest]
  local plyPed = GetPlayerPed(-1)
  local plyPos = GetEntityCoords(plyPed)
  local plyHp  = GetEntityHealth(plyPed)
  if closest then
    if plyHp > 100 then 
      if not lastZone or lastZone ~= closest then
        if lastZone then
          TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job.name)
        end
        if not StopInfluence then
          lastZone = closest
          if PlayerData.job and PlayerData.job.name and GangLookup[PlayerData.job.name] then
            TriggerServerEvent('Territories:EnterZone',closest,PlayerData.job.name)
          elseif PlayerData.job2 and PlayerData.job2.name and GangLookup[PlayerData.job2.name] then
            TriggerServerEvent('Territories:EnterZone',closest,PlayerData.job2.name)
          end
        end
      else
        if lastZone and StopInfluence then     
          if PlayerData.job and PlayerData.job.name and GangLookup[PlayerData.job.name] then
            TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job.name)
          elseif PlayerData.job2 and PlayerData.job2.name and GangLookup[PlayerData.job2.name] then
            TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job2.name)
          end   
        end
      end
    end

    if area.openzone or (area.control == PlayerData.job.name or (PlayerData.job2 and PlayerData.job2.name == area.control)) then
      if area.actions and area.actions.entry then 
        if vDist(plyPos,area.actions.entry.location) < Config.InteractDist then
          HelpNotification(area.actions.entry.helpText)
          if GetKeyUp(Config.InteractControl) then
            InsideInterior = area
            mLibs:TeleportPlayer(InsideInterior.actions.exit.location)
          end
        end
      end
    end

    if not InsideInterior and area.actions then
      if vDist(plyPos,area.actions.exit.location) < Config.InteractDist then
        HelpNotification(area.actions.exit.helpText)
        if GetKeyUp(Config.InteractControl) then
          InsideInterior = area
          mLibs:TeleportPlayer(InsideInterior.actions.entry.location)
        end
      end
    end
  else
    if lastZone then
      if PlayerData.job and PlayerData.job.name and GangLookup[PlayerData.job.name] then
        TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job.name)
      elseif PlayerData.job2 and PlayerData.job2.name and GangLookup[PlayerData.job2.name] then
        TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job2.name)
      end   
      lastZone = false
    end
    if not InsideInterior then
      local closestExit,exitDist
      for k,v in pairs(Territories) do
        if v.actions and v.actions.exit then
          local exit = v.actions.exit.location
          local dist = vDist(plyPos,exit)
          if not exitDist or dist < exitDist then
            closestExit = k
            exitDist = dist
          end
        end
      end

      if exitDist and exitDist < Config.InteractDist then
        HelpNotification(Territories[closestExit].actions.exit.helpText)
        if GetKeyUp(Config.InteractControl) then
          mLibs:TeleportPlayer(Territories[closestExit].actions.entry.location)
          InsideInterior = nil          
        end
      end
    end
  end

  if InsideInterior and InsideInterior.actions then    
    local exitDist = vDist(plyPos,InsideInterior.actions.exit.location)  
    if exitDist and exitDist < Config.InteractDist then
      HelpNotification(InsideInterior.actions.exit.helpText)
      if GetKeyUp(Config.InteractControl) then
        mLibs:TeleportPlayer(InsideInterior.actions.entry.location)
        InsideInterior = nil          
      end
    else
      local closestAct,actDist = GetClosestAction(InsideInterior)
      if actDist < Config.InteractDist then
        HelpNotification(InsideInterior.actions[closestAct].helpText)
        if GetKeyUp(Config.InteractControl) then
          SceneHandler(InsideInterior.actions[closestAct])
        end
      end
    end
  end
end

GetPlayerInventory = function(playerData)
  if Config.UsingMfInventory then
    local res
    exports["mf-inventory"]:getInventoryItems(playerData.identifier,function(items)
      res = items
    end)
    while not res do Wait(0) end
    return res
  else
    return playerData.inventory
  end
end

function DrawText3Ds(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())

  SetTextScale(0.32, 0.32)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 255)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 500
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end

-- RequestAnimDict("mp_common")
-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(100)
--     local player = PlayerPedId(-1)
--     local playerPos = GetEntityCoords(player, 0)
-- 		local handle, ped = FindFirstPed()
--     local idk = GetClosestZonePos(pos)
--     local area = Territories[idk]
-- 		local success
-- 		repeat
-- 			success, ped = FindNextPed(handle)
-- 			local pos = GetEntityCoords(ped)
-- 			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playerPos.x, playerPos.y, playerPos.z, true)
			
-- 			if distance < 2 and CanSellToPed(ped) and not IsPedInAnyVehicle(player, true) then
-- 				if IsControlPressed(1,74) then
-- 						oldped = ped
-- 						TaskStandStill(ped,5000.0)
-- 						SetEntityAsMissionEntity(ped)
-- 						FreezeEntityPosition(ped,true)
-- 						FreezeEntityPosition(player,true)
-- 						SetEntityHeading(ped,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y)+180)
-- 						SetEntityHeading(player,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y))
						
-- 						local chance = math.random(1,4)
-- 						--exports['progressBars']:startUI((Config.SellDrugsTime * 1000), Config.SellDrugsBarText)
-- 						Citizen.Wait((Config.SellDrugsTime * 1000))
-- 						if chance == 1 or chance == 3 or chance == 4 then
-- 							TaskPlayAnim(player, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
-- 							TaskPlayAnim(ped, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
--               TriggerServerEvent("Territories:SoldDrugs",idk)
-- 						else
-- 							chance = math.random(1,Config.CallPoliceChance)
-- 							if chance == 1 then
-- 								if Config.PoliceNotfiyEnabled == true then
-- 									TriggerServerEvent('t1ger_drugs:DrugSaleInProgress',GetEntityCoords(PlayerPedId()),streetName)
-- 								end
-- 								ESX.ShowNotification("Dit tilbud blev ~r~afvist~s~")
-- 							else
-- 								ESX.ShowNotification("Dit tilbud blev ~r~afvist~s~")	
-- 							end
-- 						end
						
-- 						SetPedAsNoLongerNeeded(oldped)
-- 						FreezeEntityPosition(ped,false)
-- 						FreezeEntityPosition(player,false)
-- 						Citizen.Wait(Config.DrugSaleCooldown * 1000)
-- 						break
-- 				end
-- 			end
			
-- 		until not success
-- 		EndFindPed(handle)
-- 	end
-- end)

function CanSellToPed(ped)
	if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped,false) and not IsEntityDead(ped) and IsPedHuman(ped) and GetEntityModel(ped) ~= GetHashKey("s_m_y_cop_01") and GetEntityModel(ped) ~= GetHashKey("u_m_m_partytarget") and GetEntityModel(ped) ~= GetHashKey("s_m_y_dealer_01") and GetEntityModel(ped) ~= GetHashKey("mp_m_shopkeep_01") and ped ~= oldped then 
		return true
	end
	return false
end


RequestAnimDict("mp_common")
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
        local player = PlayerPedId(-1)
        local playerPos = GetEntityCoords(player, 0)
		local handle, ped = FindFirstPed()
		local success
		repeat
			success, ped = FindNextPed(handle)
			local pos = GetEntityCoords(ped)
      local idk = GetClosestZonePos(pos)
      local area = Territories[idk]
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playerPos.x, playerPos.y, playerPos.z, true)
			
      if distance < 2 and CanSellToPed(ped) and not IsPedInAnyVehicle(player, true) and not has_value(NetworkGetNetworkIdFromEntity(ped), GetEntityModel(ped)) then
				if IsControlPressed(1,58) then
						oldped = ped
            local pedModel = GetEntityModel(ped)
						local networkID = NetworkGetNetworkIdFromEntity(ped)
						table.insert(SoldList, {network = networkID, ped = pedModel})
						TaskStandStill(ped,5000.0)
						SetEntityAsMissionEntity(ped)
						FreezeEntityPosition(ped,true)
						FreezeEntityPosition(player,true)
						SetEntityHeading(ped,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y)+180)
						SetEntityHeading(player,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y))
						
						local chance = math.random(1,3)
						exports['progressBars']:startUI((Config.SellDrugsTime * 1000), "Sælger Stoffer")
						Citizen.Wait((Config.SellDrugsTime * 1000))
            if chance == 1 or chance == 2 then
							TaskPlayAnim(player, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
							TaskPlayAnim(ped, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
              TriggerServerEvent("Territories:SoldDrugs",idk)
							-- TriggerServerEvent("t1ger_drugs:sellDrugs", securityToken)
						else
							chance = math.random(1,2)
							if chance == 1 then
								if true then
                  TriggerServerEvent('esx_outlawalert:DrugSaleInProgress',GetEntityCoords(ped),streetName)
                  TriggerServerEvent("Territories:Reported",GetEntityCoords(ped))
								end
								ESX.ShowNotification("Dit tilbud blev ~r~afvist~s~ Personen har ringet efter Politiet!")
							else
								ESX.ShowNotification("Dit tilbud blev ~r~afvist~s~")	
							end
						end
						
						SetPedAsNoLongerNeeded(oldped)
						FreezeEntityPosition(ped,false)
						FreezeEntityPosition(player,false)
						Citizen.Wait(Config.DrugSaleCooldown * 1000)
						break
					end
			end
			
		until not success
		EndFindPed(handle)
	end
end)

function has_value(id, model)
  for k, v in pairs(SoldList) do
      if v.network == id then
          if not v.ped == model then
              table.remove(SoldList, k)
              return false
          else
              return true
          end
      end
  end

  return false
end


local startTime
SceneHandler = function(action)
  local hasItem,itemLabel = not action.requireItem,''
  if action.requireItem then
    local plyData = ESX.GetPlayerData()
    local inventory = GetPlayerInventory(plyData)
    for k,v in pairs(inventory) do
      if v.name == action.requireItem then
        hasItem = (v.count >= action.requireRate)
        itemLabel = v.label
      end
    end
  elseif action.requireCash then
    hasItem = false
    itemLabel = "Dirty Money"
    local plyData = ESX.GetPlayerData()
    for k,v in pairs(plyData.accounts) do
      if v.name == Config.DirtyAccount then
        hasItem = (v.money and v.money >= action.requireCash)
      end
    end
  end

  if hasItem then
    local plyPed = GetPlayerPed(-1)

    local sceneType = action.act
    local doScene = action.scene
    local actPos = action.location - action.offset
    local actRot = action.rotation

    local animDict = SceneDicts[sceneType][doScene]
    local actItems = SceneItems[sceneType][doScene]
    local actAnims = SceneAnims[sceneType][doScene]
    local plyAnim = PlayerAnims[sceneType][doScene]

    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict); Wait(0); end

    local count = 1
    local objectCount = 0
    for k,v in pairs(actItems) do
      local hash = GetHashKey(v)
      while not HasModelLoaded(hash) do RequestModel(hash); Wait(0); end
      sceneObjects[k] = CreateObject(hash,actPos,true)
      SetModelAsNoLongerNeeded(hash)
      objectCount = objectCount + 1
      while not DoesEntityExist(sceneObjects[k]) do Wait(0); end
      SetEntityCollision(sceneObjects[k],false,false)
    end

    local scenes = {}
    local sceneConfig = Scenes.SceneConfig(actPos,actRot,2,false,false,1.0,0,1.0)

    for i=1,math.max(1,math.ceil(objectCount/3)),1 do
      scenes[i] = Scenes.Create(sceneConfig)
    end

    local pedConfig = Scenes.PedConfig(plyPed,scenes[1],animDict,plyAnim)
    Scenes.AddPed(pedConfig)

    for k,animation in pairs(actAnims) do      
      local targetScene = scenes[math.ceil(count/3)]
      local entConfig = Scenes.EntityConfig(sceneObjects[k],targetScene,animDict,animation)
      Scenes.AddEntity(entConfig)
      count = count + 1
    end

    local extras = {}
    if action.extraProps then
      for k,v in pairs(action.extraProps) do
        mLibs:LoadModel(v.model)
        local obj = CreateObject(GetHashKey(v.model), actPos + v.pos, true,true,true)
        while not DoesEntityExist(obj) do Wait(0); end
        SetEntityRotation(obj,v.rot)
        FreezeEntityPosition(obj,true)
        extras[#extras+1] = obj
      end
    end

    startTime = GetGameTimer()

    for i=1,#scenes,1 do
      Scenes.Start(scenes[i])
    end

    if progBar then
      progBar:StartProg(action.time,action.progText)
    else
      ShowNotification(action.progText)
    end

    Wait(action.time)

    for i=1,#scenes,1 do
      Scenes.Stop(scenes[i])
    end

    for k,v in pairs(extras) do
      DeleteObject(v)
    end

    RemoveAnimDict(animDict)

    TriggerServerEvent('Territories:RewardPlayer',action)
    for k,v in pairs(sceneObjects) do
      SetEntityAsMissionEntity(v,true,true)
      DeleteObject(v)
    end
    sceneObjects = {}
  else
    local str = _U["not_enough"]
    local label = (itemLabel:len() > 0 and itemLabel or 'UNKNOWN')
    local amount = (action.requireRate or (action.requireCash and "$"..action.requireCash or 'UNKNOWN'))
    ShowNotification(string.format(str,label,amount))
  end
end

GetClosestAction = function(interior)
  local plyPos = GetEntityCoords(GetPlayerPed(-1))
  local closest,closestDist
  for k,v in pairs(interior.actions) do
    if k ~= "entry" and k ~= "exit" then
      local dist = vDist(plyPos,v.location)
      if not closestDist or dist < closestDist then
        closestDist = dist
        closest = k
      end
    end
  end
  return (closest or false),(closestDist or 9999)
end

Switch = function(cond,...)
  local args = {...}
  local even = (#args%2 == 0)
  for i=1,#args-(even and 0 or 1),2 do
    if cond == args[i] then
      return args[i+1]((even and nil or args[#args]))
    end
  end
end

UpdateBlips = function()
  for k,v in pairs(Territories) do    
    if Config.DrugProcessBlip then
      if v.blipData and not v.blip and PlayerData and (PlayerData.job and PlayerData.job.name and PlayerData.job.name == v.control or PlayerData.job2 and PlayerData.job2.name and PlayerData.job2.name == v.control) then
        v.blip = mLibs:AddBlip(v.blipData.pos.x,v.blipData.pos.y,v.blipData.pos.z,v.blipData.sprite,v.blipData.color,v.blipData.text,v.blipData.scale,v.blipData.display,v.blipData.shortRange,true)
      elseif v.blip then
        local inControl = false
        inControl = (PlayerData and PlayerData.job and PlayerData.job.name and PlayerData.job.name == v.control)
        inControl = (inControl == false and PlayerData.job2 and PlayerData.job2.name and PlayerData.job2.name == v.control or true)
        if not inControl then
          mLibs:RemoveBlip(v.blip)
          v.blip = false
        end
      end
    end
    if v.blips then
      for handle,blip in pairs(v.blips) do
        if Config.DisplayZoneForAll or PlayerInGang() then
          if blip.color ~= BlipColors[v.control] or blip.alpha ~= math.floor(v.influence) then 
            mLibs:SetBlip(handle,"alpha",math.floor(v.influence)) 
            mLibs:SetBlip(handle,"color",BlipColors[v.control])

            local b = TableCopy(mLibs:GetBlip(handle))
            Territories[k].blips[handle] = b    
          end
        else
          if blip.alpha ~= 0 then
            mLibs:SetBlip(handle,"alpha",0)          
            local b = TableCopy(mLibs:GetBlip(handle))
            Territories[k].blips[handle] = b
          end
        end
      end
    end
  end
end

GetClosestZonePos = function(pos)
  local closest
  local thisZone = GetNameOfZone(pos)
  for k,v in pairs(Territories) do
    if v.zone == thisZone then
      closest = k
    end
  end
  return (closest or false)
end

GetClosestZone = function()
  local closest
  local thisZone = GetNameOfZone(GetEntityCoords(GetPlayerPed(-1)))
  for k,v in pairs(Territories) do
    if v.zone == thisZone then
      closest = k
    end
  end
  return (closest or false)
end

Sync = function(tab)
  for k,v in pairs(tab) do
    Territories[k].influence = v.influence
    Territories[k].control = v.control
  end
end

GetPlayerByEntityID = function(id)
  for i=0,Config.MaxPlayerCount do
    if(NetworkIsPlayerActive(i) and GetPlayerPed(i) == id) then return i end
  end
  return nil
end

PlayerInGang = function()
  if not PlayerData or (not PlayerData.job and not PlayerData.job2) or (not PlayerData.job.name and not PlayerData.job2.name) then return false; end
  if GangLookup[PlayerData.job.name] then 
    return true 
  else 
    if PlayerData.job2 and PlayerData.job2.name and GangLookup[PlayerData.job2.name] then
      return true
    else
      return false
    end
  end
end

if Config.StartEvent == "Thread" then
  Citizen.CreateThread(Start)
else
  AddEventHandler(Config.StartEvent,Start)
end

RegisterNetEvent('Territories:outlawNotify')
AddEventHandler('Territories:outlawNotify', function(pos,alert)
  local idk = GetClosestZonePos(pos)
  local area = Territories[idk]
  local job = ESX.GetPlayerData().job
  if area ~= nil then
      if job and job.name and PoliceLookup[job.name] or job.name == area.control then
        ESX.ShowNotification("".. alert)
      end
  end
end)

PlayerReported = function(pos)
  local idk = GetClosestZonePos(pos)
  local area = Territories[idk]
  local job = ESX.GetPlayerData().job
  if area ~= nil then
    if job and job.name and PoliceLookup[job.name] or job.name == area.control then
      local started = GetGameTimer()
      local alpha = 250
      local policeNotifyBlip = AddBlipForRadius(pos.x, pos.y, pos.z, 50.0)
      SetBlipDisplay(policeNotifyBlip, 2)
      SetBlipHighDetail(policeNotifyBlip, true)
      SetBlipColour(policeNotifyBlip, 1)
      SetBlipAlpha(policeNotifyBlip, alpha)
    
      while alpha ~= 0 do
        Citizen.Wait(60 * 4)
        alpha = alpha - 1
        SetBlipAlpha(policeNotifyBlip, alpha)
    
        if alpha == 0 then
          RemoveBlip(policeNotifyBlip)
          return
        end
      end
        Wait(0)
    else
      local job2 = ESX.GetPlayerData().job2
      if job2 and job2.name and PoliceLookup[job2.name] then
        local started = GetGameTimer()
        ShowNotification(_U["drug_deal_reported"])
        while (GetGameTimer() - started) < 8000 do
          if IsControlJustReleased(0, 101) or IsDisabledControlJustReleased(0, 101) then
            SetNewWaypoint(pos.x,pos.y)
            return
          end
          Wait(0)
        end 
      end
    end
  end
end

EnterHouse = function(...)
  if not Config.InfluenceInHouse then
    StopInfluence = true
  end
end

LeaveHouse = function(...)
  if not Config.InfluenceInHouse then
    lastZone = false
    StopInfluence = false
  end
end

StartRet = function(start,territories)
  ModStart = start
  Territories = territories
end

-- THINGS YOU MIGHT WANT TO CHANGE
GetFramework = function()
  while not ESX do Wait(0) end
  while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
end

GetPlayerData = function()
  return ESX.GetPlayerData()
end

SetJob = function(job)
  PlayerData.job = job

  if lastZone then
    TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job.name)
    lastZone = false
  end
end

SetJob2 = function(job2)
  PlayerData.job2 = job2
  if lastZone then
    TriggerServerEvent('Territories:LeaveZone',lastZone,PlayerData.job2.name)
    lastZone = false
  end
end

Smack = function()
  ShowNotification("Cheater cheater, pumpkin eater!")
  local plyPed = GetPlayerPed(-1)
  while GetEntityHealth(plyPed) > 80 do
    SetEntityHealth(plyPed,GetEntityHealth(plyPed) - 10)
    Wait(500)
  end
end

Citizen.CreateThread( function()
  while true do
     Citizen.Wait(1)
     RestorePlayerStamina(PlayerId(), 1.0)
     -- it's that simple
     end
 end)

Utils.event(1,Sync,'Territories:Sync')
Utils.event(1,StartRet,'Territories:StartRet')
Utils.event(1,SetJob,Config.SetJobEvent)
Utils.event(1,SetJob2,Config.SetJob2Event)
Utils.event(1,GotCuffed,'Territories:GotCuffed')
Utils.event(1,PlayerReported,'Territories:PlayerReported')
Utils.event(1,GotMarketAccess,'Territories:GotMarketAccess')
Utils.event(1,LostMarketAccess,'Territories:LostMarketAccess')
Utils.event(1,Smack,'Territories:Smacked')
Utils.event(1,EnterHouse,'playerhousing:Entered')
Utils.event(1,LeaveHouse,'playerhousing:Leave')