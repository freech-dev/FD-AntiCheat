AddEventHandler('explosionEvent', function(sender, ev)
    local isExplosionBlacklisted = false
    for _, blacklistedExplosion in ipairs(Config.blacklists.explosions) do
        if ev.explosionType == blacklistedExplosion then
            isExplosionBlacklisted = true
            break
        end
    end

    if isExplosionBlacklisted then
        DropPlayer(sender, "[FD AC] You have triggered a blacklisted explosion.")
        CancelEvent()
    end
end)


function GetEntityOwner(entity)
    if (not DoesEntityExist(entity)) then 
        return nil 
    end
    local owner = NetworkGetEntityOwner(entity)
    if (GetEntityPopulationType(entity) ~= 7) then return nil end
    return owner
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

function sendToDisc(title, message, footer)
    local embed = {}
    embed = {
        {
            ["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**".. title .."**",
            ["description"] = "" .. message ..  "",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    PerformHttpRequest(webhookURL, 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function DoesPlayerHasBlacklistWeapon(id)
    for i, weapon in ipairs(config.blacklists.weapons) do
        local hash = GetHashKey(weapon)
        local ped = GetPlayerPed(id)

        RemoveWeaponFromPed(ped, hash)
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local players = GetPlayers()
        for _, id in ipairs(players) do
            DoesPlayerSitInBlacklistVehicle(id)
            DoesPlayerHasBlacklistPed(id)
            DoesPlayerHasBlacklistWeapon(id)
        end
    end
end)


async function DoesPlayerHasBlacklistPed(id) {
    const ped = GetPlayerPed(id)
    for (const key in pcf) {
        
        const plped = GetEntityModel(ped)
        const hash = GetHashKey(pcf[key])

        if (plped == hash) {
            emitNet("ChangePed", id)
        }
    }
}

async function DoesPlayerSitInBlacklistVehicle(id) {
    const ped = GetPlayerPed(id)
    for (const key in vcf) {
        const plvehicle = GetVehiclePedIsIn(ped, false)
        let plmodel = 0

        if (plvehicle != 0) {
            plmodel = GetEntityModel(plvehicle)
        }

        const blvehicle = GetHashKey(vcf[key])

        if (plmodel == blvehicle) {
            const Nid = NetworkGetNetworkIdFromEntity(plvehicle)
            emitNet("LeaveVehicle", id, Nid)
        }
    }
}