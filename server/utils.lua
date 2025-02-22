function WaitWithCondition(duration, conditionCb)
    local stopAt = GetGameTimer() + duration
    while conditionCb() and GetGameTimer() < stopAt do
        Wait(50)
    end
end