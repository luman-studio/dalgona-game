local entities = {}

function startMinigameManually(pattern, timeLimit)
    timeLimit = timeLimit or 30

    LocalPlayer.state:set(STATEBAGS['dalgonaManualSucceed'], nil, true)
    
    local stopAt = GetGameTimer() + (timeLimit * 1000)
    
    -- Show timer
    SendNUIMessage({
        show = true,
        hideParticipantsCounter = true,
    })
    startTimer(timeLimit)

    local playerPed = PlayerPedId()

    -- Spawn guard near player
    local guardPed = nil
    if Config.ManualMode.SpawnGuardNearPlayer.Enabled then
        local isNetworked = Config.ManualMode.SpawnGuardNearPlayer.Networked

        local modelHash = GetHashKey("mp_m_freemode_01")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            debugPrint('wait for guard model')
            Wait(0)
        end

        local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.7, 0.0)
        local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z - 1.0, heading, isNetworked, false)
        Wait(0)
        if DoesEntityExist(ped) then
            GiveWeaponToPed(ped, `WEAPON_SMG`, 0, false, true)
            SetCurrentPedWeapon(ped, `WEAPON_SMG`, true)
            SetEntityInvincible(ped, true)
            SetPedConfigFlag(ped, 17, true) -- Ignore events
            SetPedConfigFlag(ped, 208, true) -- CPED_CONFIG_FLAG_DisableExplosionReactions
            SetPedConfigFlag(ped, 306, true) -- CPED_CONFIG_FLAG_DontActivateRagdollFromPlayerPedImpact
            SetPedConfigFlag(ped, 108, true) -- CPED_CONFIG_FLAG_DontActivateRagdollFromExplosions

            for k,v in pairs(Config.GuardOutfits[1]) do
                SetPedComponentVariation(
                    ped, 
                    k,
                    v[1],
                    v[2]
                )
            end
    
            -- Aim at player
            TaskAimGunAtEntity(ped, playerPed, -1, true)

            table.insert(entities, ped)
            guardPed = ped
        else
            print('Failed to spawn guard near the player. You hit NPC limit on your server.')
        end
    end

    -- Start mini-game
    if pattern == 'random' then
        pattern = nil
    end
    local hasSucceed = startMinigame(pattern, function()
        return GetGameTimer() < stopAt
    end)

    TriggerEvent('dalgona-game:onManualMinigameFinished', hasSucceed)

    -- Play Win/Lose animation
    if hasSucceed then
        if Config.ManualMode.WinAnimation.Enabled then
            local animations = Config.ManualMode.WinAnimation.List
            local anim = animations[math.random(#animations)]
            local dict, name = anim[1], anim[2]
            PlayAnimation(playerPed, {
                dict = dict,
                name = name,
                blendInSpeed = 1.0,
                blendOutSpeed = 1.0,
                duration = Config.ManualMode.WinAnimation.Duration or GetAnimDuration(dict, name),
                flag = 1 + 8,
                playbackRate = 0.0,
            })
        end
    else
        if Config.ManualMode.LoseAnimation.Enabled then
            local animations = Config.ManualMode.LoseAnimation.List
            local anim = animations[math.random(#animations)]
            local dict, name = anim[1], anim[2]
            PlayAnimation(playerPed, {
                dict = dict,
                name = name,
                blendInSpeed = 1.0,
                blendOutSpeed = 1.0,
                duration = Config.ManualMode.LoseAnimation.Duration or GetAnimDuration(dict, name),
                flag = 1 + 8,
                playbackRate = 0.0,
            })
        end
    end

    -- Autokill
    if Config.ManualMode.AutokillEnabled and not hasSucceed then
        Wait(2000)

        CreateThread(function()
            -- Blood headshot effect
            callBloodHeadshotEffectOnPed(playerPed)

            -- Play shot sound
            local coords = GetEntityCoords(playerPed)
            local isNetworked = true
            PlayPistolSound(coords, isNetworked)
        end)

        SetEntityHealth(playerPed, 0)
    end

    -- If guard spawned - he walks away  
    if Config.ManualMode.SpawnGuardNearPlayer.Enabled then
        if DoesEntityExist(guardPed) then
            SetEntityAsNoLongerNeeded(guardPed)
            TaskWanderStandard(guardPed, 10.0, 10)
            SetTimeout(5000, function()
                if DoesEntityExist(guardPed) then
                    DeleteEntity(guardPed)
                end
            end)
        end
    end

    -- Show win/lose indicator in case if auto-kill disabled (trigger statebag handler)
    if Config.ManualMode.WinLoseIndicatorAboveHeadEnabled then
        LocalPlayer.state:set(STATEBAGS['dalgonaManualSucceed'], hasSucceed, true)
    end

    -- Hide timer
    hideTimer()
    SendNUIMessage({
        show = false,
    })
end

AddStateBagChangeHandler(STATEBAGS['dalgonaManualSucceed'], nil, function(bagName, key, value, _, replicated)
    local playerId = GetPlayerFromStateBagName(bagName)

    -- Skip duplicated handler for localplayer
    if PlayerId() == playerId and replicated then
        return
    end

    -- Skip state reset
    if value == nil then
        return
    end

    -- Wait for value set
    local playerStateEntity = Player(GetPlayerServerId(playerId))
    while playerStateEntity.state[STATEBAGS['dalgonaManualSucceed']] ~= value do Wait(0) end

    -- Draw indiciator above player's head
    local playerPed = GetPlayerPed(playerId)
    local hasSucceed = value
    local rgba = hasSucceed and {0, 255, 0, 255} or {255, 0, 0, 255}
    local stopDrawAt = GetGameTimer() + Config.ManualMode.WinLoseIndicatorDuration
    local textureDict = 'dalgona_textures'
    local textureName = 'squid-circle'
    local bob = not hasSucceed
    RequestStreamedTextureDict(textureDict, true)
    while not HasStreamedTextureDictLoaded(textureDict) do
        Wait(0)
    end
    while playerStateEntity.state[STATEBAGS['dalgonaManualSucceed']] ~= nil and GetGameTimer() < stopDrawAt and DoesEntityExist(playerPed) and not IsEntityDead(playerPed) do
        Wait(0)
        local coords = GetEntityCoords(playerPed)
        local scale = 0.5
        DrawMarker(
            9, -- type (6 is a vertical and 3D ring)
            vector3(coords.x, coords.y, coords.z + 1.5),
            0.0, 0.0, 0.0, -- direction (?)
            90.0, 90.0, 0.0, -- rotation (90 degrees because the right is really vertical)
            scale, scale, scale, -- scale
            rgba[1], rgba[2], rgba[3], rgba[4],
            bob, -- bob
            true, -- face camera
            2, -- dunno, lol, 100% cargo cult
            false, -- rotates
            textureDict, textureName, -- texture
            false -- Projects/draws on entities
        )
    end
end)

---------------
-- API Event --
---------------
RegisterNetEvent('dalgona-game:startMinigameManually', function(pattern, timeLimit)
    startMinigameManually(pattern, timeLimit)
end)

if Config.ManualMode.Command.Enabled then
    local inCooldown = false
    RegisterCommand(Config.ManualMode.Command.Name, function(playerId, args)
        -- Colldown
        if inCooldown then
            Framework.showNotification(_('minigame_in_cooldown'))
            return
        end
        inCooldown = true

        -- Game
        startMinigameManually(nil, Config.ManualMode.Command.Duration / 1000)

        -- Cooldown
        SetTimeout(Config.ManualMode.Command.Cooldown, function()
            inCooldown = false
        end)
    end, false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k,v in ipairs(entities) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
        entities = {}
    end
end)