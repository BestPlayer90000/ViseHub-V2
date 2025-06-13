-- // Luraph Macros
if not LPH_OBFUSCATED then
    script_key = 'LXPwmzbaedHILKyuAsSxBUSkhWZmxUwT'
    LRM_UserNote = 'Blitz [DEVELOPER]'
    LRM_ScriptName = 'NG'
    LRM_SecondsLeft = math.huge
    LRM_IsUserPremium = false
    LRM_LinkedDiscordID = '855840079376285727'
    LRM_TotalExecutions = 10
    LRM_INIT_SCRIPT = function(f)
        f()
    end

    LPH_JIT = function(...)
        return ...
    end
    LPH_CRASH = function()
        -- return error(debug.traceback())
    end
    LPH_ENCNUM = function(...)
        return ...
    end
    LPH_ENCSTR = function(...)
        return ...
    end
    LPH_JIT_MAX = function(...)
        return ...
    end
    LPH_HOOK_FIX = function(...)
        return ...
    end
    LPH_JIT_ULTRA = function(...)
        return ...
    end
    LPH_NO_UPVALUES = function(f)
        return function(...)
            return f(...)
        end
    end
    LPH_NO_VIRTUALIZE = function(...)
        return ...
    end
end

-- // Libraries
local networkKeys, network = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/Introvert1337/RobloxReleases/refs/heads/main/Scripts/Jailbreak/KeyFetcher.lua'
    )
)()

-- // Hashes
local RedeemCodeKey = networkKeys.RedeemCode
local KickKey = networkKeys.Kick
local DamageKey = networkKeys.Damage
local JoinTeamKey = networkKeys.JoinTeam
local SwitchTeamKey = networkKeys.SwitchTeam
local ExitCarKey = networkKeys.ExitCar
local TazeKey = networkKeys.Taze
local DropRopeKey = networkKeys.DropRope
local PunchKey = networkKeys.Punch
local ArrestKey = networkKeys.Arrest
local PickpocketKey = networkKeys.Pickpocket
local BreakoutKey = networkKeys.Breakout
local BroadcastInputBeganKey = networkKeys.BroadcastInputBegan
local BroadcastInputEndedKey = networkKeys.BroadcastInputEnded
local HijackKey = networkKeys.Hijack
local EjectKey = networkKeys.Eject
local EnterCarKey = networkKeys.EnterCar
local RobEndKey = networkKeys.RobEnd
local RobStartKey = networkKeys.RobStart
local OpenDoorKey = networkKeys.OpenDoor
local FallDamageKey = networkKeys.FallDamage
local UnequipGunKey = networkKeys.UnequipGun
local EquipGunKey = networkKeys.EquipGun
local BuyGunKey = networkKeys.BuyGun
local RagdollKey = networkKeys.Ragdoll

-- // Services
local Services = setmetatable({}, {
    __index = function(self, service)
        return game:GetService(service)
    end,
})

local Teams = Services.Teams
local Players = Services.Players
local CoreGui = Services.CoreGui
local Workspace = Services.Workspace
local RunService = Services.RunService
local HttpService = Services.HttpService
local VirtualUser = Services.VirtualUser
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local TextChatService = Services.TextChatService
local ReplicatedStorage = Services.ReplicatedStorage
local CollectionService = Services.CollectionService
local VirtualInputManager = Services.VirtualInputManager
local PathfindingService = Services.PathfindingService

-- // Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild('PlayerGui')
local Backpack = Player:WaitForChild('Folder')
local TimeLeft = (LRM_SecondsLeft or 0)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass('Humanoid')
local Root = Character:FindFirstChild('HumanoidRootPart')
local Toggle = false
local Halt = false
local LaggedBack = false
local CurrentlyRobbing = nil
local OwnedCars = { 'Camaro', 'Jeep', 'Heli' }
local DoorPositions = {}
local NewCFrame = CFrame.new
local NewVector = Vector3.new

-- // Functions
local function RandomString()
    local Length = math.random(10, 20)
    local Result = {}

    for Index = 1, Length do
        Result[Index] = string.char(math.random(32, 126))
    end

    return table.concat(Result)
end

-- // Config
local YLevel = 350
local HomeLevel = 2000
local CopDetectionRange = 65
local Dots = 0
local JSON = nil
local Settings = {}
local ViseHub = {
    AutoArrest = {
        InstantTeleport = false,
        CarSpeed = 52.5,
        PlayerSpeed = 15,
        AutoBustBank = false,
    },
}

-- // Workspace Utilities
local Vehicles = Workspace:WaitForChild('Vehicles')
local VehicleSpawns = Workspace:WaitForChild('VehicleSpawns')
local Trains = Workspace:WaitForChild('Trains')
local Building = nil
local RaycastParams = RaycastParams.new()
local PlatformPart = Instance.new('Part')
local RaycastIgnored = { Vehicles, VehicleSpawns, Trains, PlatformPart }
local RaycastIgnorable = {
    'Items',
    'Plane',
    'Rain',
    'RainSnow',
    'RainFall',
    'DirtRoad',
}
PlatformPart.CFrame = NewCFrame(0, 0, 0)
PlatformPart.Size = NewVector(150, 5, 150)
PlatformPart.Name = 'NG'
PlatformPart.Anchored = true
PlatformPart.CanCollide = true
PlatformPart.Parent = Workspace
RaycastParams.IgnoreWater = true
RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- // Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

function Arrested()
    return PlayerGui.MainGui.CellTime.Visible == true
        or Backpack:FindFirstChild('Cuffed')
end

-- // Location Rendering
local StartPos = NewVector(-1528, 39, -5179)
local EndPos = NewVector(1567, 99, -717)
local SafeBuildingPos = NewCFrame(
    274.473419,
    35.3500443,
    853.257324,
    0.981609404,
    0.190900385,
    -5.88595867e-06,
    5.88595867e-06,
    -6.10351562e-05,
    -0.99999994,
    -0.190900385,
    0.981609404,
    -6.10351562e-05
)
local ViableLocations = {
    [1] = NewVector(-1241, 41, -1565),
    [2] = NewVector(855, 19, -3685),
    [3] = NewVector(735, 71, 1104),
    [4] = NewVector(79, 21, 2349),
    [5] = NewVector(-355, 21, 2039),
    [6] = NewVector(-240, 18, 1616),
    [7] = NewVector(107, 18, 1371),
    [8] = NewVector(-9, 18, 866),
    [9] = NewVector(1055, 101, 1253),
    [10] = NewVector(600, 20, -491),
    [11] = NewVector(62, 19, -1622),
    [12] = NewVector(-1600, 18, 662),
    [13] = NewVector(-164, 19, -4559),
    [14] = NewVector(-724, 19, -6046),
    [15] = NewVector(-2862, 193, -4058),
    [16] = NewVector(3015, 58, -4569),
    [17] = NewVector(1415, 41, -4328),
    [18] = NewVector(-676, 28, -3677),
    [19] = NewVector(1099, 48, 88),
}

task.spawn(function()
    while task.wait(10) do
        pcall(function()
            for _, Position in pairs(ViableLocations) do
                Player:RequestStreamAroundAsync(pos, 1000)
                task.wait()
            end

            for x = StartPos.X, EndPos.X, 750 do
                for z = StartPos.Z, EndPos.Z, 750 do
                    Player:RequestStreamAroundAsync(NewVector(x, 50, z), 1000)
                    task.wait()
                end
            end
        end)
    end
end)

local function GetBuilding()
    for i, v in pairs(Workspace:GetDescendants()) do
        if v:IsA('BasePart') and v.CFrame == SafeBuildingPos then
            return v
        end
    end
end

local function GetVehicleModel()
    for i, v in pairs(Vehicles:GetChildren()) do
        if
            v
            and v.Seat
            and v.Seat:FindFirstChild('PlayerName')
            and tostring(v.Seat.PlayerName.Value)
                == Players.LocalPlayer.Name
        then
            return v
        end
    end
    return nil
end

-- // Input Functions
function SpinAround(part)
    local angle = 0
    local Stop = false
    task.spawn(function()
        while true do
            angle = angle + 0.3
            local x = part.Position.X + math.cos(angle) * 15
            local z = part.Position.Z + math.sin(angle) * 15
            Root.CFrame = CFrame.new(x, part.Position.Y + 8, z)
            Root.Velocity, Root.RotVelocity = NewVector(), NewVector()
            wait()

            if Stop then
                break
            end
        end
    end)

    return {
        Stop = function()
            Stop = true
        end,
    }
end

local function Focus(part)
    Workspace.CurrentCamera.CameraType = 'Scriptable'
    Workspace.CurrentCamera.CFrame = NewCFrame(
        Workspace.CurrentCamera.CFrame.p,
        part.Position
    )
    task.wait()
    Workspace.CurrentCamera.CameraType = 'Custom'
end

local function Hold(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
end

local function Release(key)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function Press(key, duration)
    Hold(key)
    if duration then
        task.wait(duration)
    else
        task.wait()
    end
    Release(key)
end

-- // Math Functions
local function DistanceXZ(firstPos, secondPos)
    local XZVector = NewVector(firstPos.X, 0, firstPos.Z)
        - NewVector(secondPos.X, 0, secondPos.Z)
    return XZVector.Magnitude
end

local function DistanceXYZ(firstPos, secondPos)
    local XYZVector = (firstPos - secondPos)
    return XYZVector.Magnitude
end

-- // Raycast Functions
local function Raycast(start, dir, ignChar)
    if ignChar then
        RaycastIgnored[#RaycastIgnored + 1] = ignChar
    end
    RaycastParams.FilterDescendantsInstances = RaycastIgnored

    return Workspace:Raycast(start, dir, RaycastParams)
end

local function GetDoor(tried)
    local Tried = tried or {}
    local Nearest = nil
    local Distance = math.huge

    for index, value in next, CollectionService:GetTagged('Door') do
        if value.Name:sub(-4, -1) == 'Door' then
            local DoorMain = value:FindFirstChild('Touch')

            if DoorMain and DoorMain:IsA('BasePart') then
                for distance = 5, 100, 5 do
                    local ForwardPosition = DoorMain.Position
                        + DoorMain.CFrame.LookVector * (distance + 3)
                    local BackwardPosition = DoorMain.Position
                        + DoorMain.CFrame.LookVector * -(distance + 3)

                    if
                        not Raycast(
                            ForwardPosition + Vector3.new(0, 4, 0),
                            NewVector(0, YLevel, 0)
                        )
                    then
                        table.insert(
                            DoorPositions,
                            { Instance = value, Position = ForwardPosition }
                        )
                        break
                    elseif
                        not Raycast(
                            BackwardPosition + Vector3.new(0, 4, 0),
                            NewVector(0, YLevel, 0)
                        )
                    then
                        table.insert(
                            DoorPositions,
                            { Instance = value, Position = BackwardPosition }
                        )
                        break
                    end
                end
            end
        end
    end

    for _, v in next, DoorPositions do
        if not table.find(Tried, v) then
            local Dist = DistanceXZ(v.Position, Root.Position)
            if Dist < Distance then
                Distance = Dist
                Nearest = v
            end
        end
    end

    table.insert(Tried, Nearest)
    return {
        Position = Nearest.Position,
        Instance = Nearest.Instance,
        Tried = Tried,
    }
end

local function OnChildAdded(child)
    if table.find(RaycastIgnorable, child.Name) then
        RaycastIgnored[#RaycastIgnored + 1] = child
    end
end

local function OnChildRemoved(child)
    if table.find(RaycastIgnorable, child.Name) then
        table.remove(RaycastIgnored, table.find(RaycastIgnored, child))
    end
end

Workspace.ChildAdded:Connect(OnChildAdded)
Workspace.ChildRemoved:Connect(OnChildRemoved)

for i, v in pairs(Workspace:GetChildren()) do
    OnChildAdded(v)
end

for _, v in pairs(CollectionService:GetTagged('Tree')) do
    RaycastIgnored[#RaycastIgnored + 1] = v
end

for _, v in pairs(CollectionService:GetTagged('NoClipAllowed')) do
    RaycastIgnored[#RaycastIgnored + 1] = v
end

-- // Teleport Functions
local function LagCheck(part, distance)
    local ShouldStop = false
    local OldPosition = part.Position
    local Signal = part
        :GetPropertyChangedSignal('CFrame')
        :Connect(LPH_NO_VIRTUALIZE(function()
            if (part.Position - OldPosition).Magnitude > distance + 5 then
                LaggedBack = true
                task.delay(0.2, function()
                    LaggedBack = false
                end)
            end
        end))
    task.spawn(function()
        while part and ShouldStop == false do
            OldPosition = part.Position
            task.wait()
        end
    end)
    return {
        Stop = function()
            ShouldStop = true
            Signal:Disconnect()
        end,
    }
end

local function Middle()
    repeat
        if (Root.Position - NewVector(40, -44, 22)).Magnitude < 5 then
            break
        end
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
        if (Root.Position - NewVector(40, -44, 22)).Magnitude < 5 then
            break
        end
        Character:PivotTo(NewCFrame(60, -44, 22))
        if (Root.Position - NewVector(40, -44, 22)).Magnitude < 5 then
            break
        end
        task.wait()
        if (Root.Position - NewVector(40, -44, 22)).Magnitude < 5 then
            break
        end
    until (Root.Position - NewVector(40, -44, 22)).Magnitude < 5
    task.wait()
    Character:PivotTo(NewCFrame(40, 20, 22))
    task.wait()
    Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    task.wait(0.5)
    EnterVehicle()
end

local function CloseToBadBuilding(position)
    return DistanceXZ(NewVector(220, 20, 270), Root.Position) < 100
end

local function FindDoor(forced, tried)
    if not forced and (Arrested() or Halt) then
        return
    end

    local Nearest = GetDoor(tried)
    if not Nearest or not Nearest.Position then
        warn("No valid door found.")
        return
    end

    local Path = PathfindingService:CreatePath({
        WaypointSpacing = ViseHub.AutoArrest.PlayerSpeed / 3,
    })
    Path:ComputeAsync(Root.Position, Nearest.Position)

    if Path.Status == Enum.PathStatus.Success then
        local Waypoints = Path:GetWaypoints()

        for _, waypoint in ipairs(Waypoints) do
            local targetPos = waypoint.Position + Vector3.new(0, 2.5, 0)
            Root.CFrame = CFrame.new(targetPos)

            if CloseToBadBuilding(Root.Position) then
                Root.CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 200, 0))
            end

            if Raycast(Root.Position + Vector3.new(0, 4, 0), Vector3.new(0, YLevel, 0)) == nil then
                task.wait(1)
                return
            end

            task.wait()
        end
    else
        warn("Pathfinding failed. Resetting.")
        local Vehicle = GetVehicleModel()
        if Vehicle then
            ExitCar()
        end

        if Humanoid then
            Humanoid.Health = 0
        end

        return
    end

    Nearest.Tried = true
    FindDoor(forced, Nearest.Tried)
end

--[[local function Pathfind(cframe, hardcode)
    if Arrested() or Halt then
        -- return error()
    end

    local Path = nil

    if hardcode then
        Path = PathfindingService:CreatePath({ WaypointSpacing = 0.00001 })
    else
        Path = PathfindingService:CreatePath({
            WaypointSpacing = ViseHub.AutoArrest.PlayerSpeed / 2.5,
        })
    end

    Path:ComputeAsync(Root.Position, cframe.Position)

    if Path.Status == Enum.PathStatus.Success then
        local Waypoints = Path:GetWaypoints()

        for _, v in pairs(Waypoints) do
            if GetVehicleModel() then
                ExitCar()
            end
            Root.CFrame = NewCFrame(v.Position + NewVector(0, 5, 0))
            task.wait()
        end
    end

    Character:PivotTo(cframe)
end--]]

local function Pathfind(TargetCFrame, Hardcode)
    if Arrested() or Halt then
        return
    end

    local Path
    if Hardcode then
        Path = PathfindingService:CreatePath({ WaypointSpacing = 0.00001 })
    else
        Path = PathfindingService:CreatePath({
            WaypointSpacing = ViseHub.AutoArrest.PlayerSpeed / 2.5,
        })
    end

    Path:ComputeAsync(Root.Position, TargetCFrame.Position)

    if Path.Status == Enum.PathStatus.Success then
        local Waypoints = Path:GetWaypoints()

        for _, Waypoint in pairs(Waypoints) do
            if GetVehicleModel() then
                ExitCar()
            end

            local TargetPosition = Waypoint.Position + Vector3.new(0, 5, 0)
            local Distance = (Root.Position - TargetPosition).Magnitude
            local TweenTime = Distance / 148

            local TweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear)
            local Goal = { CFrame = CFrame.new(TargetPosition) }

            local Tween = TweenService:Create(Root, TweenInfo, Goal)
            Tween:Play()
            Tween.Completed:Wait()
        end
    end

    Character:PivotTo(TargetCFrame)
end

function GoToGround(offset)
    if Root.Position.Y > YLevel then
        Character:PivotTo(NewCFrame(Root.Position.x, YLevel, Root.Position.z))
    end

    wait()

    local Result = Raycast(
        Root.Position + Vector3.new(0, 4, 0),
        NewVector(0, -999, 0)
    )
    task.wait()
    if Result then
        if not GetVehicleModel() then
            Character.Humanoid.Sit = true
        end
        if offset then
            Character:PivotTo(
                NewCFrame(
                    Root.Position.x,
                    Result.Position.y + offset,
                    Root.Position.z
                )
            )
        else
            Character:PivotTo(
                NewCFrame(
                    Root.Position.x,
                    Result.Position.y + 5,
                    Root.Position.z
                )
            )
        end
        task.wait()
        if not GetVehicleModel() then
            Character.Humanoid.Sit = false
        end
    end
end

function ExitCar()
    while GetVehicleModel() do
        Press('Space')
        task.wait()
    end
    task.wait()
end

local LagbackCount = 0
local function Slide(cframe, type, offset, forced)
    if not forced and (Arrested() or Halt) then

    end

    Character:FindFirstChild('Humanoid'):SetStateEnabled('FallingDown', false)

    local LagbackCheck = nil

    if type == 'Car' then
        LagbackCheck = LagCheck(
            GetVehicleModel().PrimaryPart,
            ViseHub.AutoArrest.CarSpeed / 3
        )
    elseif type == 'Car2' then
        LagbackCheck = { Stop = function() end }
    else
        LagbackCheck = LagCheck(Root, ViseHub.AutoArrest.PlayerSpeed / 3)
    end

    local Success = true
    local StartPos = Root.CFrame
    local TargetPosition = cframe.Position
    local CurrentPosition = Root.Position
    local Distance = TargetPosition - CurrentPosition

    if offset then
        TargetPosition = NewVector(cframe.Position.X, offset, cframe.Position.Z)
        Distance = TargetPosition - CurrentPosition
    end

    if (TargetPosition - StartPos.p).Magnitude > 3 then
        local Index = 0
        if not type or type == 'Player' then
            local BV = Root:FindFirstChild('BodyVelocity')
                or Instance.new('BodyVelocity', Root)
            BV.Velocity = NewVector(0, 0, 0)
            BV.MaxForce = NewVector(9e9, 9e9, 9e9)
            local Speed = ViseHub.AutoArrest.PlayerSpeed
            local Started = false

            while Index <= Distance.Magnitude do
                if offset then
                    TargetPosition = NewVector(
                        cframe.Position.X,
                        offset,
                        cframe.Position.Z
                    )
                    Distance = TargetPosition - CurrentPosition
                else
                    TargetPosition = cframe.Position
                    Distance = TargetPosition - CurrentPosition
                end

                if LaggedBack and Started then
                    LagbackCount = LagbackCount + 1
                    task.wait(0.05)
                    if LagbackCount == 5 then
                        Humanoid.Health = 0
                        LagbackCheck:Stop()
                        -- return error('Slide() - LagbackCount exceeded.')
                    end
                    warn("resuming to 'player' tp")
                    return Slide(cframe, type, offset, forced)
                elseif not Humanoid or Humanoid.Health == 0 then
                    LagbackCheck:Stop()
                    -- return error('Slide() - Humanoid is missing or dead.')
                end

                Character:PivotTo(StartPos + Distance.Unit * Index)
                wait()
                Index = Index + Speed / 3
                Started = true
            end
            BV:Destroy()
        elseif type == 'Car' or type == 'Car2' then
            local Vehicle = GetVehicleModel()
            local BV = Vehicle.PrimaryPart:FindFirstChild('BodyVelocity')
                or Instance.new('BodyVelocity', Vehicle.PrimaryPart)
            BV.Velocity = NewVector(0, 0, 0)
            BV.MaxForce = NewVector(9e9, 9e9, 9e9)
            local Speed = ViseHub.AutoArrest.CarSpeed
            local Started = false

            while Index <= Distance.Magnitude and Vehicle do
                if offset then
                    TargetPosition = NewVector(
                        cframe.Position.X,
                        offset,
                        cframe.Position.Z
                    )
                    Distance = TargetPosition - CurrentPosition
                else
                    TargetPosition = cframe.Position
                    Distance = TargetPosition - CurrentPosition
                end

                if LaggedBack and Started then
                    LagbackCount = LagbackCount + 1
                    task.wait(0.1)
                    if LagbackCount == 8 then
                        Humanoid.Health = 0
                        LagbackCheck:Stop()
                        -- return error('Slide() - LagbackCount exceeded.')
                    end
                    return Slide(cframe, type, offset, forced)
                elseif not Humanoid or Humanoid.Health == 0 then
                    LagbackCheck:Stop()
                    -- return error('Slide() - Humanoid is missing or dead.')
                end

                Character:PivotTo(StartPos + Distance.Unit * Index)
                wait()
                Index = Index + Speed / 3
                Started = true
            end
            BV:Destroy()
        end
    end

    wait()
    LagbackCount = 0
    Character:PivotTo(NewCFrame(cframe.Position))
    task.wait()
    LagbackCheck:Stop()
end

local function ChainSlide(pos, func)
    for i, v in pairs(pos) do
        if func then
            func()
        end
        Slide(v, 'Player')
    end
end

local function ChainPathfind(pos, func, hardcode)
    for i, v in pairs(pos) do
        if func then
            func()
        end
        Pathfind(v, hardcode)
    end
end

function Travel(cframe, type, offset, ylevel, forced)
    if not forced and (Arrested() or Halt) then
    end

    if
        Raycast(
            Root.Position + Vector3.new(0, 4, 0),
            NewVector(0, YLevel, 0),
            Building
        )
    then
        FindDoor()
        wait()
    end

    Character:PivotTo(NewCFrame(Root.Position.X, YLevel, Root.Position.Z))
    wait(0.1)
    Slide(cframe, type, YLevel)
    if not GetVehicleModel() then
        Character.Humanoid.Sit = true
    end

    if offset and offset > 0 then
        Character:PivotTo(NewCFrame(cframe.Position) * NewCFrame(0, offset, 0))
    elseif ylevel and ylevel > 0 then
        Character:PivotTo(
            NewCFrame(cframe.Position.X, ylevel, cframe.Position.Z)
        )
    else
        Character:PivotTo(NewCFrame(cframe.Position))
    end
    task.wait()
    if not GetVehicleModel() then
        Character.Humanoid.Sit = false
    end
end

--[[function CarTravel(cframe, offset, ylevel)
    if Arrested() or Halt then
    end

    if
        Raycast(Root.Position + Vector3.new(0, 4, 0), NewVector(0, YLevel, 0))
    then
        FindDoor()
        wait()
    end

    if not GetVehicleModel() then
        if DistanceXZ(Root.Position, cframe.Position) < 150 then
            if offset then
                return Travel(cframe, 'Player', offset)
            else
                return Travel(cframe, 'Player')
            end
        end
        EnterVehicle()
    end

    if GetVehicleModel() then
        pcall(function()
            GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = 'Wicky IS PRO'
        end)
    end

    if GetVehicleModel() and table.find(OwnedCars, GetVehicleModel().Name) then
        if offset and offset > 0 then
            Travel(cframe, 'Car', offset)
        elseif ylevel and ylevel > 0 then
            Travel(cframe, 'Car', false, YLevel)
        else
            Travel(cframe, 'Car')
        end
    end
end--]]

function CarTravel(cframe, offset, ylevel)
    if Arrested() or Halt then
        return
    end

    -- Check if the ground is invalid and fallback to FindDoor
    if Raycast(Root.Position + Vector3.new(0, 4, 0), Vector3.new(0, YLevel, 0)) then
        FindDoor()
        task.wait()
        return
    end

    local vehicle = GetVehicleModel()

    if not vehicle then
        if DistanceXZ(Root.Position, cframe.Position) < 150 then
            return Travel(cframe, 'Player', offset)
        end
        EnterVehicle()
        vehicle = GetVehicleModel()
    end

    -- If we have a vehicle, customize and drive
    if vehicle then
        pcall(function()
            local plate = vehicle:FindFirstChild("plate", true)
            if plate and plate:FindFirstChildWhichIsA("SurfaceGui") then
                local gui = plate:FindFirstChildWhichIsA("SurfaceGui")
                if gui and gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("TextLabel") then
                    gui.Frame.TextLabel.Text = "NG"
                end
            end
        end)

        if table.find(OwnedCars, vehicle.Name) then
            if offset and offset > 0 then
                return Travel(cframe, 'Car', offset)
            elseif ylevel and ylevel > 0 then
                return Travel(cframe, 'Car', false, ylevel)
            else
                return Travel(cframe, 'Car')
            end
        end
    end
end


function Teleport(cframe)
    if Arrested() or Halt then
        -- return error()
    end

    if
        Raycast(Root.Position + Vector3.new(0, 4, 0), NewVector(0, YLevel, 0))
    then
        FindDoor()
        wait()
    end

    if not GetVehicleModel() then
        EnterVehicle()
    end

    if GetVehicleModel() and table.find(OwnedCars, GetVehicleModel().Name) then
        repeat
            if GetVehicleModel() then
                repeat
                    GetVehicleModel().PrimaryPart.CFrame = cframe
                    task.wait()
                until not GetVehicleModel()
            else
                EnterVehicle()
            end
            task.wait(0.05)
        until DistanceXZ(Root.Position, cframe.Position) < 35
            or Arrested()
            or Halt
    end
end

function SpawnCar(forced)
    GoToGround()
    task.wait(0.1)

    local args = {
        [1] = 'Chassis',
        [2] = 'Camaro',
    }

    ReplicatedStorage
        :WaitForChild('GarageSpawnVehicle')
        :FireServer(unpack(args))

    local Timeout = os.time()

    repeat
        task.wait()
        if not forced and (Arrested() or Halt) then
            break
        end
    until (GetVehicleModel() and GetVehicleModel().Name == 'Camaro')
        or string.find(
            PlayerGui.NotificationGui.ContainerNotification.Message.Text,
            'Someone'
        )
        or string.find(
            PlayerGui.NotificationGui.ContainerNotification.Message.Text,
            'team'
        )
        or string.find(
            PlayerGui.NotificationGui.ContainerNotification.Message.Text,
            'Wait'
        )
        or string.find(
            PlayerGui.NotificationGui.ContainerNotification.Message.Text,
            'spawn'
        )
        or string.find(
            PlayerGui.NotificationGui.ContainerNotification.Message.Text,
            'something'
        )
        or os.time() - Timeout > 10

    if GetVehicleModel() then
        pcall(function()
            GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = 'ViseHub'
        end)
    end
end

function EnterVehicle(forced)
    if not forced and (Arrested() or Halt) then
    end

    if GetVehicleModel() and table.find(OwnedCars, GetVehicleModel().Name) then
        pcall(function()
            GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text = 'ViseHub'
        end)
        return true
    else
        ExitCar()
    end

    if not GetVehicleModel() then
        SpawnCar()
    end

    task.wait(0.5)

    if not GetVehicleModel() then
        local SortedCars = Vehicles:GetChildren()
        table.sort(SortedCars, function(v, v2)
            local v3 = v.PrimaryPart or v:FindFirstChildWhichIsA('Part')
            local v4 = v2.PrimaryPart or v2:FindFirstChildWhichIsA('Part')
            if v3 ~= nil and v4 ~= nil then
                return DistanceXZ(v3.Position, Root.Position)
                    < DistanceXZ(v4.Position, Root.Position)
            end
        end)

        for _, v in pairs(SortedCars) do
            if
                v
                and v.PrimaryPart ~= nil
                and v.Seat.Player.Value == false
                and table.find(OwnedCars, v.Name)
                and not Raycast(
                    v.PrimaryPart.Position + Vector3.new(0, 4, 0),
                    NewVector(0, YLevel, 0)
                )
            then
                local EnterAttempts = 1
                repeat
                    if v and v.PrimaryPart and v:FindFirstChild('Seat') then
                        if
                            DistanceXZ(Root.Position, v.PrimaryPart.Position)
                            > 20
                        then
                            Travel(v.Seat, 'Player', 5)
                            task.wait(0.5)
                        end
                        if v and v.PrimaryPart and v.Seat then
                            Character:PivotTo(
                                v.Seat.CFrame * NewCFrame(-3, 1, 0)
                            )
                            Root.Velocity = NewVector(0, 0, 0)
                            Focus(v.Seat)
                            Hold('E')
                            task.wait()
                            Release('E')
                        end
                    end
                    EnterAttempts = EnterAttempts + 1
                    task.wait(0.3)
                until GetVehicleModel()
                    or string.find(
                        PlayerGui.NotificationGui.ContainerNotification.Message.Text,
                        'You'
                    )
                    or string.find(
                        PlayerGui.NotificationGui.ContainerNotification.Message.Text,
                        "can't"
                    )
                    or EnterAttempts == 10
                    or v == nil
                    or v.PrimaryPart == nil
                    or v:FindFirstChild('Seat') == nil
                    or v.Seat.Player.Value == true
                    or (forced and (Arrested() or Halt))
                task.wait(0.1)
                if GetVehicleModel() then
                    pcall(function()
                        GetVehicleModel().plate.SurfaceGui.Frame.TextLabel.Text =
                            'WICKY PRO'
                    end)
                    return true
                end
            end
            task.wait()
        end
    end

    return EnterVehicle(forced)
end

-- // Misc Functions
local function SetChar(plrChar)
    Character, Root, Humanoid =
        plrChar,
        plrChar:WaitForChild('HumanoidRootPart'),
        plrChar:WaitForChild('Humanoid')
    if
        Player.Character:FindFirstChild('Humanoid')
        and Player.Character.Humanoid:FindFirstChild('HumanoidUnloadExists')
    then
        Player.Character
            :FindFirstChild('Humanoid').HumanoidUnloadExists
            :Destroy()
    end
    if
        Player.Character:FindFirstChild('Humanoid')
        and Player.Character.Humanoid:FindFirstChild(
            'HumanoidUnloadNetworkOwnerId'
        )
    then
        Player.Character
            :FindFirstChild('Humanoid').HumanoidUnloadNetworkOwnerId
            :Destroy()
    end
    if
        Player.Character:FindFirstChild('Humanoid')
        and Player.Character.Humanoid:FindFirstChild(
            'HumanoidUnloadServerPosition'
        )
    then
        Player.Character
            :FindFirstChild('Humanoid').HumanoidUnloadServerPosition
            :Destroy()
    end
    if
        Player.PlayerScripts:FindFirstChild('HumanoidUnload')
        and Player.PlayerScripts.HumanoidUnload:FindFirstChild('HumanoidUnload')
    then
        Player.PlayerScripts.HumanoidUnload.HumanoidUnload.Disabled = true
    end
    RaycastIgnored[#RaycastIgnored + 1] = Character
    Humanoid.Died:Connect(function()
        Character, Root, Humanoid = nil, nil, nil
    end)
end

if Player.Character and Player.Character:FindFirstChild('Humanoid') then
    SetChar(Player.Character)
end

Player.CharacterAdded:Connect(SetChar, Player.Character)

-- // Player Functions
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ClosestPlayerDistance = math.huge

    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HRP = Character:FindFirstChild('HumanoidRootPart')
    if not HRP then
        return nil
    end

    for _, Child in pairs(Players:GetPlayers()) do
        if
            Child ~= Player
            and not Child:FindFirstChild("Folder"):FindFirstChild("Cuffed")
            and Child.Team == Teams:FindFirstChild('Criminal')
            and Player.Character:FindFirstChild('Humanoid')
            and Player.Character:FindFirstChild('Humanoid').Health > 0
        then
            local TargetCharacter = Child.Character
            local TargetHRP = TargetCharacter
                and TargetCharacter:FindFirstChild('HumanoidRootPart')

            if TargetHRP then
                local Distance = (HRP.Position - TargetHRP.Position).Magnitude
                if Distance < ClosestPlayerDistance then
                    ClosestPlayer = Child
                    ClosestPlayerDistance = Distance
                end
            end
        end
    end

    return ClosestPlayer
end

function Click(a)
    VirtualInputManager:SendMouseButtonEvent(
        a.AbsolutePosition.X + a.AbsoluteSize.X / 2,
        a.AbsolutePosition.Y + 50,
        0,
        true,
        a,
        1
    )
    VirtualInputManager:SendMouseButtonEvent(
        a.AbsolutePosition.X + a.AbsoluteSize.X / 2,
        a.AbsolutePosition.Y + 50,
        0,
        false,
        a,
        1
    )
end

function SwitchTeam(team)
    Halt = true

    repeat
        if not PlayerGui:FindFirstChild('TeamSelectGui') then
            if firesignal then
                firesignal(
                    PlayerGui.AppUI.Buttons.Sidebar.TeamSwitch.TeamSwitch.MouseButton1Down
                )
                repeat
                    task.wait()
                until PlayerGui.ConfirmationGui.Enabled == true
                firesignal(
                    PlayerGui.ConfirmationGui.Confirmation.Background.ContainerButtons.ContainerYes.Button.MouseButton1Down
                )
            else
                Click(PlayerGui.AppUI.Buttons.Sidebar.TeamSwitch.TeamSwitch)
                repeat
                    task.wait()
                until PlayerGui.ConfirmationGui.Enabled == true
                Click(
                    PlayerGui.ConfirmationGui.Confirmation.Background.ContainerButtons.ContainerYes.Button
                )
            end
        end
    until PlayerGui:FindFirstChild('TeamSelectGui')
    task.wait()
    if team == 'Prisoner' then
        if firesignal then
            firesignal(
                PlayerGui.TeamSelectGui.TeamSelect.Frame.MiddleContainer.TeamsContainer.ImagesContainer.CriminalTeam.Activated
            )
        else
            Click(
                PlayerGui.TeamSelectGui.TeamSelect.Frame.MiddleContainer.TeamsContainer.ImagesContainer.CriminalTeam
            )
        end
    elseif team == 'Police' then
        if firesignal then
            firesignal(
                PlayerGui.TeamSelectGui.TeamSelect.Frame.MiddleContainer.TeamsContainer.ImagesContainer.PoliceTeam.Activated
            )
        else
            Click(
                PlayerGui.TeamSelectGui.TeamSelect.Frame.MiddleContainer.TeamsContainer.ImagesContainer.PoliceTeam
            )
        end
    end
    repeat
        task.wait()
    until Character
        and Humanoid
        and Humanoid.Health > 0
        and not PlayerGui:FindFirstChild('TeamSelectGui')
    task.wait(1)
    Halt = false
end

-- return CarTravel, Pathfind, Teleport

-- // Fake Gun Setup
local FakeGun = {
    Local = true,
    IgnoreList = {},
    Config = {},
    Maid = require(ReplicatedStorage.Std.Maid).new(),
    __ClassName = 'Pistol',
}

-- // Bullet Emitter Setup
local SetupBulletEmitter = require(ReplicatedStorage.Game.Item.Gun).SetupBulletEmitter
SetupBulletEmitter(FakeGun)

--[[task.spawn(function()
   while true do
        for _, Vehicle in next, Vehicles:GetDescendants() do
            if Vehicle:IsA("Model") and Vehicle.PrimaryPart then
                FakeGun.BulletEmitter.OnHitSurface:Fire(
                    Vehicle.PrimaryPart,
                    Vehicle.PrimaryPart.Position,
                    Vehicle.PrimaryPart.Position
                )
            end
        end

        task.wait(0.25)
    end
end)--]]

local function EquipHandcuffs()
    local Folder = Player:FindFirstChild('Folder')
    if Folder and Folder:FindFirstChild('Handcuffs') then
        Folder.Handcuffs.InventoryEquipRemote:FireServer(true)
    end
end

local function UnequipHandcuffs()
	return require(ReplicatedStorage.Inventory.InventoryItemSystem).unequipAll()
end

function TeleportTwo(cframe)
    game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
    repeat
        task.wait()
    until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0
    local Timeout = os.time()
    repeat
        game:GetService("Players").LocalPlayer.Character:PivotTo(CFrame.new(cframe.Position))
        task.wait()
    until os.time() - Timeout > 1
end

local ClosestPlayer = nil

task.spawn(function()
    while true do
        ClosestPlayer = GetClosestPlayer()

        if ClosestPlayer then
            local CriminalCharacter = ClosestPlayer.Character
            local CriminalRootPart = CriminalCharacter and CriminalCharacter:FindFirstChild("HumanoidRootPart")
            local CriminalInventory = ClosestPlayer:FindFirstChild("Folder")

            if CriminalCharacter and CriminalRootPart and CriminalInventory and Root then
                local RayResult = Raycast(
                    CriminalRootPart.Position,
                    Vector3.new(0, 100, 0),
                    CriminalCharacter
                )
                if RayResult and RayResult.Instance then
                    task.wait()
                    continue
                end

                local Distance = (CriminalRootPart.Position - Root.Position).Magnitude

                if Distance >= 100 then
                    repeat
                        TeleportTwo(CFrame.new(CriminalRootPart.Position)) -- > CarTravel
                        task.wait()
                        Distance = (CriminalRootPart.Position - Root.Position).Magnitude
                    until Distance < 100 or not CriminalRootPart or not Root
                end

                if CriminalRootPart and Root then
                    task.wait(0.05)
                    Pathfind(CFrame.new(CriminalRootPart.Position))
                    task.wait()
                    EquipHandcuffs()
                    task.wait(0.01)
                    network:FireServer(ArrestKey, ClosestPlayer.Name)
                    task.wait()
                    UnequipHandcuffs()

                    ClosestPlayer = GetClosestPlayer()
                end
            end
        end

        for _, Vehicle in next, Vehicles:GetDescendants() do
            if Vehicle:IsA("Model") and Vehicle.PrimaryPart and Vehicle:FindFirstChild("Seat") then
                local Seat = Vehicle.Seat   
                local SeatPlayerName = Seat:FindFirstChild("PlayerName")

                if SeatPlayerName and tostring(SeatPlayerName.Value) == ClosestPlayer.Name then
                    FakeGun.BulletEmitter.OnHitSurface:Fire(
                        Vehicle.PrimaryPart,
                        Vehicle.PrimaryPart.Position,
                        Vehicle.PrimaryPart.Position
                    )
                end
            end
        end

        task.wait()
    end
end)