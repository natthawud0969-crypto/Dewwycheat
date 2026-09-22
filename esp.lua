--------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

local DISTANCE_MULTIPLIER = 0.346
local MAX_ESP_DISTANCE_METERS = 10000
local MAX_ESP_DISTANCE_STUDS =
    MAX_ESP_DISTANCE_METERS / DISTANCE_MULTIPLIER

--------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------

local function getCharacter(player)
    return player.Character
end

local function getRoot(character)
    if not character then return nil end

    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
end

local function getDistanceInMeters(position)
    local character = LocalPlayer.Character
    local root = getRoot(character)

    if not root then
        return math.huge
    end

    local studs = (root.Position - position).Magnitude
    return studs * DISTANCE_MULTIPLIER
end

local function getESPColor(player)
    if _G.UseTeamColor and player.Team then
        return player.Team.TeamColor.Color
    end

    if player == LocalPlayer then
        return _G.FriendColor
    end

    if LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return _G.FriendColor
    end

    return _G.EnemyColor
end

--------------------------------------------------------------------
-- PLAYER ESP
--------------------------------------------------------------------

local PlayerESP = {}

local function removePlayerESP(player)
    local data = PlayerESP[player]

    if not data then
        return
    end

    if data.Box then
        data.Box:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    PlayerESP[player] = nil
end

local function createPlayerESP(player)
    if player == LocalPlayer then
        return
    end

    removePlayerESP(player)

    local character = player.Character
    if not character then
        return
    end

    local root = getRoot(character)
    if not root then
        return
    end

    ------------------------------------------------------------
    -- BOX
    ------------------------------------------------------------

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "PlayerESP_Box"
    box.Adornee = root
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.65
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = getESPColor(player)
    box.Parent = root

    ------------------------------------------------------------
    -- DISTANCE BILLBOARD
    ------------------------------------------------------------

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP_Distance"
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = root

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Size = UDim2.fromScale(1, 1)

    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextSize = 16
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Text = "0m"

    distanceLabel.Parent = billboard

    ------------------------------------------------------------
    -- CHAMS
    ------------------------------------------------------------

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_Chams"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.FillColor = getESPColor(player)
    highlight.OutlineColor = getESPColor(player)
    highlight.Parent = character

    PlayerESP[player] = {
        Box = box,
        Billboard = billboard,
        Label = distanceLabel,
        Highlight = highlight
    }
end

--------------------------------------------------------------------
-- PLAYER ESP UPDATE
--------------------------------------------------------------------

local function updatePlayerESP(player)
    local data = PlayerESP[player]

    if not data then
        return
    end

    local character = player.Character
    local root = getRoot(character)

    if not character or not root then
        data.Box.Visible = false
        data.Billboard.Enabled = false
        data.Highlight.Enabled = false
        return
    end

    local distance = getDistanceInMeters(root.Position)

    if distance > MAX_ESP_DISTANCE_METERS then
        data.Box.Visible = false
        data.Billboard.Enabled = false
        data.Highlight.Enabled = false
        return
    end

    data.Box.Visible = true
    data.Billboard.Enabled = true
    data.Highlight.Enabled = true

    local meters = math.floor(distance + 0.5)

    data.Label.Text = tostring(meters) .. "m"

    local color = getESPColor(player)

    data.Box.Color3 = color

    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color
end

--------------------------------------------------------------------
-- PLAYER EVENTS
--------------------------------------------------------------------

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            task.spawn(function()
                createPlayerESP(player)
            end)
        end

        player.CharacterAdded:Connect(function()
            task.wait(0.3)
            createPlayerESP(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        createPlayerESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)

--------------------------------------------------------------------
-- VEHICLE ESP
--------------------------------------------------------------------

local VehicleESP = {}

local function isVehicleModel(object)
    if not object:IsA("Model") then
        return false
    end

    local name = object.Name:lower()

    if name:find("vehicle")
        or name:find("tank")
        or name:find("car")
        or name:find("truck")
        or name:find("jeep")
        or name:find("apc")
        or name:find("mbt") then

        return true
    end

    return false
end

local function findVehicleRoot(vehicle)
    if not vehicle then
        return nil
    end

    return vehicle.PrimaryPart
        or vehicle:FindFirstChild("HumanoidRootPart", true)
        or vehicle:FindFirstChild("Main", true)
        or vehicle:FindFirstChild("Chassis", true)
        or vehicle:FindFirstChildWhichIsA("BasePart", true)
end

local function addVehicleHighlight(vehicle, name, color)
    local highlight = Instance.new("Highlight")
    highlight.Name = name
    highlight.Adornee = vehicle
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = vehicle

    return highlight
end

local function removeVehicleESP(vehicle)
    local data = VehicleESP[vehicle]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    if data.Modules then
        for _, highlight in pairs(data.Modules) do
            if highlight then
                highlight:Destroy()
            end
        end
    end

    VehicleESP[vehicle] = nil
end

local function createVehicleESP(vehicle)
    if not isVehicleModel(vehicle) then
        return
    end

    if VehicleESP[vehicle] then
        return
    end

    local root = findVehicleRoot(vehicle)

    if not root then
        return
    end

    ------------------------------------------------------------
    -- VEHICLE MAIN CHAMS
    ------------------------------------------------------------

    local vehicleColor = Color3.fromRGB(255, 255, 0)

    local mainHighlight = addVehicleHighlight(
        vehicle,
        "VehicleESP_Main",
        vehicleColor
    )

    ------------------------------------------------------------
    -- DISTANCE
    ------------------------------------------------------------

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VehicleESP_Distance"
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.Parent = root

    local label = Instance.new("TextLabel")
    label.Name = "Distance"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)

    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Text = "0m"

    label.Parent = billboard

    ------------------------------------------------------------
    -- MODULE CHAMS
    ------------------------------------------------------------

    local modules = {}

    local engine = vehicle:FindFirstChild("Engine", true)
    local ammo = vehicle:FindFirstChild("Ammo", true)
    local barrel = vehicle:FindFirstChild("Barrel", true)
    local turret = vehicle:FindFirstChild("Turret", true)

    if engine then
        modules.Engine = addVehicleHighlight(
            engine,
            "VehicleESP_Engine",
            Color3.fromRGB(255, 100, 0)
        )
    end

    if ammo then
        modules.Ammo = addVehicleHighlight(
            ammo,
            "VehicleESP_Ammo",
            Color3.fromRGB(255, 0, 0)
        )
    end

    if barrel then
        modules.Barrel = addVehicleHighlight(
            barrel,
            "VehicleESP_Barrel",
            Color3.fromRGB(0, 255, 0)
        )
    end

    if turret then
        modules.Turret = addVehicleHighlight(
            turret,
            "VehicleESP_Turret",
            Color3.fromRGB(0, 170, 255)
        )
    end

    VehicleESP[vehicle] = {
        Highlight = mainHighlight,
        Billboard = billboard,
        Label = label,
        Modules = modules
    }
end

--------------------------------------------------------------------
-- VEHICLE ESP UPDATE
--------------------------------------------------------------------

local function updateVehicleESP(vehicle)
    local data = VehicleESP[vehicle]

    if not data then
        return
    end

    if not vehicle or not vehicle.Parent then
        removeVehicleESP(vehicle)
        return
    end

    local root = findVehicleRoot(vehicle)

    if not root then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false

        for _, highlight in pairs(data.Modules) do
            highlight.Enabled = false
        end

        return
    end

    local distance = getDistanceInMeters(root.Position)

    if distance > MAX_ESP_DISTANCE_METERS then
        data.Highlight.Enabled = false
        data.Billboard.Enabled = false

        for _, highlight in pairs(data.Modules) do
            highlight.Enabled = false
        end

        return
    end

    data.Highlight.Enabled = true
    data.Billboard.Enabled = true

    for _, highlight in pairs(data.Modules) do
        highlight.Enabled = true
    end

    local meters = math.floor(distance + 0.5)
    data.Label.Text = tostring(meters) .. "m"
end

--------------------------------------------------------------------
-- FIND VEHICLES
--------------------------------------------------------------------

local function getVehicleSpawnFolders()
    local list = {}

    local sf =
        workspace:FindFirstChild("SpawnerVehicles")
        or workspace:FindFirstChild("SpawnedVehicles")

    if sf then
        table.insert(list, sf)
    end

    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Folder") then
            local lowerName = child.Name:lower()

            if lowerName:find("vehicle")
                or lowerName:find("vehicles") then

                table.insert(list, child)
            end
        end
    end

    return list
end

local function scanVehicles()
    for _, folder in ipairs(getVehicleSpawnFolders()) do
        for _, object in ipairs(folder:GetChildren()) do
            if isVehicleModel(object) then
                createVehicleESP(object)
            end
        end
    end

    for _, object in ipairs(workspace:GetChildren()) do
        if isVehicleModel(object) then
            createVehicleESP(object)
        end
    end
end

scanVehicles()

workspace.ChildAdded:Connect(function(object)
    task.wait(0.2)

    if isVehicleModel(object) then
        createVehicleESP(object)
    end
end)

--------------------------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    ------------------------------------------------------------
    -- PLAYERS
    ------------------------------------------------------------

    for player, _ in pairs(PlayerESP) do
        if player and player.Parent then
            updatePlayerESP(player)
        else
            removePlayerESP(player)
        end
    end

    ------------------------------------------------------------
    -- VEHICLES
    ------------------------------------------------------------

    for vehicle, _ in pairs(VehicleESP) do
        updateVehicleESP(vehicle)
    end
end)

--------------------------------------------------------------------
-- FLY
--------------------------------------------------------------------

local flying = false
local flySpeed = 200
local flyConnection = nil

local function startFly()
    if flyConnection then
        return
    end

    flying = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            return
        end

        local character = LocalPlayer.Character
        local root = getRoot(character)

        if not root then
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            return
        end

        local moveDirection = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection += Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection -= Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection -= Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection += Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection -= Vector3.new(0, 1, 0)
        end

        if moveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity =
                moveDirection.Unit * flySpeed
        else
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopFly()
    flying = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local character = LocalPlayer.Character
    local root = getRoot(character)

    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
end

local function toggleFly()
    if flying then
        stopFly()
    else
        startFly()
    end
end

--------------------------------------------------------------------
-- FREECAM
-- Nomercy-style Freecam
--------------------------------------------------------------------

local freecamEnabled = false
local freecamConnection = nil
local freecamSpeed = 500

local freecamOriginalType = nil
local freecamOriginalSubject = nil

local function startFreecam()
    if freecamConnection then
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    freecamOriginalSubject = camera.CameraSubject
    freecamOriginalType = camera.CameraType

    camera.CameraType = Enum.CameraType.Scriptable

    local lastMousePos =
        UserInputService:GetMouseLocation()

    freecamConnection =
        RunService.RenderStepped:Connect(function(dt)

            if not freecamEnabled then
                return
            end

            local currentCamera =
                workspace.CurrentCamera

            if not currentCamera then
                return
            end

            --------------------------------------------------------
            -- MOVEMENT
            --------------------------------------------------------

            local moveDir = Vector3.zero
            local camCF = currentCamera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir += camCF.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir -= camCF.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir -= camCF.RightVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir += camCF.RightVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir += Vector3.new(0, 1, 0)
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.LeftControl
            ) then
                moveDir -= Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then
                currentCamera.CFrame =
                    currentCamera.CFrame
                    + moveDir.Unit
                    * freecamSpeed
                    * dt
            end

            --------------------------------------------------------
            -- CAMERA ROTATION
            --------------------------------------------------------

            local currentMousePos =
                UserInputService:GetMouseLocation()

            local delta =
                currentMousePos - lastMousePos

            if delta.Magnitude > 0
                and UserInputService:IsMouseButtonPressed(
                    Enum.UserInputType.MouseButton2
                ) then

                local sensitivity = 0.3

                local rotation =
                    CFrame.Angles(
                        0,
                        -math.rad(
                            delta.X * sensitivity
                        ),
                        0
                    )
                    *
                    CFrame.Angles(
                        -math.rad(
                            delta.Y * sensitivity
                        ),
                        0,
                        0
                    )

                currentCamera.CFrame =
                    currentCamera.CFrame * rotation
            end

            lastMousePos = currentMousePos
        end)
end

local function stopFreecam()
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    --------------------------------------------------------
    -- RESTORE CAMERA TYPE
    --------------------------------------------------------

    if freecamOriginalType then
        camera.CameraType = freecamOriginalType
        freecamOriginalType = nil
    else
        camera.CameraType = Enum.CameraType.Custom
    end

    --------------------------------------------------------
    -- RESTORE CAMERA SUBJECT
    --------------------------------------------------------

    if freecamOriginalSubject then
        camera.CameraSubject =
            freecamOriginalSubject

        freecamOriginalSubject = nil
    else
        local character =
            LocalPlayer.Character

        local humanoid =
            character
            and character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then
            camera.CameraSubject = humanoid
        end
    end
end

local function toggleFreecam()
    freecamEnabled = not freecamEnabled

    if freecamEnabled then
        startFreecam()
    else
        stopFreecam()
    end
end

--------------------------------------------------------------------
-- CHARACTER RESPAWN
--------------------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()
    if freecamEnabled then
        stopFreecam()

        task.wait(0.3)

        if freecamEnabled then
            startFreecam()
        end
    end
end)

--------------------------------------------------------------------
-- KEYBINDS
--------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(
    input,
    gameProcessed
)

    if gameProcessed then
        return
    end

    ------------------------------------------------------------
    -- FLY = V
    ------------------------------------------------------------

    if input.KeyCode == Enum.KeyCode.V then
        toggleFly()
    end

    ------------------------------------------------------------
    -- FREECAM = L
    ------------------------------------------------------------

    if input.KeyCode == Enum.KeyCode.L then
        toggleFreecam()
    end
end)

--------------------------------------------------------------------
-- VEHICLE RESCAN
--------------------------------------------------------------------

task.spawn(function()
    while true do
        task.wait(3)
        scanVehicles()
    end
end)
