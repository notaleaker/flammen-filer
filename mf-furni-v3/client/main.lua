local glm = require 'glm'

insideHouse = false
insideYard  = false

local loadedPreset
local uiOpen
local uiReady

local ownedFurni = {}
local spinEnts = {}
local basketItems = {}
local modelSwap
local selectTarget

local setEsxHudOpacity = function(o)  
  ESX.UI.HUD.SetDisplay(o or 0)
end

local getFurniCategory = function(catName)
  for i=1,#Config.Categories do
    if Config.Categories[i].name == catName then
      return Config.Categories[i]
    end
  end
end

local hideModelSwap = function(displayDefault)
  if modelSwap then
    for i=1,#spinEnts do
      if spinEnts[i] == modelSwap.ent then
        table.remove(spinEnts,i)
        break
      end
    end

    DeleteEntity(modelSwap.ent)

    if displayDefault then
      if modelSwap.original.ent then
        SetEntityCoords(
          modelSwap.original.ent,
          modelSwap.original.position.x,
          modelSwap.original.position.y,
          modelSwap.original.position.z
        )
      end
    end

    modelSwap = nil
  end
end

local hideUi = function()
  SendNUIMessage({
    func = "HideAll",
    arguments = {}
  })

  SetNuiFocus(false,false)
  setEsxHudOpacity(1)

  uiOpen        = false
  selectTarget  = false

  hideModelSwap(true)
end

local displayUi = function(payload)
  SendNUIMessage(payload)
  SetNuiFocus(true,true)
  uiOpen = true
  setEsxHudOpacity(0)
end

local getCategorizedFurni = function(targetFurni) 
  local categorizedFurniture = {}

  table.insert(categorizedFurniture,{
    name = "placed",
    label = "Placed",
    models = {}
  })

  for i=1,#targetFurni do
    local v = targetFurni[i]

    table.insert(categorizedFurniture[1].models,{
      name    = v.model,
      label   = v.label,
      price   = v.price,
      pos     = v.pos,
      rot     = v.rot,
      index   = i,
      placed  = true,
    })
  end

  for i=1,#ownedFurni do
    local v = ownedFurni[i]

    if #v.models > 0 then
      local found = false
      for j=1,#categorizedFurniture do
        if categorizedFurniture[j].name == v.name then
          found = j
          break
        end
      end

      if not found then
        table.insert(categorizedFurniture,{
          name = v.name,
          label = v.label,
          models = {}
        })

        found = #categorizedFurniture
      end

      for j=1,#v.models do
        local _v = v.models[j]
        table.insert(categorizedFurniture[found].models,{
          name = _v.name,
          label = _v.label,
          price = _v.price,
          count = _v.count,
          category = found,
          categoryName = categorizedFurniture[found].name,
          index = j
        })
      end
    end
  end

  return categorizedFurniture
end

local openPresets = function()  
  local targetPreset

  if insideHouse then
    targetPreset = Config.Presets[insideHouse.shell.model]
  end

  if not targetPreset then
    return
  end

  local money = 0
  local accounts = ESX.GetPlayerData().accounts

  for i=1,#accounts do
    for j=1,#Config.BuyAccounts do
      if accounts[i].name == Config.BuyAccounts[j] then
        money = money + accounts[i].money
      end
    end
  end

  displayUi({
    func = "BuyPreset",
    arguments = {
      targetPreset,
      money
    }
  })
end

local buyTarget

local onInteract = function(zoneName,actionName,vars)
  if actionName == "furni" then
    local targetFurni

    if insideHouse then
      targetFurni = insideHouse.furniture.inside
    elseif insideYard then
      targetFurni = insideYard.furniture.outside
    end

    if not targetFurni then
      return
    end

    displayUi({
      func = "PlaceFurniture",
      arguments = {getCategorizedFurni(targetFurni)}
    })
  elseif actionName == "presets" then
    openPresets()
  elseif actionName == "shop" then
    local money = 0
    local accounts = ESX.GetPlayerData().accounts

    for i=1,#accounts do
      for j=1,#Config.BuyAccounts do
        if accounts[i].name == Config.BuyAccounts[j] then
          money = money + accounts[i].money
        end
      end
    end

    basketItems = basketItems or {}

    local cats = {}

    for k,v in ipairs(Config.Categories) do
      for key,val in ipairs(vars.categories) do
        if v.name == val then
          table.insert(cats,v)          
        end
      end
    end

    buyTarget = vars

    displayUi({
      func = "BuyFurniture",
      arguments = {
        cats,
        basketItems,
        money,
        ""
      }
    })
  elseif actionName == "checkout" then
    local money = 0
    local accounts = ESX.GetPlayerData().accounts

    for i=1,#accounts do
      for j=1,#Config.BuyAccounts do
        if accounts[i].name == Config.BuyAccounts[j] then
          money = money + accounts[i].money
        end
      end
    end

    basketItems = basketItems or {}

    displayUi({
      func = "OrderFurniture",
      arguments = {
        basketItems,
        money
      }
    })
  end
end

local createTargetEnt = function(opts)
  exports['fivem-target']:AddTargetLocalEntity(opts)  
end

local createTargetPoint = function(opts)
  exports["fivem-target"]:AddTargetPoint(opts)
end

local getObjectPosition = function(offset,head,pos)
  return (Utils.RotateVectorFlat(offset,head) + pos)
end

local loadObject = function(pos,head,obj)
  local hash = type(obj.model) == "string" and GetHashKey(obj.model) or obj.model

  Utils.LoadModel(hash)

  if obj.offset then
    pos = getObjectPosition(obj.offset,head,pos)
  end

  local ent = CreateObject(hash, pos.x,pos.y,pos.z, false,false)
  SetEntityCoords(ent,pos.x,pos.y,pos.z)

  if obj.rotation then
    SetEntityRotation(ent,obj.rotation.x,obj.rotation.y,obj.rotation.z + (head or 0.0),obj.rotationOrder or 2)
  elseif head then
    SetEntityRotation(ent,0,0,head,2)
  end

  if obj.freeze then
    FreezeEntityPosition(ent,true)
  end

  SetModelAsNoLongerNeeded(hash)

  return ent
end

local hasFurniPermission = function(house)
  local playerData = ESX.GetPlayerData()

  if house.ownerInfo.identifier == playerData.identifier then
    return true
  end

  for _,v in ipairs(house.keys) do
    if v.identifier == playerData.identifier then
      return true
    end
  end
  
  return false
end

local loadStores = function()
  for k,v in ipairs(Config.Shops) do
    Utils.CreateBlip({
      location  = v.blipPosition,
      sprite    = v.blipSprite,
      color     = v.blipColor,
      display   = v.blipDisplay,
      text      = v.blipName
    })

    if v.checkoutNpcModel then
      local hash = GetHashKey(v.checkoutNpcModel)

      while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(0)
      end

      local ent = CreatePed(4, hash, v.checkoutPosition.x,v.checkoutPosition.y,v.checkoutPosition.z, v.checkoutNpcHeading,false,false)

      FreezeEntityPosition(ent,true)
      TaskSetBlockingOfNonTemporaryEvents(ent,true)
      SetEntityInvincible(ent,true)

      v.ent = ent

      createTargetEnt({
        name          = "furni:checkoutNpc:"..v.blipName,
        label         = Config.TargetOptions.checkout.label,
        icon          = Config.TargetOptions.checkout.icon,
        entId         = ent,
        interactDist  = 2.5,
        onInteract    = onInteract,
        options       = Config.TargetOptions.checkout.options,
      })
    else
      createTargetPoint({
        name          = "furni:checkout:"..v.blipName,
        label         = Config.TargetOptions.checkout.label,
        icon          = Config.TargetOptions.checkout.icon,
        point         = v.checkoutPosition,
        interactDist  = 2.5,
        onInteract    = onInteract,
        options       = Config.TargetOptions.checkout.options,
      })
    end

    for key,val in ipairs(v.displays) do
      if val.displayModel then
        local ent = loadObject(val.position,val.heading,{model = val.displayModel,freeze = true})
        SetEntityLodDist(ent,100)

        val.ent = ent

        createTargetEnt({
          name          = "furni:shop:"..v.blipName..":"..key,
          label         = val.label,
          icon          = Config.TargetOptions.category.icon,
          entId         = ent,
          interactDist  = val.interactDist or 2.5,
          onInteract    = onInteract,
          options       = Config.TargetOptions.category.options,
          vars          = val
        })

        if val.doSpin then
          table.insert(spinEnts,ent)
        end
      else
        createTargetPoint({
          name          = "furni:shop:"..v.blipName..":"..key,
          label         = val.label,
          icon          = Config.TargetOptions.category.icon,
          point         = val.position,
          interactDist  = val.interactDist or 2.5,
          onInteract    = onInteract,
          options       = Config.TargetOptions.category.options,
          vars          = val
        })
      end
    end
  end
end

local getPreset = function(model,name)
  for i=1,#Config.Presets[model] do
    if Config.Presets[model][i].name == name then
      return Config.Presets[model][i]
    end
  end
end

local unloadPreset = function()
  for k,v in ipairs(loadedPreset) do
    DeleteObject(v)
  end

  loadedPreset = nil
end

local loadPreset = function(pos,head,model,name)
  local preset = getPreset(model,name)

  if not preset then
    return
  end

  if loadedPreset then
    unloadPreset()
  end

  loadedPreset = {}

  for i=1,#preset.objects do
    table.insert(loadedPreset,loadObject(pos,head,preset.objects[i]))
  end
end

local function lookRotation(forward,up)
  local t = norm(glm.cross(up, forward))
  return quat(mat3x3(t, glm.cross(forward, t), forward))
end

local placeFurniture = function(polyZone,model,targetHead,shellModel)
  local ped                     = PlayerPedId()
  local pedPos                  = GetEntityCoords(ped)
  local start,fin               = Utils.GetCoordsInFrontOfCam(0,5000)
  local ray                     = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 1,  ped, 5000)
  local oRay                    = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 16, ped, 5000)
  local r,hit,pos,_norm,obj     = GetShapeTestResult(ray)
  local oR,oHit,oPos,oNorm,oObj = GetShapeTestResult(oRay)

  local hash    = GetHashKey(model)
  local ent     = loadObject(pos,0.0,{model = model})
  local _,__,up = GetEntityMatrix(ped)
  Wait(0)

  local camera = Utils.CreateCamera("DEFAULT_SCRIPTED_CAMERA",pedPos + (up*2),vector3(-35.0,0.0,GetEntityHeading(ped)), true)
  local controls = Utils.GetControls("place","cancel","rotateX","rotateY","rotateZ","holdSnap","zOffset")
  local sf = Utils.CreateInstructional(controls)
  Wait(0)

  targetHead = targetHead or 0.0
  local targetRot = vector3(0.0,0.0,targetHead)
  local targetPos
  local zOffset = 0.0

  while true do
    local frameTime = GetFrameTime()

    DisableAllControlActions(0)

    Utils.HandleFlyCam(camera,pedPos,Config.CameraOptions.maxDistance or 100.0)  

    start,fin               = Utils.GetCoordsInFrontOfCam(0,5000)
    ray                     = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 1,  ent, 5000)
    oRay                    = StartShapeTestRay(start.x,start.y,start.z, fin.x,fin.y,fin.z, 16, ent, 5000)
    r,hit,pos,_norm,obj      = GetShapeTestResult(ray)
    oR,oHit,oPos,oNorm,oObj = GetShapeTestResult(oRay)

    if oHit > 0 then 
      r,hit,pos,_norm,obj = oR,oHit,oPos,oNorm,oObj
    end

    SetEntityCollision(ent,false,false)
    SetEntityCompletelyDisableCollision(ent,true,false)
    SetEntityNoCollisionEntity(ent,PlayerPedId(),true)

    local rotSpeed = 3.75
    local isRotating = false

    if IsDisabledControlPressed(0,Config.ActionControls.rotateX.codes[1]) then
      if IsDisabledControlJustReleased(0,Config.ActionControls.rotateX.codes[2]) then
        targetRot = vector3(targetRot.x + rotSpeed,targetRot.y,targetRot.z)
      elseif IsDisabledControlJustReleased(0,Config.ActionControls.rotateX.codes[3]) then
        targetRot = vector3(targetRot.x - rotSpeed,targetRot.y,targetRot.z)
      end 

      isRotating = true
    end

    if IsDisabledControlPressed(0,Config.ActionControls.rotateY.codes[1]) then
      if IsDisabledControlJustReleased(0,Config.ActionControls.rotateY.codes[2]) then
        targetRot = vector3(targetRot.x,targetRot.y + rotSpeed,targetRot.z)
      elseif IsDisabledControlJustReleased(0,Config.ActionControls.rotateY.codes[3]) then
        targetRot = vector3(targetRot.x,targetRot.y - rotSpeed,targetRot.z)
      end
      
      isRotating = true
    end

    if IsDisabledControlPressed(0,Config.ActionControls.rotateZ.codes[1]) then
      if IsDisabledControlJustReleased(0,Config.ActionControls.rotateZ.codes[2]) then
        targetRot = vector3(targetRot.x,targetRot.y,targetRot.z + rotSpeed)
      elseif IsDisabledControlJustReleased(0,Config.ActionControls.rotateZ.codes[3]) then
        targetRot = vector3(targetRot.x,targetRot.y,targetRot.z - rotSpeed)
      end
      
      isRotating = true
    end

    if not isRotating then
      if IsDisabledControlJustReleased(0,Config.ActionControls.zOffset.codes[2]) then
        zOffset = zOffset + (Config.ZOffsetModifier * frameTime)
      elseif IsDisabledControlJustReleased(0,Config.ActionControls.zOffset.codes[1]) then
        zOffset = zOffset - (Config.ZOffsetModifier * frameTime)
      end
    end

    if IsDisabledControlJustReleased(0,Config.ActionControls.cancel.codes[1]) then
      DeleteObject(ent)
      Utils.DestroyFlyCam(camera)

      return false
    end

    if IsDisabledControlJustReleased(0,Config.ActionControls.place.codes[1]) then
      local pos = targetPos
      local rot = targetRot

      DeleteObject(ent)
      Utils.DestroyFlyCam(camera)

      return true,pos + vector3(0,0,zOffset),rot
    end
    
    if hit then
      local min,max = GetModelDimensions(hash)

      local x,y,z = 0,0,0
      local dist = #(start - pos)

      if dist < 15.0 + 0.5 then
        if _norm.z > 0.5 then
          z = z - min.z
        elseif _norm.z < -0.5 then
          z = z + min.z
        end

        if IsDisabledControlPressed(0,Config.ActionControls.holdSnap.codes[1]) then        
          if  _norm.x ~= 0.0
          or  _norm.y ~= 0.0 
          and _norm.z == 0.0
          then
            local forward = _norm
            local up = vec(0,0,1)

            local rot = lookRotation(forward,up)

            local eulerRad = rot:eulerAngles()
            local eulerDeg = vector3(math.deg(eulerRad.x),math.deg(eulerRad.y),math.deg(eulerRad.z))

            targetRot = vector3(0,targetRot.y,eulerDeg.z)

            local fwd = GetEntityForwardVector(ent) * Utils.RotateVectorFlat(max,eulerDeg.z)
            pos = pos - vec3(fwd.x,fwd.y,0)
          end
        end

        targetPos = pos + vector(x,y,z)
      else
        local dir = pos - start
        local clamped = Utils.ClampVecLength(dir, 15.0)
        targetPos = start + clamped
      end

      SetEntityCoords(ent,targetPos.x,targetPos.y,targetPos.z + zOffset)

      if polyZone:isPointInside(targetPos) then
        Utils.DrawEntityBoundingBox(ent, 0,255,0,50)
      else
        Utils.DrawEntityBoundingBox(ent, 255,0,0,50)
      end
    end

    SetEntityRotation(ent, targetRot.x,targetRot.y,targetRot.z,2,true)
    
    Utils.DrawScaleform(sf)

    Wait(0)
  end
end

local createTargetPoly = function(points,opts,vars,isInside)
  local polyZone = PolyZone:Create(points,opts)

  local setInside = exports["fivem-target"]:AddPolyZone({
    name = opts.name,
    label = "Furni",
    icon = "fas fa-couch",
    inside = true,
    onInteract = onInteract,
    options = {
      {
        label = "Furni",
        name  = "furni"
      },
      (isInside and {
        label = "Presets",
        name  = "presets"
      } or nil),
    },
    vars = vars
  })

  polyZone:onPointInOut(PolyZone.getPlayerPosition,function(inside)
    setInside(inside)
  end)

  return polyZone
end

local handlePlacement = function(data)
  if  ( not insideHouse or not insideHouse.polyZone )
  and ( not insideYard  or not insideYard.polyZone  )
  then
    return
  end

  local targetZone,targetType,targetPoly,targetFurni

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetType  = "inside"
    targetPoly  = insideHouse.polyZone
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetType  = "outside"
    targetPoly  = insideYard.polyZone
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetPoly
  or not targetFurni 
  then
    return
  end

  local ownedCat
  for i=1,#ownedFurni do
    if ownedFurni[i].name == data.placeItem.categoryName then
      ownedCat = ownedFurni[i]
    end
  end

  local ownedItem = ownedCat.models[data.placeItem.index]

  if ownedItem then
    hideUi()

    local doSave,pos,rot = placeFurniture(targetPoly,data.placeItem.name,targetType == 'inside' and targetZone.shell.heading,targetZone.shell.model)

    if doSave then
      if ownedCat.models[data.placeItem.index].count <= 1 then
        table.remove(ownedCat.models,data.placeItem.index)
      else
        ownedCat.models[data.placeItem.index].count = ownedCat.models[data.placeItem.index].count - 1
      end

      table.insert(targetFurni,{
        model = data.placeItem.name,
        label = data.placeItem.label,
        pos = pos,
        rot = rot,
        price = data.placeItem.price
      })

      Utils.TriggerServerEvent("placeFurniture",targetZone.houseId,targetType,data.placeItem.categoryName,data.placeItem.name,pos,rot)
    end
  end

  displayUi({
    func = "PlaceFurniture",
    arguments = {
      getCategorizedFurni(targetFurni),
      data.category,
      data.scroll
    }
  })
end

local getCategoryName = function(modelName)
  for _,cat in ipairs(Categories) do
    for _,model in ipairs(cat.models) do
      if model.name == modelName then
        return cat.name
      end
    end
  end
end

local handleSell = function(data)
  if  not insideHouse
  and not insideYard 
  then
    return
  end

  local targetZone,targetFurni

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetFurni
  then
    return
  end

  local ownedCat
  for i=1,#ownedFurni do
    if ownedFurni[i].name == data.sellItem.categoryName then
      ownedCat = ownedFurni[i]
    end
  end

  if not ownedCat then
    return
  end

  local ownedItem = ownedCat.models[data.sellItem.index]

  if ownedItem and ownedItem.name == data.sellItem.name then
    ownedItem.count = ownedItem.count - 1

    if ownedItem.count <= 0 then
      table.remove(ownedCat.models,data.sellItem.index)
    end

    Utils.TriggerServerEvent("sellFurniture",targetZone.houseId,data.sellItem)
  end

  displayUi({
    func = "PlaceFurniture",
    arguments = {
      getCategorizedFurni(targetFurni),
      data.category,
      data.scroll
    }
  })
end

local handleBuy = function(data)
  local canBuyPreset = true
  local targetZone,targetFurni,targetType

  if  not insideHouse
  and not insideYard 
  then
    canBuyPreset = false
  else
    if insideHouse and insideHouse.polyZone then
      targetZone  = insideHouse
      targetFurni = insideHouse.furniture.inside
      targetType  = "inside"
    elseif insideYard and insideYard.polyZone then
      targetZone  = insideYard
      targetFurni = insideYard.furniture.outside
      targetType  = "outside"
    end
  end

  if canBuyPreset
  and (
        not targetZone 
    or  not targetFurni
    or  not targetType
  ) then
    canBuyPreset = false
  end

  basketItems = nil

  local items = {}
  local presets = {}
  local hasItems = {}

  for i=1,#data.basketItems do
    local v = data.basketItems[i]

    if v.preset then
      if canBuyPreset then
        table.insert(presets,v.name)
      end
    else
      if hasItems[v.name] then
        hasItems[v.name].count = hasItems[v.name].count + (v.count or 1)
      else
        hasItems[v.name] = {name = v.name or v.model, label = v.label, cat = v.categoryName, count = v.count or 1}
        table.insert(items,hasItems[v.name])
      end
    end
  end

  ESX.TriggerServerCallback("mf-furni-v3:buyFurniture",function(f,_f)
    ownedFurni = f

    if _f then
      targetFurni = _f[targetType]
    end

    if targetZone then
      displayUi({
        func = "PlaceFurniture",
        arguments = {getCategorizedFurni(targetFurni)}
      })
    end

  end,items,presets,targetZone and targetZone.houseId,targetType)
end

local handlePreviewPreset = function(data)
  if not insideHouse then
    return
  end

  if loadedPreset then
    return
  end

  loadPreset(insideHouse.shell.position,insideHouse.shell.heading,insideHouse.shell.model,data.previewPresetItem.name)

  while true do
    Utils.ShowHelpNotification("~INPUT_PICKUP~ Cancel Preview")

    DisableControlAction(0,38,true)

    if IsDisabledControlJustReleased(0,38) or not insideHouse then
      unloadPreset()
      openPresets()
      return
    end

    Wait(0)
  end
end

local handleRemove = function(data)  
  if  ( not insideHouse or not insideHouse.polyZone )
  and ( not insideYard  or not insideYard.polyZone  )
  then
    return
  end

  local targetZone,targetType

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetType  = "inside"
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetType  = "outside"
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetType
  then
    return
  end

  table.remove(targetFurni,data.removeItem.index)

  ESX.TriggerServerCallback("mf-furni-v3:removeFurniture",function(f)
    ownedFurni = f  

    displayUi({
      func = "PlaceFurniture",
      arguments = {
        getCategorizedFurni(targetFurni),
        data.category,
        data.scroll
      }
    })
  end,targetZone.houseId,targetType,data.removeItem.name,data.removeItem.index)
end

local handlePreview = function(data)
  hideModelSwap()

  if buyTarget.ent and DoesEntityExist(buyTarget.ent) then    
    SetEntityCoords(
      buyTarget.ent,
      buyTarget.position.x,
      buyTarget.position.y,
      buyTarget.position.z + 100.0
    )
  end

  local newModel = GetHashKey(data.previewItem.name)

  RequestModel(newModel)

  local ent = CreateObject(
    newModel,
    buyTarget.position.x,
    buyTarget.position.y,
    buyTarget.position.z,
    buyTarget.heading
  )

  FreezeEntityPosition(ent,true)

  modelSwap = {
    original = buyTarget,
    ent = ent,
  }

  if buyTarget.doSpin then
    table.insert(spinEnts,ent)
  end
end

local handleEdit = function(data)
  if  ( not insideHouse or not insideHouse.polyZone )
  and ( not insideYard  or not insideYard.polyZone  )
  then
    return
  end

  local targetZone,targetType

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetPoly  = insideHouse.polyZone
    targetType  = "inside"
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetPoly  = insideYard.polyZone
    targetType  = "outside"
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetType
  or not targetPoly
  or not targetFurni
  then
    return
  end

  local obj = targetFurni[data.editItem.index]

  if not obj
  or not (obj.model == data.editItem.name)
  then
    return
  end

  hideUi()

  SetEntityCoords(obj.object, obj.position.x,obj.position.y,obj.position.z + 100.0)

  local doSave,pos,rot = placeFurniture(targetPoly,obj.model,targetType == 'inside' and targetZone.shell.heading,targetZone.shell.model)

  if not doSave then
    SetEntityCoords(obj.object, obj.position.x,obj.position.y,obj.position.z)
    return
  end

  SetEntityRotation(obj.object,rot.x,rot.y,rot.z)
  SetEntityCoords(obj.object,pos.x,pos.y,pos.z)

  obj.rotation = rot
  obj.position = pos

  displayUi({
    func = "PlaceFurniture",
    arguments = {
      getCategorizedFurni(targetFurni),
      data.category,
      data.scroll
    }
  })

  Utils.TriggerServerEvent("editFurniture",targetZone.houseId,targetType,data.editItem.index,obj.model,pos,rot)
  selectTarget = nil
end

local handleSelect = function(data)
  if  ( not insideHouse or not insideHouse.polyZone )
  and ( not insideYard  or not insideYard.polyZone  )
  then
    return
  end

  local targetZone,targetType

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetPoly  = insideHouse.polyZone
    targetType  = "inside"
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetPoly  = insideYard.polyZone
    targetType  = "outside"
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetType
  or not targetPoly
  or not targetFurni
  then
    return
  end

  local obj = targetFurni[data.placeFurnitureSelect.index]

  if not obj
  or not (obj.model == data.placeFurnitureSelect.name)
  then
    return
  end

  if data.placeFurnitureSelect.placed then
    selectTarget = obj.object
  else
    selectTarget = nil
  end
end

RegisterNUICallback("uiMessage",function(data)
  if not data then
    return
  end

  if data.init then
    uiReady = true
    return
  end

  if data.close then
    hideUi()
  end

  if data.place then
    handlePlacement(data)
  elseif data.placeFurnitureSelect then
    handleSelect(data)
  elseif data.removeItem then
    handleRemove(data)
  elseif data.editItem then
    handleEdit(data)
  elseif data.sell then
    handleSell(data)
  elseif data.buy then
    handleBuy(data)
  elseif data.basketItems then
    basketItems = data.basketItems
  elseif data.previewPreset then
    handlePreviewPreset(data)
  elseif data.preview then
    handlePreview(data)
  end
end)

Citizen.CreateThread(function()
  local start = GetGameTimer()

  Utils.InitESX()

  while not ESX.IsPlayerLoaded() do
    Wait(500)
  end

  local now = GetGameTimer()
  local diff = GetGameTimer() - start

  if diff < 2000 then
    Wait(2000 - diff)
  end

  Utils.TriggerServerEvent("getFurniture")

  while not uiReady do
    SendNUIMessage({
      func = "Init",
      arguments = {
        GetCurrentResourceName(),
        'uiMessage'
      }
    })

    Wait(500)
  end

  loadStores()

  while true do
    local waitTime = 500

    if selectTarget then
      Utils.DrawEntityBoundingBox(selectTarget, 255,255,255, 50)
      waitTime = 0
    end

    if uiOpen then
      InvalidateIdleCam()
      HideHudAndRadarThisFrame()
      waitTime = 0
    end

    if #spinEnts > 0 then
      local pos = GetEntityCoords(PlayerPedId())

      for k,v in ipairs(spinEnts) do
        local d = #(GetEntityCoords(v) - pos)

        if d <= 50.0 then
          local rot = GetEntityRotation(v)
          SetEntityRotation(v, rot.x,rot.y,rot.z + (10.0 * GetFrameTime()),2)

          waitTime = 0
        end
      end
    end

    Wait(waitTime)
  end
end)

Utils.RegisterNetEvent("gotFurniture",function(f)
  ownedFurni = f
end)

AddEventHandler("mf-housing-v3:syncFurniture",function(houseData)
  if  insideHouse 
  and insideHouse.houseId == houseData.houseId 
  and hasFurniPermission(houseData)
  then
    exports["fivem-target"]:RemoveTargetPoint(string.format("furni:%s:shell",houseData.houseId))
    insideHouse.polyZone:destroy()

    insideHouse = houseData

    local min,max = GetModelDimensions(GetEntityModel(houseData.shellobject))
    local points = Utils.Get2DEntityBoundingBox(houseData.shellobject)

    insideHouse.polyZone = createTargetPoly(
      points,
      {
        name=string.format("furni:%s:%s",houseData.houseId,"shell"),
        minZ=houseData.shell.position.z + (min.z),
        maxZ=houseData.shell.position.z + (max.z*2),
        debugGrid=Config.Debug or false,
        gridDivisions=25
      },
      {
        houseId = houseData.houseId
      },
      true
    )
  end

  if  insideYard 
  and insideYard.houseId == houseData.houseId 
  and hasFurniPermission(houseData)
  then
    exports["fivem-target"]:RemoveTargetPoint(string.format("furni:%s:exterior",houseData.houseId))
    insideYard.polyZone:destroy()

    insideYard = houseData

    insideYard.polyZone = createTargetPoly(
      houseData.polyZone.points,
      {
        name=string.format("furni:%s:exterior",houseData.houseId),
        minZ=houseData.polyZone.minZ,
        maxZ=houseData.polyZone.maxZ,
        debugGrid=Config.Debug or false,
        gridDivisions=25
      },
      {
        houseId = houseData.houseId
      }
    )
  end
end)

AddEventHandler("mf-housing-v3:enterInterior",function(houseData)
  if insideHouse then
    return
  end

  if not hasFurniPermission(houseData) then
    return
  end

  insideHouse = houseData

  local min,max = GetModelDimensions(GetEntityModel(houseData.shellobject))
  local points = Utils.Get2DEntityBoundingBox(houseData.shellobject)

  insideHouse.polyZone = createTargetPoly(
    points,
    {
      name=string.format("furni:%s:%s",houseData.houseId,"shell"),
      minZ=houseData.shell.position.z + (min.z),
      maxZ=houseData.shell.position.z + (max.z*2),
      debugGrid=Config.Debug or false,
      gridDivisions=25
    },
    {
      houseId = houseData.houseId
    },
    true
  )
end)

AddEventHandler("mf-housing-v3:exitInterior",function(houseData)
  if (insideHouse and insideHouse.houseId == insideHouse.houseId) then
    exports["fivem-target"]:RemoveTargetPoint(string.format("furni:%s:shell",houseData.houseId))
    insideHouse.polyZone:destroy()
    insideHouse = nil
  end
end)

AddEventHandler("mf-housing-v3:enterPolyzone",function(houseData)
  if insideYard then
    return
  end

  if not hasFurniPermission(houseData) then
    return
  end

  insideYard = houseData

  insideYard.polyZone = createTargetPoly(
    houseData.polyZone.points,
    {
      name=string.format("furni:%s:exterior",houseData.houseId),
      minZ=houseData.polyZone.minZ,
      maxZ=houseData.polyZone.maxZ,
      debugGrid=Config.Debug or false,
      gridDivisions=25
    },
    {
      houseId = houseData.houseId
    }
  )
end)

AddEventHandler("mf-housing-v3:exitPolyzone",function(houseData)
  if (insideYard and insideYard.houseId == houseData.houseId) then
    exports["fivem-target"]:RemoveTargetPoint(string.format("furni:%s:exterior",houseData.houseId))
    insideYard.polyZone:destroy()
    insideYard = nil
  end
end)

Utils.RegisterNetEvent("placeFurnitureItem",function(itemName) 
  local targetZone,targetType,targetPoly,targetFurni

  if insideHouse and insideHouse.polyZone then
    targetZone  = insideHouse
    targetType  = "inside"
    targetPoly  = insideHouse.polyZone
    targetFurni = insideHouse.furniture.inside
  elseif insideYard and insideYard.polyZone then
    targetZone  = insideYard
    targetType  = "outside"
    targetPoly  = insideYard.polyZone
    targetFurni = insideYard.furniture.outside
  end

  if not targetZone 
  or not targetPoly
  or not targetFurni 
  then
    return
  end

  local doSave,pos,rot = placeFurniture(targetPoly,itemName,targetType == 'inside' and targetZone.shell.heading,targetZone.shell.model)

  if doSave then
    Utils.TriggerServerEvent("placeFurnitureItem",targetZone.houseId,targetType,itemName,pos,rot)
  end
end)