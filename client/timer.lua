local airdropTimer
startTimer = function(s)
    s = math.ceil(s)

    local m = math.floor(s / 60)
    local s = s - m * 60
    SendNUIMessage({
        start = true,
        s = s,
        m = m,
        playTickTockSound = true,
    })
end

hideTimer = function()
    SendNUIMessage({
        hideTimer = true,
        stopTickTockSound = true,
    })
end

resetTimer = function()
    SendNUIMessage({
        reset = true,
    })
end