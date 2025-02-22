local lastPlayerModel
local skinData

function restorePlayerSkin()
    local playerPed = PlayerPedId()
    if lastPlayerModel and GetEntityModel(playerPed) ~= lastPlayerModel then
        RequestModel(lastPlayerModel)
        while not HasModelLoaded(lastPlayerModel) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), lastPlayerModel)
        playerPed = PlayerPedId()
    end
    if skinData then
        SetSkinData(playerPed, skinData)
    end
    lastPlayerModel = nil
    skinData = nil
end

function savePlayerSkin(playerModel)
    if playerModel then
        lastPlayerModel = playerModel
    else
        lastPlayerModel = GetEntityModel(PlayerPedId())
    end
    skinData = GetSkinData(PlayerPedId())
end

function setPlayerSkinForGame()
    local playerId = PlayerId()

    -- Player model is set via server-side
    -- It's a workaround for crash: low-cola-sweet

    local playerPed = PlayerPedId()
    local playerPedModel = GetEntityModel(playerPed)

    -- Set clothes
    if playerPedModel == GetHashKey("mp_m_freemode_01") then
        if #Config.PlayerOutfits["male"] > 0 then
            for k,v in pairs(Config.PlayerOutfits["male"][math.random(#Config.PlayerOutfits["male"])]) do
                SetPedComponentVariation(
                    playerPed, 
                    k,
                    v[1],
                    v[2]
                )
            end
        end
    elseif playerPedModel == GetHashKey("mp_f_freemode_01") then
        if #Config.PlayerOutfits["female"] > 0 then
            for k,v in pairs(Config.PlayerOutfits["female"][math.random(#Config.PlayerOutfits["female"])]) do
                SetPedComponentVariation(
                    playerPed, 
                    k,
                    v[1],
                    v[2]
                )
            end
        end
    end
end