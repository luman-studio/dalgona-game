function debugPrint(msg, ...)
    if Config.Debug then
        print('^1[DEBUG]:^0 ' .. msg, ...)
    end
end