local bridge = exports['luman-bridge']

Framework = {}

function Framework.showNotification(message)
    return bridge:notify(message)
end