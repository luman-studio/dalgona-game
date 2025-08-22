debugPrint('Game Init')

if Config.AccumulativeReward then
    totalReward = math.max(GetResourceKvpInt('totalReward') or 0, 0)
else
    totalReward = 0
end

gameStarted = false
joinedPlayers = {}
allParticipants = {}

function isGameStarted()
    return gameStarted
end

function startGame()
    if gameStarted then
        return
    end
    
    if next(joinedPlayers) == nil then
        return
    end
    
    -- Store all participants during whole game
    allParticipants = {}
    for playerId,v in pairs(joinedPlayers) do
        table.insert(allParticipants, playerId)
    end

    -- Check for min players requirement
    if #allParticipants < Config.MinimumParticipants then
        for k,v in ipairs(allParticipants) do
            Framework.showNotification(v, _U('minimum_participatns_requirement_%s', Config.MinimumParticipants))
        end
        return
    end

    gameStarted = true

    -- Set player models, clothes and teleport them into game area
    -- Start cutscene
    local occupiedSpawnsByPlayers = {}
    local nextSpawnIdx = 1
    for playerId,v in pairs(joinedPlayers) do
        local playerPed = GetPlayerPed(playerId)
        local playerPedModel = GetEntityModel(playerPed)
        -- Set player model via server-side
        -- It's a workaround for crash: low-cola-sweet
        -- 13.01.2025
        -- Crash reproduction:
        -- Player 1 - MP female character with clothes
        -- Player 2 - Usual Ped (Hipster)
        -- And move below functionality to client-side into `gameInitiated` handler
        if Config.UsePedModelsInsteadOutfitsForPlayers then
            -- Set usual ped model
            if #Config.PlayerPeds > 0 then
                local hash = GetHashKey(Config.PlayerPeds[math.random(#Config.PlayerPeds)])
                SetPlayerModel(playerId, hash)
            end
        elseif Config.AllowCustomPeds then
            -- Just skip setting new model
        else
            -- Set MP male/female model
            if playerPedModel ~= GetHashKey("mp_m_freemode_01") and playerPedModel ~= GetHashKey("mp_f_freemode_01") then
                local maleModel = "mp_m_freemode_01"
                local femaleModel = "mp_f_freemode_01"
                local randomValue = math.random(0, 1)
                local selectedModel = randomValue == 1 and maleModel or femaleModel
                local model = GetHashKey(selectedModel)
                SetPlayerModel(playerId, model)
                while GetEntityModel(GetPlayerPed(playerId)) ~= model do
                    Wait(0)
                end
            end
        end

        -- Teleport
        local spawnIdx = nextSpawnIdx
        local coords = Config.SpawnCoords.GameStarted[spawnIdx]
        TriggerClientEvent(EVENTS['gameInitiated'], playerId, coords, playerPedModel)
        occupiedSpawnsByPlayers[tostring(spawnIdx)] = true

        -- Get next spawn point
        nextSpawnIdx = nextSpawnIdx + 1
        if nextSpawnIdx > #Config.SpawnCoords.GameStarted then
            nextSpawnIdx = 1
        end
    end

    -- Spawn participants NPC's with delay, to avoid issue with unloaded map
    for playerId,v in pairs(joinedPlayers) do
        TriggerClientEvent(EVENTS['spawnNPC'], playerId)
    end

    -- Wait for cutscene
    if Config.Cutscene.Enabled then
        local sequenceDuration = 0
        for k,v in ipairs(Config.Cutscene.Sequence) do
            sequenceDuration = sequenceDuration + v.transitionTime + v.waitTime
        end
        WaitWithCondition(sequenceDuration, isGameStarted)
        if not isGameStarted() then
            return
        end
    end

    -- Show initial countdown
    Wait(0)
    for playerId,v in pairs(joinedPlayers) do
        TriggerClientEvent(EVENTS['drawCountdown'], playerId)
    end
    Wait(3000)
    if not isGameStarted() then
        return
    end

    -- Get players amount
    local playersAmount = getPlayersCount()
    TriggerEvent(EVENTS['gameStarted'], playersAmount)

    -- Unfreeze players
    for playerId,v in pairs(joinedPlayers) do
        local playerPed = GetPlayerPed(playerId)
        TriggerClientEvent(EVENTS['gameStarted'], playerId, playersAmount)
    end

    -- Stop game when time is up
    CreateThread(function()
        local timestamp = GetGameTimer()
        while gameStarted and GetGameTimer() - timestamp < Config.GameDuration do
            Wait(1000)
        end
        if gameStarted then
            stopGame()
        end
    end)

    while gameStarted do
        Wait(100)
    end

    if gameStarted then
        stopGame()
    end
end

function stopGame()
    -- Calculate reward per player
    local rewardPerPlayer = getRewardPerPlayer()

    -- Process players
    for playerId,v in pairs(joinedPlayers) do

        -- Check if player succeed
        local succeed = hasPlayerSucceed(playerId) 
        
        -- Give reward
        if succeed then
            giveRewardToPlayer(playerId, rewardPerPlayer)
            totalReward = totalReward - rewardPerPlayer
        end

        -- Give reward item if configured
        if Config.RewardItem and Config.RewardItem ~= '' then
            Framework.giveItem(playerId, Config.RewardItem, 1)
        end

        -- Reset player
        resetPlayer(playerId, succeed)
    end

    joinedPlayers = {}

    -- Erase all participants when the game stopped
    allParticipants = {}

    -- Keep reward for next game / reset reward
    if Config.AccumulativeReward then
        SetResourceKvpInt('totalReward', totalReward)
    else
        totalReward = 0
    end

    gameStarted = false

    TriggerEvent(EVENTS['gameOver'])
end

function resetPlayer(playerId, didSucceed)
    local coords = nil
    if didSucceed then
        local successSpawns = Config.SpawnCoords.GameSuccess
        if #successSpawns > 0 then
            coords = successSpawns[math.random(#successSpawns)]
        end
    else
        local failedSpawns = Config.SpawnCoords.GameFailed
        if #failedSpawns > 0 then
            local playerPed = GetPlayerPed(playerId)
            coords = failedSpawns[math.random(#failedSpawns)]
        end
    end

    TriggerClientEvent(EVENTS['resetPlayer'], playerId, didSucceed, coords)
end

function playerFailed(playerId)
    -- Remove player from the list of joined players
    joinedPlayers[tostring(playerId)] = nil

    -- Reset player
    resetPlayer(playerId, false)

    -- If we still have players - notify about changed players count
    if next(joinedPlayers) ~= nil then
        TriggerEvent(EVENTS['onPlayersAmountChanged'])
        return
    end

    -- Stop the game if there no more players
    stopGame()
end

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    playerFailed(playerId)
end)

RegisterNetEvent(EVENTS['onPlayerOutOfGameZone'], function()
    local playerId = tostring(source)

    if not gameStarted then
        return
    end

    if not joinedPlayers[playerId] then
        return
    end

    playerFailed(playerId)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then

    end
end)