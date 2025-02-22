---------------
-- Show/hide --
---------------
RegisterNetEvent(EVENTS['gameStarted'], function(playersAmount)
    SendNUIMessage({
        show = true,
    })
    startTimer(Config.GameDuration / 1000)
end)
RegisterNetEvent(EVENTS['resetPlayer'], function(playersAmount)
    SendNUIMessage({
        show = false,
    })
end)

---------------------------------
-- Update Participatns Counter --
---------------------------------
RegisterNetEvent(EVENTS['gameStarted'], function(playersAmount)
    SendNUIMessage({
        setParticipantsCounter = playersAmount,
        show = true,
    })
end)
RegisterNetEvent(EVENTS['setParticipantsCounter'], function(playersAmount)
    SendNUIMessage({
        setParticipantsCounter = playersAmount,
        show = true,
    })
end)