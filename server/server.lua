AddEventHandler("explosionEvent", function(sender, ev)
    for _, blacklistedExplosion in ipairs(Config.blacklists.explosions) do
        if blacklistedExplosion[ev.explosionType] then
            CancelEvent()
            return
        end
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local name, setKickReason, deferrals = name, setKickReason, deferrals;
    local ipIdentifier
    local identifiers = GetPlayerIdentifiers(player)
    local acePerm = Config.bypass
    local card = '{"type":"AdaptiveCard","$schema":"http://adaptivecards.io/schemas/adaptive-card.json","version":"1.2","body":[{"type":"TextBlock","text":"Hello,","wrap":true},{"type":"TextBlock","text":"We have detected that your IP address is associated with a VPN.","wrap":true},{"type":"TextBlock","text":"Please disable the VPN and try connecting again.","wrap":true}],"actions":[{"type":"Action.OpenUrl","title":"More Information","url":"https://example.com"}],"banner":{"type":"Image","url":"https://i.imgur.com/EXAMPLE.jpg"}}'
    deferrals.defer()
    Wait(1000)
    deferrals.update(string.format("[FD AC] Hello %s. Your IP Address is being checked.", name))
    for _, v in pairs(identifiers) do
        if string.find(v, "ip") then
            ipIdentifier = v:sub(4)
            break
        end
    end
    Wait(1000)
    if not ipIdentifier then
        deferrals.done("We could not find your IP Address.")
    else
        PerformHttpRequest("http://ip-api.com/json/" .. ipIdentifier .. "?fields=proxy", function(err, text, headers)
            local isAllowed = false
            if tonumber(err) == 200 then
                local tbl = json.decode(text)
                if tbl["proxy"] == false or IsPlayerAceAllowed(player, acePerm) then
                    deferrals.done()
                else
                    deferrals.presentCard(card)
                end
            else
                deferrals.done("There was an error in the API.")
            end
        end)
    end
end)

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
