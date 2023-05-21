--blackBars = false
--local passengerDriveBy = true
local holstered = true
local taking = false
-- https://forum.fivem.net/t/how-to-disable-aggressive-npcs-in-sandy-shores/62822/2


--local ragdoll_chance = 0.0 -- edit this decimal value for chance of falling (e.g. 80% = 0.8    75% = 0.75    32% = 0.32)

-- code, not recommended to edit below this point
--[[Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100) -- check every 100 ticks, performance matters
		local ped = PlayerPedId()
		if IsPedOnFoot(ped) and not IsPedSwimming(ped) and (IsPedRunning(ped) or IsPedSprinting(ped)) and not IsPedClimbing(ped) and IsPedJumping(ped) and not IsPedRagdoll(ped) and GetPlayerSprintStaminaRemaining(PlayerId()) > 70 then
			local chance_result = math.random()
			if chance_result < ragdoll_chance then
				Citizen.Wait(600) -- roughly when the ped loses grip
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
				SetPedToRagdoll(ped, 5000, 1, 2)
			else
				Citizen.Wait(2000) -- cooldown before continuing
			end
		end
	end
end)]]

StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')

CreateThread(function()
    SetAudioFlag('DisableFlightMusic', true)
    SetAudioFlag('PoliceScannerDisabled', true)

    while true do
        local VehicleIsIn = GetVehiclePedIsIn(PlayerPedId(), false)
        if VehicleIsIn ~= 0 then
            SetUserRadioControlEnabled(false)
            if GetPlayerRadioStationName() ~= nil then
                SetVehRadioStation(VehicleIsIn, "OFF")
            end
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        SetVehicleModelIsSuppressed(`blimp`, true)
        SetVehicleModelIsSuppressed(`blimp2`, true)
        SetVehicleModelIsSuppressed(`blimp3`, true)

        DisablePlayerVehicleRewards(PlayerId())

        if IsControlJustReleased(1, 20) then
            ClearPedTasks(PlayerPedId())
        end

        Wait(0)
    end
end)

local relationshipTypes = {
	`GANG_1`,
	`GANG_2`,
	`GANG_9`,
	`GANG_10`,
	`AMBIENT_GANG_LOST`,
	`AMBIENT_GANG_MEXICAN`,
	`AMBIENT_GANG_FAMILY`,
	`AMBIENT_GANG_BALLAS`,
	`AMBIENT_GANG_MARABUNTE`,
	`AMBIENT_GANG_CULT`,
	`AMBIENT_GANG_SALVA`,
	`AMBIENT_GANG_WEICHENG`,
	`AMBIENT_GANG_HILLBILLY`,
	`DEALER`,
	`COP`,
	`PRIVATE_SECURITY`,
	`SECURITY_GUARD`,
	`ARMY`,
	`MEDIC`,
	`FIREMAN`,
	`HATES_PLAYER`,
	`NO_RELATIONSHIP`,
	`SPECIAL`,
	`MISSION2`,
	`MISSION3`,
	`MISSION4`,
	`MISSION5`,
	`MISSION6`,
	`MISSION7`,
	`MISSION8`
}

local weapons = {
	`WEAPON_PISTOL`,
	`WEAPON_COMBATPISTOL`,
	`WEAPON_STUNGUN`,
    `WEAPON_PISTOL50`,
	`WEAPON_NIGHTSTICK`,
	`WEAPON_FLASHLIGHT`,
	`WEAPON_FIREEXTINGUISHER`,
	`WEAPON_FLARE`,
	`WEAPON_SNSPISTOL`,
	`WEAPON_MACHINEPISTOL`,
	`WEAPON_KNIFE`,
	`WEAPON_KNUCKLE`,
	`WEAPON_HAMMER`,
	`WEAPON_BAT`,
	`WEAPON_GOLFCLUB`,
	`WEAPON_CROWBAR`,
	`WEAPON_BOTTLE`,
	`WEAPON_DAGGER`,
	`WEAPON_HATCHET`,
	`WEAPON_MACHETE`,
	`WEAPON_SWITCHBLADE`,
	`WEAPON_PROXMINE`,
	`WEAPON_BZGAS`,
	`WEAPON_SMOKEGRENADE`,
	`WEAPON_MOLOTOV`
}

CreateThread(function()
	while true do
		for i = 1, #relationshipTypes do
			SetRelationshipBetweenGroups(1, `PLAYER`, relationshipTypes[i]) -- could be removed
			SetRelationshipBetweenGroups(1, relationshipTypes[i], `PLAYER`)
		end

        Wait(5000)
	end
end)

CreateThread(function()
    for i = 1, 255 do
        Citizen.InvokeNative(0xDC0F817884CDD856, i, false)
    end

    -- Other stuff normally here, stripped for the sake of only scenario stuff
    local SCENARIO_TYPES = {
        "WORLD_VEHICLE_MILITARY_PLANES_SMALL", -- Zancudo Small Planes
        "WORLD_VEHICLE_MILITARY_PLANES_BIG" -- Zancudo Big Planes
    }

    local SCENARIO_GROUPS = {
        2017590552, -- LSIA planes
        2141866469, -- Sandy Shores planes
        1409640232, -- Grapeseed planes
        "ng_planes" -- Far up in the skies jets
    }

    local SUPPRESSED_MODELS = {
        `SHAMAL`, -- They spawn on LSIA and try to take off
        `LUXOR`, -- They spawn on LSIA and try to take off
        `LUXOR2`, -- They spawn on LSIA and try to take off
        `JET`, -- They spawn on LSIA and try to take off and land, remove this if you still want em in the skies
        `LAZER`, -- They spawn on Zancudo and try to take off
        `TITAN`, -- They spawn on Zancudo and try to take off
        `BARRACKS`, -- Regularily driving around the Zancudo airport surface
        `BARRACKS2`, -- Regularily driving around the Zancudo airport surface
        `CRUSADER`, -- Regularily driving around the Zancudo airport surface
        `RHINO`, -- Regularily driving around the Zancudo airport surface
        `AIRTUG`, -- Regularily spawns on the LSIA airport surface
        `RIPLEY` -- Regularily spawns on the LSIA airport surface
    }

	local Player = PlayerId()

    SetPlayerCanDoDriveBy(Player, false)

    local Pickups = {`PICKUP_WEAPON_BULLPUPSHOTGUN`, `PICKUP_WEAPON_ASSAULTSMG`, `PICKUP_VEHICLE_WEAPON_ASSAULTSMG`, `PICKUP_WEAPON_PISTOL50`, `PICKUP_VEHICLE_WEAPON_PISTOL50`, `PICKUP_AMMO_BULLET_MP`, `PICKUP_AMMO_MISSILE_MP`, `PICKUP_AMMO_GRENADELAUNCHER_MP`, `PICKUP_WEAPON_ASSAULTRIFLE`, `PICKUP_WEAPON_CARBINERIFLE`, `PICKUP_WEAPON_ADVANCEDRIFLE`, `PICKUP_WEAPON_MG`, `PICKUP_WEAPON_COMBATMG`, `PICKUP_WEAPON_SNIPERRIFLE`, `PICKUP_WEAPON_HEAVYSNIPER`, `PICKUP_WEAPON_MICROSMG`, `PICKUP_WEAPON_SMG`, `PICKUP_ARMOUR_STANDARD`, `PICKUP_WEAPON_RPG`, `PICKUP_WEAPON_MINIGUN`, `PICKUP_HEALTH_STANDARD`, `PICKUP_WEAPON_PUMPSHOTGUN`, `PICKUP_WEAPON_SAWNOFFSHOTGUN`, `PICKUP_WEAPON_ASSAULTSHOTGUN`, `PICKUP_WEAPON_GRENADE`, `PICKUP_WEAPON_MOLOTOV`, `PICKUP_WEAPON_SMOKEGRENADE`, `PICKUP_WEAPON_STICKYBOMB`, `PICKUP_WEAPON_PISTOL`, `PICKUP_WEAPON_COMBATPISTOL`, `PICKUP_WEAPON_APPISTOL`, `PICKUP_WEAPON_GRENADELAUNCHER`, `PICKUP_MONEY_VARIABLE`, `PICKUP_GANG_ATTACK_MONEY`, `PICKUP_WEAPON_STUNGUN`, `PICKUP_WEAPON_PETROLCAN`, `PICKUP_WEAPON_KNIFE`, `PICKUP_WEAPON_NIGHTSTICK`, `PICKUP_WEAPON_HAMMER`, `PICKUP_WEAPON_BAT`, `PICKUP_WEAPON_GOLFCLUB`, `PICKUP_WEAPON_CROWBAR`, `PICKUP_CUSTOM_SCRIPT`, `PICKUP_CAMERA`, `PICKUP_PORTABLE_PACKAGE`, `PICKUP_PORTABLE_CRATE_UNFIXED`, `PICKUP_PORTABLE_PACKAGE_LARGE_RADIUS`, `PICKUP_PORTABLE_FM_CONTENT_MISSION_ENTITY_SMALL`, `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR`, `PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS`, `PICKUP_PORTABLE_CRATE_UNFIXED_INAIRVEHICLE_WITH_PASSENGERS_UPRIGHT`, `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_WITH_PASSENGERS`, `PICKUP_PORTABLE_CRATE_FIXED_INCAR_WITH_PASSENGERS`, `PICKUP_PORTABLE_CRATE_FIXED_INCAR_SMALL`, `PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL`, `PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW`, `PICKUP_MONEY_CASE`, `PICKUP_MONEY_WALLET`, `PICKUP_MONEY_PURSE`, `PICKUP_MONEY_DEP_BAG`, `PICKUP_MONEY_MED_BAG`, `PICKUP_MONEY_PAPER_BAG`, `PICKUP_MONEY_SECURITY_CASE`, `PICKUP_VEHICLE_WEAPON_COMBATPISTOL`, `PICKUP_VEHICLE_WEAPON_APPISTOL`, `PICKUP_VEHICLE_WEAPON_PISTOL`, `PICKUP_VEHICLE_WEAPON_GRENADE`, `PICKUP_VEHICLE_WEAPON_MOLOTOV`, `PICKUP_VEHICLE_WEAPON_SMOKEGRENADE`, `PICKUP_VEHICLE_WEAPON_STICKYBOMB`, `PICKUP_VEHICLE_HEALTH_STANDARD`, `PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW`, `PICKUP_VEHICLE_ARMOUR_STANDARD`, `PICKUP_VEHICLE_WEAPON_MICROSMG`, `PICKUP_VEHICLE_WEAPON_SMG`, `PICKUP_VEHICLE_WEAPON_SAWNOFF`, `PICKUP_VEHICLE_CUSTOM_SCRIPT`, `PICKUP_VEHICLE_CUSTOM_SCRIPT_NO_ROTATE`, `PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW`, `PICKUP_VEHICLE_MONEY_VARIABLE`, `PICKUP_SUBMARINE`, `PICKUP_HEALTH_SNACK`, `PICKUP_PARACHUTE`, `PICKUP_AMMO_PISTOL`, `PICKUP_AMMO_SMG`, `PICKUP_AMMO_RIFLE`, `PICKUP_AMMO_MG`, `PICKUP_AMMO_SHOTGUN`, `PICKUP_AMMO_SNIPER`, `PICKUP_AMMO_GRENADELAUNCHER`, `PICKUP_AMMO_RPG`, `PICKUP_AMMO_MINIGUN`, `PICKUP_WEAPON_GUSENBERG`, `PICKUP_WEAPON_HATCHET`, `PICKUP_WEAPON_RAILGUN`, `PICKUP_WEAPON_REVOLVER`, `PICKUP_WEAPON_SWITCHBLADE`, `PICKUP_WEAPON_STONE_HATCHET`, `PICKUP_WEAPON_AUTOSHOTGUN`, `PICKUP_WEAPON_BATTLEAXE`, `PICKUP_WEAPON_COMPACTLAUNCHER`, `PICKUP_WEAPON_MINISMG`, `PICKUP_WEAPON_PIPEBOMB`, `PICKUP_WEAPON_POOLCUE`, `PICKUP_WEAPON_WRENCH`, `PICKUP_WEAPON_PROXMINE`, `PICKUP_WEAPON_HOMINGLAUNCHER`, `PICKUP_AMMO_HOMINGLAUNCHER`, `PICKUP_WEAPON_BULLPUPRIFLE_MK2`, `PICKUP_WEAPON_DOUBLEACTION`, `PICKUP_WEAPON_MARKSMANRIFLE_MK2`, `PICKUP_WEAPON_PUMPSHOTGUN_MK2`, `PICKUP_WEAPON_REVOLVER_MK2`, `PICKUP_WEAPON_SNSPISTOL_MK2`, `PICKUP_WEAPON_SPECIALCARBINE_MK2`, `PICKUP_WEAPON_RAYPISTOL`, `PICKUP_WEAPON_RAYCARBINE`, `PICKUP_WEAPON_RAYMINIGUN`, `PICKUP_WEAPON_PISTOLXM3`, `PICKUP_WEAPON_CANDYCANE`, `PICKUP_WEAPON_RAILGUNXM3`, `PICKUP_WEAPON_ASSAULTRIFLE_MK2`, `PICKUP_WEAPON_CARBINERIFLE_MK2`, `PICKUP_WEAPON_COMBATMG_MK2`, `PICKUP_WEAPON_HEAVYSNIPER_MK2`, `PICKUP_WEAPON_PISTOL_MK2`, `PICKUP_WEAPON_SMG_MK2`, `PICKUP_WEAPON_BOTTLE`, `PICKUP_WEAPON_SNSPISTOL`, `PICKUP_WEAPON_FLASHLIGHT`, `PICKUP_WEAPON_FLAREGUN`, `PICKUP_AMMO_FLAREGUN`, `PICKUP_WEAPON_CERAMICPISTOL`, `PICKUP_WEAPON_HAZARDCAN`, `PICKUP_WEAPON_NAVYREVOLVER`, `PICKUP_WEAPON_COMBATSHOTGUN`, `PICKUP_WEAPON_GADGETPISTOL`, `PICKUP_WEAPON_MILITARYRIFLE`, `PICKUP_WEAPON_MACHETE`, `PICKUP_WEAPON_MACHINEPISTOL`, `PICKUP_WEAPON_COMPACTRIFLE`, `PICKUP_WEAPON_DBSHOTGUN`, `PICKUP_WEAPON_COMBATPDW`, `PICKUP_WEAPON_KNUCKLE`, `PICKUP_WEAPON_MARKSMANPISTOL`, `PICKUP_PORTABLE_CRATE_FIXED_INCAR`, `PICKUP_WEAPON_EMPLAUNCHER`, `PICKUP_AMMO_EMPLAUNCHER`, `PICKUP_WEAPON_HEAVYRIFLE`, `PICKUP_WEAPON_PETROLCAN_SMALL_RADIUS`, `PICKUP_WEAPON_FERTILIZERCAN`, `PICKUP_WEAPON_STUNGUN_MP`, `PICKUP_WEAPON_HEAVYPISTOL`, `PICKUP_WEAPON_SPECIALCARBINE`, `PICKUP_WEAPON_METALDETECTOR`, `PICKUP_WEAPON_TACTICALRIFLE`, `PICKUP_WEAPON_PRECISIONRIFLE`, `PICKUP_WEAPON_BULLPUPRIFLE`, `PICKUP_WEAPON_DAGGER`, `PICKUP_WEAPON_VINTAGEPISTOL`, `PICKUP_WEAPON_FIREWORK`, `PICKUP_WEAPON_MUSKET`, `PICKUP_AMMO_FIREWORK`, `PICKUP_AMMO_FIREWORK_MP`, `PICKUP_WEAPON_HEAVYSHOTGUN`, `PICKUP_WEAPON_MARKSMANRIFLE`, `PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE`}
	for i=1, #Pickups do
		ToggleUsePickupsForPlayer(Player, Pickups[i], false)
    end

    for i = 1, #SCENARIO_TYPES do
        SetScenarioTypeEnabled(SCENARIO_TYPES[i], false)
    end

    for i = 1, #SCENARIO_GROUPS do
        SetScenarioGroupEnabled(SCENARIO_GROUPS[i], false)
    end

    while true do
        --[[RemoveAllPickupsOfType(0xDF711959) -- carbine rifle
        RemoveAllPickupsOfType(0xF9AFB48F) -- pistol
        RemoveAllPickupsOfType(0xA9355DCD) -- pumpshotgun
        RemoveAllPickupsOfType(0xD93F3079) -- Pistol i køretøj
        RemoveAllPickupsOfType(0xEA91B807) -- Pistol]]
        --local playerLocalisation = GetEntityCoords(PlayerPedId())

        --ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)

        for i = 1, #SUPPRESSED_MODELS do
            SetVehicleModelIsSuppressed(SUPPRESSED_MODELS[i], true)
        end

        Wait(100)
    end
end)

--[[local ragdoll = false
function setRagdoll(flag)
  ragdoll = flag
end
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if ragdoll then
      SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
    end
  end
end)]]

local IsRagdoll = false
local RagdollSwitch = false
local RagdollCounter = math.mininteger

local function RagdollPlus()
    if IsRagdoll then
        IsRagdoll = false
        RagdollSwitch = false
    else
        IsRagdoll = true
        local NewCounter = RagdollCounter + 1
        RagdollCounter += 1
        RagdollSwitch = false

        CreateThread(function()
            local Ped = PlayerPedId()
            SetPedToRagdoll(Ped, 150, 150, 0, false, false, false)
            while IsRagdoll do
                ResetPedRagdollTimer(Ped)
                Wait(25)
            end
        end)

        SetTimeout(350, function()
            if RagdollCounter == NewCounter then
                RagdollSwitch = true
            end
        end)
    end
end

local function RagdollMinus()
    if IsRagdoll and RagdollSwitch then
        IsRagdoll = false
        RagdollSwitch = false
    end
end

RegisterCommand('+ragdoll', RagdollPlus, false)

RegisterCommand('-ragdoll', RagdollMinus, false)

RegisterKeyMapping('+ragdoll', 'Toggle Ragdoll', 'keyboard', 'u')

local crouched = false

CreateThread( function()
    while true do
        DisableControlAction(0, 36, true) -- INPUT_DUCK

        if (IsDisabledControlJustPressed(0, 36)) then

            local ped = PlayerPedId()

            if (DoesEntityExist(ped) and not IsEntityDead(ped)) then

                if (not IsPauseMenuActive()) then
                    RequestAnimSet("move_ped_crouched")

                    while (not HasAnimSetLoaded("move_ped_crouched")) do
                        Wait(50)
                    end

                    if (crouched == true) then
                        TriggerEvent("HouseRobberies:Crouching", false)  -----#### AND HERE FOR WHEN FALSE.

                        ResetPedMovementClipset(ped, 0)
                        crouched = false
                    elseif (crouched == false) then
                        TriggerEvent("HouseRobberies:Crouching", true) ----#### WE HAVE ADDED THE TRIGGER EVENT HERE FOR WHEN CROUCHING IS TRUE

                        SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
                        crouched = true
                    end
                end
            end
        end

        Wait(0)
    end
end )

--[[ragdol = true
RegisterNetEvent("Ragdoll")
AddEventHandler("Ragdoll", function()
    print("fiwnfwin")
	if ( ragdol ) then
		setRagdoll(true)
		ragdol = false
	else
		setRagdoll(false)
		ragdol = true
	end
end)]]

--[[RegisterNetEvent("testclient")
AddEventHandler("testclient", function(link)
    xSound = exports.xsound
    Citizen.CreateThread(function()
        local pos = GetEntityCoords(PlayerPedId())
        xSound:PlayUrlPos("name",link,0.2,vector3(115.84216308594,-1285.6335449219,31.083185195923))
        --some links will not work cause to copyright or autor did not allowed to play video from iframe.
        xSound:Distance("name",20)

        -- Citizen.Wait(1000*30)
        -- xSound:Destroy("name")
    end)
end)]]

--[[CreateThread(function()
    while true do
 		if IsControlPressed(2, 303) then
 		    TriggerEvent("Ragdoll")
 		end
        Wait(100)
 	end
end)]]

--[[Citizen.CreateThread(function()
    while true do
        Citizen.Wait(750)
        for _, ped in ipairs(GetGamePool("CPed")) do
            SetPedDropsWeaponsWhenDead(ped, false)
        end
    end
end)]]

local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
--local oldval = false
--local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        local Ped = PlayerPedId()

        if not keyPressed then
            local PressedPoint, OnFoot = IsControlPressed(0, 29), IsPedOnFoot(Ped)
            if PressedPoint and not mp_pointing and OnFoot then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (PressedPoint and mp_pointing) or (not OnFoot and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end

        local MoveNetworkActive = IsTaskMoveNetworkActive(Ped)

        if MoveNetworkActive and not mp_pointing then
            stopPointing()
        end

        if MoveNetworkActive then
            if not IsPedOnFoot(Ped) then
                stopPointing()
            else
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = false
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(Ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, Ped, 7);
                nn,blocked,coords,coords = GetShapeTestResult(ray)

                SetTaskMoveNetworkSignalFloat(Ped, "Pitch", camPitch)
                SetTaskMoveNetworkSignalFloat(Ped, "Heading", camHeading * -1.0 + 1.0)
                SetTaskMoveNetworkSignalBool(Ped, "isBlocked", blocked)
                SetTaskMoveNetworkSignalBool(Ped, "isFirstPerson", GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)

            end
        end
    end
end)

local WeaponsParsed = {}

local HylstersParsedMale = {}
local HylstersParsedFemale = {}

local function hasHylster(ped)
    local DrawVar = GetPedDrawableVariation(ped, 7)
	if IsPedModel(ped, 1885233650) then
        return HylstersParsedMale[DrawVar] == true

		/*for i = 1, #Config.Holster.male do
			if Config.Holster.male[i] == DrawVar then
				return true
			end
		end*/
	else
        return HylstersParsedFemale[DrawVar] == true

		/*for i = 1, #Config.Holster.female do
			if Config.Holster.female[i] == DrawVar then
				return true
			end
		end*/
	end
end

local function DisableFiring()
    local Ped = PlayerPedId()
    while taking do
        DisablePlayerFiring(Ped, true)
        DisableControlAction(1, 140, true)
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)
        Wait(0)
    end
end

local function LoadAnimDict(Dict)
    RequestAnimDict(Dict)
	while not HasAnimDictLoaded(Dict) do
		Wait(0)
	end
end

CreateThread(function()
    for i = 1, #weapons do
        WeaponsParsed[weapons[i]] = true
    end

    for i = 1, #Config.Holster.male do
        HylstersParsedMale[Config.Holster.male[i]] = true
    end

    for i = 1, #Config.Holster.female do
        HylstersParsedFemale[Config.Holster.female[i]] = true
    end

	while true do
		local ped = PlayerPedId()
        if WeaponsParsed[GetSelectedPedWeapon(ped)] == true then
            if holstered and not hasHylster(ped) then
                if not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, true) then
                    LoadAnimDict('reaction@intimidation@1h')
                    TaskPlayAnim(ped, 'reaction@intimidation@1h', 'intro', 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
                    taking = true

                    CreateThread(DisableFiring)

                    Wait(2500)
                    taking = false

                    ClearPedTasks(ped)

                    Wait(100)
                    holstered = false
                end
            end
        else
            if not holstered and not hasHylster(ped) then
                if not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, true) then
                    LoadAnimDict('reaction@intimidation@1h')
                    TaskPlayAnim(ped, 'reaction@intimidation@1h', 'outro', 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
                    taking = true

                    CreateThread(DisableFiring)

                    Wait(1500)
                    taking = false

                    ClearPedTasks(ped)

                    holstered = true
                end
            end
        end
        Wait(0)
	end
end)

local IdleCameraDisabled = false

RegisterCommand('idlecam', function()
    IdleCameraDisabled = not IdleCameraDisabled
    DisableIdleCamera(IdleCameraDisabled)
    TriggerEvent('esx:showNotification', IdleCameraDisabled and 'Idle cam slået ~r~fra~s~.' or 'Idle cam slået ~g~til~s~.')
end, false)