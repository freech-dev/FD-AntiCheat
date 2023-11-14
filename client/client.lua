Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local ped = PlayerPedId()
        local veh = nil

        if IsPedInAnyVehicle(ped, false) then
            veh = GetVehiclePedIsUsing(ped)
        else
            veh = GetVehiclePedIsTryingToEnter(ped)
        end

        local model = GetEntityModel(veh)

        if model ~= nil then
            if IsVehicleModelInConfigBlacklist(model) then
                local driver = GetPedInVehicleSeat(veh, -1)
                if driver == ped then
                    local playerName = GetPlayerName(PlayerId())
                    local vehicleName = GetDisplayNameFromVehicleModel(model)
                    local title = "Vehicle Deleted"
                    local message = playerName .. " spawned a blacklisted vehicle with the spawncode " .. vehicleName
                    local footer = "[FD AC] Vehicle Blacklist "
                    TriggerServerEvent("sendToDisc", title, message, footer)
                    DeleteEntity(veh)
                    ClearPedTasksImmediately(ped)
                end
            end
        end
    end
end)

function IsVehicleModelInConfigBlacklist(model)
    for _, vehicleModel in ipairs(Config.blacklists.vehicles) do
        if GetHashKey(vehicleModel) == model then
            return true
        end
    end
    return false
end