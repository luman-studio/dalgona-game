local xscale = 4.0
local yscale = 4.0
local aspect = GetAspectRatio(0)

local function drawSprite(dictName, textureName, duration)
    RequestStreamedTextureDict(dictName, true)
    while not HasStreamedTextureDictLoaded(dictName) do
        Wait(0)
        debugPrint('Requesting texture dictionary', dictName)
    end

    local stopAt = GetGameTimer() + duration
    while GetGameTimer() < stopAt do
        DrawSprite(dictName, textureName, 0.5, 0.1, xscale * 0.08, yscale * 0.08 * aspect, 0, 255, 255, 255, 255)
        Wait(0)
    end
end

RegisterNetEvent(EVENTS['drawCountdown'], function()
    local timestamp = GetGameTimer()
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    drawSprite("squidgame", "1", 1000)
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    drawSprite("squidgame", "2", 1000)
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    drawSprite("squidgame", "3", 1000)
end)