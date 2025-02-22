local frozen = false

local interiorId = 0

-- Freeze player and request collision
RegisterNetEvent(EVENTS['gameInitiated'], function(coords)
    Wait(0)
    debugPrint('Game initiated:')

    -- Teleport and freeze player
    debugPrint('- Teleporting and freezing player')
    SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityHeading(PlayerPedId(), 0.0)

    -- Force interior loading
    debugPrint('- Requesting MLO loading')
    interiorId = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if IsValidInterior(interiorId) then
        PinInteriorInMemory(interiorId)
        SetInteriorActive(interiorId, true)
        RefreshInterior(interiorId)
    end

    -- Force collision loading
    debugPrint('- Requesting collision loading')
    -- Make sure player is frozen during collision loading
    local stopAt = GetGameTimer() + 5000
    frozen = true
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() < stopAt do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(100)
    end
    
    -- Game starting, make sure player is frozen before game countdown over
    while gameInitiated and not gameStarted do
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(100)
    end

    -- Unfreeze player
    FreezeEntityPosition(PlayerPedId(), false)
    frozen = false
end)

RegisterNetEvent(EVENTS['resetPlayer'], function()
    if IsValidInterior(interiorId) then
        UnpinInterior(interiorId)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if frozen then
            FreezeEntityPosition(PlayerPedId(), false)
            if IsValidInterior(interiorId) then
                UnpinInterior(interiorId)
            end
        end
    end
end)