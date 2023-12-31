Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

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
                    DeleteEntity(veh)
                    ClearPedTasksImmediately(ped)
                end
            end
        end

        for _, restrictedWeapon in ipairs(Config.blacklists.weapons) do
            local weapon = GetHashKey(restrictedWeapon)
            if HasPedGotWeapon(ped, weapon, false) or HasPedGotWeaponComponent(ped, weapon, false) then
                RemoveWeaponFromPed(ped, weapon)
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