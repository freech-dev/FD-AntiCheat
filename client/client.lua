local OnDuty = false
local onDutyPlayers = {}
lastChecked = nil
hasPerm = nil


RegisterCommand("duty", function(source, args)
    local department = tostring(args[1]) 
    local callsign = args[2]
    if callsign == "" or department == "" then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {'[FD Duty]', {255, 0, 0}, 'Your Callsign or Department cannot be blank'}
        })
    else
        TriggerServerEvent("fd-duty:onDuty", department, callsign)
    end
end, false)

RegisterCommand("offduty", function(source, args)
    local department = tostring(args[1])
    TriggerServerEvent("fd-duty:offDuty", department)
end, false)

RegisterCommand("clearduty", function(source)
    TriggerServerEvent("fd-duty:ClearDutyLogs")
end, false)

RegisterNetEvent("fd-duty:SetOnDuty")
AddEventHandler("fd-duty:SetOnDuty", function(isOnDuty)
    OnDuty = isOnDuty
    if isOnDuty then
        TriggerServerEvent("fd-duty:GetOnDutyPlayers")
    end
end)

RegisterNetEvent("fd-duty:GetOnDutyPlayers")
AddEventHandler("fd-duty:GetOnDutyPlayers", function(players)
    onDutyPlayers = players
end)

RegisterNetEvent("fd-duty:UpdateOnDutyPlayers")
AddEventHandler("fd-duty:UpdateOnDutyPlayers", function(players)
    onDutyPlayers = players
end)

Citizen.CreateThread(function()
    Citizen.Trace("\n~g~[FD-Duty]: ~w~Adding Chat Suggestions for FD Duty\n")
    TriggerEvent('chat:addSuggestion', '/duty', 'Go on duty as your department', {{ name="department", help="The Department example: BCSO"}, { name="callsign", help="Your Assigned Callsign example: 1X-01"}})
    TriggerEvent('chat:addSuggestion', '/offduty', 'Go on duty as your department', {{ name="department", help="The Department example (Must be the department you went on duty as): BCSO"}})
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if OnDuty then
            TriggerServerEvent("fd-duty:GetOnDutyPlayers")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(ped)
        local model = GetEntityModel(veh)
        local check_seat = GetPedInVehicleSeat(veh, -1)
        if check_seat == ped and veh ~= 0 then
            local department = OnDuty[source]
            if department and Config.departments[department] then
                local restrictedVehicles = Config.departments[department].restricted_vehicles
                for k, v in ipairs(restrictedVehicles) do
                    if model == GetHashKey(v) then
                        TriggerServerEvent('fd-duty:CheckVeh', model)
                        break
                    end
                end
            end
        end
    end
end)


RegisterNetEvent('fd-duty:DelVeh')
AddEventHandler('fd-duty:DelVeh', function()
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteEntity(veh)
    TriggerEvent("chat:addMessage", {
        template = '<div style="padding: 0.7vh; text-align: center; margin: 0.5vw; background-color: rgb(0,255,0 0.4); font-size: 1.7vh; border-radius: 0.5px;"><b>{0}</b></div>',
        args = {'^1Error^0: You have to be onduty to spawn this vehicle!'}
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if OnDuty then
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                local playerId = GetPlayerServerId(player)
                if NetworkIsPlayerActive(player) and player ~= PlayerId() and onDutyPlayers[playerId] then
                    local blip = AddBlipForEntity(ped)
                    SetBlipSprite(blip, 1)
                    SetBlipColour(blip, 3)
                    SetBlipAsShortRange(blip, true)
                    ShowHeadingIndicatorOnBlip(blip, true)
                    SetBlipDisplay(blip, 4)
                    SetBlipScale(blip, 0.8)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(GetPlayerName(player))
                    EndTextCommandSetBlipName(blip)
                end
            end
        end
    end
end)

local resource_banner = [[
  ______ _____             _____  _    _ _________     __   _______     _______ _______ ______ __  __ 
 |  ____|  __ \           |  __ \| |  | |__   __\ \   / /  / ____\ \   / / ____|__   __|  ____|  \/  |
 | |__  | |  | |  ______  | |  | | |  | |  | |   \ \_/ /  | (___  \ \_/ / (___    | |  | |__  | \  / |
 |  __| | |  | | |______| | |  | | |  | |  | |    \   /    \___ \  \   / \___ \   | |  |  __| | |\/| |
 | |    | |__| |          | |__| | |__| |  | |     | |     ____) |  | |  ____) |  | |  | |____| |  | |
 |_|    |_____/           |_____/ \____/   |_|     |_|    |_____/   |_| |_____/   |_|  |______|_|  |_|
                                                                                                      
                                                                                                      
]]

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    print(resource_banner)
  end)


