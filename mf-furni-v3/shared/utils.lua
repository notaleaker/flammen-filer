Utils = {}
Utils.RenderList = {}

Utils.Characters = {}
Utils.Numbers = {}

for i = 48,  57 do table.insert(Utils.Numbers, string.char(i))     end
for i = 65,  90 do table.insert(Utils.Characters, string.char(i))  end
for i = 97, 122 do table.insert(Utils.Characters, string.char(i))  end

Utils.GenerateRandomUid = function(characters,numbers)
  math.randomseed(os.time())
  local str = ''
  for i=1,characters,1 do
    str = str .. Utils.Characters[math.random(#Utils.Characters)]
  end
  for i=1,numbers,1 do
    str = str .. Utils.Numbers[math.random(#Utils.Numbers)]
  end
  return str
end

Utils.GenerateUniqueId = function(kvp,chars,numbers)
  local uid = Utils.GenerateRandomUid(chars,numbers)
  while kvp[uid] do
    uid = Utils.GenerateRandomUid(chars,numbers)
  end
  return uid
end

Utils.JsonEncode = function(tab)
  __utilsJsonEncodeInternalDecode = function(t)
    local _t = {}
    for k,v in pairs(t) do
      if type(v) == "vector4" then
        _t[k] = {x = v.x, y = v.y, z = v.z, w = v.w}
      elseif type(v) == "vector3" then
        _t[k] = {x = v.x, y = v.y, z = v.z}
      elseif type(v) == "vector2" then
        _t[k] = {x = v.x, y = v.y}
      elseif type(v) == "table" then
        _t[k] = __utilsJsonEncodeInternalDecode(v)
      else
        _t[k] = v
      end
    end
    return _t
  end
  return json.encode(__utilsJsonEncodeInternalDecode(tab))
end

Utils.JsonDecode = function(js)
  __utilsJsonDecodeInternalDecode = function(t)
    local _t = {}
    for k,v in pairs(t) do
      if type(v) == "table" then
        if v.x and v.y and v.z and v.w and Utils.TableCount(v) == 4 then
          _t[k] = vector4(v.x,v.y,v.z,v.w)
        elseif v.x and v.x and v.z and Utils.TableCount(v) == 3 then
          _t[k] = vector3(v.x,v.y,v.z)
        elseif v.x and v.y and Utils.TableCount(v) == 2 then
          _t[k] = vector2(v.x,v.y)
        else
          _t[k] = __utilsJsonDecodeInternalDecode(v)
        end
      else
        _t[k] = v
      end
    end
    return _t
  end

  return __utilsJsonDecodeInternalDecode(json.decode(js))
end

Utils.TableCopy = function(t)
  local copy = {}
  for k,v in pairs(t) do
    if type(v) == "table" then
      copy[k] = Utils.TableCopy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

Utils.TableCount = function(t)
  local c = 0
  for k,v in pairs(t) do
    c = c + 1
  end
  return c
end

Utils.PrintT = function(t) 
  local print_r_cache={}
  local function sub_print_r(t,indent)
      if (print_r_cache[tostring(t)]) then
          print(indent.."*"..tostring(t))
      else
          print_r_cache[tostring(t)]=true
          if (type(t)=="table") then
              for pos,val in pairs(t) do
                  if (type(val)=="table") then
                      print(indent.."["..pos.."] => "..tostring(t).." {")
                      sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                      print(indent..string.rep(" ",string.len(pos)+6).."}")
                  else
                      print(indent.."["..pos.."] => "..tostring(val))
                  end
              end
          else
              print(indent..tostring(t))
          end
      end
  end
  sub_print_r(t,"  ")
end

Utils.Log = function(...)
  print(string.format("[%s]",Protected.ResourceName),...)
end

Utils.LoadModel = function(hash)
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0) end
end

Utils.CreateBlip = function(opts)
  local blip = AddBlipForCoord(opts.location.x,opts.location.y,opts.location.z)

  SetBlipSprite               (blip, (opts.sprite or 1))
  SetBlipColour               (blip, (opts.color or 4))
  SetBlipScale                (blip, (opts.scale or 0.8))
  SetBlipDisplay              (blip, (opts.display or 3))
  SetBlipAsShortRange         (blip, (opts.shortRange or false))
  SetBlipHighDetail           (blip, (opts.highDetail or true))
  BeginTextCommandSetBlipName ("STRING")
  AddTextComponentString      (opts.text)
  EndTextCommandSetBlipName   (blip)

  return blip
end

Utils.RemoveBlip = function(blipId)
  RemoveBlip(blipId)
end

Utils.AddMarkerToRenderList = function(name,opts)
  if not name  or opts then return; end
  local marker = {
    name = name,
    type = "marker",
    opts = opts
  }
  table.insert(Utils.RenderList,marker)
  return marker
end

Utils.RemoveMarkerFromRenderList = function(opts)
  for k,v in ipairs(Utils.RenderList) do
    if v == opts then
      table.remove(Utils.RenderList,k)
      return
    end
  end
end

Utils.AddDrawTextToRenderList = function(name,opts)
  if not name or not opts then return; end
  local drawText = {
    name = name,
    type = "drawText",
    opts = opts
  }
  table.insert(Utils.RenderList,drawText)
  return drawText
end

Utils.RemoveDrawTextFromRenderList = function(opts)
  for k,v in ipairs(Utils.RenderList) do
    if v == opts then
      table.remove(Utils.RenderList,k)
      return
    end
  end
end

Utils.RotateVectorFlat = function(vec,heading) 
  if type(vec) == "table" then
    vec = vector3(vec.x or 0.0,vec.y or 0.0,vec.z or 0.0)
  end

  heading = heading / 57.2958
  local cos = math.cos(heading)
  local sin = math.sin(heading)
  if type(vec) == "vector4" then
    return vector4(cos*vec.x-sin*vec.y,sin*vec.x+cos*vec.y,vec.z,vec.w)
  elseif type(vec) == "vector3" then
    return vector3(cos*vec.x-sin*vec.y,sin*vec.x+cos*vec.y,vec.z)
  elseif type(vec) == "vector2" then
    return vector2(cos*vec.x-sin*vec.y,sin*vec.x+cos*vec.y)
  end
end

Utils.HandleRenderList = function()
  local rendered = false
  local pos = GetEntityCoords(PlayerPedId())
  for k,v in ipairs(Utils.RenderList) do
    if v.type == "marker" then
      local dist = #(v.opts.location.xyz - pos)
      if dist < v.opts.renderDist then
        Utils.DrawMarker(v.opts)
        rendered = true
      end
    elseif v.type == "drawText" then
      local dist = #(v.opts.location.xyz - pos)
      if dist < v.opts.renderDist then
        if dist < v.opts.interactDist then
          v.opts.text = string.format("%s %s",v.opts.interactText,v.opts.drawText)
          if IsControlJustPressed(0,v.opts.interactControl) then
            v.opts.onInteract(v)
          end
        else
          v.opts.text = v.opts.drawText
        end
        Utils.DrawText3D(v.opts)
        rendered = true
      end
    elseif v.type == "helpText" then
      local dist = #(v.opts.location.xyz - pos)
      if not v.opts.renderDist or dist < v.opts.renderDist then
        Utils.ShowHelpNotification(v.opts.text)
        rendered = true
      end
    end
  end
  return rendered
end

Utils.CreateCamera = function(typeof,pos,rot,render,pointAt)
  local camera = CreateCamWithParams(typeof, pos.x,pos.y,pos.z, 0, 0, 0, 50 * 1.0)

  SetCamCoord(camera,pos.x,pos.y,pos.z)
  SetCamRot(camera,rot.x,rot.y,rot.z,2)

  if render then
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, false)
  end

  if pointAt then
    PointCamAtEntity(camera,pointAt)
  end

  return camera
end

Utils.DrawMarker = function(opts)
  if not opts.location or not opts.location.x or not opts.location.y or not opts.location.z then return; end
  DrawMarker(
    opts.type or 0,
    opts.location.x,opts.location.y,opts.location.z, 
    opts.direction and opts.direction.x or 1.0, opts.direction and opts.direction.y or 0.0, opts.direction and opts.direction.z or 0.0,
    opts.rotation and opts.rotation.x or 1.0, opts.rotation and opts.rotation.y or 0.0, opts.rotation and opts.rotation.z or 0.0,
    opts.scale and opts.scale.x or 1.0, opts.scale and opts.scale.y or 1.0, opts.scale and opts.scale.z or 1.0,
    opts.red or 255,
    opts.green or 255,
    opts.blue or 255, 
    opts.alpha or 255,
    opts.bobUpAndDown or false,
    opts.faceCamera == nil or opts.faceCamera,
    opts.p19 or 2,
    opts.rotate or false
  )
end

Utils.ShowNotification = function(msg)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(msg)
  DrawNotification(false, true)
end

Utils.ShowHelpNotification = function(msg)
  AddTextEntry('furniHelp', msg)
  DisplayHelpTextThisFrame('furniHelp', false)
end

Utils.DrawText3D = function(opts)
  local coords = vector3(opts.location.x,opts.location.y,opts.location.z)
  local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
  local camCoords      = GetGameplayCamCoords()
  local dist           = GetDistanceBetweenCoords(camCoords, coords.x, coords.y, coords.z, true)
  local size           = size

  local size  = opts.size or 1
  local scale = (size / dist) * 2
  local fov   = (1 / GetGameplayCamFov()) * 100
  scale = scale * fov

  if onScreen then
    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(opts.font or 1)
    SetTextColour(opts.red or 255, opts.green or 255, opts.blue or 255, opts.alpha or 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)

    AddTextComponentString(opts.text)
    DrawText(x, y)
  end
end

if IsDuplicityVersion() then
  Utils.TriggerClientEvent = function(name,source,...)
    local eventName = string.format("%s:%s",Protected.ResourceName,name)
    TriggerClientEvent(eventName,source,...)

    if Config.Debug then
      Utils.Log(string.format("Triggering client event: %s (%i).",eventName,source))
    end
  end

  Utils.GetDatabaseName = function()
    local dbconvar = GetConvar('mysql_connection_string', 'Empty')

    if not dbconvar or dbconvar == "Empty" then 
      return false
    else
      local strStart,strEnd = string.find(dbconvar, "database=")
      if not strStart or not strEnd then
        local oStart,oEnd = string.find(dbconvar,"mysql://")
        if not oStart or not oEnd then
          return false
        else
          local hostStart,hostEnd = string.find(dbconvar,"@",oEnd)
          local dbStart,dbEnd = string.find(dbconvar,"/",hostEnd+1)
          local eStart,eEnd = string.find(dbconvar,"?")
          local _end = (eEnd and eEnd-1 or dbconvar:len())
          local dbName = string.sub(dbconvar, dbEnd + 1, _end) 
          return dbName
        end
      else
        local dbStart,dbEnd = string.find(dbconvar,";",strEnd)
        local dbName = string.sub(dbconvar, strEnd + 1, (dbEnd and dbEnd-1 or dbconvar:len())) 
        return dbName
      end    
    end
  end
else 
  Utils.TriggerServerEvent = function(name,...)
    local eventName = string.format("%s:%s",Protected.ResourceName,name)
    TriggerServerEvent(eventName,...)

    if Config.Debug then
      Utils.Log(string.format("Triggering server event: %s.",eventName))
    end
  end
end

Utils.RegisterNetEvent = function(name,ref)
  local eventName = string.format("%s:%s",Protected.ResourceName,name)
  RegisterNetEvent(eventName)
  if Config.Debug then
    Utils.Log(string.format("Net event %s registered.",eventName))
    AddEventHandler(eventName,function(...)
      Utils.Log(string.format("Net event %s triggered.",eventName))
      ref(...)
    end)
  else
    AddEventHandler(eventName,ref)
  end
end

Utils.RegisterEvent = function(name,ref)
  local eventName = string.format("%s:%s",Protected.ResourceName,name)
  AddEventHandler(eventName,ref)
end

Utils.InitESX = function(cb)
  local eventName = (IsDuplicityVersion() and Config.EsxEvents.getServer or Config.EsxEvents.getClient)
  TriggerEvent(eventName,function(esx)
    ESX = esx

    if Config.Debug then
      Utils.Log("Retrieved ESX object sucessfully.")
    end

    if cb then
      cb()
    end
  end)
end

Utils.DisableControlActions = function(...)
  local c = select("#",...)
  for i=1,c,1 do
    local control = select(i,...)
    DisableControlAction(0,control,true)
  end
end

Utils.DrawEntityBoundingBox = function(entity,r,g,b,a)
  local box = Utils.GetEntityBoundingBox(entity)
  Utils.DrawBoundingBox(box,r,g,b,a)
end

Utils.GetEntityBoundingBox = function(entity)
  local min,max = GetModelDimensions(GetEntityModel(entity))
  local pad = 0.001

  return {
    [1] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad),
    [2] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad),
    [3] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad),
    [4] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad),

    [5] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, max.z + pad),
    [6] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, max.z + pad),
    [7] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, max.z + pad),
    [8] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, max.z + pad),
  }
end

Utils.Get2DEntityBoundingBox = function(entity)
  local min,max = GetModelDimensions(GetEntityModel(entity))
  local pad = 0.001

  return {
    [1] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad),
    [2] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad),
    [3] = GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad),
    [4] = GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad),
  }
end

Utils.DrawBoundingBox = function(box,r,g,b,a)
  local polyMatrix = Utils.GetBoundingBoxPolyMatrix(box)
  local edgeMatrix = Utils.GetBoundingBoxEdgeMatrix(box)

  Utils.DrawPolyMatrix(polyMatrix,r,g,b,a)
  Utils.DrawEdgeMatrix(edgeMatrix,r,g,b,a)
end

Utils.GetBoundingBoxPolyMatrix = function(box)
   return {
    [1]  = {[1] = box[3],  [2] = box[2],  [3] = box[1]},
    [2]  = {[1] = box[4],  [2] = box[3],  [3] = box[1]},

    [3]  = {[1] = box[5],  [2] = box[6],  [3] = box[7]},
    [4]  = {[1] = box[5],  [2] = box[7],  [3] = box[8]},

    [5]  = {[1] = box[3],  [2] = box[4],  [3] = box[7]},
    [6]  = {[1] = box[8],  [2] = box[7],  [3] = box[4]},

    [7]  = {[1] = box[1],  [2] = box[2],  [3] = box[5]},
    [8]  = {[1] = box[6],  [2] = box[5],  [3] = box[2]},

    [9]  = {[1] = box[2],  [2] = box[3],  [3] = box[6]},
    [10] = {[1] = box[3],  [2] = box[7],  [3] = box[6]},

    [11] = {[1] = box[5],  [2] = box[8],  [3] = box[4]},
    [12] = {[1] = box[5],  [2] = box[4],  [3] = box[1]},
   }
end

Utils.GetBoundingBoxEdgeMatrix = function(box)
   return {
    [1]  = {[1] = box[1], [2] = box[2]},
    [2]  = {[1] = box[2], [2] = box[3]},
    [3]  = {[1] = box[3], [2] = box[4]},
    [4]  = {[1] = box[4], [2] = box[1]},

    [5]  = {[1] = box[5], [2] = box[6]},
    [6]  = {[1] = box[6], [2] = box[7]},
    [7]  = {[1] = box[7], [2] = box[8]},
    [8]  = {[1] = box[8], [2] = box[5]},

    [9]  = {[1] = box[1], [2] = box[5]},
    [10] = {[1] = box[2], [2] = box[6]},
    [11] = {[1] = box[3], [2] = box[7]},
    [12] = {[1] = box[4], [2] = box[8]},
   }
end

Utils.DrawPolyMatrix = function(polyCollection,r,g,b,a)
  for k=1,#polyCollection,1 do
    local v = polyCollection[k]
    DrawPoly(v[1].x,v[1].y,v[1].z, v[2].x,v[2].y,v[2].z, v[3].x,v[3].y,v[3].z, r,g,b,a)
  end
end

Utils.DrawEdgeMatrix = function(linesCollection,r,g,b,a)
  for k=1,#linesCollection,1 do
    local v = linesCollection[k]
    DrawLine(v[1].x,v[1].y,v[1].z, v[2].x,v[2].y,v[2].z, r,g,b,a)
  end
end

Utils.DrawScaleform = function(id)
  DrawScaleformMovieFullscreen(id,255,255,255,255)
end

Utils.DisableControlAction = function(index)
  DisableControlAction(0,index,true)
end

Utils.CreateInstructional = function(controls)
  local Scaleforms = exports["meta_libs"]:Scaleforms()
  if not Scaleforms then
    error("meta_libs not present.",1)
  else
    local scaleform = Scaleforms.LoadMovie('INSTRUCTIONAL_BUTTONS')

    Scaleforms.PopVoid(scaleform,'CLEAR_ALL')
    Scaleforms.PopInt(scaleform,'SET_CLEAR_SPACE',200) 

    for i=1,#controls,1 do
      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(i-1)

      for k=1,#controls[i].codes,1 do
        ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, controls[i].codes[k], true))
      end

      BeginTextCommandScaleformString("STRING")
      AddTextComponentScaleform(controls[i].label)
      EndTextCommandScaleformString()
      PopScaleformMovieFunctionVoid()
    end

    Scaleforms.PopVoid(scaleform,'DRAW_INSTRUCTIONAL_BUTTONS')

    return scaleform
  end
end

Utils.GetControls = function(...)
  local res = {}
  local count = select("#",...)
  
  for i=1,count,1 do
    local controlIndex = select(i,...)
    local cameraControl = Config.ActionControls[controlIndex]
    table.insert(res,cameraControl)
  end

  return res
end
  
Utils.HandleFlyCam = function(cam,boundPos,boundDist)
  local camPos = GetCamCoord(cam)
  local camRot = GetCamRot(cam,2)

  local frameTime = GetFrameTime()

  local controls = Config.ActionControls
  local camOpts = Config.CameraOptions

  local mouseX = GetDisabledControlNormal(0,1)
  local mouseY = GetDisabledControlNormal(0,2)
  local right,fwd,up,pos = GetCamMatrix(cam)  

  if IsControlJustPressed(0,44) or IsDisabledControlPressed(0,44) then
    camPos = camPos + (up * (camOpts.climbSpeed * frameTime))
    didMove = true
  elseif IsControlJustPressed(0,46) or IsDisabledControlPressed(0,46) then
    camPos = camPos - (up * (camOpts.climbSpeed * frameTime))
    didMove = true
  end

  if IsControlJustPressed(0,32) or  IsDisabledControlPressed(0,32) then
    camPos = camPos + (fwd * (camOpts.moveSpeed * frameTime))
    didMove = true
  elseif IsControlJustPressed(0,33) or  IsDisabledControlPressed(0,33) then
    camPos = camPos - (fwd * (camOpts.moveSpeed * frameTime))
    didMove = true
  end

  if IsControlJustPressed(0,35) or  IsDisabledControlPressed(0,35) then
    camPos = camPos + (right * (camOpts.moveSpeed * frameTime))
    didMove = true
  elseif IsControlJustPressed(0,34) or  IsDisabledControlPressed(0,34) then
    camPos = camPos - (right * (camOpts.moveSpeed * frameTime))
    didMove = true
  end

  if mouseY ~= 0.0 then
    local x = math.max(-80.0,math.min(80.0,camRot.x - (mouseY * camOpts.lookSpeedX * frameTime)))

    camRot = vector3(x,camRot.y,camRot.z)
    didRot = true
  end
  
  if mouseX ~= 0.0 then
    camRot = vector3(camRot.x,camRot.y,camRot.z - (mouseX * camOpts.lookSpeedY * frameTime))
    didRot = true
  end

  if didMove then
    SetCamCoord(cam,camPos)
  end

  if didRot then
    SetCamRot(cam,camRot,2)
  end

  if boundPos and boundDist then
    local dist = #(camPos - boundPos)

    if dist > boundDist then
      local boundDir = norm(camPos - boundPos)
      camPos = boundPos + (boundDir * boundDist)
      SetCamCoord(cam,camPos)
    end
  end

  return camPos,camRot
end

Utils.DestroyFlyCam = function(cam)
  SetCamActive(cam, false)
  DestroyCam(cam)
  ClearFocus()
  RenderScriptCams(false, false, 0)
end

Utils.AddOfflineMoney = function(identifier,accountName,amount)
  if Config.EsxVersion == 1.3 then
    MySQL.Async.execute("SELECT * FROM users WHERE identifier=@identifier",{
      ['@identifier'] = identifier
    },function(res)
      local accounts = json.decode(res[1].accounts)
      accounts[accountName] = accounts[accountName] + amount
      MySQL.Async.execute("UPDATE users SET accounts=@accounts WHERE identifier=@identifier",{
        ['@accounts'] = json.encode(accounts)
      })
    end)
  else
    MySQL.Async.execute("UPDATE user_accounts SET money = money + @amount WHERE identifier=@identifier AND name=@name",{
      ['@amount'] = amount,
      ['@identifier'] = identifier,
      ['@name'] = accountName
    })
  end
end

Utils.ScreenToWorld = function(ent)
  local camRot = GetGameplayCamRot(0)
  local camPos = GetGameplayCamCoord()
  local posX = GetControlNormal(0, 239)
  local posY = GetControlNormal(0, 240)
  local cursor = vector2(posX, posY)
  local cam3DPos, forwardDir = Utils.ScreenRelToWorld(camPos, camRot, cursor)
  local direction = camPos + forwardDir * 50.0
  local rayHandle = StartShapeTestRay(cam3DPos.x,cam3DPos.y,cam3DPos.z, direction.x,direction.y,direction.z, -1, ent or 0, 4)
  local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
  return hit,endCoords,entityHit,surfaceNormal
end
 
Utils.ScreenRelToWorld = function(camPos, camRot, cursor)
  local camForward = Utils.RotationToDirection(camRot)
  local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
  local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
  local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
  local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
  local camRight = Utils.RotationToDirection(rotRight) - Utils.RotationToDirection(rotLeft)
  local camUp = Utils.RotationToDirection(rotUp) - Utils.RotationToDirection(rotDown)
  local rollRad = -(camRot.y * math.pi / 180.0)
  local camRightRoll = camRight * math.cos(rollRad) - camUp * math.sin(rollRad)
  local camUpRoll = camRight * math.sin(rollRad) + camUp * math.cos(rollRad)
  local point3DZero = camPos + camForward * 1.0
  local point3D = point3DZero + camRightRoll + camUpRoll
  local point2D = Utils.World3DToScreen2D(point3D)
  local point2DZero = Utils.World3DToScreen2D(point3DZero)
  local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
  local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
  local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
  local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
  return point3Dret, forwardDir
end
 
Utils.RotationToDirection = function(rotation)
  local x = rotation.x * math.pi / 180.0
  local z = rotation.z * math.pi / 180.0
  local num = math.abs(math.cos(x))
  return vector3((-math.sin(z) * num), (math.cos(z) * num), math.sin(x))
end
 
Utils.World3DToScreen2D = function(pos)
  local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
  return vector2(sX, sY)
end

Utils.SelectPlayer = function()
  local plyPos = GetEntityCoords(PlayerPedId())

  local players = GetActivePlayers()
  local peds = {}
  for k,v in ipairs(players) do
    local ped = GetPlayerPed(v)
    if ped > 0 and DoesEntityExist(ped) then
      local dist = #(GetEntityCoords(ped) - plyPos)
      if dist <= 20.0 then
        table.insert(peds,ped)
      end
    end
  end

  local controls = Utils.GetControls("select_player","change_player","cancel")
  local sf = Utils.CreateInstructional(controls)

  local index = 1

  while true do
    if IsControlJustPressed(0,Config.ActionControls.cancel.codes[1]) then
      return
    end

    if IsControlJustPressed(0,Config.ActionControls.select_player.codes[1]) then
      return NetworkGetEntityOwner(peds[index])
    end

    if IsControlJustPressed(0,Config.ActionControls.change_player.codes[1]) then
      index = index + 1
      if index > #peds then
        index = 1
      end      
    elseif IsControlJustPressed(0,Config.ActionControls.change_player.codes[2]) then
      index = index - 1
      if index < 1 then
        index = #peds
      end      
    end

    Utils.DrawMarker({type = 0,scale = vector3(0.2,0.2,0.2),location = GetEntityCoords(peds[index]) + vector3(0.0,0.0,1.0)})
    Utils.DrawScaleform(sf)
    Wait(0)
  end
end

local Iterator = function(iFunc,nFunc,eFunc)
  local r = {}
  local i,ent = iFunc()
  while ent do
    r[#r+1] = ent
    ent     = nFunc(i)
  end
  eFunc(i)
  return r
end

Utils.GetAllPeds = function()
  return Iterator(FindFirstPed, FindNextPed, EndFindPed)
end

Utils.GetAllObjects = function()
  return Iterator(FindFirstObject, FindNextObject, EndFindObject)
end

Utils.GetAllVehicles = function()
  return Iterator(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

Utils.FindNthInString = function(str,comp,n)
  find = function(str,comp,start)
    return str:find(comp,start)
  end

  local st,fn
  for i=1,n,1 do
    st,fn = find(str,comp,fn and fn+1 or 0)
  end

  return st,fn
end

Utils.GetVehiclePlate = function(veh)
  return GetVehicleNumberPlateText(veh):gsub("^%s*(.-)%s*$", "%1")
end

Utils.AddOfflineMoney = function(identifier,amount)
  if Config.EsxVersion == 1.3 then
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier=@identifier",{
      ['@identifier'] = identifier
    },function(res)
      if res and res[1] then
        local accounts = json.decode(res[1].accounts)
        accounts[Config.AccountNames.bank] = accounts[Config.AccountNames.bank] + amount
        MySQL.Async.execute("UPDATE users SET accounts=@accounts WHERE identifier=@identifier",{
          ['@accounts'] = json.encode(accounts),
          ['@identifier'] = identifier
        })
      end
    end)
  else
    MySQL.Async.fetchAll("SELECT * FROM user_accounts WHERE identifier=@identifier AND name=@name",{
      ['@identifier'] = identifier,
      ['@name'] = Config.AccountNames.bank
    },function(res)
      if res and res[1] then
        local money = res[1].money + amount
        MySQL.Async.execute("UPDATE user_accounts SET money=@money WHERE identifier=@identifier AND name=@name",{
          ['@identifier'] = identifier,
          ['@name'] = Config.AccountNames.bank,
          ['@money'] = money
        })
      end
    end)
  end
end

Utils.NuiCallback = RegisterNUICallback

Utils.Thread = Citizen.CreateThread

Utils.ClampVecLength = function(v,maxLength)    
  local sqMagnitude = ((v.x * v.x) + (v.y * v.y) + (v.z * v.z))  

  if sqMagnitude > (maxLength * maxLength) then         
    return Utils.VecNorm(v) * maxLength   
  end    

  return v 
end  

Utils.VecNorm = function(v)   
  local len = #v    

  if len == 1 then     
    return v   
  elseif len > 1e-5 then         
    return v / len
  else         
    return vector3(0,0,0)   
  end  
end 

Utils.GetCoordsInFrontOfCam = function(...)   
  local unpack = table.unpack   
  local inTable = {...}   
  local cam = GetRenderingCam()
  local coords,direction 
  
  if cam <= 0 then
    coords = GetGameplayCamCoord()
    direction = Utils.RotationToDirection()  
  else
    coords = GetCamCoord(cam)
    direction = Utils.RotationToDirection(GetCamRot(cam,2))
  end  

  local retTable = {}    

  if ( #inTable == 0 ) or ( inTable[1] < 0.000001 ) then 
    inTable[1] = 0.000001 
  end    

  for k,distance in pairs(inTable) do     
    if ( type(distance) == "number" ) then       
      if ( distance == 0 ) then         
        retTable[k] = coords       
      else         
        retTable[k] = vector3( coords.x + ( distance*direction.x ), coords.y + ( distance*direction.y ), coords.z + ( distance*direction.z ) )       
      end     
    end   
  end    

  return unpack(retTable) 
end  

Utils.RotationToDirection = function(rot)   
  if ( rot == nil ) then 
    rot = GetGameplayCamRot(2)
  end   

  local rotZ = rot.z * ( 3.141593 / 180.0 )   
  local rotX = rot.x * ( 3.141593 / 180.0 )   
  local c = math.cos(rotX)   
  local multXY = math.abs(c)   
  local res = vector3( ( math.sin(rotZ) * -1 )*multXY, math.cos(rotZ)*multXY, math.sin(rotX) )   

  return res 
end  