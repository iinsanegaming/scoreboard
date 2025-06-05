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
        viewerPerms = data.viewerPerms,
        total = data.total,
        lawmen = data.lawmen,
        medics = data.medics,
        msg = data.msg
    })
end)

RegisterNUICallback('hideUI', function(_, cb)
    scoreboardVisible = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "toggle", display = false })
    cb({})
end)