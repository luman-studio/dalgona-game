-- Configuration for cinematics
local CinematicConfig = {
    Debug = false,
    DefaultTransitionTime = 5000,
    DefaultRotation = { pitch = 0.0, roll = 0.0, yaw = 90.0 }
}

-- Utility functions
local function CreateCameraAtPosition(shot)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, shot.position.x, shot.position.y, shot.position.z)
    SetCamRot(cam, shot.rotation.pitch, shot.rotation.roll, shot.rotation.yaw)
    return cam
end

local function TransitionBetweenCams(fromCam, toCam, duration)
    SetCamActiveWithInterp(toCam, fromCam, duration, 1, 1)
    Wait(duration)
end

-- Main cinematic controller
CinematicController = {
    isPlaying = false,
    activeCameras = {},
    
    ---@param sequence table Array of CameraShot definitions
    PlaySequence = function(self, sequence)
        if CinematicConfig.Debug then
            return
        end
        
        if self.isPlaying then
            return
        end
        
        self.isPlaying = true
        SetPlayerControl(PlayerId(), false, 0)
        
        -- Create and store all cameras
        for _, shot in ipairs(sequence) do
            local cam = CreateCameraAtPosition(shot)
            table.insert(self.activeCameras, cam)
        end
        
        -- Activate first camera
        SetCamActive(self.activeCameras[1], true)
        RenderScriptCams(true, false, 0, true, true)
        
        -- Process transitions
        for i = 1, #self.activeCameras - 1 do
            local currentShot = sequence[i]
            TransitionBetweenCams(
                self.activeCameras[i],
                self.activeCameras[i + 1],
                currentShot.transitionTime
            )
            
            if currentShot.waitTime and currentShot.waitTime > 0 then
                Wait(currentShot.waitTime)
            end
        end
        
        -- Cleanup
        self:EndSequence()
    end,
    
    EndSequence = function(self)
        RenderScriptCams(false, false, 0, true, true)
        
        for _, cam in ipairs(self.activeCameras) do
            DestroyCam(cam, false)
        end
        
        self.activeCameras = {}
        SetPlayerControl(PlayerId(), true, 0)
        self.isPlaying = false
    end
}

-- Event handler for resource stop
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if Config.Cutscene.Enabled then
            CinematicController:EndSequence()
        end
    end
end)

RegisterNetEvent(EVENTS['resetPlayer'], function()
    if Config.Cutscene.Enabled then
        CinematicController:EndSequence()
    end
end)

-- Play cutscene when game initiated
RegisterNetEvent(EVENTS['gameInitiated'], function(coords)
    DoScreenFadeOut(0)
    Wait(Config.PlayerNPCSpawnDelay)
    DoScreenFadeIn(250)
    
    if Config.Cutscene.Enabled then
        CinematicController:PlaySequence(Config.Cutscene.Sequence)
    end
end)