# Mini-game Documentation - for Manual Mode

This is documentation for Manual Mode of the Mingle-Game. Manual mode is basically Candy Mini-Game which is triggered by command or by item usage. By default you can use a command `/dalgona-game-manual` to start it or you can disable it in `config.lua` and use instead item from inventory to trigger the mini-game.

## Events
```lua
-- Trigger mini-game start. From server-side:
TriggerClientEvent('dalgona-game:startMinigameManually', playerId, 'triangle', 120)

-- Trigger mini-game start. From client-side:
TriggerEvent('dalgona-game:startMinigameManually', 'square', 120)
```

## List of patterns that can be used in Event Trigger
- circle
- triangle
- square
- star
- umbrella
- random

## Items
First you have to add new items in your framework (images for items inside `item_images` folder). Then you need to define handlers for item usage and inside them trigger mini-game to start. For example this is how it can be done in ESX/QB frameworks:
```lua
-- Server-side:

-- Define handler for item usage for ESX framework.
ESX.RegisterUsableItem('dalgona_circle', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer.hasItem('dalgona_circle') then
        xPlayer.removeInventoryItem('dalgona_circle', 1)
        TriggerClientEvent('dalgona-game:startMinigameManually', playerId, 'circle', 120)
    end
end)

-- Define handler for item usage for QB framework. Server-side:
QBCore.Functions.CreateUseableItem('dalgona_umbrella', function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player.Functions.RemoveItem('dalgona_umbrella', 1) then
        TriggerClientEvent('dalgona-game:startMinigameManually', playerId, 'umbrella', 120)
    end
end)
```

## Game Over
If you want to do something aditional after the game has over you can use event handler on client-side.
```lua
-- client-side
AddEventHandler('dalgona-game:onManualMinigameFinished', function(hasSucceed)
    if hasSucceed then
        print('The game is over, you won.')
    else
        print('The game is over, you lost.')
    end
end)
```