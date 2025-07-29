local bridge = exports['luman-bridge']

Framework = {}

function Framework.hasItem(playerId, item, amount)
    return bridge:getItemAmount(playerId, item) >= amount
end

function Framework.takeItem(playerId, item, amount)
    return bridge:removeItem(playerId, item, amount)
end

function Framework.giveItem(playerId, item, amount)
    return bridge:addItem(playerId, item, amount)
end

function Framework.hasMoney(playerId, amount)
    return bridge:getMoneyAmount(playerId) >= amount
end

function Framework.takeMoney(playerId, amount)
    return bridge:removeMoney(playerId, amount)
end

function Framework.giveMoney(playerId, amount)
    return bridge:addMoney(playerId, amount)
end

function Framework.showNotification(playerId, message)
    return bridge:notify(playerId, message)
end

function Framework.getCharacterName(playerId)
    local firstName, lastName = bridge:getCharacterName(playerId)
    return firstName .. ' ' .. lastName
end