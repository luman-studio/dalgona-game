function refreshGameInfo()
    local playersCount = 0
    for k,v in pairs(joinedPlayers) do
        playersCount = playersCount + 1
    end

    for k,v in pairs(joinedPlayers) do
        TriggerClientEvent(EVENTS['refreshGameInfo'], k, {
            playersCount = playersCount,
            totalReward = totalReward,
        })
    end
end

function tryPushPlayerToLobby(playerId)
    if joinedPlayers[tostring(playerId)] then
        Framework.showNotification(playerId, _U("player_already_joined", playerId))
        return false
    end
    
    if gameStarted then
        TriggerClientEvent(EVENTS['notifyGameAlreadyStarted'], playerId)
        return false
    end

    -- Check money
    local hasMoney = true
    if Config.Fee and Config.Fee > 0 then
        if not Framework.hasMoney(playerId, Config.Fee) then
            TriggerClientEvent(EVENTS['notifyNotEnoughMoney'], playerId)
            hasMoney = false
        end
    end

    -- Check item
    local hasItem = true
    if Config.FeeItem and Config.FeeItem ~= '' then
        if not Framework.hasItem(playerId, Config.FeeItem, 1) then
            TriggerClientEvent(EVENTS['notifyNotEnoughItem'], playerId)
            hasItem = false
        end
    end

    if not hasMoney or not hasItem then
        return false
    end

    -- Take money
    if Config.Fee and Config.Fee > 0 then
        Framework.takeMoney(playerId, Config.Fee)
        totalReward = totalReward + Config.Fee
    end

    -- Take item
    if Config.FeeItem and Config.FeeItem ~= '' then
        Framework.takeItem(playerId, Config.FeeItem, 1)
    end
    

    for playerId,v in pairs(joinedPlayers) do
        Framework.showNotification(playerId, _U("player_joined", playerId))
    end

    joinedPlayers[tostring(playerId)] = true
    Framework.showNotification(playerId, _U("you_joined_game"))

    refreshGameInfo()

    Player(playerId).state:set("squidgame:inFinishZone", false, true)

    return true
end

function tryPushPlayerToLobbyAndActivateTimer(playerId)
    local isPushed = tryPushPlayerToLobby(playerId)
    if isPushed then
        CreateThread(function()
            tryActivateTimer(playerId)
        end)
    end
end

RegisterNetEvent(EVENTS['joinLobby'], function()
    local playerId = source
    tryPushPlayerToLobbyAndActivateTimer(playerId)
end)

RegisterNetEvent(EVENTS['quitLobby'], function()
    local playerId = source
    tryQuitPlayerFromLobby(playerId)
end)

function tryQuitPlayerFromLobby(playerId)
    if gameStarted then
        return false
    end

    if not joinedPlayers[tostring(playerId)] then
        return false
    end

    joinedPlayers[tostring(playerId)] = nil

    if Config.Fee and Config.Fee > 0 then
        Framework.giveMoney(playerId, Config.Fee)
        totalReward = totalReward - Config.Fee
    end

    if Config.FeeItem and Config.FeeItem ~= '' then
        Framework.giveItem(playerId, Config.FeeItem, 1)
    end

    Framework.showNotification(playerId, _U("you_left_game"))
    refreshGameInfo()
end



-- Start timer when first player joined lobby
local timerStarted = false
function tryActivateTimer(byPlayerId)
    if gameStarted then
        return
    end
    
    if timerStarted then 
        return 
    end

    timerStarted = true
    local gameStartsAt = GetGameTimer() + Config.GameStartInterval
    while not gameStarted and next(joinedPlayers) do

        local timeLeftBeforeGameStarts = math.max(0, gameStartsAt - GetGameTimer())
        for playerId,v in pairs(joinedPlayers) do
            TriggerClientEvent(EVENTS['timeLeftBeforeGameStarts'], playerId, timeLeftBeforeGameStarts)
        end

        if timeLeftBeforeGameStarts == 0 then
            CreateThread(function()
                startGame()
            end)
            break
        end
        
        Wait(1000)
    end

    timerStarted = false
end

AddEventHandler(EVENTS['gameOver'], function()
    -- After we finished the game
    -- Get players inside starting point marker and automatically push them into lobby
    local playersInside = 0
    for k,playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        local coords = GetEntityCoords(ped)
        if #(coords - Config.StartPoint) <= Config.StartPointSize then
            playersInside = playersInside + 1
            tryPushPlayerToLobby(playerId)
        end
    end
    if playersInside > 0 then
        tryActivateTimer()
    end
end)

GlobalState[STATEBAGS['startPointEnabled']] = Config.StartPointEnabled
