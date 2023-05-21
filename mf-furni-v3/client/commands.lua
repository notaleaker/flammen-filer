local getFlatVector = function(objPoint,interiorPoint,interiorHeading)
  local relPoint = objPoint - interiorPoint
  local inverseHeading = -interiorHeading
  return Utils.RotateVectorFlat(relPoint,inverseHeading)
end

RegisterCommand('furni:exportDefault',function()
  if not insideHouse 
  or #insideHouse.furniture.inside <= 0 
  or insideHouse.shell.heading ~= 0.0
  then
    Utils.ShowNotification("Invalid export attempt, ensure inside house and shell heading = 0.0.")
    return
  end

  local flatFurni = {}

  for i=1,#insideHouse.furniture.inside do
    local f = insideHouse.furniture.inside[i]
    local flatPos = getFlatVector(f.position,insideHouse.shell.position,insideHouse.shell.heading)

    local head = insideHouse.shell.heading
    local zRot = f.rotation.z

    if head > zRot then
      local diff = head - zRot
      zRot = 360.0 - diff
    else
      zRot = zRot - head
    end

    table.insert(flatFurni,{
      model = f.model,
      label = f.label,
      offset = flatPos,
      rotation = vector3(f.rotation.x,f.rotation.y,zRot),
      rotationDirection = 2,
      freeze = true
    })
  end

  exports['mf-housing-v3']:Copy(json.encode(flatFurni))
  Utils.ShowNotification("Stringified furni copied to clipboard.")
end)