gameInitiated = false
gameStarted = false

gameZone = BoxZone:Create(Config.ZoneCoords.GameCenter, Config.ZoneCoords.GameWidth, Config.ZoneCoords.GameLength, {
    name = "gameZone",
    heading = 0,
    useZ = true,
    debugPoly = Config.Debug
})

insideGameZone = false
gameZone:onPlayerInOut(function(isPointInside, point)
    insideGameZone = isPointInside
    if gameStarted and not insideGameZone then
        TriggerServerEvent(EVENTS['onPlayerOutOfGameZone'])
    end

    -- For manual mode
    if isPointInside then
        TriggerServerEvent(EVENTS['enteredGameZone'])
    else
        TriggerServerEvent(EVENTS['leftGameZone'])
    end
end)

function restrictPlayerOnTick()
    local playerPed = PlayerPedId()

    if Config.EnableGodmode then
        SetEntityInvincible(playerPed, true)
        SetPlayerInvincible(PlayerId(), true)
    end

    if Config.InGameTick then
        Config.InGameTick(playerPed)
    end
end

RegisterNetEvent(EVENTS['gameStarted'], function()
    gameStarted = true
end)

RegisterNetEvent(EVENTS['resetPlayer'], function(didSucceed, coords)
    local playerPed = PlayerPedId()

    -- Reset state
    hideTimer()
    gameStarted = false
    SetTimeout(5000, function()
        SendNUIMessage({
            stopSong = true,
        })
    end)

    -- Show notification
    Framework.showNotification(_U("game_finished"))

    -- Immitate player's death
    local IK_Head = 12844
    if not didSucceed then
        -- Set to ragdoll (immitate death)
        ClearPedTasks(playerPed)
        SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)

        -- Make a thread, because we expect delays in playin sound or visual effect
        CreateThread(function()
            -- Blood headshot effect
            callBloodHeadshotEffectOnPed(playerPed)

            -- Play shot sound
            local coords = GetEntityCoords(playerPed)
            local isNetworked = true
            PlayPistolSoundFrontend()
            PlayPistolSound(coords, isNetworked)
        end)
        
        Wait(1500)
    end

    if didSucceed then
        SendNUIMessage({
            playSong = 'win.wav',
        })
    end

    -- Set player on position
    if coords then
        SetEntityCoords(playerPed, coords)
    end

    -- Restore skin
    if Config.ChangePlayerSkin then
        restorePlayerSkin()
    end

    cleanUpNPCsAndProps()
    cleanupAllDecals()

    gameInitiated = false
end)

RegisterNetEvent(EVENTS['gameInitiated'], function(coords, lastPlayerModel)
    gameInitiated = true
    
    hideTimer()
    
    -- Set Player Camera looking to direction
    -- SetGameplayCoordHint(Config.CarouselCoords.x, Config.CarouselCoords.y, Config.CarouselCoords.z, 500, 500, 500)

    -- Set player clothes
    if Config.ChangePlayerSkin then
        savePlayerSkin(lastPlayerModel)
        setPlayerSkinForGame()
    end

    -- Wait for the end of game
    while gameInitiated do
        Wait(0)
        restrictPlayerOnTick()  
    end

    -- Disable godmode if was enabled
    if Config.EnableGodmode then
        local playerPed = PlayerPedId()
        SetEntityInvincible(playerPed, false)
        SetPlayerInvincible(PlayerId(), false)
    end
end)