Framework = {}

function Framework.showNotification(message)
    if Config.Framework == FRAMEWORK_ESX then
        return ESX.ShowNotification(message)
    elseif Config.Framework == FRAMEWORK_QB then
        TriggerEvent('QBCore:Notify', message)
    elseif Config.Framework == FRAMEWORK_VRP then
        vRP.notify({message})
    elseif Config.Framework == FRAMEWORK_STANDALONE then
        TriggerEvent(EVENTS['notification'], message)
        return true
    end
end

RegisterNetEvent(EVENTS['notification'], function(message)
    showNotification(message)
end)