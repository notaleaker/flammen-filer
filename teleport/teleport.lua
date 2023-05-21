







key_to_teleport = 38

Teleport_Vehicles = true

positions = {
    --{{1867.42, 3666.11, 32.80, 0}, {1863.09, 3673.94, 33.1, 0},{36,237,157}, "First Teleport"}, vector4(891.356, -3246.247, -98.27505, 90.00326)
    {{-1266.6490, -2983.1531, -48.4897, 328.5},{-1136.4772, -3385.9446, 13.9401, 180.1},{255, 157, 0}, "Hanger"}, -- vector4(-3030.644, 3334.113, 10.13117, 273.3925)
}

-----------------------------------------------------------------------------
-------------------------DO NOT EDIT BELOW THIS LINE-------------------------
-----------------------------------------------------------------------------

local player = GetPlayerPed(-1)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        local player = GetPlayerPed(-1)
        local playerLoc = GetEntityCoords(player)

        for _,location in ipairs(positions) do
            teleport_text = location[4]
            loc1 = {
                x=location[1][1],
                y=location[1][2],
                z=location[1][3],
                heading=location[1][4]
            }
            loc2 = {
                x=location[2][1],
                y=location[2][2],
                z=location[2][3],
                heading=location[2][4]
            }
            Red = 50
            Green = 50
            Blue = 204


            if CheckPos(playerLoc.x, playerLoc.y, playerLoc.z, loc1.x, loc1.y, loc1.z, 2) then 
                TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk [E] For at forlade hangeren")
                
                if IsControlJustReleased(1, key_to_teleport) then
                    if IsPedInAnyVehicle(player, true) and Teleport_Vehicles == true then
                        SetEntityCoords(GetVehiclePedIsUsing(player), loc2.x, loc2.y, loc2.z)
                        SetEntityHeading(GetVehiclePedIsUsing(player), 328.1)
                    else
                        SetEntityCoords(player, loc2.x, loc2.y, loc2.z)
                        SetEntityHeading(player, 328.1)
                    end
                end
			elseif CheckPos(playerLoc.x, playerLoc.y, playerLoc.z, loc2.x, loc2.y, loc2.z, 2) then
                TriggerEvent('cd_drawtextui:ShowUI', 'show', "Tryk [E] For at tilgåhangeren")

                if IsControlJustReleased(1, key_to_teleport) then
					TriggerEvent('cd_drawtextui:HideUI')
                    if IsPedInAnyVehicle(player, true) and Teleport_Vehicles == true then
                        SetEntityCoords(GetVehiclePedIsUsing(player), loc1.x, loc1.y, loc1.z)
                        SetEntityHeading(GetVehiclePedIsUsing(player), 180.1)
                    else
                        SetEntityCoords(player, loc1.x, loc1.y, loc1.z)
                        SetEntityHeading(player, 180.1)
                    end
                end
			elseif CheckPos(playerLoc.x, playerLoc.y, playerLoc.z, loc2.x, loc2.y, loc2.z, 100) then
                TriggerEvent('cd_drawtextui:HideUI')
				DrawMarker(2, loc2.x, loc2.y, loc2.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Red, Green, Blue, 100, false, true, 2, false, false, false, false)
            elseif CheckPos(playerLoc.x, playerLoc.y, playerLoc.z, loc1.x, loc1.y, loc1.z, 100) then 
                TriggerEvent('cd_drawtextui:HideUI')
                DrawMarker(2, loc1.x, loc1.y, loc1.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Red, Green, Blue, 100, false, true, 2, false, false, false, false)
			end
        end
    end
end)

function CheckPos(x, y, z, cx, cy, cz, radius)
    local t1 = x - cx
    local t12 = t1^2

    local t2 = y-cy
    local t21 = t2^2

    local t3 = z - cz
    local t31 = t3^2

    return (t12 + t21 + t31) <= radius^2
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end