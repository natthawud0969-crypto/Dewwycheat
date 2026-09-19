_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

--------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------

local DISTANCE_MULTIPLIER = 0.346

-- Fly speed is fixed at 200
local FLY_SPEED = 200

local FREECAM_SPEED = 500

--------------------------------------------------------------------
-- PLAYER ESP
--------------------------------------------------------------------

local Holder = Instance.new("Folder")
Holder.Name = "ESP"
Holder.Parent = game.CoreGui

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)

local Tag = Instance.new("TextLabel")
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 40)
Tag.TextSize = 15
Tag.TextColor3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Tag.TextStrokeColor3 = Color3.new(0, 0, 0)
Tag.TextStrokeTransparency = 0.4
Tag.Text = "nil"
Tag.Font = Enum.Font.GothamMedium
Tag.TextScaled = false
Tag.Parent = NameTag

--------------------------------------------------------------------
-- PLAYER ESP LOAD
--------------------------------------------------------------------

local UnloadCharacter

local function LoadCharacter(v)

    repeat
        task.wait()
    until v.Character ~= nil

    local humanoid =
        v.Character:WaitForChild("Humanoid", 5)

    if not humanoid then
        return
    end

    local vHolder =
        Holder:FindFirstChild(v.Name)

    if not vHolder then
        return
    end

    vHolder:ClearAllChildren()

    ------------------------------------------------------------
    -- BOX
    ------------------------------------------------------------

    local b = Box:Clone()

    b.Name = v.Name .. "Box"
    b.Adornee = v.Character
    b.Visible = true
    b.Parent = vHolder

    ------------------------------------------------------------
    -- NAME + DISTANCE
    ------------------------------------------------------------

    local t = NameTag:Clone()

    t.Name = v.Name .. "NameTag"
    t.Enabled = true
    t.Parent = vHolder

    local head =
        v.Character:WaitForChild("Head", 5)

    if not head then
        UnloadCharacter(v)
        return
    end

    t.Adornee = head

    t.Tag.Text =
        v.Name .. "\n[--m]"

    ------------------------------------------------------------
    -- TEAM COLOR
    ------------------------------------------------------------

    b.Color3 = v.TeamColor.Color
    t.Tag.TextColor3 = v.TeamColor.Color

    ------------------------------------------------------------
    -- HIDE ROBLOX NAME
    ------------------------------------------------------------

    humanoid.DisplayDistanceType =
        Enum.HumanoidDisplayDistanceType.None
end

--------------------------------------------------------------------
-- PLAYER ESP UNLOAD
--------------------------------------------------------------------

UnloadCharacter = function(v)

    local vHolder =
        Holder:FindFirstChild(v.Name)

    if vHolder then
        vHolder:ClearAllChildren()
    end
end

--------------------------------------------------------------------
-- PLAYER SETUP
--------------------------------------------------------------------

local function LoadPlayer(v)

    if v == LocalPlayer then
        return
    end

    local vHolder =
        Holder:FindFirstChild(v.Name)

    if not vHolder then

        vHolder = Instance.new("Folder")
        vHolder.Name = v.Name
        vHolder.Parent = Holder
    end

    v.CharacterAdded:Connect(function()

        task.wait(0.1)

        pcall(function()
            LoadCharacter(v)
        end)
    end)

    v.CharacterRemoving:Connect(function()

        pcall(function()
            UnloadCharacter(v)
        end)
    end)

    v.Changed:Connect(function(prop)

        if prop == "TeamColor" then

            pcall(function()

                UnloadCharacter(v)

                task.wait()

                LoadCharacter(v)

            end)
        end
    end)

    pcall(function()
        LoadCharacter(v)
    end)
end

--------------------------------------------------------------------
-- PLAYER UNLOAD
--------------------------------------------------------------------

local function UnloadPlayer(v)

    UnloadCharacter(v)

    local vHolder =
        Holder:FindFirstChild(v.Name)

    if vHolder then
        vHolder:Destroy()
    end
end

--------------------------------------------------------------------
-- EXISTING PLAYERS
--------------------------------------------------------------------

for _, v in pairs(Players:GetPlayers()) do

    task.spawn(function()
        pcall(function()
            LoadPlayer(v)
        end)
    end)
end

Players.PlayerAdded:Connect(function(v)

    pcall(function()
        LoadPlayer(v)
    end)
end)

Players.PlayerRemoving:Connect(function(v)

    pcall(function()
        UnloadPlayer(v)
    end)
end)

LocalPlayer.NameDisplayDistance = 0

--------------------------------------------------------------------
-- PLAYER CHAMS
--------------------------------------------------------------------

if not _G.Reantheajfdfjdgs then

    _G.Reantheajfdfjdgs =
        ":suifayhgvsdghfsfkajewfrhk321rk213kjrgkhj432rj34f67df"

end

local function playerChams(target, color)

    if not target.Character then
        return
    end

    local highlight =
        target.Character:FindFirstChild("GetReal")

    if not highlight then

        highlight = Instance.new("Highlight")

        highlight.RobloxLocked = true
        highlight.Name = "GetReal"
        highlight.Adornee = target.Character

        highlight.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop

        highlight.FillColor = color
        highlight.Parent = target.Character

    else

        highlight.FillColor = color
    end
end

--------------------------------------------------------------------
-- PLAYER DISTANCE + CHAMS UPDATE
--------------------------------------------------------------------

RunService.RenderStepped:Connect(function()

    local localCharacter =
        LocalPlayer.Character

    if not localCharacter then
        return
    end

    local localRoot =
        localCharacter:FindFirstChild("HumanoidRootPart")

    if not localRoot then
        return
    end

    for _, player in pairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            --------------------------------------------------------
            -- DISTANCE
            --------------------------------------------------------

            if player.Character then

                local targetRoot =
                    player.Character:FindFirstChild(
                        "HumanoidRootPart"
                    )

                local playerHolder =
                    Holder:FindFirstChild(player.Name)

                if targetRoot and playerHolder then

                    local nameTag =
                        playerHolder:FindFirstChild(
                            player.Name .. "NameTag"
                        )

                    if nameTag
                        and nameTag:FindFirstChild("Tag") then

                        local studs =
                            (
                                localRoot.Position
                                - targetRoot.Position
                            ).Magnitude

                        local meters =
                            math.floor(
                                studs * DISTANCE_MULTIPLIER
                            )

                        nameTag.Tag.Text =
                            player.Name
                            .. "\n["
                            .. meters
                            .. "m]"
                    end
                end
            end

            --------------------------------------------------------
            -- CHAMS COLOR
            --------------------------------------------------------

            local color

            if _G.UseTeamColor then

                color =
                    player.TeamColor.Color

            else

                if LocalPlayer.TeamColor
                    == player.TeamColor then

                    color = _G.FriendColor

                else

                    color = _G.EnemyColor
                end
            end

            playerChams(player, color)
        end
    end
end)

--------------------------------------------------------------------
-- VEHICLE ESP
--------------------------------------------------------------------

local vehicleESPData = {}
local vehSpawnFolders = {}

local vehicleEspEnabled = true
local vehiclePartsEnabled = true

--------------------------------------------------------------------
-- VEHICLE COLORS
--------------------------------------------------------------------

local VEHICLE_TYPE_COLORS = {

    tank = {
        fill = Color3.fromRGB(170, 0, 255),
        outline = Color3.fromRGB(200, 100, 255)
    },

    air = {
        fill = Color3.fromRGB(0, 200, 255),
        outline = Color3.fromRGB(0, 150, 255)
    },

    sea = {
        fill = Color3.fromRGB(0, 100, 200),
        outline = Color3.fromRGB(0, 80, 180)
    },

    ground = {
        fill = Color3.fromRGB(255, 150, 0),
        outline = Color3.fromRGB(255, 120, 0)
    }
}

--------------------------------------------------------------------
-- VEHICLE MODULES
--------------------------------------------------------------------

local MODULE_DEFS = {

    {
        pattern = "^Engine$",
        fill = Color3.fromRGB(255, 255, 0),
        outline = Color3.fromRGB(255, 200, 0),
        label = "ENG"
    },

    {
        pattern = "[Aa]mmo",
        fill = Color3.fromRGB(255, 0, 0),
        outline = Color3.fromRGB(255, 100, 100),
        label = "AMMO"
    },

    {
        pattern = "[Bb]arrel|[Tt]urret",
        fill = Color3.fromRGB(255, 100, 120),
        outline = Color3.fromRGB(255, 150, 170),
        label = "TURR"
    }
}

--------------------------------------------------------------------
-- VEHICLE TYPE
--------------------------------------------------------------------

local function classifyVehicleType(vehicle)

    return "ground"
end

--------------------------------------------------------------------
-- FIND MODULE PARTS
--------------------------------------------------------------------

local function findModuleParts(vehicle)

    local modules = {}

    for _, mdef in ipairs(MODULE_DEFS) do

        for _, desc in ipairs(
            vehicle:GetDescendants()
        ) do

            if desc:IsA("BasePart")
                and desc.Name:match(mdef.pattern) then

                if not modules[mdef.label] then

                    modules[mdef.label] = {

                        part = desc,
                        fill = mdef.fill,
                        outline = mdef.outline
                    }
                end

                break
            end
        end
    end

    return modules
end

--------------------------------------------------------------------
-- FIND VEHICLE FOLDERS
--------------------------------------------------------------------

local function getVehicleSpawnFolders()

    local list = {}

    local sf =
        workspace:FindFirstChild("SpawnerVehicles")
        or workspace:FindFirstChild("SpawnedVehicles")

    if sf then
        table.insert(list, sf)
    end

    for _, c in ipairs(workspace:GetChildren()) do

        if c:IsA("Folder")
            and (
                c.Name:find("Vehicle")
                or c.Name:find("Spawn")
            ) then

            table.insert(list, c)
        end
    end

    return list
end

--------------------------------------------------------------------
-- ADD VEHICLE ESP
--------------------------------------------------------------------

local function addVehicleESP(vehicle)

    if vehicleESPData[vehicle] then
        return
    end

    if not vehicle
        or not vehicle:IsA("Model") then

        return
    end

    local primary =
        vehicle.PrimaryPart
        or vehicle:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

    if not primary then
        return
    end

    local highlights = {}
    local label = nil

    ------------------------------------------------------------
    -- MAIN VEHICLE HIGHLIGHT
    ------------------------------------------------------------

    if vehicleEspEnabled then

        local colors =
            VEHICLE_TYPE_COLORS[
                classifyVehicleType(vehicle)
            ]

        local mainHL =
            Instance.new("Highlight")

        mainHL.Name = "VehicleESP"

        mainHL.FillColor =
            colors.fill

        mainHL.OutlineColor =
            colors.outline

        mainHL.FillTransparency = 0.55
        mainHL.OutlineTransparency = 0

        mainHL.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop

        mainHL.Parent = vehicle

        table.insert(
            highlights,
            mainHL
        )

        --------------------------------------------------------
        -- VEHICLE DISTANCE
        --------------------------------------------------------

        local bb =
            Instance.new("BillboardGui")

        bb.Name = "VehicleDistance"

        bb.Size =
            UDim2.new(0, 120, 0, 20)

        bb.StudsOffset =
            Vector3.new(0, 5, 0)

        bb.AlwaysOnTop = true
        bb.Adornee = primary
        bb.Parent = primary

        local txt =
            Instance.new("TextLabel")

        txt.Name = "Distance"

        txt.Size =
            UDim2.fromScale(1, 1)

        txt.BackgroundTransparency = 1

        txt.Font =
            Enum.Font.GothamMedium

        txt.TextSize = 11

        txt.TextColor3 =
            Color3.new(1, 1, 1)

        txt.TextStrokeTransparency = 0.3

        txt.TextStrokeColor3 =
            Color3.new(0, 0, 0)

        txt.Text = "[--m]"

        txt.Parent = bb

        label = bb
    end

    ------------------------------------------------------------
    -- VEHICLE PARTS
    ------------------------------------------------------------

    if vehiclePartsEnabled then

        local moduleParts =
            findModuleParts(vehicle)

        for _, modData in pairs(moduleParts) do

            local hl =
                Instance.new("Highlight")

            hl.Name =
                "VehicleModuleESP"

            hl.FillColor =
                modData.fill

            hl.OutlineColor =
                modData.outline

            hl.FillTransparency = 0.3
            hl.OutlineTransparency = 0

            hl.DepthMode =
                Enum.HighlightDepthMode.AlwaysOnTop

            hl.Parent =
                modData.part

            table.insert(
                highlights,
                hl
            )
        end
    end

    ------------------------------------------------------------
    -- SAVE DATA
    ------------------------------------------------------------

    vehicleESPData[vehicle] = {

        highlights = highlights,
        label = label,
        primary = primary
    }
end

--------------------------------------------------------------------
-- REMOVE VEHICLE ESP
--------------------------------------------------------------------

local function removeVehicleESP(vehicle)

    local data =
        vehicleESPData[vehicle]

    if not data then
        return
    end

    for _, hl in ipairs(data.highlights) do

        pcall(function()
            hl:Destroy()
        end)
    end

    if data.label then

        pcall(function()
            data.label:Destroy()
        end)
    end

    vehicleESPData[vehicle] = nil
end

--------------------------------------------------------------------
-- FIND VEHICLES
--------------------------------------------------------------------

local function findVehicles()

    local vehicles = {}

    for _, folder in ipairs(
        vehSpawnFolders
    ) do

        if folder
            and folder.Parent then

            for _, child in ipairs(
                folder:GetChildren()
            ) do

                if child:IsA("Model") then

                    vehicles[child] = true
                end
            end
        end
    end

    return vehicles
end

--------------------------------------------------------------------
-- VEHICLE FOLDER WATCHERS
--------------------------------------------------------------------

local function setupSpawnFolderWatchers()

    vehSpawnFolders =
        getVehicleSpawnFolders()

    for _, folder in ipairs(
        vehSpawnFolders
    ) do

        folder.ChildAdded:Connect(
            function(child)

                if (
                    vehicleEspEnabled
                    or vehiclePartsEnabled
                )
                and child:IsA("Model") then

                    task.wait()

                    addVehicleESP(child)
                end
            end
        )

        folder.ChildRemoved:Connect(
            function(child)

                if child:IsA("Model") then

                    removeVehicleESP(child)
                end
            end
        )
    end
end

--------------------------------------------------------------------
-- INITIAL VEHICLES
--------------------------------------------------------------------

task.spawn(function()

    setupSpawnFolderWatchers()

    for vehicle in pairs(
        findVehicles()
    ) do

        if vehicleEspEnabled
            or vehiclePartsEnabled then

            addVehicleESP(vehicle)
        end
    end
end)

--------------------------------------------------------------------
-- VEHICLE DISTANCE UPDATE
--------------------------------------------------------------------

RunService.RenderStepped:Connect(
    function()

        if not vehicleEspEnabled then
            return
        end

        local character =
            LocalPlayer.Character

        if not character then
            return
        end

        local localRoot =
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        if not localRoot then
            return
        end

        for vehicle, data in pairs(
            vehicleESPData
        ) do

            if data.label
                and data.label.Parent
                and data.primary
                and data.primary.Parent then

                local textLabel =
                    data.label:FindFirstChild(
                        "Distance"
                    )

                if textLabel then

                    local studs =
                        (
                            localRoot.Position
                            - data.primary.Position
                        ).Magnitude

                    local meters =
                        math.floor(
                            studs
                            * DISTANCE_MULTIPLIER
                        )

                    textLabel.Text =
                        "["
                        .. meters
                        .. "m]"
                end
            end
        end
    end
)

--------------------------------------------------------------------
-- FLY
-- Based on the requested nomercy-style movement
-- Fixed speed = 200
--------------------------------------------------------------------

local flyEnabled = false
local flyConnection = nil

--------------------------------------------------------------------
-- STOP FLY
--------------------------------------------------------------------

local function stopFly()

    flyEnabled = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local character =
        LocalPlayer.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if root then

        root.Anchored = false

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if humanoid then
        humanoid.AutoRotate = true
    end
end

--------------------------------------------------------------------
-- START FLY
--------------------------------------------------------------------

local function startFly()

    if flyConnection then
        return
    end

    local character =
        LocalPlayer.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not root or not humanoid then
        return
    end

    flyEnabled = true

    humanoid.AutoRotate = false

    flyConnection =
        RunService.Heartbeat:Connect(
            function(dt)

                if not flyEnabled then
                    return
                end

                local currentCharacter =
                    LocalPlayer.Character

                if not currentCharacter then
                    stopFly()
                    return
                end

                local currentRoot =
                    currentCharacter:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if not currentRoot then
                    return
                end

                local camera =
                    workspace.CurrentCamera

                if not camera then
                    return
                end

                ------------------------------------------------
                -- LOCK PHYSICS
                ------------------------------------------------

                currentRoot.Anchored = true

                currentRoot.AssemblyLinearVelocity =
                    Vector3.zero

                currentRoot.AssemblyAngularVelocity =
                    Vector3.zero

                ------------------------------------------------
                -- MOVEMENT
                ------------------------------------------------

                local direction =
                    Vector3.zero

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then

                    direction +=
                        camera.CFrame.LookVector
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then

                    direction -=
                        camera.CFrame.LookVector
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    direction -=
                        camera.CFrame.RightVector
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then

                    direction +=
                        camera.CFrame.RightVector
                end

                ------------------------------------------------
                -- UP / DOWN
                ------------------------------------------------

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftShift
                ) then

                    direction +=
                        Vector3.new(0, 1, 0)
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then

                    direction -=
                        Vector3.new(0, 1, 0)
                end

                ------------------------------------------------
                -- MOVE
                ------------------------------------------------

                local newPosition =
                    currentRoot.Position

                if direction.Magnitude > 0 then

                    newPosition =
                        newPosition
                        + direction.Unit
                        * FLY_SPEED
                        * dt
                end

                ------------------------------------------------
                -- ROTATION
                ------------------------------------------------

                local lookDirection =
                    camera.CFrame.LookVector

                if lookDirection.Magnitude > 0.01 then

                    currentRoot.CFrame =
                        CFrame.lookAt(
                            newPosition,
                            newPosition
                            + lookDirection
                        )

                else

                    currentRoot.CFrame =
                        CFrame.new(
                            newPosition
                        )
                end

                ------------------------------------------------
                -- RELEASE FOR THIS FRAME
                ------------------------------------------------

                currentRoot.Anchored = false
            end
        )
end

--------------------------------------------------------------------
-- TOGGLE FLY
--------------------------------------------------------------------

local function toggleFly()

    if flyEnabled then
        stopFly()
    else
        startFly()
    end
end

--------------------------------------------------------------------
-- FREECAM
--------------------------------------------------------------------

local freecamEnabled = false

local freecamConnection = nil
local freecamInputConnection = nil

local freecamCFrame = nil

local oldCameraType = nil
local oldCameraSubject = nil

local freecamYaw = 0
local freecamPitch = 0

--------------------------------------------------------------------
-- STOP FREECAM
--------------------------------------------------------------------

local function stopFreecam()

    freecamEnabled = false

    if freecamConnection then

        freecamConnection:Disconnect()
        freecamConnection = nil
    end

    if freecamInputConnection then

        freecamInputConnection:Disconnect()
        freecamInputConnection = nil
    end

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    local camera =
        workspace.CurrentCamera

    camera.CameraType =
        oldCameraType
        or Enum.CameraType.Custom

    if oldCameraSubject then

        camera.CameraSubject =
            oldCameraSubject

    else

        local character =
            LocalPlayer.Character

        local humanoid =
            character
            and character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then
            camera.CameraSubject =
                humanoid
        end
    end
end

--------------------------------------------------------------------
-- START FREECAM
--------------------------------------------------------------------

local function startFreecam()

    if freecamEnabled then
        return
    end

    local camera =
        workspace.CurrentCamera

    freecamEnabled = true

    oldCameraType =
        camera.CameraType

    oldCameraSubject =
        camera.CameraSubject

    freecamCFrame =
        camera.CFrame

    local lookVector =
        freecamCFrame.LookVector

    freecamYaw =
        math.atan2(
            -lookVector.X,
            -lookVector.Z
        )

    freecamPitch =
        math.asin(
            math.clamp(
                lookVector.Y,
                -1,
                1
            )
        )

    camera.CameraType =
        Enum.CameraType.Scriptable

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.LockCenter

    ------------------------------------------------------------
    -- MOUSE
    ------------------------------------------------------------

    freecamInputConnection =
        UserInputService.InputChanged:Connect(
            function(input)

                if not freecamEnabled then
                    return
                end

                if input.UserInputType
                    == Enum.UserInputType.MouseMovement then

                    local sensitivity =
                        0.0025

                    freecamYaw -=
                        input.Delta.X
                        * sensitivity

                    freecamPitch -=
                        input.Delta.Y
                        * sensitivity

                    freecamPitch =
                        math.clamp(
                            freecamPitch,
                            math.rad(-89),
                            math.rad(89)
                        )
                end
            end
        )

    ------------------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------------------

    freecamConnection =
        RunService.RenderStepped:Connect(
            function(dt)

                if not freecamEnabled then
                    return
                end

                local camera =
                    workspace.CurrentCamera

                local rotation =
                    CFrame.Angles(
                        0,
                        freecamYaw,
                        0
                    )
                    * CFrame.Angles(
                        freecamPitch,
                        0,
                        0
                    )

                local move =
                    Vector3.zero

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then

                    move +=
                        Vector3.new(
                            0,
                            0,
                            -1
                        )
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then

                    move +=
                        Vector3.new(
                            0,
                            0,
                            1
                        )
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    move +=
                        Vector3.new(
                            -1,
                            0,
                            0
                        )
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then

                    move +=
                        Vector3.new(
                            1,
                            0,
                            0
                        )
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then

                    move +=
                        Vector3.new(
                            0,
                            1,
                            0
                        )
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then

                    move +=
                        Vector3.new(
                            0,
                            -1,
                            0
                        )
                end

                if move.Magnitude > 0 then

                    move =
                        move.Unit

                    local worldMove =
                        rotation:VectorToWorldSpace(
                            move
                        )

                    freecamCFrame =
                        freecamCFrame
                        + worldMove
                        * FREECAM_SPEED
                        * dt
                end

                freecamCFrame =
                    CFrame.new(
                        freecamCFrame.Position
                    )
                    * rotation

                camera.CFrame =
                    freecamCFrame
            end
        )
end

--------------------------------------------------------------------
-- KEYBINDS
--------------------------------------------------------------------

UserInputService.InputBegan:Connect(
    function(input, gameProcessed)

        if gameProcessed then
            return
        end

        ------------------------------------------------------------
        -- V = FLY
        ------------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.V then

            toggleFly()
        end

        ------------------------------------------------------------
        -- L = FREECAM
        ------------------------------------------------------------

        if input.KeyCode ==
            Enum.KeyCode.L then

            if freecamEnabled then
                stopFreecam()
            else
                startFreecam()
            end
        end
    end
)

--------------------------------------------------------------------
-- CHARACTER RESET
--------------------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(
    function()

        if flyEnabled then
            stopFly()
        end

        if freecamEnabled then
            stopFreecam()
        end
    end
)
