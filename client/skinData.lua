local faceFeatures = {
    "Nose_Width", "Nose_Peak_Hight", "Nose_Peak_Lenght", "Nose_Bone_High", "Nose_Peak_Lowering",
    "Nose_Bone_Twist", "EyeBrown_High", "EyeBrown_Forward", "Cheeks_Bone_High", "Cheeks_Bone_Width",
    "Cheeks_Width", "Eyes_Openning", "Lips_Thickness", "Jaw_Bone_Width", "Jaw_Bone_Back_Lenght",
    "Chimp_Bone_Lowering", "Chimp_Bone_Lenght", "Chimp_Bone_Width", "Chimp_Hole", "Neck_Thikness",
}

local headOverlays = {
    "Blemishes", "FacialHair", "Eyebrows", "Ageing", "Makeup", "Blush", "Complexion", "SunDamage",
    "Lipstick", "MolesFreckles", "ChestHair", "BodyBlemishes", "AddBodyBlemishes",
}

local function GetHeadOverlayData(ped)
    local headData = {}
    for i = 1, #headOverlays do
        local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, i - 1)
        if retval then
            headData[i] = {
                name = headOverlays[i],
                overlayValue = overlayValue,
                colourType = colourType,
                firstColour = firstColour,
                secondColour = secondColour,
                overlayOpacity = overlayOpacity
            }
        end
    end
    return headData
end

local function GetHeadStructure(ped)
    local structure = {}
    for i = 1, #faceFeatures do
        structure[i] = GetPedFaceFeature(ped, i - 1)
    end
    return structure
end

local function GetPedHair(ped)
    return {
        GetPedHairColor(ped),
        GetPedHairHighlightColor(ped)
    }
end

local function GetPedHeadBlendData(ped)
    local blob = string.rep("\0\0\0\0\0\0\0\0", 6 + 3 + 1)
    if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, blob, true) then
        return nil
    end

    return {
        shapeFirst = string.unpack("<i4", blob, 1),
        shapeSecond = string.unpack("<i4", blob, 9),
        shapeThird = string.unpack("<i4", blob, 17),
        skinFirst = string.unpack("<i4", blob, 25),
        skinSecond = string.unpack("<i4", blob, 33),
        skinThird = string.unpack("<i4", blob, 41),
        shapeMix = string.unpack("<f", blob, 49),
        skinMix = string.unpack("<f", blob, 57),
        thirdMix = string.unpack("<f", blob, 65),
        hasParent = string.unpack("b", blob, 73) ~= 0
    }
end

local function GetPedComponentData(ped)
    local components = {
        {0, "head"}, {1, "beard"}, {2, "hair"}, {3, "torso"}, {4, "legs"},
        {5, "hands"}, {6, "foot"}, {7, "acc1"}, {8, "acc2"}, {9, "acc3"},
        {10, "mask"}, {11, "aux"}
    }
    local componentData = {}
    for _, component in ipairs(components) do
        componentData[tostring(component[1])] = {
            drawable = GetPedDrawableVariation(ped, component[1]),
            texture = GetPedTextureVariation(ped, component[1]),
            palette = GetPedPaletteVariation(ped, component[1])
        }
    end
    return componentData
end

local function GetPedPropData(ped)
    local props = {
        {0, "hat"}, {1, "glasses"}, {2, "ear"}, {6, "watch"}, {7, "wrist"}
    }
    local propData = {}
    for _, prop in ipairs(props) do
        propData[tostring(prop[1])] = {
            propIndex = GetPedPropIndex(ped, prop[1]),
            propTexture = GetPedPropTextureIndex(ped, prop[1])
        }
    end
    return propData
end

function GetSkinData(ped)
    return {
        headBlend = GetPedHeadBlendData(ped),
        headOverlays = GetHeadOverlayData(ped),
        headStructure = GetHeadStructure(ped),
        hair = GetPedHair(ped),
        components = GetPedComponentData(ped),
        props = GetPedPropData(ped),
        tattoos = GetPedDecorations(ped)
    }
end

function SetSkinData(ped, skinData)
    -- Set head blend
    if skinData.headBlend then
        SetPedHeadBlendData(ped, 
            skinData.headBlend.shapeFirst, skinData.headBlend.shapeSecond, skinData.headBlend.shapeThird,
            skinData.headBlend.skinFirst, skinData.headBlend.skinSecond, skinData.headBlend.skinThird,
            skinData.headBlend.shapeMix, skinData.headBlend.skinMix, skinData.headBlend.thirdMix, false)
    end

    -- Set head structure
    if skinData.headStructure then
        for i = 1, #faceFeatures do
            SetPedFaceFeature(ped, i - 1, skinData.headStructure[i])
        end
    end

    -- Set head overlays
    if skinData.headOverlays then
        for i = 1, #headOverlays do
            local overlay = skinData.headOverlays[i]
            if overlay then
                SetPedHeadOverlay(ped, i - 1, overlay.overlayValue, overlay.overlayOpacity)
                -- Set color for overlays that support it
                if i == 2 or i == 3 or i == 5 or i == 6 or i == 9 then
                    SetPedHeadOverlayColor(ped, i - 1, overlay.colourType, overlay.firstColour, overlay.secondColour)
                end
            end
        end
    end

    -- Set hair
    if skinData.hair then
        SetPedHairColor(ped, skinData.hair[1], skinData.hair[2])
    end

    -- Set components
    if skinData.components then
        for componentId, component in pairs(skinData.components) do
            local componentIndex = tonumber(componentId)
            SetPedComponentVariation(ped, componentIndex, component.drawable, component.texture, component.palette)
        end
    end

    -- Set props
    if skinData.props then
        for propId, prop in pairs(skinData.props) do
            local propIndex = tonumber(propId)
            if prop.propIndex == -1 then
                ClearPedProp(ped, propIndex)
            else
                SetPedPropIndex(ped, propIndex, prop.propIndex, prop.propTexture, true)
            end
        end
    end

    -- Set tattoos
    ClearPedDecorations(ped)
    if skinData.tattoos then
        for _, tattoo in ipairs(skinData.tattoos) do
            AddPedDecorationFromHashes(ped, tattoo[1], tattoo[2])
        end
    end
end