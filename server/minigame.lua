AddStateBagChangeHandler(EVENTS['minigameSucceed'], nil, function(bagName, key, value, _, replicated)
    local playerId = GetPlayerFromStateBagName(bagName)
    local entity = GetEntityFromStateBagName(bagName)

    debugPrint('statebag', bagName, key, value, _, replicated)
    debugPrint('statebag player', playerId)
    debugPrint('statebag entity', entity)

    local playerId = tostring(playerId)
    if not gameStarted then
        return
    end
    if not joinedPlayers[playerId] then
        return
    end

    -- Handle failed player by mini-game
    local hasFailed = value == false
    if hasFailed then
        playerFailed(playerId)
    end
end)