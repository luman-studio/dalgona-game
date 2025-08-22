--
-- Start marker (lobby) for entering the game 
--

local timeLeftBeforeGameStarts = 0
local playersCount = 0
local totalReward = 0
local insideStartPoint = false
local startPoint = {
    zone = nil,
    drawZone = nil,
    blip = nil,
}
local insideDrawMarkerPoint = false
local isGameAlreadyStarted = false
local isEnoughMoney = true
local isEnoughItem = true

RegisterNetEvent(EVENTS['timeLeftBeforeGameStarts'], function(v)
    timeLeftBeforeGameStarts = v
end)

RegisterNetEvent(EVENTS['refreshGameInfo'], function(v)
    playersCount = v.playersCount
    totalReward = v.totalReward
    isGameAlreadyStarted = false
    isEnoughMoney = true
    isEnoughItem = true
end)

local function createStartPoint()
    local zone = CircleZone:Create(Config.StartPoint, Config.StartPointSize, {
        name="zone",
        useZ=true,
        -- debugPoly=true
    })
    
    local drawZone = CircleZone:Create(Config.StartPoint, 50.0, {
        name="drawZone",
        useZ=false,
        -- debugPoly=true
    })

    local blip = nil
    if Config.StartPointBlip.Enabled then
        blip = AddBlipForCoord(Config.StartPoint.x,Config.StartPoint.y,Config.StartPoint.z)
        SetBlipSprite(blip, Config.StartPointBlip.Id)
        SetBlipColour(blip, Config.StartPointBlip.Color)
        SetBlipScale(blip, Config.StartPointBlip.Scale)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        SetBlipHighDetail(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U("squid_game"))
        EndTextCommandSetBlipName(blip)
    end

    zone:onPlayerInOut(function(isPointInside, point)
        insideStartPoint = isPointInside

        timeLeftBeforeGameStarts = 0
        isGameAlreadyStarted = false
        isEnoughMoney = true
        isEnoughItem = true
        
        if not gameStarted and insideStartPoint then
            TriggerServerEvent(EVENTS['joinLobby'])
        end
    
        if not insideStartPoint and not gameStarted then
            TriggerServerEvent(EVENTS['quitLobby'])
        end

        Wait(500)
    
        CreateThread(function()
            while not zone.destroyed and insideStartPoint do
                Wait(0)
                local gameInfoText = ""
                
                if gameStarted then
                    gameInfoText = "~r~GAME STARTED"
                else
                    local seconds = math.ceil(timeLeftBeforeGameStarts / 1000)

                    if isGameAlreadyStarted then
                        gameInfoText = _U("game_already_started")
                    elseif not isEnoughMoney and not isEnoughItem then
                        gameInfoText = _U("not_enaugh_money_and_item", Config.Fee)
                    elseif not isEnoughMoney then
                        gameInfoText = _U("not_enaugh_money", Config.Fee)
                    elseif not isEnoughItem then
                        gameInfoText = _U("no_required_item")
                    else
                        gameInfoText = _U("game_waiting", seconds, totalReward)
                    end
                end
    
                Draw3DText(Config.StartPoint.x, Config.StartPoint.y, Config.StartPoint.z + 1.0, gameInfoText)
            end
        end)
    end)
    drawZone:onPlayerInOut(function(isPointInside, point)
        insideDrawMarkerPoint = isPointInside
        CreateThread(function()
            while not drawZone.destroyed and insideDrawMarkerPoint do
                Wait(0)
                local gameInfoText = ""
                DrawIndicator(vec3(Config.StartPoint.x, Config.StartPoint.y, Config.StartPoint.z + 2.0), {255, 255, 255, 255})
                DrawMarker(
                    1, -- type (6 is a vertical and 3D ring)
                    vec3(Config.StartPoint.x, Config.StartPoint.y, Config.StartPoint.z - 2.0),
                    0.0, 0.0, 0.0, -- direction (?)
                    0.0, 0.0, 0.0, -- rotation (90 degrees because the right is really vertical)
                    Config.StartPointSize * 2.0, Config.StartPointSize * 2.0, 4.0, -- scale
                    Config.StartPointColor[1], Config.StartPointColor[2], Config.StartPointColor[3], Config.StartPointColor[4],
                    false, -- bob
                    true, -- face camera
                    2, -- dunno, lol, 100% cargo cult
                    false, -- rotates
                    nil, nil, -- texture
                    false -- Projects/draws on entities
                )
            end
        end)
    end)

    return zone, drawZone, blip
end

local function destroyStartPoint()
    if startPoint.zone then
        startPoint.zone:destroy()
    end
    if startPoint.drawZone then
        startPoint.drawZone:destroy()
    end
    if startPoint.blip then
        RemoveBlip(startPoint.blip)
    end
    startPoint.zone = nil
    startPoint.drawZone = nil
    startPoint.blip = nil
end

local function onEnabled()
    isEnabled = true
    destroyStartPoint()
    startPoint.zone, startPoint.drawZone, startPoint.blip = createStartPoint()
end

local function onDisabled()
    isEnabled = false
    destroyStartPoint()

    -- leave game lobby
    if insideStartPoint and not gameStarted then
        TriggerServerEvent(EVENTS['quitLobby'])
    end
end

AddStateBagChangeHandler(STATEBAGS['startPointEnabled'], nil, function(bagName, key, value)
    if value == true then
        onEnabled()
    elseif value == false then
        onDisabled()
    end
end)

CreateThread(function()
    if Config.StartPointEnabled then
        onEnabled()
    end
end)

RegisterNetEvent(EVENTS['notifyGameAlreadyStarted'], function()
    Framework.showNotification(_U("game_already_started"))
    isGameAlreadyStarted = true
end)

RegisterNetEvent(EVENTS['notifyNotEnoughMoney'], function()
    Framework.showNotification(_U("not_enaugh_money", Config.Fee))
    isEnoughMoney = false
end)

RegisterNetEvent(EVENTS['notifyNotEnoughItem'], function()
    Framework.showNotification(_U('no_required_item'))
    isEnoughItem = false
end)