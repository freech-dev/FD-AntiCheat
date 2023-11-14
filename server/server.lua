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

RegisterServerEvent('FDAC:ExtractIdentifiers')

RegisterServerEvent('sendToDisc')
AddEventHandler('sendToDisc', function(title, message, footer)
    local webhookURL = Config.LogWebhook
    local embed = {
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
end)
