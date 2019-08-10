local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- ### Player Commands ### --

-- Clear Chat
RegisterCommand("clearchat", function() 
    TriggerEvent('chat:clear')
    SystemNotify("Chat Clear", "SYSTEM")
end)

-- Suicide
RegisterCommand("suicide", function()
    local player = GetPlayerPed(-1)
    RequestAnimDict('mp_suicide')
    while not HasAnimDictLoaded('mp_suicide') do Wait(0) end
    TaskPlayAnim(player, 'mp_suicide', 'pill', 8.0, 1.0, 5000, 0, 1, true, true, true)
    Wait(4600)
    SetEntityHealth(player, 0)
end)

RegisterCommand("giveweapons", function()
    local player = GetPlayerPed(-1)
	GiveWeaponToPed(player, "WEAPON_KNIFE", 1000, false, true)
	GiveWeaponToPed(player, "WEAPON_PISTOL", 1000, false, true)
	GiveWeaponToPed(player, "WEAPON_RPG", 1000, false, true)
	GiveWeaponToPed(player, "WEAPON_SMG", 1000, false, true)
	GiveWeaponToPed(player, "WEAPON_MINIGUN", 1000, false, true)
end)

-- ### Snippets ### --

-- Enable PVP
AddEventHandler("playerSpawned", function()
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
end)

-- NeverWanted
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end
end)

-- Server Name
function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
  AddTextEntry('FE_THDR_GTAO','~r~SERVER NAME ~w~- ~b~' .. GetPlayerName(PlayerId()) .. ' ~w~- ~o~ID: ' .. GetPlayerServerId(PlayerId()))
end)

-- NPC Control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0) 
        SetVehicleDensityMultiplierThisFrame(0.1) -- Traffic Density
		SetPedDensityMultiplierThisFrame(0.1) -- NPC Density
		SetRandomVehicleDensityMultiplierThisFrame(0.1) -- Random Vehicle Density
		SetParkedVehicleDensityMultiplierThisFrame(0.1) -- Parked Density
		SetScenarioPedDensityMultiplierThisFrame(0.1, 0.1) -- Walking NPC Density
		SetGarbageTrucks(true) -- Enable/Disable Garbage Trucks
		SetRandomBoats(true) -- Enable/Disable Boats
        SetCreateRandomCops(false) -- Enable/Disable Random Cops
		SetCreateRandomCopsNotOnScenarios(false) --- Enable/Disable Spawn Cops Off Scenarios
		SetCreateRandomCopsOnScenarios(false) -- Enable/Disable Spawn Cops On Scenarios
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
		RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
	 end
end)

-- Disable Dispatch
Citizen.CreateThread(function()
	for i = 1, 15 do
		EnableDispatchService(i, false)
	 end
end)

-- NoDropNPC (Disable Weapon Drops From NPC)
Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      --(https://pastebin.com/8EuSv2r1)
      RemoveAllPickupsOfType(0xDF711959) -- Carbine rifle
      RemoveAllPickupsOfType(0xF9AFB48F) -- Pistol
      RemoveAllPickupsOfType(0xA9355DCD) -- Pumpshotgun
    end
end)

-- ### Basic Car Commands ### --

-- Spawn Car
RegisterCommand('car', function(source, args, rawCommand)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.5))
    local veh = args[1]
    if veh == nil then veh = "adder" end -- defaul car
    vehiclehash = GetHashKey(veh)
    RequestModel(vehiclehash)
    Citizen.CreateThread(function() 
        local waiting = 0
        while not HasModelLoaded(vehiclehash) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 10000 then
				Notify ("~r~O veiculo está a demorar a carregar, ele deve ser pesado ou pode dar crash.", "Mecânico")
                break
            end
        end
        CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId())+10, 1, 0)
		Notify ("Veiculo ~g~spawnado~s~ a tua frente.", "Mecânico")
    end)
end)

-- DV
RegisterCommand('dv', function(source, args, rawCommand)
local distanceToCheck = 5.0
    local ped = GetPlayerPed( -1 )
    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
        local pos = GetEntityCoords( ped )
        if ( IsPedSittingInAnyVehicle( ped ) ) then 
            local vehicle = GetVehiclePedIsIn( ped, false )
            if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
                SetEntityAsMissionEntity( vehicle, true, true )
                deleteCar( vehicle )
                if ( DoesEntityExist( vehicle ) ) then 
					Notify ("~r~Imposivel deletar o veiculo, tenta outra vez.", "Mecânico")
                else 
					Notify ("Veiculo ~r~deletado~s~.", "Mecânico")
                end 
            else 
				Notify ("Deves estar no assento do motorista.", "Mecânico")
            end 
        else
            local playerPos = GetEntityCoords( ped, 1 )
            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( ped, 0.0, distanceToCheck, 0.0 )
            local vehicle = GetVehicleInDirection( playerPos, inFrontOfPlayer )
            if ( DoesEntityExist( vehicle ) ) then 
                SetEntityAsMissionEntity( vehicle, true, true )
                deleteCar( vehicle )
                if ( DoesEntityExist( vehicle ) ) then 
					Notify ("~r~Imposivel deletar o veiculo, tenta outra vez.", "Mecânico")
                else 
					Notify ("Veiculo ~r~deletado~s~.", "Mecânico")
                end 
            else 
				Notify ("Tu deves estar perto do veiculo para o poder deletar.", "Mecânico")
            end 
        end 
    end 
end )
function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end
function GetVehicleInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed( -1 ), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end

-- Fix and Clear
RegisterCommand('fix', function(source, args, rawCommand)
	local playerPed = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleEngineHealth(vehicle, 1000)
		SetVehicleEngineOn( vehicle, true, true )
		SetVehicleFixed(vehicle)
		Notify ("O teu veiculo foi reparado.", "Mecânico")
	else
		SystemNotify ("Tu deves estar num veiculo para o poder reparar.", "SYSTEM")
	end
end)
RegisterCommand('clear', function(source, args, rawCommand)
	local playerPed = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		SetVehicleDirtLevel(vehicle, 0)
		Notify ("O teu beiculo foi limpo.", "Mecânico")
	else
		SystemNotify ("Tu deves estar num veiculo para o poder limpar.", "SYSTEM")
	end
end)

-- ### Functions ### --
function Notify(message,title)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    SetNotificationMessage("CHAR_LS_CUSTOMS", "CHAR_LS_CUSTOMS", true, 1, title)
    DrawNotification(false, true)
end
function SystemNotify(message,title)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    SetNotificationMessage("CHAR_MP_FM_CONTACT", "CHAR_MP_FM_CONTACT", true, 1, title)
    DrawNotification(false, true)
end
