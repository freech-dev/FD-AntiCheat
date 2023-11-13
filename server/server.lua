local OnDuty = {}
local dutyTimers = {}

RegisterServerEvent("fd-duty:onDuty")
AddEventHandler("fd-duty:onDuty", function(department, callsign)
    local source = source
    local discord = ExtractIdentifiers(source).discord:gsub("discord:", "")

    local acePerm = Config.departments[department].ace_perm
    if IsPlayerAceAllowed(source, acePerm) then
        OnDuty[source] = department
        TriggerClientEvent("fd-duty:SetOnDuty", source, true)
        TriggerClientEvent("chatMessage", source, "[FD Duty]", {0, 255, 0}, "You are now on duty as " .. department .. " (" .. callsign .. ")")

        StartStopwatch(source)
    else
        TriggerClientEvent("chatMessage", source, "[FD Duty]", {255, 0, 0}, "Failed to start duty. Please try again.")
    end
end)

RegisterServerEvent("fd-duty:offDuty")
AddEventHandler("fd-duty:offDuty", function()
    local source = source

    if OnDuty[source] then
        local discord = ExtractIdentifiers(source).discord:gsub("discord:", "")
        local department = OnDuty[source]
        local dutyTimeMinutes = math.floor(dutyTimers[source].dutyTime / 60)

        local result = MySQL.Sync.fetchScalar("SELECT time FROM dutylogs WHERE discord = @discord AND department = @department", {
            ['@discord'] = discord,
            ['@department'] = department
        })

        if result then
            local totalTime = tonumber(result) + dutyTimeMinutes

            local updateResult = MySQL.Sync.execute("UPDATE dutylogs SET time = @time WHERE discord = @discord AND department = @department", {
                ['@discord'] = discord,
                ['@department'] = department,
                ['@time'] = totalTime
            })

            if not updateResult then
                print("Failed to update duty time for player " .. source .. " at 1-minute interval.")
            end
        else
            local insertResult = MySQL.Sync.insert("INSERT INTO dutylogs (discord, department, callsign, time) VALUES (@discord, @department, @callsign, @time)", {
                ['@discord'] = discord,
                ['@department'] = department,
                ['@callsign'] = callsign,
                ['@time'] = dutyTimeMinutes
            })

            if not insertResult then
                print("Failed to log duty for player " .. source .. " at 1-minute interval.")
            end
        end

        OnDuty[source] = nil
        dutyTimers[source] = nil
        TriggerClientEvent("fd-duty:SetOnDuty", source, false)
        sendToDiscord(Config.departments[department].webHook, 000000, "User went off duty", "User " .. discord .. " went off duty", "FD Duty Logs")
        TriggerClientEvent("chatMessage", source, "[FD Duty]", {255, 255, 255}, "You are now off duty")
    else
        TriggerClientEvent("chatMessage", source, "[FD Duty]", {255, 0, 0}, "You are not on duty.")
    end
end)

function StartStopwatch(source)
    dutyTimers[source] = {
        startTime = os.time(),
        dutyTime = 0
    }

    Citizen.CreateThread(function()
        while OnDuty[source] do
            Citizen.Wait(60000) 
            if OnDuty[source] then
                dutyTimers[source].dutyTime = os.time() - dutyTimers[source].startTime
                UpdateDutyTime(source)
                TriggerClientEvent("fd-duty:UpdateOnDutyPlayers", source, onDutyPlayers) 
            end
        end
    end)
end

function UpdateDutyTime(source)
    local discord = ExtractIdentifiers(source).discord:gsub("discord:", "")
    local department = OnDuty[source]
    local dutyTimeMinutes = math.floor(dutyTimers[source].dutyTime / 60)

    local result = MySQL.Sync.fetchScalar("SELECT time FROM dutylogs WHERE discord = @discord AND department = @department", {
        ['@discord'] = discord,
        ['@department'] = department
    })

    if result then
        local totalTime = tonumber(result) + 1

        local updateResult = MySQL.Sync.execute("UPDATE dutylogs SET time = @time WHERE discord = @discord AND department = @department", {
            ['@discord'] = discord,
            ['@department'] = department,
            ['@time'] = totalTime
        })

        if not updateResult then
            print("Failed to update duty time for player " .. source .. " at 1-minute interval.")
        end
    else
        local insertResult = MySQL.Sync.insert("INSERT INTO dutylogs (discord, department, callsign, time) VALUES (@discord, @department, @callsign, @time)", {
            ['@discord'] = discord,
            ['@department'] = department,
            ['@callsign'] = "", -- Replace with the callsign variable
            ['@time'] = 1 -- Set initial time to 1 minute
        })

        if not insertResult then
            print("Failed to log duty for player " .. source .. " at 1-minute interval.")
        end
    end
end

RegisterServerEvent("fd-duty:GetOnDutyPlayers")
AddEventHandler("fd-duty:GetOnDutyPlayers", function()
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local source = tonumber(player)
        if OnDuty[source] then
            players[source] = true
        end
    end
    TriggerClientEvent("fd-duty:GetOnDutyPlayers", source, players)
end)

exports("GetOnDutyPlayers", function()
    return OnDuty
end)

RegisterServerEvent("fd-duty:ClearDutyLogs")
AddEventHandler("fd-duty:ClearDutyLogs", function()
    local source = source
    if IsPlayerAceAllowed(source, "fd-duty.devperms") then
        MySQL.Async.execute("DELETE FROM dutylogs", {}, function(rowsAffected)
            if rowsAffected > 0 then
                TriggerClientEvent("chatMessage", source, "[FD Duty]", {0, 255, 0}, "Duty Logs Cleared Successfully.")
            else
                TriggerClientEvent("chatMessage", source, "[FD Duty]", {255, 0, 0}, "Duty Log Clear Failed.")
            end
        end)
    end
end)

RegisterNetEvent('fd-duty:CheckVeh')
AddEventHandler('fd-duty:CheckVeh', function(hash)
    local src = source
    local discord = ExtractIdentifiers(src).discord:gsub("discord:", "")
    local check = false
    local department = OnDuty[src]
    if department and Config.departments[department] then
        local restrictedVehicles = Config.departments[department].restricted_vehicles
        for i, v in ipairs(plyarray[src].vehicles) do
            if hash == tonumber(v.hash) then
                check = true
                break
            end
        end
        if not check or not IsVehicleAllowed(hash, restrictedVehicles) then
            TriggerClientEvent('fd-duty:DelVeh', src)
        end
    end
end)

function IsVehicleAllowed(hash, restrictedVehicles)
    for i, v in ipairs(restrictedVehicles) do
        if GetHashKey(v) == hash then
            return true
        end
    end
    return false
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
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
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

function sendToDiscord(webhook_url, color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
          }
      }
  
    PerformHttpRequest(webhook_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end


local resource_banner = [[
     ______ _____ 
    |  ____|  __ \  
    | |__  | |  | | 
    |  __| | |  | |
    | |    | |__| | 
    |_|    |_____/ 

    Made by @freech_dev

    FD FiveM Duty System
                                                                                                      
                                                                                                      
]]

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    print(resource_banner)
  end)


