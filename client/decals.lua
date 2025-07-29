local glm = require("glm")

-- Cache common functions
local vec2 = vec2
local vec3 = vec3
local glm_up = glm.up()
local glm_right = glm.right()

-- Store all created decal handles
local createdDecals = {}

-- Function to create decal from surface info
local function createBloodDecalFromSurface(pos, surface, entity, textureSize)
    local decalEps = 1E-2  -- Decal properties
    local decalTimeout = -1.0
    local decalForward = -surface
    local decalRight = nil
    
    -- Slightly adjust position above surface to prevent clipping
    pos = pos + surface * 0.0666
    
    -- Compute perpendicular of the surface
    decalRight = glm.perpendicular(surface, -glm_up, glm_right)
    
    -- If surface is horizontal, align with camera
    local dot_up = glm.dot(surface, glm_up)
    if glm.approx(math.abs(dot_up), 1.0, decalEps) then
        local camRot = GetFinalRenderedCamRot(2)
        decalRight = quat(camRot.z, glm_up) * glm_right
    end
    
    -- Blood decal type (you may need to adjust this value based on your game version)
    local bloodDecalType = 1010
    
    local decalHandle = AddDecal(bloodDecalType,
        pos.x, pos.y, pos.z,
        decalForward.x, decalForward.y, decalForward.z,
        decalRight.x, decalRight.y, decalRight.z,
        textureSize.x, textureSize.y,
        0.5, 0.01, 0.01, 1.0,  -- Red tint for blood
        decalTimeout,
        1, 0, 1  -- Permanent decal, allow on vehicles
    )

    -- Store the decal handle for cleanup
    if decalHandle then
        table.insert(createdDecals, decalHandle)
    end

    return decalHandle
end

-- Main function to create blood decal behind a ped
function createBloodDecalBehindPed(ped)
    -- Decal size
    local decalSize = vec2(2.0, 2.0)
    
    -- Get ped position and heading
    local pedPos = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    
    -- Calculate position behind ped (adjust distance as needed)
    local behindDistance = -1.25
    local behindOffset = vec3(
        -math.sin(math.rad(pedHeading)) * behindDistance,
        math.cos(math.rad(pedHeading)) * behindDistance,
        0.0
    )
    local decalPos = pedPos + behindOffset
    
    -- Raycast down to find ground
    local groundPos = decalPos + vec3(0.0, 0.0, 0.5) -- Start slightly above
    local rayEnd = groundPos + vec3(0.0, 0.0, -5.0)   -- Ray 5 units down
    
    local ray = StartShapeTestRay(
        groundPos.x, groundPos.y, groundPos.z,
        rayEnd.x, rayEnd.y, rayEnd.z,
        1, -- Intersect with map
        ped, -- Ignore the ped
        0
    )
    
    local _, hit, hitPos, surfaceNormal, hitEntity = GetShapeTestResult(ray)
    
    if hit == 1 then
        -- Convert surface normal to glm vector
        local surface = vec3(surfaceNormal.x, surfaceNormal.y, surfaceNormal.z)
        surface = glm.normalize(surface)
        
        -- Create the decal
        return createBloodDecalFromSurface(
            vec3(hitPos.x, hitPos.y, hitPos.z),
            surface,
            hitEntity,
            decalSize
        )
    end
    
    return nil
end

-- Function to clean up all decals
function cleanupAllDecals()
    for _, handle in ipairs(createdDecals) do
        RemoveDecal(handle)
    end
    createdDecals = {}
end

-- Register cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        cleanupAllDecals()
    end
end)