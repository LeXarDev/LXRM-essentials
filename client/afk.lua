local LXFramework = exports['LXRM-core']:GetCoreObject()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local ignoredGroups = {
    ['mod'] = true,
    ['admin'] = true,
    ['god'] = true
}
local secondsUntilKick = 1800 -- AFK Kick Time Limit (in seconds)
local checkUser = true
local prevPos, time = nil, nil
local timeMinutes = {
    ['900'] = 'minutes',
    ['600'] = 'minutes',
    ['300'] = 'minutes',
    ['150'] = 'minutes',
    ['60'] = 'minutes',
    ['30'] = 'seconds',
    ['20'] = 'seconds',
    ['10'] = 'seconds',
}

local function updatePermissionLevel()
    LXFramework.Functions.TriggerCallback('LXRM-afkkick:server:GetPermissions', function(userGroups)
        for k in pairs(userGroups) do
            if ignoredGroups[k] then
                checkUser = false
                break
            end
            checkUser = true
        end
    end)
end

RegisterNetEvent('LXFramework:Client:OnPlayerLoaded', function()
    updatePermissionLevel()
    isLoggedIn = true
end)

RegisterNetEvent('LXFramework:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('LXFramework:Client:OnPermissionUpdate', function()
    updatePermissionLevel()
end)

CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        if isLoggedIn then
            if checkUser then
                local currentPos = GetEntityCoords(playerPed, true)
                if prevPos then
                    if currentPos == prevPos then
                        if time then
                            if time > 0 then
                                local _type = timeMinutes[tostring(time)]
                                if _type == 'minutes' then
                                    LXFramework.Functions.Notify(Lang:t('error.you_are_will_be_kicked_in',{time = math.ceil(time / 60)}), 'error', 10000)
                                elseif _type == 'seconds' then
                                    LXFramework.Functions.Notify(Lang:t('error.you_are_and_will_be_kicked_in_seconds',{time = time}), 'error', 10000)
                                end
                                time -= 1
                            else
                                TriggerServerEvent('KickForAFK')
                            end
                        else
                            time = secondsUntilKick
                        end
                    else
                        time = secondsUntilKick
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)
