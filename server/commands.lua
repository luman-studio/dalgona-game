RegisterCommand(COMMANDS['stop'], function()
    stopGame()
end, true)

RegisterCommand(COMMANDS['announce'], function()
    if gameStarted then
        return error("Game is started. First you need to finish the game.", 1)
    end

    local players = GetPlayers()
    for k,v in ipairs(players) do
        Framework.showNotification(v, _U("game_starts"))
    end
end, true)


RegisterCommand(COMMANDS['start'], function()
    startGame()
end, true)

RegisterCommand(COMMANDS['start-for-all'], function()
    for k,playerId in ipairs(GetPlayers()) do
        tryPushPlayerToLobby(playerId)
    end
    startGame()
end, true)


RegisterCommand(COMMANDS['enable'], function()
    GlobalState[STATEBAGS['startPointEnabled']] = true
    Config.StartPointEnabled = true
end, true)

RegisterCommand(COMMANDS['disable'], function()
    GlobalState[STATEBAGS['startPointEnabled']] = false
    Config.StartPointEnabled = false
end, true)

RegisterCommand(COMMANDS['left'], function(source, args, raw)
    local playerId = source
    tryQuitPlayerFromLobby(playerId)
end, true)

RegisterCommand(COMMANDS['join'], function(source, args, raw)
    local playerId = source
    tryPushPlayerToLobbyAndActivateTimer(playerId)
end, true)