local playersInGame = 0

function getPlayersCount()
    local playersCount = 0
    for playerId,v in pairs(joinedPlayers) do
        playersCount = playersCount + 1
    end
    return playersCount
end

AddEventHandler(EVENTS['gameStarted'], function(playersAmount)
    playersInGame = playersAmount
end)

AddEventHandler(EVENTS['onPlayersAmountChanged'], function()
    -- Get players count
    local playersCount = getPlayersCount()

    -- Notify players
    for playerId,v in pairs(joinedPlayers) do
        TriggerClientEvent(EVENTS['setParticipantsCounter'], playerId, playersCount)
    end

    -- Set global value
    playersInGame = playersCount
end)

AddEventHandler(EVENTS['gameOver'], function()
    playersInGame = 0
end)