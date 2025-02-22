function hasPlayerSucceed(playerId)
    return Player(playerId).state[STATEBAGS['minigameSucceed']] == true
end

function getRewardPerPlayer()
    local succeedPlayersCounter = 0
    for playerId,v in pairs(joinedPlayers) do
        if hasPlayerSucceed(playerId) then
            succeedPlayersCounter = succeedPlayersCounter + 1
        end
    end
    local rewardPerPlayer = math.floor(totalReward / succeedPlayersCounter)
    return rewardPerPlayer
end

function giveRewardToPlayer(playerId, reward)
    Framework.giveMoney(playerId, reward)
    -- Show winner message to all players
    if Config.ShowWinnerMessageGlobally then
        Framework.showWinnerMessage(-1, playerId, reward)
    -- Or to participants only
    else
        for _,participant in ipairs(allParticipants) do
            Framework.showWinnerMessage(participant, playerId, reward)
        end
    end
end