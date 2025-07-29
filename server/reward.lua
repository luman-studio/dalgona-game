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

function showWinnerMessage(toWhomId, winnerId, rewardAmount)
    local winnerName = Framework.getCharacterName(winnerId)
    TriggerClientEvent('chat:addMessage', toWhomId, {
        color = { 255, 0, 0},
        multiline = true,
        args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
    })
end

function giveRewardToPlayer(playerId, reward)
    Framework.giveMoney(playerId, reward)
    -- Show winner message to all players
    if Config.ShowWinnerMessageGlobally then
        showWinnerMessage(-1, playerId, reward)
    -- Or to participants only
    else
        for _,participant in ipairs(allParticipants) do
            showWinnerMessage(participant, playerId, reward)
        end
    end
end