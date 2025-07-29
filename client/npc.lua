local createdPeds = {}
local createdProps = {}

local function spawnParticipantsNPC()
    for spawnIdx,spawnCoords in ipairs(Config.SpawnCoords.ParticipantsNPC) do
        debugPrint('spawn participant', spawnIdx)
        local isMale = math.random(0, 1) == 1
        local modelHash = nil
        if Config.UsePedModelsInsteadOutfitsForPlayers then
            if #Config.PlayerPeds > 0 then
                modelHash = GetHashKey(Config.PlayerPeds[math.random(#Config.PlayerPeds)])
            else
                break -- NPC's not created, because `Config.PlayerPeds` is empty 
            end
        else
            if isMale then
                modelHash = GetHashKey("mp_m_freemode_01")
            else
                modelHash = GetHashKey("mp_f_freemode_01")
            end
        end

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            debugPrint('wait for particpant model')
            Wait(0)
        end

        local heading = math.random(0, 359) + 0.0
        spawnCoords = spawnCoords + vec3(0.0, 0.0, -1.0) -- no offset
        local ped = CreatePed(0, modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, false, false)
        local timeoutAt = GetGameTimer() + 200
        while not DoesEntityExist(ped) and GetGameTimer() < timeoutAt do
            debugPrint('wait for particpant creation')
            Wait(0)
        end

        if DoesEntityExist(ped) then
            FreezeEntityPosition(ped, true)

            -- Set clothes
            if not Config.UsePedModelsInsteadOutfitsForPlayers then
                if isMale and #Config.PlayerOutfits["male"] > 0 then
                    for k,v in pairs(Config.PlayerOutfits["male"][math.random(#Config.PlayerOutfits["male"])]) do
                        SetPedComponentVariation(
                            ped, 
                            k,
                            v[1],
                            v[2]
                        )
                    end
                elseif not isMale and #Config.PlayerOutfits["female"] > 0 then
                    for k,v in pairs(Config.PlayerOutfits["female"][math.random(#Config.PlayerOutfits["female"])]) do
                        SetPedComponentVariation(
                            ped, 
                            k,
                            v[1],
                            v[2]
                        )
                    end
                end
            end

            SetPedConfigFlag(ped, 17, true) -- Ignore events
            SetPedConfigFlag(ped, 89, true) -- DontActivateRagdollFromAnyPedImpact 
            SetPedConfigFlag(ped, 208, true) -- CPED_CONFIG_FLAG_DisableExplosionReactions

            -- Play anim
            local animation = Config.ParticipantAnimations[math.random(#Config.ParticipantAnimations)]
            local dict = animation[1]
            local name = animation[2]
            local anim  = {
                dict = dict,
                name = name,
                blendInSpeed = 1.0,
                blendOutSpeed = 1.0,
                duration = -1,
                flag = 2 + 8,
                playbackRate = 0.0,
            }
            RequestAnimDict(anim.dict)
            while not HasAnimDictLoaded(anim.dict) do
                debugPrint('wait for anim dict')
                Wait(0)
            end
            TaskPlayAnim(ped, anim.dict, anim.name, anim.blendInSpeed, anim.blendOutSpeed, anim.duration, anim.flag, anim.playbackRate, false, false, false)
            RemoveAnimDict(anim.dict)

            CreateThread(function()
                local prop = attachCookiePropToHand(ped)
                table.insert(createdProps, prop)
            end)

            table.insert(createdPeds, {
                ped = ped,
                type = "participant",
            })
        else
            debugPrint('skip particpant creation, ped was not created / was deleted')
        end
    end
end

local function spawnGuardsNPC()
    -- Spawn NPC Guards
    for k,v in ipairs(Config.SpawnCoords.GuardsNPC) do
        debugPrint('spawn guard', k)
        local modelHash = nil
        if Config.UsePedModelsInsteadOutfitsForGuards then
            modelHash = GetHashKey(Config.GuardPeds[1])
        else
            modelHash = GetHashKey("mp_m_freemode_01")
        end

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            debugPrint('wait for guard model')
            Wait(0)
        end
        
        local coords = v[1] + vec3(0.0, 0.0, -1.0) -- no offset
        local heading = v[2]
        local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z, heading, false, false)

        local timeoutAt = GetGameTimer() + 200
        while not DoesEntityExist(ped) and GetGameTimer() < timeoutAt do
            debugPrint('wait for guard creation')
            Wait(0)
        end

        if DoesEntityExist(ped) then
            -- Set weapon in hands
            GiveWeaponToPed(ped, `WEAPON_SMG`, 0, false, true)
            SetCurrentPedWeapon(ped, `WEAPON_SMG`, true)

            FreezeEntityPosition(ped, true)
            SetPedConfigFlag(ped, 17, true) -- Ignore events
            SetPedConfigFlag(ped, 208, true) -- CPED_CONFIG_FLAG_DisableExplosionReactions

            if not Config.UsePedModelsInsteadOutfitsForGuards then
                for k,v in pairs(Config.GuardOutfits[1]) do
                    SetPedComponentVariation(
                        ped, 
                        k,
                        v[1],
                        v[2]
                    )
                end
            end

            table.insert(createdPeds, {
                ped = ped,
                type = "guard",
            })
        else
            debugPrint('skip guard creation, ped was not created / was deleted')
        end
    end
end

local function killParticipantsNPC()
    local peds = {}
    for k,v in ipairs(createdPeds) do
        if v.type == 'participant' then
            table.insert(peds, v.ped)
        end
    end

    while #createdPeds > 0 and #peds > 0 do
        Wait(math.random(10000, 15000))
        if #createdPeds > 0 and #peds > 0 then
            local index = math.random(#peds)
        
            -- Create effect of shot
            local ped = peds[index]

            CreateThread(function()
                -- Blood headshot effect
                callBloodHeadshotEffectOnPed(ped)

                -- Play shot sound
                local coords = GetEntityCoords(ped)
                local isNetworked = false
                PlayPistolSound(coords, isNetworked)
            end)

            -- Prevent pain audio
            DisablePedPainAudio(ped, true)

            -- Ragdoll ped
            FreezeEntityPosition(ped, false)
            SetPedToRagdoll(ped, -1, 0, 0)
            SetEntityHealth(ped, 0)

            -- Create blood decal
            createBloodDecalBehindPed(ped)

            table.remove(peds, index)
        end
    end
end

function cleanUpNPCsAndProps()
    for k,v in ipairs(createdPeds) do
        if DoesEntityExist(v.ped) then
            DeleteEntity(v.ped)
        end
    end
    createdPeds = {}

    for k,v in ipairs(createdProps) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    createdProps = {}
end

RegisterNetEvent(EVENTS['spawnNPC'], function()
    if Config.EnableNPCs.EnableParticipants then
        spawnParticipantsNPC()
    end

    if Config.EnableNPCs.EnableGuards then
        spawnGuardsNPC()
    end
end)

RegisterNetEvent(EVENTS['gameStarted'], function()
    if Config.EnableNPCs.EnableParticipants then
        killParticipantsNPC()
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        cleanUpNPCsAndProps()
    end
end)