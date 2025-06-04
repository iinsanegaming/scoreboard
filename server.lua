local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('scoreboard:requestPlayers')
AddEventHandler('scoreboard:requestPlayers', function()
    local players = {}
    local lawmen = 0
    local medics = 0

    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local player = RSGCore.Functions.GetPlayer(src)

        if player then
            local jobType = player.PlayerData.job.type
            local onDuty = player.PlayerData.job.onduty == true

            local first = player.PlayerData.charinfo.firstname or "Unknown"
            local last = player.PlayerData.charinfo.lastname or ""

            if jobType == "leo" and onDuty then
                lawmen = lawmen + 1
            elseif jobType == "medic" and onDuty then
                medics = medics + 1
            end

            table.insert(players, {
                id = player.PlayerData.citizenid,
                name = first .. " " .. last,
                job = player.PlayerData.job.grade.name or "Unranked"
            })
        end
    end


    TriggerClientEvent('scoreboard:update', source, {
        players = players,
        lawmen = lawmen,
        medics = medics
    })
end)