Framework = {}
function Framework.takeMoney(playerId, amount)
    playerId = tonumber(playerId)
    
    if Config.Framework == FRAMEWORK_ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local money = xPlayer.getMoney()
        if money >= amount then
            xPlayer.removeMoney(amount)
            return true
        end
        return false
    elseif Config.Framework == FRAMEWORK_QB then
		local Ply = QBCore.Functions.GetPlayer(playerId)
		if Ply.PlayerData.money["cash"] >= amount then
            return Ply.Functions.RemoveMoney("cash", amount, "squid-game-level-1")
		else
            return false
        end
    elseif Config.Framework == FRAMEWORK_VRP then
        local userId = vRP.getUserId({playerId})
        if vRP.tryPayment({userId, amount}) then
            return true
        else
            return false
        end	
    elseif Config.Framework == FRAMEWORK_STANDALONE then
        Framework.showNotification(playerId, _U('removed_money', amount))
        return true
    end
end

function Framework.giveMoney(playerId, amount)
    playerId = tonumber(playerId)

    if Config.Framework == FRAMEWORK_ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addMoney(amount)
        return true
    elseif Config.Framework == FRAMEWORK_QB then
		local Ply = QBCore.Functions.GetPlayer(playerId)
        return Ply.Functions.AddMoney("cash", amount, "squid-game-level-1")
    elseif Config.Framework == FRAMEWORK_VRP then
        local userId = vRP.getUserId({playerId})
        vRP.giveMoney({userId, amount})
        return true
    elseif Config.Framework == FRAMEWORK_STANDALONE then
        Framework.showNotification(playerId, _U('received_money', amount))
        return true
    end
end

function Framework.showNotification(playerId, message)
    if Config.Framework == FRAMEWORK_ESX then
        TriggerClientEvent("esx:showNotification", playerId, message)
    elseif Config.Framework == FRAMEWORK_QB then
        TriggerClientEvent('QBCore:Notify', playerId, message)
    elseif Config.Framework == FRAMEWORK_VRP then
        local vRPclient = Tunnel.getInterface("vRP", GetCurrentResourceName())
        vRPclient.notify(playerId, {message})
    elseif Config.Framework == FRAMEWORK_STANDALONE then
        TriggerClientEvent(EVENTS['notification'], playerId, message)
        return true
    end
end

function Framework.showWinnerMessage(toWhomId, winnerId, rewardAmount)
    local winnerName = GetPlayerName(winnerId)

    if Config.Framework == FRAMEWORK_ESX then
        local xPlayer = ESX.GetPlayerFromId(winnerId)
        if xPlayer then
            winnerName = xPlayer.getName()
        end
        TriggerClientEvent('chat:addMessage', toWhomId, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
        })
    elseif Config.Framework == FRAMEWORK_QB then
        local Ply = QBCore.Functions.GetPlayer(winnerId)
        if Ply then
            winnerName = Ply.PlayerData.charinfo.firstname .. " " .. Ply.PlayerData.charinfo.lastname
        end
        TriggerClientEvent('chat:addMessage', toWhomId, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
        })
    elseif Config.Framework == FRAMEWORK_VRP then
        local winnerName = GetPlayerName(winnerId)
        TriggerClientEvent('chat:addMessage', toWhomId, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
        })

        -- local userId = vRP.getUserId({toWhomId})
        -- vRP.getUserIdentity(userId, function(identity)
        --     if identity then
        --         winnerName = identity.firstname .. " " .. identity.name
        --     end
        --     TriggerClientEvent('chat:addMessage', toWhomId, {
        --         color = { 255, 0, 0},
        --         multiline = true,
        --         args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
        --     })
        -- end)
    elseif Config.Framework == FRAMEWORK_STANDALONE then
        TriggerClientEvent('chat:addMessage', toWhomId, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Config.GameName, _U("player_%s_won_%s", winnerName, rewardAmount)}
        })
    end
end