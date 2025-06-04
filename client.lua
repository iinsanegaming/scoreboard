local scoreboardVisible = false

RegisterCommand("scoreboard", function()
    scoreboardVisible = not scoreboardVisible

    SetNuiFocus(scoreboardVisible, false)
    SendNUIMessage({ type = "toggle", display = scoreboardVisible })

    if scoreboardVisible then
        TriggerServerEvent('scoreboard:requestPlayers')
    end
end, false)


RegisterNetEvent('scoreboard:update')
AddEventHandler('scoreboard:update', function(data)
    SendNUIMessage({
        type = "update",
        players = data.players,
        lawmen = data.lawmen,
        medics = data.medics
    })
end)

RegisterNUICallback('hideUI', function(_, cb)
    scoreboardVisible = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "toggle", display = false })
    cb({})
end)

RegisterNetEvent('scoreboard:update')
AddEventHandler('scoreboard:update', function(data)
    SendNUIMessage({
        type = "update",
        players = data.players,
        lawmen = data.lawmen,
        medics = data.medics
    })
end)
