Config = {}
Config.Locale = "en" -- Language "en"
Config.GameName = "Dalgona Game"

Config.MinimumParticipants = 1 -- How much players the game requires for start
Config.Fee = 0 -- How much money cost to participate in game
Config.StartPoint = vec3(2080.37, 3342.61, 46.86) -- Lobby point
Config.StartPointSize = 7.5 -- radius
Config.StartPointColor = {238, 169, 184, 125} -- red, green, blue, alpha
Config.StartPointBlip = {
    Enabled = true,
    Id = 1, -- https://docs.fivem.net/docs/game-references/blips/
    Color = 8,
    Scale = 0.75,
}
Config.StartPointEnabled = true -- You can use command, see docs/COMMANDS.md
Config.GameDuration = 120000 -- Game duration 120000 milliseconds
Config.GameStartInterval = 10000 -- miliseconds

-- Enable NPCs
Config.EnableNPCs = {
    EnableGuards = true,
    EnableParticipants = true,
}

Config.ChangePlayerSkin = true
Config.UsePedModelsInsteadOutfitsForPlayers = false -- Useful when you want to use ped models and don't want to use multiplayer clothes
Config.UsePedModelsInsteadOutfitsForGuards = false -- Useful when you want to use ped models and don't want to use multiplayer clothes
Config.AllowCustomPeds = false -- Players with custom ped models will have them in game

Config.EnableGodmode = true -- players will not receive damage

Config.ShowWinnerMessageGlobally = false -- show message to everyone or only to participants
Config.InGameTick = function(playerPed)
    -- You can add/remove here buttons to block during the game
    DisableControlAction(2, 37, true) -- Disable Weaponwheel
    DisablePlayerFiring(playerPed, true) -- Disable firing
    DisableControlAction(0, 45, true) -- Disable reloading
    DisableControlAction(0, 24, true) -- Disable attacking
    DisableControlAction(0, 263, true) -- Disable melee attack 1
    DisableControlAction(0, 140, true) -- Disable light melee attack (r)
    DisableControlAction(0, 142, true) -- Disable left mouse button (pistol whack etc)
end

-- Player spawns when game starts, finish and guards position
Config.SpawnCoords = {
    GameStarted = {
        vec3(2188.04, 3494.24, 0.72),
        vec3(2190.006103515625, 3507.512451171875, 0.87251996994018),
        vec3(2181.84033203125, 3505.52880859375, 0.80640906095504),
        vec3(2185.314208984375, 3500.983154296875, 0.82763677835464),
        vec3(2190.56103515625, 3500.63037109375, 0.77740979194641),
        vec3(2197.342529296875, 3503.6787109375, 0.80395567417144),
        vec3(2202.322265625, 3495.670654296875, 0.83293431997299),
        vec3(2180.46337890625, 3494.616455078125, 0.76439321041107),
        vec3(2178.1123046875, 3488.546875, 0.80805826187133),
        vec3(2193.36279296875, 3483.39892578125, 0.747418820858),
        vec3(2190.0126953125, 3493.20751953125, 0.76818436384201),
        vec3(2197.583251953125, 3480.404296875, 0.85798817873001),
        vec3(2183.451416015625, 3491.805908203125, 0.81965631246566),
    },
    GameSuccess = { 
        -- Player won the game. You can use it for teleporting player to next level
        -- You can delete coordinates, if you don't want to teleport players on game over
        vec3(2123.95, 3298.85, 56.55),
        vec3(2120.95, 3298.85, 56.55),
    },
    GameFailed = { 
        -- Player failed the game. You can use it for teleporting player to some limbo or something :P
        -- You can delete coordinates, if you don't want to teleport players on game over
        vec3(2065.04, 3285.5, 43.89),
        vec3(2060.04, 3285.5, 43.89),
    },
    ParticipantsNPC = {
        vec3(2193.12646484375, 3506.857177734375, 0.79461407661437),
        vec3(2186.85546875, 3506.588134765625, 0.8113242983818),
        vec3(2177.670654296875, 3503.100341796875, 1.26015734672546),
        vec3(2188.4267578125, 3502.42041015625, 0.77578389644622),
        vec3(2194.75146484375, 3500.704345703125, 0.84598606824874),
        vec3(2201.6884765625, 3503.71044921875, 0.76441770792007),
        vec3(2185.29345703125, 3493.196044921875, 0.81292831897735),
        vec3(2181.662841796875, 3497.52978515625, 0.77046650648117),
        vec3(2198.316162109375, 3488.64599609375, 0.79819357395172),
        vec3(2188.478271484375, 3482.36328125, 0.71716803312301),
        vec3(2174.987548828125, 3490.958251953125, 0.76166749000549),
        vec3(2196.601806640625, 3495.146728515625, 0.75443446636199),
        vec3(2179.807861328125, 3497.5791015625, 0.84907180070877),
    },
    GuardsNPC = {
        -- doors (circles)
        {vec3(2178.31396484375, 3510.762451171875, 0.7685112953186), 180.0},
        {vec3(2182.052490234375, 3510.605712890625, 0.85947620868682), 180.0},
        {vec3(2184.27392578125, 3510.712646484375, 0.77897769212722), 180.0},
        {vec3(2187.83349609375, 3510.46044921875, 0.85623228549957), 180.0},
        {vec3(2189.95556640625, 3510.70458984375, 0.83099859952926), 180.0},
        {vec3(2193.58837890625, 3510.693359375, 0.85412091016769), 180.0},
        {vec3(2195.833740234375, 3510.62451171875, 0.86943519115448), 180.0},
        {vec3(2199.60888671875, 3510.622802734375, 0.72429639101028), 180.0},

        -- field (triangles)
        {vec3(2184.470947265625, 3506.1728515625, 0.775963306427), 180.0},
        {vec3(2189.12109375, 3506.422119140625, 0.77136689424514), 167.0},
        {vec3(2201.928955078125, 3508.67431640625, 0.81131660938262), 142.0},
        {vec3(2199.07275390625, 3501.970947265625, 0.77001368999481), -50.0},
        {vec3(2200.960693359375, 3498.267822265625, 0.8111480474472), 177.0},
        {vec3(2192.768310546875, 3490.746337890625, 0.84262681007385), 81.0},
        {vec3(2183.67138671875, 3494.913818359375, 0.83924794197082), 80.0},
        
        {vec3(2176.9033203125, 3492.93310546875, 0.79378116130828), -156.0},
        {vec3(2179.875244140625, 3501.068359375, 1.26891863346099), -102.0},
        {vec3(2179.254150390625, 3502.391357421875, 1.27013039588928), -54.0},

        {vec3(2195.40234375, 3490.852294921875, 5.92286920547485), 128.0},
        {vec3(2203.118408203125, 3480.057373046875, 0.84032607078552), 17.0},
        {vec3(2177.66796875, 3500.5068359375, 1.26545631885528), -176.0},

        -- Doors (circles)
        {vec3(2191.2314453125, 3478.88818359375, 0.78903579711914), 0.0},
        {vec3(2186.373046875, 3478.846435546875, 0.77880197763442), 0.0},
    },
}


-- Clothes https://forum.cfx.re/t/release-paid-squid-game-clothing-pack-optimisation/
-- Guidline: https://forum.cfx.re/t/squid-game-level-1-esx-qbcore-standalone/4768952/31?u=draobrehtom
Config.PlayerOutfits = {
    ["male"] = {
        -- Player 001 (open jacket + tshirt)
        {
            [4] = {5, 0}, -- pants_1, pants_2
            [6] = {43, 0}, -- shoes_1, shoes_2
            
            [8] = {0, 1}, -- tshirt_1, tshirt_2
            [11] = {74, 0}, -- torso_1, torso_2

            [1] = {0, 0}, -- mask_1, mask_2
            -- [2] = {0, 0}, -- hair
            [3] = {0, 0}, -- arms, arms_2
            [5] = {0, 0}, -- bags_1, bags_2
            [7] = {0, 0}, -- chain_1, chain_2
            [9] = {0, 0}, -- bproof_1, bproof_2
            [10] = {0, 0}, -- decals_1, decals_2
        },

        -- Player 101 (open jacket + tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},
            [8] = {0, 2},
            [11] = {74, 1},

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 199 (open jacket + tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {0, 3},
            [11] = {74, 2},

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 218 (open jacket + tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},
            [8] = {0, 4},
            [11] = {74, 3},

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 456 (open jacket + tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {0, 5}, -- tshirt
            [11] = {74, 4}, -- open jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 001 (closed jacket)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {75, 0}, -- closed jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        
        -- Player 101 (closed jacket)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {75, 1}, -- closed jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 199 (closed jacket)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {75, 2}, -- closed jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 218 (closed jacket)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {75, 3}, -- closed jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 456 (closed jacket)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {75, 4}, -- closed jacket

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 001 (only tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {0, 1}, -- tshirt

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 101 (only tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {0, 2}, -- tshirt

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 199 (only tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {0, 3}, -- tshirt

            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },

        -- Player 218 (only tshirt)
        {
            [4] = {5, 0},
            [6] = {43, 0},

            [8] = {15, 0}, -- empty body
            [11] = {0, 4}, -- tshirt
            
            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },
    },
    ["female"] = {
        {
            [4] = {66, 0},
            [6] = {80, 0},
            [8] = {2, 0},
            [11] = {147, 0},
            
            [1] = {0, 0},
            -- [2] = {0, 0},
            [3] = {0, 0},
            [5] = {0, 0},
            [7] = {0, 0},
            [9] = {0, 0},
            [10] = {0, 0},
        },
    }
}

-- Guard clothes, credits https://de.gta5-mods.com/player/squid-game-mask-for-mp-male-sp-fivem
Config.GuardOutfits = {
    {
        [1] = {4, 0},
        [4] = {19, 0}, -- b1608 {19, 0}, b2189 {122, 0}, 
        [3] = {16, 0},
        [11] = {65, 0},
        [6] = {25, 0}, -- b1608 {25, 0}, b2189 {97, 0},
        [8] = {15, 0},
    },
    {
        [1] = {4, 1},
        [4] = {19, 0}, 
        [3] = {16, 0},
        [11] = {65, 0},
        [6] = {25, 0},
        [8] = {15, 0},

    },
    {
        [1] = {4, 2},
        [4] = {19, 0}, 
        [3] = {16, 0},
        [11] = {65, 0},
        [6] = {25, 0},
        [8] = {15, 0},
    },
}

-- Same as PlayerOutfits, but intead used ped models
Config.PlayerPeds = {"u_m_y_zombie_01", "u_m_y_mani", "u_m_y_juggernaut_01", "u_m_m_streetart_01", "ig_rashcosvki", "ig_claypain"}
-- Same as GuardOutfits, but instead used ped models
Config.GuardPeds = {"hc_gunman", "hc_driver", "s_m_y_swat_01"}

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- Variables bellow are only for devs, 
-- but you can try to change it if you want to experiment
-- just make a backup of files.
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
Config.ZoneCoords = {
    GameCenter = vec3(2188.94, 3494.73, 0.79),
    GameWidth = 34.0,
    GameLength = 34.0,
    GameHeading = 0.0,
}
  

Config.Cutscene = {
    Enabled = true, -- true/false - Set to false if you have crash or anticheat issue 
    Sequence = {
        {
            position = vec3(2189.03, 3494.75, 2.10),
            rotation = { pitch = 0.0, roll = 0.0, yaw = 180.0 },
            transitionTime = 5000,
            waitTime = 0
        },
        {
            position = vec3(2188.81, 3502.22, 4.10),
            rotation = { pitch = 0.0, roll = 0.0, yaw = 0.0 },
            transitionTime = 0,
            waitTime = 0
        },
    }
}

Config.ParticipantAnimations = {
    {'dalgona@animation', 'idle_dalgona'},
    {'dalgona@animation', 'idle_dalgona_2'},
    {'dalgona@animation', 'idle_dalgona_3'},
}

----------------------------------------------------------
-- Manual Mode for RP scenarious. See docs/MINIGAME.md ---
----------------------------------------------------------
Config.ManualMode = {
    -------------
    -- Command --
    -------------
    Command = {
        Enabled = true, -- Enable/disable command
        Name = 'dalgona-game-manual', -- Command name
        Cooldown = 30000, -- Usage cooldown in milliseconds
        Duration = 120000, -- Game duration in milliseconds
    },

    ---------------------------------------
    -- Indicator above head on win/lose ---
    ---------------------------------------
    WinLoseIndicatorAboveHeadEnabled = true,
    WinLoseIndicatorDuration = 30000, -- milliseconds

    ----------------------------
    -- Animations on win/lose --
    ----------------------------
    WinAnimation = {
        Enabled = true,
        List = {
            {"rcmfanatic1celebrate", "celebrate"},
        },
        Duration = 5000,
    },
    LoseAnimation = {
        Enabled = true,
        List = {
            {"random@arrests@busted", "idle_a"},
            {"anim@heists@ornate_bank@hostages@hit", "hit_loop_ped_b"},
        },
        Duration = 10000,
    },

    ---------------------------------
    -- Auto-kill player if he lose --
    ---------------------------------
    AutokillEnabled = true,

    -----------------------------------
    -- Guard NPC in front of player ---
    -----------------------------------
    SpawnGuardNearPlayer = {
        Enabled = true,
        Networked = true,
    },
}

-- Minigame complexity. Make value bellow twice larger if you want it easier to play.
-- For example Config.MinigameComplexityCheck = 0.0070
Config.MinigameComplexityCheck = 0.0035

-------------------------
-- Uncomment for tests --
-------------------------
-- Config.Debug = true
-- Config.Cutscene.Enabled = false
-- Config.MinimumParticipants = 1