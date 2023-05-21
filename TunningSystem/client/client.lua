ESX = nil
local myjob
local blips = {}
local nomidaberto
carroselected = nil
rodaatual = nil
rodaatual2 = nil
local cam = nil
local gameplaycam = nil
local focuson = false
local TunagensDefault = {}
local preco = 0
local multiplier = 1
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
	Wait(500)
	while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
	myjob = ESX.GetPlayerData().job
	Wait(1000)
	for i = 1, #Config.TunningLocations do
		local v = Config.TunningLocations[i]
		if v.blipmap then
			if (myjob.name == v.job or v.job == nil) or v.blipeveryone then
				blips[i] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
				SetBlipAsShortRange(blips[i], true)
				SetBlipSprite(blips[i], v.blipsprite)
				SetBlipScale(blips[i], 0.9)
				SetBlipColour(blips[i],17)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(v.name)
				EndTextCommandSetBlipName(blips[i])
			end
		end
	end
end)

RegisterNetEvent('TunningSystem:Used')
AddEventHandler('TunningSystem:Used', function(id,bool)
	Config.TunningLocations[id].used = bool
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	myjob = job
	for i = 1, #Config.TunningLocations do
		local v = Config.TunningLocations[i]
		if v.blipmap then
			if (myjob.name == v.job or v.job == nil) or v.blipeveryone then
				blips[i] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
				SetBlipAsShortRange(blips[i], true)
				SetBlipSprite(blips[i], v.blipsprite)
				SetBlipScale(blips[i], 0.9)
				SetBlipColour(blips[i],17)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(v.name)
				EndTextCommandSetBlipName(blips[i])
			else
				local j = blips[i]
				RemoveBlip(j)
				blips[i] = nil
			end
		end
	end
end)

function GetClosestVehicle(coords)
	local vehicles        = ESX.Game.GetVehicles()
	local closestDistance = -1
	local closestVehicle  = -1
	local coords          = coords

	if coords == nil then
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end
	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

		if closestDistance == -1 or closestDistance > distance then
			closestVehicle  = vehicles[i]
			closestDistance = distance
		end
	end
	return closestVehicle, closestDistance
end

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	while myjob == nil do
		Wait(100)
	end
	while true do
		local dormir = 2000
		local coords = GetEntityCoords(PlayerPedId())
		if nomidaberto == nil then
			for i = 1, #Config.TunningLocations do
				local v = Config.TunningLocations[i]
				if (myjob.name == v.job or v.job == nil) and not v.used then
					local distance = #(coords - v.coords)
					if distance <= Config.Range+2 then
						dormir = 500
						if distance <= Config.Range then
							dormir = 0
							DrawText3D(v.coords.x, v.coords.y, v.coords.z, "~r~E~w~ - Modify the Car")
							if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), false) then
								local veh, distance = GetClosestVehicle(v.coords)
								if DoesEntityExist(veh) and distance <= Config.Range then
									ESX.TriggerServerCallback("TunningSystem:Used", function(cb)
										if cb then
											while not Config.TunningLocations[i].used do
												Wait(0)
											end
											TunagensDefault = {}
											preco = 0
											while not NetworkHasControlOfEntity(veh) do
												Citizen.Wait(0)
											
												NetworkRequestControlOfEntity(veh)
											end
											carroselected = veh
											FreezeEntityPosition(carroselected,true)
											Wait(0)
											SetVehicleEngineOn(carroselected,true,true,false)
											nomidaberto = i
											multiplier = (v.howmuchtopay)/100
											local listado = false
											if Config.AllowVehicleExceptions then
												local vehname = GetName(carroselected)
												local mplus = Config.VehicleExceptions[vehname:lower()]
												if mplus then
													listado = true
													multiplier=mplus
												end
											end
											if Config.PricesByClass and not listado then
												local vehclass = GetVehicleClass(carroselected)
												local mplus = Config.ClassPrices[vehclass]
												if mplus then
													multiplier=mplus
												end
											end
											SetVehicleModKit(veh,0)
											local tabelainfo = ModsAvailable(veh)
											SetNuiFocus(true, true)
											focuson = true
											gameplaycam = GetRenderingCam()
											cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true,2)
											SendNUIMessage({
												action = "updateTotal",
												text = "Total: "..preco..Config.Currency,
											})
											SendNUIMessage({
												action = "openMenu",
												menuTable = tabelainfo,
											})
											SendNUIMessage({
												action = "showFreeUpButton",
											})
											Citizen.CreateThread(function()
												while nomidaberto do
													Wait(2000)
													local popocords = GetEntityCoords(veh)
													local coords = GetEntityCoords(PlayerPedId())
													if not DoesEntityExist(veh) or #(popocords - v.coords) >= 10.0 or #(coords - v.coords) >= 10.0 then
														ModelCancel(veh)
														break
													end
												end
											end)
										else
										
										end
									end,i,NetworkGetNetworkIdFromEntity(veh))
								end
							end
							break
						end
					end
				end
			end
		end
		Wait(dormir)
	end
end)

function ModelCancel(veh)
	if DoesEntityExist(veh) then
		while not NetworkHasControlOfEntity(veh) do
			Citizen.Wait(0)
		
			NetworkRequestControlOfEntity(veh)
		end
		CancelEverything()
	end
	TunagensDefault = {}
	preco = 0
	FreezeEntityPosition(carroselected,false)
	SetNuiFocus(false, false)
	focuson = false
	camControl("close")
	--ResetCam()
	TriggerServerEvent("TunningSystem:Used", nomidaberto)
	nomidaberto = nil
	menuatual = nil
	carroselected = nil
	SendNUIMessage({
		action = "close",
	})
end

function GetName(isveh)
	local model = GetEntityModel(isveh)
	local displaytext = GetDisplayNameFromVehicleModel(model)
	local name = displaytext
	return name
end

function AddToMenu(name,smenu,selected)
	local transla = Config.Translations[name]
	if transla == nil then
		transla = name
	end
	local addmen = {
		type = json.encode({tipo = name}),
		title = transla,
		src = "img/"..name..".png",
		subMenuTitle = Config.Translations["change"].." "..transla,
		subMenuSelected = selected,
		subMenu = smenu
	}
	return addmen
end

function AddToSubMenu(name,maxn,moto,sel)
	local transla = Config.Translations[name]
	if transla == nil then
		transla = name
	end
	local submenu = {}
	local somar = 0
	if sel then
		somar = 1
		submenu[1] = {
			type = json.encode({tipo = name, index = sel, moto = moto}),
			title = Config.Translations["def"]..": "..sel,
			src = "img/Default.png",
		}
	end
	local lel = 0
	if moto then
		lel = 1
	end
	for i = 1, maxn do
		submenu[i+somar] = {
			type = json.encode({tipo = name, index = i-lel, moto = moto}),
			title = transla.." "..i,
			src = "img/"..name..".png",
		}
	end
	return submenu
end

function isWheelType(type,numeromod)
	local types = Config.Wheels[type]
	local bool = false
	local wheel = 0
	local num = 0
	local wtype = GetVehicleWheelType(carroselected)
	if wtype == types then
		bool = true
		if numeromod == 23 then
			wheel = rodaatual
		else
			wheel = rodaatual2
		end
	end
	SetVehicleWheelType(carroselected,types)
	num = GetNumVehicleMods(carroselected,numeromod)
	SetVehicleWheelType(carroselected,wtype)
	return bool, wheel, num

end


function ModsAvailable(carro)
	local mods = {}
	TunagensDefault = {}
	preco = 0
	rodaatual = GetVehicleMod(carro,23)
	SetVehicleMod(carro,23, rodaatual,GetVehicleModVariation(carro,23))
	rodaatual2 = GetVehicleMod(carro,24)
	SetVehicleMod(carro,24, rodaatual2,GetVehicleModVariation(carro,24))
	mods[#mods+1],corprinc,corsec,pearltab,whlclrtab,dshclrtab,intclrtab = GetColors()
	TunagensDefault["corprinc"] = corprinc
	TunagensDefault["corsec"] = corsec
	TunagensDefault["pearltab"] = pearltab
	TunagensDefault["whlclrtab"] = whlclrtab
	TunagensDefault["dshclrtab"] = dshclrtab
	TunagensDefault["intclrtab"] = intclrtab
	mods[#mods+1],neonstable = GetNeons()
	TunagensDefault["neons"] = neonstable
	mods[#mods+1],smoketable = GetSmoke()
	TunagensDefault["smoke"] = smoketable
	local windssting = GetVehicleWindowTint(carro)
	if windssting < 0 then
		SetVehicleWindowTint(carro,0)
		windssting = GetVehicleWindowTint(carro)
	end
	mods[#mods+1] = AddToMenu("windtint",AddToSubMenu("windtint",6,false,windssting+1),windssting+1)
	TunagensDefault["windtint"] = windssting
	mods[#mods+1] = AddToMenu("plate",AddToSubMenu("plate",6,false,GetVehicleNumberPlateTextIndex(carro)+1),GetVehicleNumberPlateTextIndex(carro)+1)
	TunagensDefault["plate"] = GetVehicleNumberPlateTextIndex(carro)+1
	mods[#mods+1] = TurboMenu()
	local turbom = false
	if IsToggleModOn(carro,18) then
		turbom = true
	end
	TunagensDefault["turbo"] = turbom
	mods[#mods+1],headlighttable = HeadLight()
	TunagensDefault["headlight"] = headlighttable
	mods[#mods+1],tyrestable = GetTyres("Tyres Front")
	TunagensDefault["tyres"] = tyrestable
	if GetVehicleClass(carroselected) == 8 then
		SetVehicleWheelType(carroselected,6)
		--mods[#mods+1],tyrestable2 = GetTyres("Tyres Back")
		TunagensDefault["tyresb"] = tyrestable2
	end
	mods[#mods+1],tyresotable = GetTyresOptions()
	TunagensDefault["tyreso"] = tyresotable
	local extrasss,extratable = GetExtraOptions()
	if next(extrasss.subMenu,1) then
		mods[#mods+1] = extrasss
		TunagensDefault["extra"] = extratable
	end
	local livery = true
	for i=0,52 do
		for k,v in pairs(Config.TunningMods) do
			if v == i then
				if GetNumVehicleMods(carro, Config.TunningMods[k]) >= 1 and k ~= "Tyres Front" and k ~= "Tyres Back" and k ~= "Turbo" then
					local merdaselected = 999
					local vehmod = GetVehicleMod(carro,Config.TunningMods[k])+1
					TunagensDefault[k] = vehmod-1
					if vehmod >= 0 then
						merdaselected = vehmod
					end
					mods[#mods+1] = AddToMenu(k,AddToSubMenu(k,GetNumVehicleMods(carro, Config.TunningMods[k])+1,false,merdaselected+1),merdaselected+1)
					if k == "Livery" then
						livery = false
					end
				end
			end
		end
	end
	if livery then
		livery = GetVehicleLiveryCount(carro)
		if livery > -1 then
			local merdaselected = 999
			local vehmod = GetVehicleLivery(carro)
			TunagensDefault["Livery2"] = vehmod
			if vehmod >= 0 then
				merdaselected = vehmod
			end
			mods[#mods+1] = AddToMenu("Livery",AddToSubMenu("Livery2",livery,false,merdaselected+1),merdaselected+1)
		end
	end
	return mods
end

function getnameclr(id)
	local retornar = id
	for k in pairs(Config.ColoursExtra) do
		local clri = Config.ColoursExtra[k]
		if clri.id == id then
			retornar = clri.name
		end
	end
	return retornar
end

function AplicarMod(mod,index)
	local modindex = Config.TunningMods[mod]
	if modindex and mod ~= "Tyres Front" and mod ~= "Tyres Back" and mod ~= "Turbo" and mod ~= "Xenon" then
		local antigo = GetVehicleMod(carroselected,Config.TunningMods[mod])
		if modindex == 39 or modindex == 40 or modindex == 41 then
			SetVehicleDoorOpen(carroselected, 4, false, false)
		elseif modindex == 37 or modindex == 38 or modindex == 31 then
			SetVehicleDoorOpen(carroselected, 5, false, false)
			SetVehicleDoorOpen(carroselected, 0, false, false)
			SetVehicleDoorOpen(carroselected, 1, false, false)
		end
		SetVehicleMod(carroselected,modindex,index,false)
		if mod == "Horn" then
			StartVehicleHorn(carroselected, 5000, GetHashKey("HELDDDOWN"), false)
			Citizen.CreateThread(function()
				local tempo=0
				while tempo<=500 do
					tempo=tempo+1
					SetControlNormal(0,86,1.0) 
					Wait(0)
				end
			end)
		end
		AddMoneyDefault(mod,index,antigo)
	elseif mod == "neonsc" then
		index = index+2
		local neonsligado = false
		for i = 0, 3 do
			if IsVehicleNeonLightEnabled(carroselected,i) then
				neonsligado = true
			end
		end
		local wht = false
		if index >= 1 then
			wht = true
		end
		AddMoneyNotDefault(TunagensDefault["neons"].ligado,Config.TunningPrices["neons"],wht,neonsligado)
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(carroselected,i,index)
		end
		SendNUIMessage({
			action = "updateTotal",
			text = "Total: "..preco..Config.Currency,
		})
		if preco < 0 then
			ModelCancel(veh)
		end
		index = index-2
	elseif mod == "turbo" then
		local costum = true
		if IsToggleModOn(carroselected,18) then
			costum = false
		end
		AddMoneyNotDefault(TunagensDefault["turbo"],Config.TunningPrices["turbo"],costum,not costum)
		ToggleVehicleMod(carroselected,18,costum)
	elseif mod == "xenon" then
		local costum = true
		local wut = false
		if IsToggleModOn(carroselected,22) then
			wut = true
			costum = false
		end
		AddMoneyNotDefault(TunagensDefault["headlight"].ligado,Config.TunningPrices["xenon"],costum,wut)
		ToggleVehicleMod(carroselected,22,costum)
	elseif mod == "windtint" then
		local antigo = GetVehicleWindowTint(carroselected)
		AddMoneyNotDefault(TunagensDefault[mod],Config.TunningPrices[mod],index+1,antigo)
		SetVehicleWindowTint(carroselected,index+1)
	elseif mod == "plate" then
		local antigo = GetVehicleNumberPlateTextIndex(carroselected)
		AddMoneyNotDefault(TunagensDefault[mod]-2,Config.TunningPrices[mod],index,antigo-1)
		SetVehicleNumberPlateTextIndex(carroselected, index+1)
	elseif mod == "extra" then
		index=index+2
		local jatava = IsVehicleExtraTurnedOn(carroselected, index)
		local aplicar = 0
		local wht = true
		local wht2
		if jatava then
			aplicar = 1
			wht = nil
			wht2 = true
		end
		if aplicar == 1 then
			SetVehicleAutoRepairDisabled(carroselected,true)
		else
			SetVehicleAutoRepairDisabled(carroselected,false)
		end
		SetVehicleExtra(carroselected,index,aplicar)
		if jatava ~= IsVehicleExtraTurnedOn(carroselected, index) then
			AddMoneyNotDefault(TunagensDefault["extra"][index],Config.TunningPrices["extra"],wht,wht2)
		end
	elseif mod == "Livery2" then
		local antigo = GetVehicleLivery(carroselected)
		SetVehicleLivery(carroselected,index+1)
		AddMoneyDefault("Livery2",index+1,antigo)
	end
end

local menuatual

function AddMoneyDefault(mod,index,antigo)
	if index == TunagensDefault[mod] and index ~= antigo then
		preco = preco-(Config.TunningPrices[mod].base+(antigo+1)*Config.TunningPrices[mod].bylevel)*multiplier
	elseif antigo ~= index then
		if antigo ~= TunagensDefault[mod] then
			preco = preco-(Config.TunningPrices[mod].base+(antigo+1)*Config.TunningPrices[mod].bylevel)*multiplier
			preco = preco+(Config.TunningPrices[mod].base+(index+1)*Config.TunningPrices[mod].bylevel)*multiplier
		else
			preco = preco+(Config.TunningPrices[mod].base+(index+1)*Config.TunningPrices[mod].bylevel)*multiplier
		end
	end
	preco = math.floor(preco)
	SendNUIMessage({
		action = "updateTotal",
		text = "Total: "..preco..Config.Currency,
	})
	if preco < 0 then
		ModelCancel(veh)
	end
end

function AddMoneyNotDefault(default,price,index,antigo,teste,teste2)
	local somar1 = 0
	local somar2 = 0
	if type(antigo) == "number" then
		somar1 = (antigo+1)
	end
	if type(index) == "number" then
		somar2 = (index+1)
	end
	if teste2 then
		somar1 = (teste2+1)
	end
	if teste then
		somar2 = (teste+1)
	end
	if index == default and index ~= antigo then
		preco = preco-(price.base+(somar1)*price.bylevel)*multiplier
	elseif antigo ~= index then
		if antigo ~= default then
			preco = preco-(price.base+(somar1)*price.bylevel)*multiplier
			preco = preco+(price.base+(somar2)*price.bylevel)*multiplier
		else
			preco = preco+(price.base+(somar2)*price.bylevel)*multiplier
		end
	end
	preco = math.floor(preco)
	SendNUIMessage({
		action = "updateTotal",
		text = "Total: "..preco..Config.Currency,
	})
	if preco < 0 then
		ModelCancel(veh)
	end
end

function AddMoneyCorRGB(cor,tipo)
	local rantigo,gantigo,bantigo
	local cenas
	if tipo == "PrimaryRGBColor" then
		cenas = TunagensDefault["corprinc"]
		rantigo,gantigo,bantigo = GetVehicleCustomPrimaryColour(carroselected)
	elseif tipo == "SecondaryRGBColor" then
		cenas = TunagensDefault["corsec"]
		rantigo,gantigo,bantigo = GetVehicleCustomSecondaryColour(carroselected)
	elseif tipo == "NeonsRGBColor" then
		cenas = TunagensDefault["neons"]
		rantigo,gantigo,bantigo = GetVehicleNeonLightsColour(carroselected)
	elseif tipo == "SmokeRGBColor" then
		cenas = TunagensDefault["smoke"]
		rantigo,gantigo,bantigo = GetVehicleTyreSmokeColor(carroselected)
	end
	local if1 = (cenas.r == cor.r and cenas.g == cor.g and cenas.b == cor.b)
	local if2 = (rantigo ~= cor.r or gantigo ~= cor.g or bantigo ~= cor.b)
	local if3 = (rantigo ~= cenas.r or gantigo ~= cenas.g or bantigo ~= cenas.b)
	if if1 and if2 then
		preco = preco-(Config.TunningPrices[tipo].base)*multiplier
	elseif if2 then
		if if3 then
			preco = preco-(Config.TunningPrices[tipo].base)*multiplier
			preco = preco+(Config.TunningPrices[tipo].base)*multiplier
		else
			preco = preco+(Config.TunningPrices[tipo].base)*multiplier
		end
	end
	preco = math.floor(preco)
	SendNUIMessage({
		action = "updateTotal",
		text = "Total: "..preco..Config.Currency,
	})
	if preco < 0 then
		ModelCancel(veh)
	end
end

function AddMoneyTyres(mota,roda,tipo,antigonum)
	local default = TunagensDefault["tyres"]
	if mota == 24 then
		default = TunagensDefault["tyresb"]
	end
	local antigo
	for k in pairs(Config.Wheels) do
		local bool,wheel,num = isWheelType(k,mota)
		if bool then
			antigo = {tipo=k,rodadefault=antigonum+1}
		end
	end
	local def = (default.tipo.." "..default.rodadefault+1)
	local index = tipo.." "..roda+1
	local ant = antigo.tipo.." "..antigo.rodadefault
	if index == def and index ~= ant then
		local price = Config.TunningPrices[antigo.tipo]
		preco = preco-(price.base+(antigo.rodadefault-1)*price.bylevel)*multiplier
	elseif index ~= ant then
		if ant ~= def then
			local price = Config.TunningPrices[antigo.tipo]
			preco = preco-(price.base+(antigo.rodadefault-1)*price.bylevel)*multiplier
			price = Config.TunningPrices[tipo]
			preco = preco+(price.base+(roda)*price.bylevel)*multiplier
		else
			local price = Config.TunningPrices[tipo]
			preco = preco+(price.base+(roda)*price.bylevel)*multiplier
		end
	end
	preco = math.floor(preco)
	SendNUIMessage({
		action = "updateTotal",
		text = "Total: "..preco..Config.Currency,
	})
	if preco < 0 then
		ModelCancel(veh)
	end
end
local chegoupago = false
RegisterNUICallback("action", function(data)
	SetVehicleDoorsShut(carroselected, false)
	if data.action == "openSubMenu" then -- aqui e quando o gajo clica para abrir 
		local tab = json.decode(data.type)
		menuatual = tab.tipo
		if tab.tipo == "HeadLight" then
			SetVehicleLights(carroselected,2)
		end
		camControl(tab.tipo)
		PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	elseif data.action == "subMenuAction" then  -- aqui é quando o gajo clica para que nivel quer tunar
		local tab = json.decode(data.type)
		menuatual = tab.tipo
		if menuatual == "rodadefault" then
			AddMoneyTyres(tab.index.mota,tab.index.roda,tab.index.tipo,GetVehicleMod(carroselected,tab.index.mota))
			SetVehicleWheelType(carroselected,Config.Wheels[tab.index.tipo])
			SetVehicleMod(carroselected,tab.index.mota,tab.index.roda,GetVehicleModVariation(carroselected,tab.index.mota))
		elseif menuatual == "defaultneon" then
			AddMoneyCorRGB(tab.index,"NeonsRGBColor")
			local neonsligado = false
			for i = 0, 3 do
				if IsVehicleNeonLightEnabled(carroselected,i) then
					neonsligado = true
				end
			end
			AddMoneyNotDefault(tab.ligado,Config.TunningPrices["neons"],tab.ligado,neonsligado)
			for i = 0, 3 do
				SetVehicleNeonLightEnabled(carroselected,i,tab.ligado)
			end
			SetVehicleNeonLightsColour(carroselected,tab.index.r,tab.index.g,tab.index.b)
		elseif menuatual == "smokedefault" then
			ToggleVehicleMod(carroselected, 20, true)
			local aply = tab.index
			if tab.index.r == 0 and tab.index.g == 0 and tab.index.b == 0 then
				aply.b = 1
			end
			AddMoneyCorRGB(aply,"SmokeRGBColor")
			SetVehicleTyreSmokeColor(carroselected,aply.r,aply.g,aply.b)
		elseif menuatual == "xenonfault" then
			local wut = false
			if IsToggleModOn(carroselected,22) then
				wut = true
			end
			AddMoneyNotDefault(TunagensDefault["headlight"].ligado,Config.TunningPrices["xenon"],tab.ligado,wut)
			ToggleVehicleMod(carroselected,22,tab.ligado)
			if tab.index ~= 99 and tab.index ~= 98 then
				AddMoneyNotDefault(TunagensDefault["headlight"].nmr,Config.TunningPrices["xenoncolor"],tab.index,GetVehicleXenonLightsColour(carroselected))
				SetVehicleXenonLightsColour(carroselected,tab.index)
			end
		elseif menuatual == "extrafault" then
			local cenas = TunagensDefault["extra"]
			for id = 0, 20, 1 do
				if DoesExtraExist(carroselected, id) then
					if IsVehicleExtraTurnedOn(carroselected, id) then
						local jatava = IsVehicleExtraTurnedOn(carroselected, id)
						local wht = true
						local wht2
						if jatava then
							aplicar = 1
							wht = nil
							wht2 = true
						end
						SetVehicleAutoRepairDisabled(carroselected,true)
						SetVehicleExtra(carroselected,id,1)
						if jatava ~= IsVehicleExtraTurnedOn(carroselected, id) then
							AddMoneyNotDefault(cenas[id],Config.TunningPrices["extra"],wht,wht2)
						end
					end
				end
			end
			for i = 1, #cenas do
				if DoesExtraExist(carroselected, i) then
					local aplicar = 1
					if cenas[i] then
						aplicar=0
					end
					local jatava = IsVehicleExtraTurnedOn(carroselected, i)
					local wht = true
					local wht2
					if jatava then
						aplicar = 1
						wht = nil
						wht2 = true
					end
					if aplicar == 1 then
						SetVehicleAutoRepairDisabled(carroselected,true)
					else
						SetVehicleAutoRepairDisabled(carroselected,false)
					end
					SetVehicleExtra(carroselected,i,aplicar)
					if jatava ~= IsVehicleExtraTurnedOn(carroselected, i) then
						AddMoneyNotDefault(cenas[i],Config.TunningPrices["extra"],wht,wht2)
					end
				end
			end
		else
			AplicarMod(tab.tipo,tab.index-2)
		end
		PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    elseif data.action == "opensubSubMenu" then  -- aqui é quando o gajo clica para que nivel quer tunar
		local tab = json.decode(data.type)
		menuatual = tab.tipo
		camControl(tab.tipo)
		PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    elseif data.action == "subSubMenuAction" then  -- aqui é quando o gajo clica para que nivel quer tunar
		local tab = json.decode(data.type)
		if tab.tipo == "cortipop" then
			local def = TunagensDefault["corprinc"].tipao
			local price = Config.TunningPrices["PrimaryColorType"]
			local ptp, colorp,nnn = GetVehicleModColor_1(carroselected)
			if ptp >= 6 then
				ptp = 0
			end
			local rr,gg,bb = GetVehicleCustomPrimaryColour(carroselected)
			AddMoneyNotDefault(def,price,tab.index,ptp)
			SetVehicleModColor_1(carroselected,tab.index,0,0)
			SetVehicleCustomPrimaryColour(carroselected,rr,gg,bb)
		elseif tab.tipo == "cortipos" then
			local pts, colors = GetVehicleModColor_2(carroselected)
			if pts >= 6 then
				pts = 0
			end
			local def = TunagensDefault["corsec"].tipao
			local price = Config.TunningPrices["SecondaryColorType"]
			local rr,gg,bb = GetVehicleCustomSecondaryColour(carroselected)
			AddMoneyNotDefault(def,price,tab.index,pts)
			SetVehicleModColor_2(carroselected,tab.index,0,0)
			SetVehicleCustomSecondaryColour(carroselected,rr,gg,bb)
		elseif tab.tipo == "defaultprgb" then
			AddMoneyCorRGB(tab.index,"PrimaryRGBColor")
			local def = TunagensDefault["corprinc"].tipao
			local price = Config.TunningPrices["PrimaryColorType"]
			local ptp, colorp,nnn = GetVehicleModColor_1(carroselected)
			if ptp >= 6 then
				ptp = 0
			end
			AddMoneyNotDefault(def,price,tab.index.tipao,ptp)
			SetVehicleModColor_1(carroselected,tab.index.tipao,0,0)
			SetVehicleCustomPrimaryColour(carroselected,tab.index.r,tab.index.g,tab.index.b)
		elseif tab.tipo == "defaultsrgb" then
			AddMoneyCorRGB(tab.index,"SecondaryRGBColor")
			local def = TunagensDefault["corsec"].tipao
			local price = Config.TunningPrices["SecondaryColorType"]
			local pts, colors,nnn = GetVehicleModColor_2(carroselected)
			if pts >= 6 then
				pts = 0
			end
			AddMoneyNotDefault(def,price,tab.index.tipao,pts)
			SetVehicleModColor_2(carroselected,tab.index.tipao,0,0)
			SetVehicleCustomSecondaryColour(carroselected,tab.index.r,tab.index.g,tab.index.b)
		elseif (tab.tipo == "sport" or tab.tipo == "muscle" or tab.tipo == "lowrider" or tab.tipo == "suv" or tab.tipo == "offroad" or tab.tipo == "tuner" or tab.tipo == "motorcycle" or tab.tipo == "highend" or tab.tipo == "bennys" or tab.tipo == "bespoke" or tab.tipo == "f1" or tab.tipo == "rua" or tab.tipo == "track") then
			AddMoneyTyres(tab.moto,tab.index,tab.tipo,GetVehicleMod(carroselected,tab.moto))
			SetVehicleWheelType(carroselected,Config.Wheels[tab.tipo])
			SetVehicleMod(carroselected,23,tab.index,GetVehicleModVariation(carroselected,tab.moto))
			SetVehicleMod(carroselected,24,tab.index,GetVehicleModVariation(carroselected,tab.moto))
		elseif tab.tipo == "costum" then
			local rodai = GetVehicleMod(carroselected,23)
			local costum = not GetVehicleModVariation(carroselected,23)
			local whut = GetVehicleModVariation(carroselected,23)
			AddMoneyNotDefault(TunagensDefault["tyreso"].costum,Config.TunningPrices["costum-wheel"],costum,whut)
			SetVehicleMod(carroselected,23,rodai,costum)
		elseif tab.tipo == "bproof" then
			local costum = 1
			if GetVehicleTyresCanBurst(carroselected) then
				costum = false
			end
			AddMoneyNotDefault(TunagensDefault["tyreso"].bproof,Config.TunningPrices["bulletproof"],costum,GetVehicleTyresCanBurst(carroselected))
			SetVehicleTyresCanBurst(carroselected,costum)
		elseif tab.tipo == "drift" then
			local costum = GetDriftTyresEnabled(carroselected)
			AddMoneyNotDefault(TunagensDefault["tyreso"].drift,Config.TunningPrices["drift"],not costum,GetDriftTyresEnabled(carroselected))
			SetDriftTyresEnabled(carroselected,not costum)
		elseif tab.tipo == "xcolor" then
			AddMoneyNotDefault(TunagensDefault["headlight"].nmr,Config.TunningPrices["xenoncolor"],tab.index,GetVehicleXenonLightsColour(carroselected))
			SetVehicleXenonLightsColour(carroselected,tab.index)
		elseif menuatual == "pearlescent" then
			local plrcolour, whcolour = GetVehicleExtraColours(carroselected)
			AddMoneyDefault("pearltab",tab.index,plrcolour)
			SetVehicleExtraColours(carroselected, tab.index, whcolour)
		elseif menuatual == "wheel-colour" then
			local plrcolour, whcolour = GetVehicleExtraColours(carroselected)
			AddMoneyDefault("whlclrtab",tab.index,whcolour)
			SetVehicleExtraColours(carroselected, plrcolour, tab.index)
		elseif menuatual == "dash-colour" then
			local antigito = GetVehicleDashboardColour(carroselected)
			AddMoneyDefault("dshclrtab",tab.index,antigito)
			SetVehicleDashboardColour(carroselected, tab.index)
		elseif menuatual == "int-colour" then
			local antigito = GetVehicleInteriorColour(carroselected)
			AddMoneyDefault("intclrtab",tab.index,antigito)
			SetVehicleInteriorColour(carroselected, tab.index)
		end
		PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	elseif data.action == "backToMainMenu" then -- quando clicar no butao para voltar
		PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		camControl("close")
		menuatual = nil
    elseif data.action == "changeColor" then
		local cor = data.rgb
		if menuatual == "corrgbp" then
			AddMoneyCorRGB(cor,"PrimaryRGBColor")
			SetVehicleCustomPrimaryColour(carroselected,cor.r,cor.g,cor.b)
		elseif menuatual == "corrgbs" then
			AddMoneyCorRGB(cor,"SecondaryRGBColor")
			SetVehicleCustomSecondaryColour(carroselected,cor.r,cor.g,cor.b)
		elseif menuatual == "change-neons" then
			AddMoneyCorRGB(cor,"NeonsRGBColor")
			SetVehicleNeonLightsColour(carroselected,cor.r,cor.g,cor.b)
		elseif menuatual == "smoke" then
			ToggleVehicleMod(carroselected, 20, true)
			local aply = cor
			if cor.r == 0 and cor.g == 0 and cor.b == 0 then
				aply.b = 1
			end
			AddMoneyCorRGB(aply,"SmokeRGBColor")
			SetVehicleTyreSmokeColor(carroselected,aply.r,aply.g,aply.b)
		end
	elseif data.action == "cancel" then-- quando acabar
		CancelEverything(data)
		TunagensDefault = {}
		preco = 0
        FreezeEntityPosition(carroselected,false)
		SetNuiFocus(false, false)
		focuson = false
		PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		camControl("close")
		--ResetCam()
		TriggerServerEvent("TunningSystem:Used", nomidaberto)
		nomidaberto = nil
		multiplier = 1
		menuatual = nil
		carroselected = nil
    elseif data.action == "finish" then-- quando acabar
		if preco > 0 then
			TriggerServerEvent("TunningSystem:PayModifications",preco,nomidaberto,ESX.Game.GetVehicleProperties(carroselected))
		else
			TriggerServerEvent("TunningSystem:Used", nomidaberto)
		end
		while not chegoupago and preco > 0 do
			Wait(10)
		end
		preco = 0
		chegoupago = false
		TunagensDefault = {}
        FreezeEntityPosition(carroselected,false)
		SetNuiFocus(false, false)
		focuson = false
		PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		camControl("close")
		--ResetCam()
		nomidaberto = nil
		multiplier = 1
		menuatual = nil
		carroselected = nil
	elseif data.action == "kinda" then-- quando acabar
		PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	elseif data.action == "camlivre" then-- quando acabar
		if focuson then
			camControl("close")
			SetNuiFocus(false, false)
			SendNUIMessage({
				action = "hideFreeUpButton",
			})
			focuson = false
			while nomidaberto and not focuson do
				Citizen.Wait(5)
				DisableControlAction(0,85,true)
				if IsControlJustReleased(0,44) and not focuson then
					focuson = true
					SendNUIMessage({
						action = "showFreeUpButton",
					})
					Wait(500)
					SetNuiFocus(true, true)
				end
			end
		end
	elseif data.action == "backTosubMainMenu" then -- quando clicar no butao para voltar
		PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	end
end)

function CancelEverything(data)
	for k,v in pairs(TunagensDefault) do
		local modindex = Config.TunningMods[k]
		local cenas = TunagensDefault[k]
		if modindex then
			SetVehicleMod(carroselected,modindex,v,false)
		elseif k=="corprinc" then
			if GetIsVehiclePrimaryColourCustom(carroselected) ~= false then
				SetVehicleModColor_1(carroselected,cenas.tipao,0,0)
				SetVehicleCustomPrimaryColour(carroselected,cenas.r,cenas.g,cenas.b)
			end
		elseif k=="corsec" then
			if GetIsVehicleSecondaryColourCustom(carroselected) ~= false then
				SetVehicleModColor_2(carroselected,cenas.tipao,0,0)
				SetVehicleCustomSecondaryColour(carroselected,cenas.r,cenas.g,cenas.b)
			end
		elseif k=="pearltab" then
			local plrcolour, whcolour = GetVehicleExtraColours(carroselected)
			SetVehicleExtraColours(carroselected, cenas, whcolour)
		elseif k=="whlclrtab" then
			local plrcolour, whcolour = GetVehicleExtraColours(carroselected)
			SetVehicleExtraColours(carroselected, plrcolour, cenas)
		elseif k=="dshclrtab" then
			SetVehicleDashboardColour(carroselected, cenas)
		elseif k=="intclrtab" then
			SetVehicleInteriorColour(carroselected, cenas)
		elseif k=="neons" then
			for i = 0, 3 do
				SetVehicleNeonLightEnabled(carroselected,i,cenas.ligado)
			end
			SetVehicleNeonLightsColour(carroselected,cenas.r,cenas.g,cenas.b)
		elseif k=="smoke" then
			ToggleVehicleMod(carroselected, 20, true)
			SetVehicleTyreSmokeColor(carroselected,cenas.r,cenas.g,cenas.b)
			if cenas.r == 0 and cenas.g == 0 and cenas.b == 0 then
				SetVehicleTyreSmokeColor(carroselected,0,0,1)
			end
		elseif k=="windtint" then
			SetVehicleWindowTint(carroselected,cenas)
		elseif k == "plate" then
			SetVehicleNumberPlateTextIndex(carroselected, cenas-1)
		elseif k == "turbo" then
			ToggleVehicleMod(carroselected,18,cenas)
		elseif k == "headlight" then
			ToggleVehicleMod(carroselected,22,cenas.ligado)
			if cenas.nmr ~= 99 then
				SetVehicleXenonLightsColour(carroselected,cenas.nmr)
			end
		elseif k == "tyres" then
			SetVehicleWheelType(carroselected,Config.Wheels[cenas.tipo])
			SetVehicleMod(carroselected,23,cenas.rodadefault,GetVehicleModVariation(carroselected,23))
		elseif k == "tyreso" then
			local rodai = GetVehicleMod(carroselected,23)
			SetVehicleMod(carroselected,23,rodai,cenas.costum)
			SetVehicleTyresCanBurst(carroselected,cenas.bproof)
			if GetGameBuildNumber() >= 2372 then
				SetDriftTyresEnabled(carroselected,cenas.drift)
			end
		elseif k == "tyresb" then
			SetVehicleWheelType(carroselected,Config.Wheels[cenas.tipo])
			SetVehicleMod(carroselected,24,cenas.rodadefault,GetVehicleModVariation(carroselected,24))
		elseif k == "extra" then
			for id = 0, 20, 1 do
				if DoesExtraExist(carroselected, id) then
					if IsVehicleExtraTurnedOn(carroselected, id) then
						SetVehicleAutoRepairDisabled(carroselected,true)
						SetVehicleExtra(carroselected,id,1)
					end
				end
			end
			for i = 1, #cenas do
				if DoesExtraExist(carroselected, i) then
					local aplicar = 1
					if cenas[i] then
						aplicar=0
					end
					if aplicar == 1 then
						SetVehicleAutoRepairDisabled(carroselected,true)
					else
						SetVehicleAutoRepairDisabled(carroselected,false)
					end
					SetVehicleExtra(carroselected,i,aplicar)
				end
			end
		elseif k == "Livery2" then
			SetVehicleLivery(carroselected,v)
		end
	end
end

RegisterNetEvent('TunningSystem:PayAfter')
AddEventHandler('TunningSystem:PayAfter', function(pago)
	if not pago then
		CancelEverything()
	end
	chegoupago = true
	TriggerServerEvent("TunningSystem:Used", nomidaberto)
	nomidaberto = nil
	SetNuiFocus(false, false)
end)

function DrawText3D(x, y, z, text,r,g,b,a)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
	if r and g and b and a then
		SetTextColour(r, g, b, a)
	else
		SetTextColour(255, 255, 255, 215)
	end
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--CAM POS/STUFF, CREDITS TO OhTanoshi -- https://github.com/OhTanoshi/FLRP_Customs/

function f(n)
	return (n + 0.00001)
end

function ResetCam()
	SetCamCoord(cam,GetGameplayCamCoords())
	SetCamRot(cam, GetGameplayCamRot(2), 2)
	RenderScriptCams( 0, 1, 1000, 0, 0)
	SetCamActive(gameplaycam, true)
	EnableGameplayCam(true)
	SetCamActive(cam, false)
end

function PointCamAtBone(bone,ox,oy,oz)
	SetCamActive(cam, true)
	local veh = carroselected
	local b = GetEntityBoneIndexByName(veh, bone)
	if b and b > -1 then
		local bx,by,bz = table.unpack(GetWorldPositionOfEntityBone(veh, b))
		local ox2,oy2,oz2 = table.unpack(GetOffsetFromEntityGivenWorldCoords(veh, bx, by, bz))
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(veh, ox2 + f(ox), oy2 + f(oy), oz2 +f(oz)))
		SetCamCoord(cam, x, y, z)
		PointCamAtCoord(cam,GetOffsetFromEntityInWorldCoords(veh, 0, oy2, oz2))
		RenderScriptCams( 1, 1, 1000, 0, 0)
	end
end

function camControl(c)
	Wait(50)
	if c == "Front Bumper" or c == "Grill" or c == "Vanity Plate" or c == "Aerial" then
		MoveVehCam('front',-0.6,1.5,0.4)
	elseif c == "color" or c == "Livery" or c == "Livery2" then
		MoveVehCam('middle',-2.6,2.5,1.4)
	elseif  c == "Rear Bumper" or c == "Exhaust" or c == "Fuel Tank" then
		MoveVehCam('back',-0.5,-1.5,0.2)
	elseif c == "Hood" then
		MoveVehCam('front-top',-0.5,1.3,1.0)
	elseif c == "Roof" or c == "Trim B" then
		MoveVehCam('middle',-2.2,2,1.5)
	elseif c == "Window" or c == "windtint" then
		MoveVehCam('middle',-2.0,2,0.5)
	elseif c == "HeadLight" or c == "Arch Cover" then
		MoveVehCam('front',-0.6,1.3,0.6)
	elseif c == "Plate Holder" or c == "Plaque" or c == "Trunk" or c == "Hydraulic" or c == "plate" then
		MoveVehCam('back',0,-1,0.2)
	elseif c == "Engine Block" or c == "Air Filter" or c == "Strut" then
		MoveVehCam('front',0.0,1.0,2.0)
	elseif c == "Skirt" then
		MoveVehCam('left',-1.8,-1.3,0.7)
	elseif c == "Spoiler" or c == "Left Fender" or c == "Right Fender" then
		MoveVehCam('back',1.5,-1.6,1.3)
	elseif c == "Tyres Back" or c == "smoke" then
		PointCamAtBone("wheel_lr",-1.4,0,0.3)
	elseif c == "Tyres Front" or c == "tyresoptions" then
		PointCamAtBone("wheel_lf",-1.4,0,0.3)
	elseif c == "neons" or c == "Suspension" or c == "Side Skirt" then
		PointCamAtBone("neon_l",-2.0,2.0,0.4)
	elseif c == "Interior" or c == "Ornaments" or c == "Dashboard" or c == "Seats" or c =="Roll Cage" or c == "Trim A" then
		MoveVehCam('back-top',0.0,5.0,0.7)
	elseif c == "Steering Wheel" or c == "Dial" or c == "Shifter Leaver" then
		MoveVehCam('back-top',0.0,4.0,0.7)
	elseif c == "close"	then
		SetCamCoord(cam,GetGameplayCamCoords())
		SetCamRot(cam, GetGameplayCamRot(2), 2)
		RenderScriptCams( 0, 1, 1000, 0, 0)
		SetCamActive(gameplaycam, true)
		EnableGameplayCam(true)
	end
end

function MoveVehCam(pos,x,y,z)
	if carroselected then
		SetCamActive(cam, true)
		local veh = carroselected
		local vx,vy,vz = table.unpack(GetEntityCoords(veh))
		local d = GetModelDimensions(GetEntityModel(veh))
		local length,width,height = d.y*-2, d.x*-2, d.z*-2
		local ox,oy,oz
		if pos == 'front' then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length/2)+ f(y), f(z)))
		elseif pos == "front-top" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length/2) + f(y),(height) + f(z)))
		elseif pos == "back" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length/2) + f(y),f(z)))
		elseif pos == "back-top" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length/2) + f(y),(height/2) + f(z)))
		elseif pos == "left" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, -(width/2) + f(x), f(y), f(z)))
		elseif pos == "right" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, (width/2) + f(x), f(y), f(z)))
		elseif pos == "middle" then
			ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), f(y), (height/2) + f(z)))
		end
		SetCamCoord(cam, ox, oy, oz)
		PointCamAtCoord(cam,GetOffsetFromEntityInWorldCoords(veh, 0, 0, f(0)))
		RenderScriptCams( 1, 1, 1000, 0, 0)
	end
end