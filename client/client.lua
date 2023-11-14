RegisterNetEvent("FDAC:Blacklists:LeaveVehicle")
AddEventHandler("FDAC:Blacklists:LeaveVehicle", function(vehicleNetId)
    local ped = GetPlayerPed(-1)
    local vehicle = NetworkGetEntityFromNetworkId(Nid)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        TaskLeaveVehicle(ped, vehicle, 0)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
    end
end)

RegisterNetEvent("FDAC:Blacklists:ChangePed")
AddEventHandler("FDAC:Blacklists:ChangePed", function(wcf)
    local ped = GetPlayerPed(-1)
    local model = "a_m_y_skater_01"
    RequestModel(GetHashKey(model))
    
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(1)
    end

    SetPlayerModel(PlayerId(), GetHashKey(model))
end)
