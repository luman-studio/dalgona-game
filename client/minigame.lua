local isMinigameActive = false
local isDrawing = false
local segments = {}
local completedSegments = {}
local cursorPosition = vec2(0.5, 0.5) -- Default center position
local CURSOR_SPEED = 0.001 -- Adjust this value to control cursor sensitivity

-- Constants
local TEXTURE_DICT = "dalgona_textures"
local TEXTURES = {
    needle = "needle_flip",
    
    star = "star",
    umbrella = "umbrella",
    circle = "circle",
    square = "square",
    triangle = "triangle",

    crack1 = "crack1",
    crack2 = "crack2",
}

local TEXTURE_SCALE = 0.25

-- Input Constants
local CONTROLS = {
    MOUSE_X = 239,
    MOUSE_Y = 240,
    CONTROLLER_X = 220,
    CONTROLLER_Y = 221,
    MOUSE_BUTTON = 24,
    CONTROLLER_BUTTON = 191  -- Default to A/X button
}

local NEEDLE_SIZE_X = 0.12
local NEEDLE_SIZE_Y = 0.20
local NEEDLE_OFFSET_X = (NEEDLE_SIZE_X / 2.0) * -1.0
local NEEDLE_OFFSET_Y = (NEEDLE_SIZE_Y / 2.0) * -1.0

local SEGMENT_DRAW_LINE_WIDTH = 0.0005*1.5

local AudioBankName     = "SAFE_CRACK"
local SafeSoundset      = "SAFE_CRACK_SOUNDSET"
local SafeTurnSound    = "tumbler_turn"
local SafePinSound = "tumbler_pin_fall"
local SafeFinalSound	= "tumbler_pin_fall_final"

local DEBUG_MODE_ADD_NEW_DRAW = false
local DEBUG_SEGMENTS = {}

-- Update cursor position based on input
local function updateCursorPosition()
    -- Check if mouse is being used (any mouse movement)
    if IsUsingKeyboard(0) then
        cursorPosition = vec2(
            GetControlNormal(0, CONTROLS.MOUSE_X),
            GetControlNormal(0, CONTROLS.MOUSE_Y)
        )
    else
        -- Controller input
        local moveX = GetControlNormal(0, CONTROLS.CONTROLLER_X)
        local moveY = GetControlNormal(0, CONTROLS.CONTROLLER_Y)
        
        -- Apply deadzone to prevent drift
        if math.abs(moveX) < 0.2 then moveX = 0 end
        if math.abs(moveY) < 0.2 then moveY = 0 end
        
        -- Update position with speed modifier
        cursorPosition = vec2(
            math.max(0.0, math.min(1.0, cursorPosition.x + (moveX * CURSOR_SPEED))),
            math.max(0.0, math.min(1.0, cursorPosition.y + (moveY * CURSOR_SPEED)))
        )
    end
end

-- Modified drawNeedle function to use cursorPosition
local function drawNeedle()
    DrawSprite(
        TEXTURE_DICT,
        TEXTURES.needle,
        cursorPosition.x + NEEDLE_OFFSET_X,
        cursorPosition.y + NEEDLE_OFFSET_Y,
        NEEDLE_SIZE_X,
        NEEDLE_SIZE_Y,
        0.0,
        255, 255, 255, 255
    )
    if DEBUG_MODE_ADD_NEW_DRAW then
        DrawRect(cursorPosition.x, cursorPosition.y, 0.002, 0.002, 255, 0, 0, 255)  -- Small red dot at center
    end
end

-- Rest of your existing functions remain the same
local function loadTextures()
    RequestStreamedTextureDict(TEXTURE_DICT, true)
    while not HasStreamedTextureDictLoaded(TEXTURE_DICT) do
        Wait(100)
    end
end

local function interpolate(segments, splitBy)
    local result = {}
    for i=1,#segments do
        local startPoint = segments[i]
        local endPoint = segments[i % #segments + 1]
        local segmentLength = (endPoint - startPoint) / splitBy
        table.insert(result, startPoint)
        
        for k=1,(splitBy-1) do
            table.insert(result, startPoint + k*segmentLength)
        end
    end
    return result
end

-- Create line segments from points
local function generateSegments(star)
    local segments = {}

    -- Create segments between consecutive points
    for i = 1, #star do
        local startPoint = star[i]
        local endPoint = star[i % #star + 1] -- Wrap around to first point
        
        table.insert(segments, {
            completed = false,
            start = startPoint,
            finish = endPoint
        })
    end
    
    return segments
end

-- Check if point is close to line segment
local function distanceToSegment(px, py, x1, y1, x2, y2)
    local A = px - x1
    local B = py - y1
    local C = x2 - x1
    local D = y2 - y1

    local dot = A * C + B * D
    local len_sq = C * C + D * D

    -- If line segment is basically a point
    if len_sq == 0 then 
        return #(vec2(px - x1, py - y1))
    end

    local param = dot / len_sq

    local xx, yy
    if param < 0 then
        xx = x1
        yy = y1
    elseif param > 1 then
        xx = x2
        yy = y2
    else
        xx = x1 + param * C
        yy = y1 + param * D
    end

    return #(vec2(px - xx, py - yy))
end

-- Draw cookie background
local function drawCookie(name)
    DrawSprite(
        TEXTURE_DICT,
        TEXTURES[name],
        0.5,
        0.5,
        1.0 * TEXTURE_SCALE,
        1.77 * TEXTURE_SCALE,
        0.0,
        255, 255, 255, 255
    )
end

local function drawCrack(name, strength)
    DrawSprite(
        TEXTURE_DICT,
        TEXTURES[name],
        0.5,
        0.5,
        1.0 * TEXTURE_SCALE,
        1.77 * TEXTURE_SCALE,
        0.0,
        255, 255, 255, math.floor(255*strength)
    )
end

local function drawCenterPoint()
    DrawRect(0.5, 0.5, 0.002, 0.002, 255, 0, 0, 255)  -- Small red dot at center
end

-- Draw line between two points
local function drawLine(x1, y1, x2, y2, r, g, b, a)
    DrawLine_2d(
        x1,
        y1, 
        x2, 
        y2, 
        SEGMENT_DRAW_LINE_WIDTH,
        r, g, b, a
    )

end

-- Modified gameLoop to handle both controller and mouse input
local function gameLoop(pattern)
    local hasSucceed = false

    local DEFAULT_LIFES = 4
    local lifes = DEFAULT_LIFES
    local timeoutAfterFailEndAt = GetGameTimer()  
    while isMinigameActive do
        Citizen.Wait(0)
        
        -- Update cursor position
        updateCursorPosition()
        
        -- Disable standard controls
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 24, true)
        
        -- Draw base elements
        drawCookie(pattern)

        if lifes <= 0 then
            drawCrack('crack2', 1.00)
        elseif lifes == 1 then
            drawCrack('crack2', 0.20)
        elseif lifes == 2 then
            drawCrack('crack2', 0.10)
        end

        if lifes < DEFAULT_LIFES then
            drawCrack('crack1', 1.0)
        end

        -- drawCenterPoint()

        -- Draw segments
        for _, segment in ipairs(segments) do
            if segment.completed then
                drawLine(
                    segment.start.x, segment.start.y,
                    segment.finish.x, segment.finish.y,
                    0, 255, 0, 200
                )
            elseif DEBUG_MODE_ADD_NEW_DRAW then
                drawLine(
                    segment.start.x, segment.start.y,
                    segment.finish.x, segment.finish.y,
                    255, 255, 255, 100
                )
            end
        end

        -- Handle input (both mouse and controller)
        if (DEBUG_MODE_ADD_NEW_DRAW and (IsDisabledControlJustPressed(0, CONTROLS.MOUSE_BUTTON) or IsDisabledControlJustPressed(0, CONTROLS.CONTROLLER_BUTTON))) or
            (not DEBUG_MODE_ADD_NEW_DRAW and (IsDisabledControlPressed(0, CONTROLS.MOUSE_BUTTON) or IsDisabledControlPressed(0, CONTROLS.CONTROLLER_BUTTON))) then
            
            isDrawing = true
            
            if DEBUG_MODE_ADD_NEW_DRAW then
                table.insert(DEBUG_SEGMENTS, vec2(cursorPosition.x, cursorPosition.y))
                if #DEBUG_SEGMENTS > 1 then
                    segments = generateSegments(DEBUG_SEGMENTS)

                    debugPrint('--------')
                    for k,v in ipairs(DEBUG_SEGMENTS) do
                        debugPrint(('vec2(%s, %s),'):format(v.x, v.y))
                    end
                end
            elseif lifes > 0 and GetGameTimer() >= timeoutAfterFailEndAt then
                local clickedIntoSegment = false
                for _, segment in ipairs(segments) do
                    local distance = distanceToSegment(
                        cursorPosition.x, cursorPosition.y,
                        segment.start.x, segment.start.y,
                        segment.finish.x, segment.finish.y
                    )
                    if distance < Config.MinigameComplexityCheck then
                        clickedIntoSegment = true
                        if not segment.completed then
                            segment.completed = true
                            table.insert(completedSegments, segment)
                            PlaySoundFrontend(0, SafeTurnSound, SafeSoundset, false)
                        end
                    end
                end

                if not clickedIntoSegment then
                    lifes = lifes - 1
                    timeoutAfterFailEndAt = GetGameTimer() + 500
                    if lifes > 0 then
                        PlaySoundFrontend(0, SafePinSound, SafeSoundset, false)
                    else
                        PlaySoundFrontend(0, SafeFinalSound, SafeSoundset, false)
                        -- isMinigameActive = false
                        completedSegments = {}
                        debugPrint('You loose')
                        
                        timeoutAfterFailEndAt = GetGameTimer() + 500
                        SetTimeout(500, function()
                            stopGame()
                            hasSucceed = false
                        end)
                    end
                end

                if #completedSegments == #segments then
                    completedSegments = {}
                    debugPrint('You win')
                    
                    timeoutAfterFailEndAt = GetGameTimer() + 500
                    SetTimeout(500, function()
                        stopGame()
                        hasSucceed = true
                    end)
                end
            end

            drawParticle(cursorPosition.x, cursorPosition.y)
        else
            isDrawing = false
        end
        
        -- Draw needle last
        drawNeedle()
    end

    return hasSucceed
end

local starSegments = {
    vec2(0.50052088499069, 0.39351850748062),
    vec2(0.48229169845581, 0.45740738511085),
    vec2(0.44114586710929, 0.47037035226821),
    vec2(0.47135418653488, 0.52129626274108),
    vec2(0.46458336710929, 0.59074074029922),
    vec2(0.50052088499069, 0.55833333730697),
    vec2(0.53645837306976, 0.58981478214263),
    vec2(0.52968752384185, 0.52037036418914),
    vec2(0.55833333730697, 0.46944442391395),
    vec2(0.51875001192092, 0.45833331346511),
}
starSegments = interpolate(starSegments, 10)


local umbrellaSegments = {
    vec2(0.50312501192093, 0.40000000596046),
    vec2(0.50885421037674, 0.4111111164093),
    vec2(0.52864587306976, 0.42222222685814),
    vec2(0.54895836114883, 0.45370370149612),
    vec2(0.55729168653488, 0.49907407164574),
    vec2(0.55416667461395, 0.51574075222015),
    vec2(0.54583334922791, 0.50833332538605),
    vec2(0.5390625, 0.50462961196899),
    vec2(0.53072917461395, 0.51388889551163),
    vec2(0.52500003576279, 0.51388889551163),
    vec2(0.51614588499069, 0.50370371341705),
    vec2(0.50937503576279, 0.50833332538605),
    vec2(0.50885421037674, 0.53703701496124),
    vec2(0.50885421037674, 0.56759256124496),
    vec2(0.50208336114883, 0.58703702688217),
    vec2(0.49010419845581, 0.58981478214264),
    vec2(0.48125001788139, 0.5768518447876),
    vec2(0.4802083671093, 0.55555552244186),
    vec2(0.48593753576279, 0.54907405376434),
    vec2(0.49010419845581, 0.55648148059845),
    vec2(0.49322918057442, 0.57314813137054),
    vec2(0.49791669845581, 0.56388890743256),
    vec2(0.49791669845581, 0.53981482982635),
    vec2(0.49739587306976, 0.50833332538605),
    vec2(0.49062502384186, 0.50370371341705),
    vec2(0.48229169845581, 0.51296293735504),
    vec2(0.47760418057442, 0.51574075222015),
    vec2(0.46666669845581, 0.50370371341705),
    vec2(0.45937502384186, 0.51111108064651),
    vec2(0.45416668057442, 0.51574075222015),
    vec2(0.4489583671093, 0.50648146867752),
    vec2(0.45312502980232, 0.47037035226822),
    vec2(0.46302086114883, 0.44074073433876),
    vec2(0.47812503576279, 0.42129629850388),
    vec2(0.48854169249535, 0.41481480002403),
    vec2(0.49687501788139, 0.41296294331551),
    vec2(0.49895834922791, 0.4037036895752),
}
umbrellaSegments = interpolate(umbrellaSegments, 4)

local squareSegements = {
    vec2(0.45156252384186, 0.41388887166977),
    vec2(0.546875, 0.41388887166977),
    vec2(0.54739588499069, 0.5842592716217),
    vec2(0.45156252384186, 0.58518517017365),
}
squareSegements = interpolate(squareSegements, 20)

local circleSegments = {
    vec2(0.5, 0.39074072241783),
    vec2(0.50885421037674, 0.39074072241783),
    vec2(0.51822918653488, 0.39722222089767),
    vec2(0.52968752384186, 0.4037036895752),
    vec2(0.53854167461395, 0.41481480002403),
    vec2(0.54479169845581, 0.42685183882713),
    vec2(0.55156254768372, 0.43888887763023),
    vec2(0.55677086114883, 0.45555555820465),
    vec2(0.55937504768372, 0.47314813733101),
    vec2(0.56145834922791, 0.4879629611969),
    vec2(0.56197917461395, 0.51018518209457),
    vec2(0.56041669845581, 0.53055554628372),
    vec2(0.55677086114883, 0.54629629850388),
    vec2(0.55156254768372, 0.56111109256744),
    vec2(0.54635417461395, 0.57499998807907),
    vec2(0.5390625, 0.58611112833023),
    vec2(0.53020834922791, 0.59722220897675),
    vec2(0.52135419845581, 0.60555553436279),
    vec2(0.51041668653488, 0.60925924777985),
    vec2(0.49843752384186, 0.61018514633179),
    vec2(0.48541668057442, 0.60648149251938),
    vec2(0.47343751788139, 0.59999996423721),
    vec2(0.46250003576279, 0.58611112833023),
    vec2(0.45416668057442, 0.5722222328186),
    vec2(0.44739586114883, 0.55462962388992),
    vec2(0.44218751788139, 0.53425925970078),
    vec2(0.43906253576279, 0.51111108064651),
    vec2(0.43906253576279, 0.48611110448837),
    vec2(0.44270834326744, 0.46296295523643),
    vec2(0.4489583671093, 0.44074073433876),
    vec2(0.45572918653488, 0.42222222685814),
    vec2(0.46562501788139, 0.40925925970078),
    vec2(0.47291669249535, 0.40185183286667),
    vec2(0.48177087306976, 0.39629629254341),
    vec2(0.49114584922791, 0.39259257912636),
}
circleSegments = interpolate(circleSegments, 2)

local triangleSegments = {
    vec2(0.49947920441628, 0.40462961792946),
    vec2(0.55520838499069, 0.57129627466202),
    vec2(0.44479170441628, 0.57129627466202),
}
triangleSegments = interpolate(triangleSegments, 20)

-- Exported functions
local patterns = {
    ['star'] = {
        segments = starSegments,
        propHash = `dalgona_candy_star`,
    },
    ['umbrella'] = {
        segments = umbrellaSegments,
        propHash = `dalgona_candy_umbrella`,
    },
    ['square'] = {
        segments = squareSegements,
        propHash = `dalgona_candy_square`,
    },
    ['circle'] = {
        segments = circleSegments,
        propHash = `dalgona_candy_circle`,
    },
    ['triangle'] = {
        segments = triangleSegments,
        propHash = `dalgona_candy_triangle`,
    },
}

function getRandomPattern()
    local elements = {}
    for k,v in pairs(patterns) do
        table.insert(elements, k)
    end
    local pattern = elements[math.random(#elements)]
    return pattern
end

local entities = {}
function attachCookiePropToHand(ped, pattern, networked)
    if pattern == nil or not patterns[pattern] then
        pattern = getRandomPattern()
    end
    local modelHash = patterns[pattern].propHash
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
            debugPrint('Waiting for model from pattern', pattern)
        end
    end
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, networked)
    AttachEntityToEntity(
        prop, 
        ped,
        GetPedBoneIndex(ped, 18905), -- skel_l_hand
        0.142,	0.01,	0.025, 
        -12.0,	-26.0,	0.0,
        false, false, false, true, 2, true
    )
    return prop
end


function startMinigame(pattern, cbTrue)
    isMinigameActive = true
    
    -- Animation
    CreateThread(function()
        local ped = PlayerPedId()

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
        if not DoesAnimDictExist(anim.dict) then
            return false
        end
        RequestAnimDict(anim.dict)
        while isMinigameActive and not HasAnimDictLoaded(anim.dict) do
            Wait(0)
        end

        while isMinigameActive do
            -- Always play anim during mini-game
            if not IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
                TaskPlayAnim(ped, anim.dict, anim.name, anim.blendInSpeed, anim.blendOutSpeed, anim.duration, anim.flag, anim.playbackRate, false, false, false, '', false)
            end
            Wait(100)
        end
    end)

    -- Load textures and audio
    loadTextures()
    if not RequestAmbientAudioBank(AudioBank, false) then 
        RequestAmbientAudioBank(AudioBankName, false)
    end

    -- Params
    if cbTrue == nil then
        cbTrue = function()
            return true
        end
    end

    -- Random pattern
    if pattern == nil or not patterns[pattern] then
        pattern = getRandomPattern()
        startRoulette(pattern)    
    end

    -- Init mini-game
    if not DEBUG_MODE_ADD_NEW_DRAW then
        segments = generateSegments(patterns[pattern].segments)
    end

    -- Attach cookie prop
    CreateThread(function()
        local prop = attachCookiePropToHand(PlayerPedId(), pattern, true)
        table.insert(entities, prop)
    end)
    
    -- Stop minigame if main game stopped
    CreateThread(function()
        while cbTrue() and isMinigameActive do
            Wait(100)
        end
        isMinigameActive = false
    end)

    -- Start game and wait till gave over
    local hasSucceed = gameLoop(pattern)

    -- Clear
    ClearPedTasks(PlayerPedId())
    for k,v in ipairs(entities) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    Wait(0)

    return hasSucceed 
end

function stopGame()
    isMinigameActive = false
    SetStreamedTextureDictAsNoLongerNeeded(TEXTURE_DICT)
end

-- Test command
if DEBUG_MODE_ADD_NEW_DRAW then
    RegisterCommand('dalgona', function(source, args)
        if isMinigameActive then
            isMinigameActive = false
            Wait(0)
            Framework.showNotification(_('minigame_stopped'))
            return
        end
    
        local pattern = args[1]
        
        if not DEBUG_MODE_ADD_NEW_DRAW then
            if not patterns[pattern] then
                Framework.showNotification(_('no_pattern'))
                return
            end
        end
    
    
        startMinigame(pattern)
    end)
end

---- particle

-- Global settings
local g_ParticlePool = {}
local g_TextureLoaded = false
local g_LastUpdateTime = 0


-- Configuration
local CONFIG = {
    maxParticles = 100,         -- Maximum particles in the system at once
    burstSize = 3,              -- Number of particles per emission
    emissionInterval = 50,      -- Milliseconds between emissions
    textureDictionary = "dalgona_textures",
    textureSprite = "star",
    baseColor = {r = 139, g = 69, b = 19}
}

-- Physics parameters
local PHYSICS = {
    gravity = 0.003,            -- Downward acceleration
    friction = 0.67,            -- Velocity damping
    turbulence = 0.2,           -- Random movement factor
    lifeDecay = 0.8             -- How quickly particles fade
}

-- Initialize the particle system
local function InitializeParticleSystem()
    -- Request texture if not loaded
    if not g_TextureLoaded then
        RequestStreamedTextureDict(CONFIG.textureDictionary)
        g_TextureLoaded = HasStreamedTextureDictLoaded(CONFIG.textureDictionary)
    end
    
    -- Pre-allocate particle pool
    for i = 1, CONFIG.maxParticles do
        g_ParticlePool[i] = {active = false}
    end
    
    g_LastUpdateTime = GetGameTimer()
end

-- Find an available particle in the pool
local function GetFreeParticle()
    for i = 1, #g_ParticlePool do
        if not g_ParticlePool[i].active then
            return g_ParticlePool[i]
        end
    end
    
    -- If full, overwrite oldest particle
    local oldestIdx = 1
    local oldestTime = GetGameTimer()
    
    for i = 1, #g_ParticlePool do
        if g_ParticlePool[i].creationTime < oldestTime then
            oldestTime = g_ParticlePool[i].creationTime
            oldestIdx = i
        end
    end
    
    return g_ParticlePool[oldestIdx]
end

-- Emit a particle with physics-based properties
local function EmitParticle(screenX, screenY)
    local particle = GetFreeParticle()
    local screenWidth, screenHeight = GetActiveScreenResolution()
    local pixelX, pixelY = screenX * screenWidth, screenY * screenHeight
    
    -- Calculate initial velocity with angle and magnitude
    local angle = math.random() * 2 * math.pi
    local speed = math.random() * 0.5 + 0.5
    
    -- Initialize physics properties
    particle.active = true
    particle.creationTime = GetGameTimer()
    particle.position = {x = pixelX, y = pixelY}
    particle.velocity = {
        x = math.cos(angle) * speed,
        y = math.sin(angle) * speed
    }
    particle.rotation = math.random() * 360
    particle.rotationSpeed = (math.random() - 0.5) * 2
    particle.size = math.random() * 2 + 1.5
    particle.energy = 1.0  -- Full energy at creation
    particle.lifespan = math.random(800, 1300)
    particle.turbulenceOffset = {
        x = math.random() * 1000,
        y = math.random() * 1000
    }
end

-- Update particle physics
local function UpdateParticles()
    local currentTime = GetGameTimer()
    local deltaTime = currentTime - g_LastUpdateTime
    g_LastUpdateTime = currentTime
    
    for i = 1, #g_ParticlePool do
        local p = g_ParticlePool[i]
        
        if p.active then
            -- Calculate life percentage
            local age = currentTime - p.creationTime
            if age >= p.lifespan then
                p.active = false
            else
                -- Apply gravity
                p.velocity.y = p.velocity.y + PHYSICS.gravity * deltaTime
                
                -- Apply friction/drag
                p.velocity.x = p.velocity.x * PHYSICS.friction
                p.velocity.y = p.velocity.y * PHYSICS.friction
                
                -- Apply turbulence (simplex noise simulation)
                local turbX = math.sin(p.turbulenceOffset.x + age * 0.001) * PHYSICS.turbulence
                local turbY = math.cos(p.turbulenceOffset.y + age * 0.001) * PHYSICS.turbulence
                p.velocity.x = p.velocity.x + turbX * deltaTime * 0.01
                p.velocity.y = p.velocity.y + turbY * deltaTime * 0.01
                
                -- Update position
                p.position.x = p.position.x + p.velocity.x * deltaTime
                p.position.y = p.position.y + p.velocity.y * deltaTime
                
                -- Update rotation
                p.rotation = p.rotation + p.rotationSpeed * deltaTime * 0.1
                
                -- Update energy level (for opacity)
                p.energy = math.pow(1 - (age / p.lifespan), PHYSICS.lifeDecay)
            end
        end
    end
end

-- Render active particles
local function RenderParticles()
    local screenWidth, screenHeight = GetActiveScreenResolution()
    
    for i = 1, #g_ParticlePool do
        local p = g_ParticlePool[i]
        
        if p.active and p.energy > 0.01 then
            local alpha = math.floor(p.energy * 255)
            
            -- Draw the particle sprite
            DrawSprite(
                CONFIG.textureDictionary,
                CONFIG.textureSprite,
                p.position.x / screenWidth,
                p.position.y / screenHeight,
                p.size / screenWidth,
                p.size / screenHeight,
                p.rotation,
                CONFIG.baseColor.r,
                CONFIG.baseColor.g,
                CONFIG.baseColor.b,
                alpha
            )
        end
    end
end

-- Main function to be called every frame
function drawParticle(x, y)
    if #g_ParticlePool == 0 then
        InitializeParticleSystem()
    end
    
    -- Ensure texture is loaded
    if not g_TextureLoaded and HasStreamedTextureDictLoaded(CONFIG.textureDictionary) then
        g_TextureLoaded = true
    end
    
    -- Check if we should emit particles
    local currentTime = GetGameTimer()
    local timeSinceLastEmission = currentTime - (g_LastEmissionTime or 0)
    
    if timeSinceLastEmission >= CONFIG.emissionInterval then
        for i = 1, CONFIG.burstSize do
            EmitParticle(x, y)
        end
        g_LastEmissionTime = currentTime
    end
    
    -- Update and render all particles
    UpdateParticles()
    RenderParticles()
end

---------------------

-- Constants for the roulette animation
local patternsList = {
    'star',
    'umbrella',
    'circle',
    'square',
    'triangle',
}

-- Animation timing configuration
local INITIAL_INTERVAL = 12   -- Faster initial speed (was 50)
local FINAL_INTERVAL = 200    -- Faster final speed (was 500)
local ACCELERATION = 1.8      -- Faster slowdown (was 1.2)
local MIN_SPINS = 1          -- Fewer minimum spins (was 2)

local currentTextureIndex = 1
local isSpinning = false
local currentInterval = INITIAL_INTERVAL
local lastUpdateTime = 0
local spinStartTime = 0
local finalTexture = nil

local function getNextTextureIndex()
    currentTextureIndex = currentTextureIndex + 1
    if currentTextureIndex > #patternsList then
        currentTextureIndex = 1
    end
    return currentTextureIndex
end

local function calculateCurrentInterval(elapsedTime)
    -- Start slowing down after MIN_SPINS full rotations
    local minSpinTime = (INITIAL_INTERVAL * #patternsList * MIN_SPINS)
    if elapsedTime < minSpinTime then
        return INITIAL_INTERVAL
    end
    
    -- Calculate how much to slow down based on elapsed time
    local slowdownTime = elapsedTime - minSpinTime
    local interval = INITIAL_INTERVAL * math.pow(ACCELERATION, slowdownTime / 1000)
    
    -- Cap at final interval
    return math.min(interval, FINAL_INTERVAL)
end

local function updateRoulette()
    if not isSpinning then return end
    
    local currentTime = GetGameTimer()
    local elapsedTime = currentTime - spinStartTime
    
    -- Update interval based on elapsed time
    currentInterval = calculateCurrentInterval(elapsedTime)
    
    -- Check if it's time to switch to next texture
    if currentTime - lastUpdateTime >= currentInterval then
        lastUpdateTime = currentTime
        currentTextureIndex = getNextTextureIndex()
        
        -- Play sound
        PlaySoundFrontend(0, SafeTurnSound, SafeSoundset, false)
        
        -- Check if we should stop
        if currentInterval >= FINAL_INTERVAL and patternsList[currentTextureIndex] == finalTexture then
            isSpinning = false
        end
    end
    
    -- Draw current texture
    drawCookie(patternsList[currentTextureIndex])
end

-- Function to start the roulette
function startRoulette(targetTexture)
    finalTexture = targetTexture
    currentTextureIndex = 1
    currentInterval = INITIAL_INTERVAL
    isSpinning = true
    spinStartTime = GetGameTimer()
    lastUpdateTime = spinStartTime
    while isSpinning do
        Wait(0)
        updateRoulette()
    end
    return finalTexture
end


--------------------\

-- Event handler for resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        ClearPedTasks(PlayerPedId())

        for k,v in ipairs(entities) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
        entities = {}
    end
end)

RegisterNetEvent(EVENTS['gameStarted'], function()
    Wait(0)
    -- Reset status (nil)
    LocalPlayer.state:set(STATEBAGS['minigameSucceed'], nil, true)
    -- Init mini-game
    local hasSucceed = startMinigame(pattern, function()
        return gameStarted
    end)
    -- Set status of mini-game 
    LocalPlayer.state:set(STATEBAGS['minigameSucceed'], hasSucceed, true)
end)