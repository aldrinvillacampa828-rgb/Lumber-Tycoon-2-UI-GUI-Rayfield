-- Aldrin UI GUI V1 (Rayfield Interface Suite)
-- Built from provided Ancestor logic & GUISettings structure

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Executor = (identifyexecutor and identifyexecutor()) or "Unknown"
getgenv().Ancestor_Loaded = false

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local UserInputService = UIS
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")
local PerformanceStats = StatsService:FindFirstChild("PerformanceStats")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Safe Maid fallback if remote Maid isn't reachable
local Maid = {
    Timer = {
        Wait = function(_, seconds)
            return task.wait(seconds)
        end
    },
    Threads = {
        Create = function(_, fn)
            return task.spawn(fn)
        end
    }
}

pcall(function()
    local remoteMaid = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/KhayneGleave/Ancestor/main/Maid.txt"))()
    if type(remoteMaid) == "table" and remoteMaid.Threads and remoteMaid.Timer then
        Maid = remoteMaid
    end
end)

local Connections = {}

local Ancestor = {
    SelectedTreeType             = "Generic",
    BringTreeAmount              = 1,
    AutobuyAmount                = 1,
    AutobuySelectedItem          = "Basic Hatchet",
    BringTreeSelectedPosition    = "Current Position",
    RotatingObject               = false,
    Sprinting                    = false,
    ModerationType               = "Vehicle",
    ModerationAction             = "Kill",
    PlayerToModerate             = nil,
    InventoryDuplicationAmount   = 1,
    PropertyToDuplicate          = 1,
    PlayerToDuplicatePropertyTo  = Players:GetPlayers()[1],
    ModWoodSawmill               = nil,
    AutofarmTrees                = false,
    CharacterGodMode             = "FirstTimeExecutionProtection",
    IsClientFlying               = false,
    TreeToDismember              = false,
    SelectedVehicleColourToSpawn = "Dark red",
    CurrentlySavingOrLoading     = nil,
    DonatingProperty             = false,
    SpawnItemsAmount             = 1,
    SpawnItemName                = "BasicHatchet",
    ModdingWood                  = false,
    Autobuying                   = false,
    BringingTree                 = false,
    DupingInventory              = false,
    SelectedBlueprint            = nil,
    SelectedPlank                = nil,
    ModWoodTree                  = nil,
    VehicleSpawnerSpot           = nil
}

local GUISettings = {
    WalkSpeed                          = 16,
    JumpPower                          = 50,
    HipHeight                          = 0,
    SprintSpeed                        = 20,
    FOV                                = 70,
    InfiniteJump                       = false,
    SelectedDropType                   = "Both",
    Light                              = false,
    SprintKey                          = "LeftShift",
    NoclipKey                          = "LeftControl",
    KeyTP                              = "G",
    Noclip                             = false,
    FastCheckout                       = false,
    FixCashierRange                    = false,
    HardDragger                        = false,
    AxeRangeActive                     = false,
    AxeSwingActive                     = false,
    FlyKey                             = "F",
    WaterWalk                          = false,
    WaterFloat                         = true,
    FlySprintSpeed                     = 10,
    AlwaysDay                          = false,
    AlwaysNight                        = false,
    NoFog                              = false,
    Spook                              = false,
    AxeSwing                           = 0,
    AxeRange                           = 0,
    FlySpeed                           = 200,
    CarSpeed                           = 1,
    CarPitch                           = 1,
    AntiAFK                            = (Executor ~= "Krnl"),
    TreesEnabled                       = true,
    StopPlayersLoading                 = false,
    SignDuplicationAmount              = 1,
    TeleportBackAfterBringTree         = true,
    FastRotate                         = false,
    XRotate                            = 1,
    YRotate                            = 1,
    SelectedTreeTypeSize               = "Largest",
    ActivateVehicleModifications       = true,
    AutoSaveGUIConfiguration           = true,
    Brightness                         = 1,
    GlobalShadows                      = true,
    RejoinExecute                      = false,
    UnboxItems                         = false,
    FreeCamera                         = false,
    WaterGodMode                       = false,
    BetterGraphics                     = false,
    DropToolsAfterInventoryDuplication = false,
    InstantDropAxes                    = false,
    ClickDelete                        = false,
    SellPlankAfterMilling              = false,
    AutoStopOnPinkVehicle              = false,
    DeleteSpawnPadAfterVehicleSpawn    = false,
    AutoChopTrees                      = false,
    SitInAnyVehicle                    = false,
    ClickToSell                        = false,
    ForceWhitelist                     = false,
    CloseStores                        = false,
    TomahawkAxeFling                   = false,
    SelectedProperty                   = 1
}

-- Safe notice helper
local SendUserNotice = {
    Fire = function(_, title, content)
        Rayfield:Notify({
            Title = tostring(title or "Aldrin UI"),
            Content = tostring(content or ""),
            Duration = 4
        })
    end
}

local function Notify(title, msg)
    SendUserNotice:Fire(title, msg)
end

-- Safe game references
local PropertiesFolder = workspace:FindFirstChild("Properties")
local StoresFolder = workspace:FindFirstChild("Stores")
local PlayerModels = workspace:FindFirstChild("PlayerModels")
local LogModels = workspace:FindFirstChild("LogModels")
local AxeFolder = ReplicatedStorage:FindFirstChild("AxeClasses")
local ClientItemInfo = ReplicatedStorage:FindFirstChild("ClientItemInfo")

local function SafeGetEnv(scriptObj)
    if scriptObj and getsenv then
        local ok, env = pcall(getsenv, scriptObj)
        if ok then return env end
    end
    return nil
end

local NPCChattingClient = SafeGetEnv(PlayerGui:FindFirstChild("ChatGUI") and PlayerGui.ChatGUI:FindFirstChild("NPCChattingClient"))
local CharacterFloat = SafeGetEnv(PlayerGui:FindFirstChild("Scripts") and PlayerGui.Scripts:FindFirstChild("CharacterFloat"))
local PropertyPurchasingClient = SafeGetEnv(PlayerGui:FindFirstChild("PropertyPurchasingGUI") and PlayerGui.PropertyPurchasingGUI:FindFirstChild("PropertyPurchasingClient"))
local LoadSaveClient = SafeGetEnv(PlayerGui:FindFirstChild("LoadSaveGUI") and PlayerGui.LoadSaveGUI:FindFirstChild("LoadSaveClient"))
local UserInput = SafeGetEnv(PlayerGui:FindFirstChild("Scripts") and PlayerGui.Scripts:FindFirstChild("UserInput"))
local SettingsClient = SafeGetEnv(PlayerGui:FindFirstChild("SettingsGUI") and PlayerGui.SettingsGUI:FindFirstChild("SettingsClient"))

local InteractionPermission
pcall(function()
    InteractionPermission = require(ReplicatedStorage.Interaction.InteractionPermission)
end)

local RequestLoad = ReplicatedStorage:FindFirstChild("LoadSaveRequests") and ReplicatedStorage.LoadSaveRequests:FindFirstChild("RequestLoad")
local RequestSave = ReplicatedStorage:FindFirstChild("LoadSaveRequests") and ReplicatedStorage.LoadSaveRequests:FindFirstChild("RequestSave")
local GetMetaData = ReplicatedStorage:FindFirstChild("LoadSaveRequests") and ReplicatedStorage.LoadSaveRequests:FindFirstChild("GetMetaData")
local ClientMayLoad = ReplicatedStorage:FindFirstChild("LoadSaveRequests") and ReplicatedStorage.LoadSaveRequests:FindFirstChild("ClientMayLoad")
local ClientGetUserPermissions = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("ClientGetUserPermissions")
local ClientExpandedProperty = ReplicatedStorage:FindFirstChild("PropertyPurchasing") and ReplicatedStorage.PropertyPurchasing:FindFirstChild("ClientExpandedProperty")
local ClientPurchasedProperty = ReplicatedStorage:FindFirstChild("PropertyPurchasing") and ReplicatedStorage.PropertyPurchasing:FindFirstChild("ClientPurchasedProperty")
local ClientInteracted = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("ClientInteracted")
local ClientIsDragging = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("ClientIsDragging")
local RemoteProxy = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("RemoteProxy")
local PromptChat = ReplicatedStorage:FindFirstChild("NPCDialog") and ReplicatedStorage.NPCDialog:FindFirstChild("PromptChat")
local PlayerChatted = ReplicatedStorage:FindFirstChild("NPCDialog") and ReplicatedStorage.NPCDialog:FindFirstChild("PlayerChatted")
local SetChattingValue = ReplicatedStorage:FindFirstChild("NPCDialog") and ReplicatedStorage.NPCDialog:FindFirstChild("SetChattingValue")
local TestPing = ReplicatedStorage:FindFirstChild("TestPing")
local UpdateUserSettings = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("UpdateUserSettings")
local ClientPlacedStructure = ReplicatedStorage:FindFirstChild("PlaceStructure") and ReplicatedStorage.PlaceStructure:FindFirstChild("ClientPlacedStructure")
local SelectLoadPlot = ReplicatedStorage:FindFirstChild("PropertyPurchasing") and ReplicatedStorage.PropertyPurchasing:FindFirstChild("SelectLoadPlot")
local ClientPlacedBlueprint = ReplicatedStorage:FindFirstChild("PlaceStructure") and ReplicatedStorage.PlaceStructure:FindFirstChild("ClientPlacedBlueprint")
local DestroyStructure = ReplicatedStorage:FindFirstChild("Interaction") and ReplicatedStorage.Interaction:FindFirstChild("DestroyStructure")

local LoadPass
pcall(function()
    if LoadSaveClient and LoadSaveClient.saveSlot and getupvalue then
        LoadPass = getupvalue(LoadSaveClient.saveSlot, 12)
    end
end)

local TransientFunctionCache
pcall(function()
    local Util = ReplicatedStorage:WaitForChild("Util", 5)
    if Util and Util:FindFirstChild("TransientFunctionCache") then
        TransientFunctionCache = require(Util.TransientFunctionCache)
    end
end)

local VehicleColours = {
    "Dark red", "Sand red", "Sand yellow metalic", "Lemon metalic", "Gun metalic",
    "Earth orange", "Earth yellow", "Brick yellow", "Rust", "Really black",
    "Faded green", "Sand green", "Black metalic", "Dark grey metallic", "Dark grey",
    "Silver", "Medium stone grey", "Mid grey", "Hot pink"
}

local SlotNames = {
    Slot1 = "Slot 1",
    Slot2 = "Slot 2",
    Slot3 = "Slot 3",
    Slot4 = "Slot 4",
    Slot5 = "Slot 5",
    Slot6 = "Slot 6"
}

-- File & Config Helpers
local function HasFileAPI()
    return (typeof(isfile) == "function") and (typeof(readfile) == "function") and (typeof(writefile) == "function")
end

local DefaultSettings = table.clone and table.clone(GUISettings) or (function(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end)(GUISettings)

if HasFileAPI() then
    pcall(function()
        if not isfile("AldrinSlotNames.cfg") then
            local data = { [tostring(Player)] = SlotNames }
            writefile("AldrinSlotNames.cfg", HttpService:JSONEncode(data))
        end
        local decodedSlots = HttpService:JSONDecode(readfile("AldrinSlotNames.cfg"))
        if decodedSlots[tostring(Player)] then
            SlotNames = decodedSlots[tostring(Player)]
        else
            decodedSlots[tostring(Player)] = SlotNames
            writefile("AldrinSlotNames.cfg", HttpService:JSONEncode(decodedSlots))
        end

        if not isfile("AldrinV1Configuration.cfg") then
            writefile("AldrinV1Configuration.cfg", HttpService:JSONEncode(GUISettings))
        end
        local decodedCfg = HttpService:JSONDecode(readfile("AldrinV1Configuration.cfg"))
        if type(decodedCfg) == "table" then
            for k, v in pairs(decodedCfg) do
                GUISettings[k] = v
            end
        end
        for k, v in pairs(DefaultSettings) do
            if GUISettings[k] == nil then
                GUISettings[k] = v
            end
        end
    end)
end

function Ancestor:SaveConfigurationFile(silent)
    if not HasFileAPI() then
        if not silent then Notify("Config", "File functions are not supported by this executor.") end
        return
    end
    pcall(function()
        writefile("AldrinV1Configuration.cfg", HttpService:JSONEncode(GUISettings))
        if not silent then Notify("Config", "Saved Aldrin UI V1 configuration!") end
    end)
end

function Ancestor:DeleteConfigurationFile()
    GUISettings.AutoSaveGUIConfiguration = false
    if HasFileAPI() and typeof(delfile) == "function" then
        pcall(function()
            if isfile("AldrinV1Configuration.cfg") then
                delfile("AldrinV1Configuration.cfg")
            end
            Notify("Config", "Deleted configuration file.")
        end)
    else
        Notify("Config", "Config auto-save disabled.")
    end
end

function Ancestor:SaveSlotNames()
    if not HasFileAPI() then
        Notify("Slot Names", "File API unavailable; names updated in memory.")
        return
    end
    pcall(function()
        local oldData = isfile("AldrinSlotNames.cfg") and HttpService:JSONDecode(readfile("AldrinSlotNames.cfg")) or {}
        oldData[tostring(Player)] = SlotNames
        writefile("AldrinSlotNames.cfg", HttpService:JSONEncode(oldData))
        Notify("Slot Names", "Saved custom slot names.")
    end)
end

-- Cashier tracking
local CashiersAutobuy = {}
if PromptChat then
    pcall(function()
        PromptChat.OnClientEvent:Connect(function(_, Cashier)
            if Cashier and CashiersAutobuy[Cashier.Name] == nil then
                CashiersAutobuy[Cashier.Name] = Cashier.ID
            end
        end)
    end)
end

-- Loaded Trees cache
getgenv().LoadedTrees = {
    Update = function(self, Tree)
        if not Tree then return end
        self[#self + 1] = {
            Parent = Tree.Parent,
            Model  = Tree
        }
        if Tree.Parent then
            Tree.Parent = (GUISettings.TreesEnabled and Tree.Parent) or Lighting
        end
    end
}

-- Core Helper Functions
function Ancestor:GetConnection(Name, DisconnectConnection)
    for ConnName, Data in pairs(Connections) do
        if tostring(ConnName) == tostring(Name) then
            if DisconnectConnection then
                pcall(function()
                    if Data.Function and Data.Function.Disconnect then
                        Data.Function:Disconnect()
                    end
                end)
                Connections[Name] = nil
                return false
            end
            return Data.Function
        end
    end
    return false
end

function Ancestor:MergeTables(Tbl, NewTbl)
    for _, Value in pairs(Tbl) do
        NewTbl[#NewTbl + 1] = Value
    end
    return NewTbl
end

function Ancestor:GetAxes()
    local Axes = {}
    local char = Player.Character
    local bp = Player:FindFirstChild("Backpack")
    local Tools = self:MergeTables(bp and bp:GetChildren() or {}, char and char:GetChildren() or {})
    for _, Tool in ipairs(Tools) do
        if Tool:FindFirstChild("CuttingTool") then
            Axes[#Axes + 1] = Tool
        end
    end
    return Axes
end

function Ancestor:DoesAxeExist()
    return self:GetAxes()[1] ~= nil
end

function Ancestor:GetBestAxe()
    local Axes = self:GetAxes()
    local BestAxe, BestDamage = nil, 0
    for _, Axe in ipairs(Axes) do
        local toolNameObj = Axe:FindFirstChild("ToolName")
        if toolNameObj and AxeFolder and AxeFolder:FindFirstChild("AxeClass_" .. tostring(toolNameObj.Value)) then
            local nameVal = tostring(toolNameObj.Value)
            if self.SelectedTreeType == "LoneCave" and nameVal == "EndTimesAxe" then return Axe end
            if self.SelectedTreeType == "Volcano" and nameVal == "FireAxe" then return Axe end
            if self.SelectedTreeType == "CaveCrawler" and nameVal == "CaveAxe" then return Axe end
            if self.SelectedTreeType == "Frost" and nameVal == "IceAxe" then return Axe end
            if self.SelectedTreeType == "GoldSwampy" and nameVal == "AxeSwamp" then return Axe end

            local ok, stats = pcall(function()
                return require(AxeFolder["AxeClass_" .. nameVal]).new()
            end)
            if ok and stats then
                if stats.SpecialTrees and stats.SpecialTrees[self.SelectedTreeType] then
                    return Axe
                end
                local dmg = stats.Damage or 0
                if dmg > BestDamage then
                    BestDamage = dmg
                    BestAxe = Axe
                end
            end
        end
    end
    return BestAxe
end

function Ancestor:IsNetworkOwnerOfModel(Model)
    if Executor == "Krnl" or Executor == "Fluxus" or Executor == "Valyse" then
        if TestPing then
            for _ = 1, 4 do
                pcall(function() TestPing:InvokeServer() end)
            end
        end
        return true
    end
    if not Model then return false end
    for _, Child in ipairs(Model:GetChildren()) do
        if Child:IsA("BasePart") and typeof(isnetworkowner) == "function" then
            local ok, owned = pcall(isnetworkowner, Child)
            if ok and owned then
                return true
            end
        end
    end
    return false
end

function Ancestor:Teleport(CF)
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.PrimaryPart then
        local veh = hum.SeatPart.Parent
        local ori = veh.PrimaryPart.Orientation
        pcall(function()
            veh:PivotTo(CF * CFrame.Angles(math.rad(ori.X), math.rad(ori.Y), math.rad(ori.Z)))
        end)
        return
    end

    pcall(function()
        char:PivotTo(CF)
    end)
end

function Ancestor:SafeSuicide()
    local char = Player.Character
    if char and char:FindFirstChild("Head") then
        pcall(function() char.Head:Destroy() end)
    else
        Notify("Character", "Character or Head not available.")
    end
end

function Ancestor:BTools()
    local bp = Player:FindFirstChild("Backpack")
    if not bp or bp:FindFirstChildOfClass("HopperBin") then return end
    for i = 1, 4 do
        local hb = Instance.new("HopperBin")
        hb.BinType = i
        hb.Parent = bp
    end
    Notify("BTools", "Added HopperBins to Backpack.")
end

function Ancestor:ApplyLight()
    local char = Player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local existing = head:FindFirstChild("PointLight")
    if existing then existing:Destroy() end

    if GUISettings.Light then
        local ptLight = Instance.new("PointLight")
        ptLight.Range = 150
        ptLight.Brightness = 1.7
        ptLight.Parent = head
    end
end

function Ancestor:AntiAFK(State)
    if State and Executor == "Krnl" then
        Notify("Anti-AFK", "Executor does not support disabling Idled connection.")
        return
    end
    if getconnections and Player.Idled then
        local ok, conns = pcall(getconnections, Player.Idled)
        if ok and conns and conns[1] then
            pcall(function()
                if State then
                    conns[1]:Disable()
                else
                    conns[1]:Enable()
                end
            end)
        end
    end
end

function Ancestor:GodMode(BruteForce, State)
    if not BruteForce and self.CharacterGodMode == "FirstTimeExecutionProtection" then
        return
    end
    if (BruteForce and not State) or (not self.CharacterGodMode) then
        return self:SafeSuicide()
    end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local joint = hrp and hrp:FindFirstChild("RootJoint")
    if joint then
        local clone = joint:Clone()
        clone.Parent = hrp
        joint.Parent = nil
        clone:Destroy()
        joint.Parent = char
    end
end

function Ancestor:Rejoin()
    if GUISettings.RejoinExecute then
        if syn and syn.queue_on_teleport then
            pcall(function()
                syn.queue_on_teleport([[
                    repeat task.wait() until game:IsLoaded()
                    loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/KhayneGleave/Ancestor/main/AncestorV2'))()
                ]])
            end)
        else
            Notify("Rejoin", "Queue-on-teleport not available on this executor; rejoining normally.")
        end
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end

-- Client Fly
function Ancestor:Fly()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local Gyro = hrp:FindFirstChild("AldrinFlyGyro") or Instance.new("BodyGyro")
    Gyro.Name = "AldrinFlyGyro"
    Gyro.P = 9e4
    Gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    Gyro.CFrame = hrp.CFrame
    Gyro.Parent = hrp

    local Velocity = hrp:FindFirstChild("AldrinFlyVel") or Instance.new("BodyVelocity")
    Velocity.Name = "AldrinFlyVel"
    Velocity.Velocity = Vector3.zero
    Velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Velocity.Parent = hrp

    GUISettings.Noclip = true
    hum.PlatformStand = (hum.SeatPart == nil)

    task.spawn(function()
        while self.IsClientFlying and hrp.Parent do
            local moveDir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

            local speed = GUISettings.FlySpeed or 200
            if moveDir.Magnitude > 0 then
                Velocity.Velocity = moveDir.Unit * speed
            else
                Velocity.Velocity = Vector3.zero
            end
            Gyro.CFrame = Camera.CFrame
            task.wait()
        end

        if Gyro.Parent then Gyro:Destroy() end
        if Velocity.Parent then Velocity:Destroy() end
        if hum and hum.Parent then hum.PlatformStand = false end
        GUISettings.Noclip = false
    end)
end

-- Game Options Functions
function Ancestor:FastRotate(State)
    pcall(function()
        if UserInput and setconstant then
            if UserInput.getSteerFromKeys then
                setconstant(UserInput.getSteerFromKeys, 1, (State and GUISettings.FastRotate and GUISettings.XRotate) or 1)
            end
            if UserInput.getThrottleFromKeys then
                setconstant(UserInput.getThrottleFromKeys, 1, (State and GUISettings.FastRotate and GUISettings.YRotate) or 1)
            end
        end
    end)
end

function Ancestor:HardDragger(State)
    if not State then
        self:GetConnection("HardDragger", true)
        return
    end
    Connections.HardDragger = {
        Function = workspace.ChildAdded:Connect(function(Dragger)
            if tostring(Dragger) == "Dragger" then
                task.spawn(function()
                    local bp = Dragger:WaitForChild("BodyPosition", 5)
                    local bg = Dragger:WaitForChild("BodyGyro", 5)
                    while Dragger.Parent and bp and bg do
                        bp.P = 80000
                        bp.D = 1000
                        bp.MaxForce = Vector3.new(1, 1, 1) * 1000000
                        bg.MaxTorque = Vector3.new(1, 1, 1) * 200
                        bg.P = 1200
                        bg.D = 140
                        task.wait()
                    end
                end)
            end
        end)
    }
end

function Ancestor:BetterGraphics()
    if not Terrain then return end
    Lighting.GlobalShadows = GUISettings.GlobalShadows
    Lighting.GeographicLatitude = 0
    Lighting.ExposureCompensation = (GUISettings.BetterGraphics and 0.03) or 0
    Terrain.WaterColor = Color3.fromRGB(40, 40, 40)
    Terrain.WaterReflectance = 0.3
    Terrain.WaterWaveSize = 1
    Terrain.WaterWaveSpeed = 5

    for _, eff in ipairs(Lighting:GetChildren()) do
        if eff:IsA("PostEffect") and eff.Name:match("^Aldrin_") then
            eff:Destroy()
        end
    end

    if GUISettings.BetterGraphics then
        local blur = Instance.new("BlurEffect")
        blur.Name = "Aldrin_Blur"
        blur.Size = 3
        blur.Parent = Lighting

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "Aldrin_CC"
        cc.Brightness = 0.03
        cc.Contrast = 0.3
        cc.Saturation = 0.01
        cc.TintColor = Color3.fromRGB(244, 244, 244)
        cc.Parent = Lighting

        local sr = Instance.new("SunRaysEffect")
        sr.Name = "Aldrin_SunRays"
        sr.Intensity = 0.1
        sr.Spread = 1
        sr.Parent = Lighting
    end
end

-- Troll Options Functions
function Ancestor:UpdatePrivilege(TargetPlayer, Type, Value)
    if UpdateUserSettings and TargetPlayer then
        pcall(function()
            UpdateUserSettings:FireServer("UserPermission", tostring(TargetPlayer.UserId), Type, Value)
        end)
    end
end

function Ancestor:ModeratePlayer(Option)
    local target = self.PlayerToModerate
    if not target or not Players:FindFirstChild(tostring(target)) then
        Notify("Troll Options", "Select a valid target player first.")
        return
    end
    if tostring(target) == tostring(Player) then
        Notify("Troll Options", "Cannot target yourself.")
        return
    end
    if self.ModerationType == "Axe" and not self:DoesAxeExist() then
        Notify("Troll Options", "You need an axe for Axe mode.")
        return
    end
    if self.ModerationType == "Vehicle" then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.SeatPart then
            Notify("Troll Options", "You need to be seated in a vehicle for Vehicle mode.")
            return
        end
        self:UpdatePrivilege(target, "Sit", true)
    end

    Notify("Troll Options", string.format("Executing '%s' (%s) on %s...", tostring(Option), tostring(self.ModerationType), tostring(target)))
    pcall(function()
        local tChar = target.Character
        local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local myChar = Player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if tHRP and myHRP then
            if Option == "Bring" then
                tHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -4)
            elseif Option == "Fling" then
                tHRP.CFrame = myHRP.CFrame
                tHRP.Velocity = Vector3.new(600, 600, 600)
                tHRP.RotVelocity = Vector3.new(600, 600, 600)
            elseif Option == "Kill" or Option == "Hard Kill" then
                tHRP.CFrame = CFrame.new(-1675, 740, 1295)
            end
        end
    end)
end

function Ancestor:ForceWhitelist()
    if InteractionPermission and getgenv().UserCanInteract then
        InteractionPermission.UserCanInteract = GUISettings.ForceWhitelist and function()
            return true
        end or getgenv().UserCanInteract
    end
end

function Ancestor:FireAll(ItemTypeName)
    if not PlayerModels or not RemoteProxy then return end
    local count = 0
    for _, obj in ipairs(PlayerModels:GetChildren()) do
        local iName = obj:FindFirstChild("ItemName")
        if iName and tostring(iName.Value) == ItemTypeName then
            local ev = obj:FindFirstChildOfClass("BindableEvent")
            if ev then
                pcall(function()
                    RemoteProxy:FireServer(ev)
                    count += 1
                end)
            end
        end
    end
    Notify("Server Troll", string.format("Triggered %d '%s' object(s).", count, tostring(ItemTypeName)))
end

-- Property Options Functions
function Ancestor:GetLoadedSlot()
    local valObj = Player:FindFirstChild("CurrentSaveSlot")
    return valObj and valObj.Value or -1
end

function Ancestor:GetPlayersBase(Target)
    Target = Target or Player
    if not PropertiesFolder then return nil end
    for _, prop in ipairs(PropertiesFolder:GetChildren()) do
        local owner = prop:FindFirstChild("Owner")
        if owner and tostring(owner.Value) == tostring(Target) then
            return prop
        end
    end
    return nil
end

function Ancestor:GetFreeLand()
    if not PropertiesFolder then return nil end
    local char = Player.Character
    local head = char and char:FindFirstChild("Head")
    local originPos = head and head.Position or Vector3.zero
    local best, bestDist = nil, 9e9
    for _, prop in ipairs(PropertiesFolder:GetChildren()) do
        local owner = prop:FindFirstChild("Owner")
        local sq = prop:FindFirstChild("OriginSquare")
        if owner and owner.Value == nil and sq then
            local d = (sq.Position - originPos).Magnitude
            if d < bestDist then
                bestDist = d
                best = prop
            end
        end
    end
    return best
end

function Ancestor:FreeLand()
    local prop = self:GetFreeLand()
    if not prop then
        Notify("Property", "No free land available nearby.")
        return
    end
    if ClientPurchasedProperty then
        local sq = prop:FindFirstChild("OriginSquare")
        pcall(function()
            ClientPurchasedProperty:FireServer(prop, sq and sq.Position or Vector3.zero)
        end)
        if sq then
            self:Teleport(CFrame.new(sq.Position) + Vector3.new(0, 5, 0))
        end
        Notify("Property", "Attempted to claim free land.")
    end
end

function Ancestor:MaxLand()
    local prop = self:GetPlayersBase(Player)
    if not prop then
        self:FreeLand()
        task.wait(0.5)
        prop = self:GetPlayersBase(Player)
    end
    if not prop or not prop:FindFirstChild("OriginSquare") or not ClientExpandedProperty then
        Notify("Property", "Could not find owned property or OriginSquare.")
        return
    end
    local p = prop.OriginSquare.Position
    local offsets = {
        Vector3.new(40, 0, 0), Vector3.new(-40, 0, 0), Vector3.new(0, 0, 40), Vector3.new(0, 0, -40),
        Vector3.new(40, 0, 40), Vector3.new(40, 0, -40), Vector3.new(-40, 0, 40), Vector3.new(-40, 0, -40),
        Vector3.new(80, 0, 0), Vector3.new(-80, 0, 0), Vector3.new(0, 0, 80), Vector3.new(0, 0, -80),
        Vector3.new(80, 0, 80), Vector3.new(80, 0, -80), Vector3.new(-80, 0, 80), Vector3.new(-80, 0, -80),
        Vector3.new(40, 0, 80), Vector3.new(-40, 0, 80), Vector3.new(80, 0, 40), Vector3.new(80, 0, -40),
        Vector3.new(-80, 0, 40), Vector3.new(-80, 0, -40), Vector3.new(40, 0, -80), Vector3.new(-40, 0, -80)
    }
    for _, off in ipairs(offsets) do
        pcall(function()
            ClientExpandedProperty:FireServer(prop, CFrame.new(p + off))
        end)
    end
    self:Teleport(CFrame.new(p) + Vector3.new(0, 5, 0))
    Notify("Property", "Expanded property plots.")
end

function Ancestor:SaveSlot()
    if self.CurrentlySavingOrLoading then
        Notify("Slot Save", "Already saving or loading.")
        return
    end
    if RequestSave then
        self.CurrentlySavingOrLoading = true
        pcall(function() RequestSave:InvokeServer(self:GetLoadedSlot(), Player) end)
        self.CurrentlySavingOrLoading = false
        Notify("Slot Save", "Requested save for slot " .. tostring(self:GetLoadedSlot()))
    end
end

function Ancestor:LoadSlot(slotNum)
    if self.CurrentlySavingOrLoading then
        Notify("Slot Load", "Already saving or loading.")
        return
    end
    if RequestLoad then
        self.CurrentlySavingOrLoading = true
        pcall(function() RequestLoad:InvokeServer(slotNum, Player) end)
        self.CurrentlySavingOrLoading = false
        Notify("Slot Load", "Requested load for slot " .. tostring(slotNum))
    end
end

function Ancestor:UnloadSlot()
    if self.CurrentlySavingOrLoading then return end
    if RequestLoad then
        self.CurrentlySavingOrLoading = true
        pcall(function() RequestLoad:InvokeServer(math.huge, Player) end)
        self.CurrentlySavingOrLoading = false
        Notify("Slot Unload", "Requested slot unload.")
    end
end

function Ancestor:DeleteSlot(slotNum)
    if RequestLoad and RequestSave then
        pcall(function()
            RequestLoad:InvokeServer(math.huge, Player)
            RequestSave:InvokeServer(slotNum, Player)
        end)
        Notify("Slot Delete", "Processed delete request for slot " .. tostring(slotNum))
    end
end

-- Tree, Shop, Axe & Vehicle Helpers
function Ancestor:GetAllTrees()
    local list = {}
    for _, region in ipairs(workspace:GetChildren()) do
        if tostring(region):match("TreeRegion") then
            for _, tree in ipairs(region:GetChildren()) do
                if tree:FindFirstChild("TreeClass") and #tree:GetChildren() >= 4 then
                    list[#list + 1] = { Parent = tree.Parent, Model = tree }
                end
            end
        end
    end
    return list
end

function Ancestor:BringTree()
    local treeList = self:GetAllTrees()
    local targetTree
    for _, entry in ipairs(treeList) do
        local m = entry.Model
        local tc = m:FindFirstChild("TreeClass")
        if tc and (self.SelectedTreeType == "Generic" or tostring(tc.Value) == self.SelectedTreeType) then
            targetTree = m:FindFirstChild("WoodSection") or m.PrimaryPart
            if targetTree then break end
        end
    end
    if not targetTree then
        Notify("Tree Options", "No matching '" .. tostring(self.SelectedTreeType) .. "' tree found.")
        return
    end

    local dest = CFrame.new(targetTree.Position) + Vector3.new(0, 5, 0)
    if self.BringTreeSelectedPosition == "Spawn" then
        dest = CFrame.new(174, 15, 66)
    elseif self.BringTreeSelectedPosition == "Sell Point" then
        dest = CFrame.new(315, 3, 85)
    elseif self.BringTreeSelectedPosition == "To Property" then
        local base = self:GetPlayersBase(Player)
        if base and base:FindFirstChild("OriginSquare") then
            dest = base.OriginSquare.CFrame + Vector3.new(0, 5, 0)
        end
    end

    self:Teleport(CFrame.new(targetTree.Position) + Vector3.new(0, 4, 0))
    if ClientIsDragging and targetTree.Parent then
        pcall(function()
            ClientIsDragging:FireServer(targetTree.Parent)
        end)
    end
    if GUISettings.TeleportBackAfterBringTree then
        self:Teleport(dest)
    end
    Notify("Tree Options", "Moved to selected tree.")
end

function Ancestor:DropTools()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:UnequipTools() end)
        if GUISettings.InstantDropAxes then
            hum.Health = 0
            return
        end
    end
    local axes = self:GetAxes()
    for _, axe in ipairs(axes) do
        if ClientInteracted and char and char.PrimaryPart then
            pcall(function()
                ClientInteracted:FireServer(axe, "Drop tool", char.PrimaryPart.CFrame)
            end)
            task.wait(0.12)
        end
    end
    Notify("Axe Options", "Dropped axes.")
end

function Ancestor:SitInAnyVehicle()
    local ps = Player:FindFirstChild("PlayerScripts")
    local sitPerm = ps and ps:FindFirstChild("SitPermissions")
    if sitPerm then
        pcall(function()
            sitPerm.Disabled = GUISettings.SitInAnyVehicle
        end)
    end
end

function Ancestor:SpawnVehicle()
    Notify("Vehicle Spawner", "Click one of your owned Vehicle Spots in-game...")
    local conn
    conn = Mouse.Button1Down:Connect(function()
        conn:Disconnect()
        local hitTarget = Mouse.Target
        local spot = hitTarget and hitTarget.Parent
        if spot and spot:FindFirstChild("Type") and tostring(spot.Type.Value):match("Vehicle Spot") then
            local remote = spot:FindFirstChild("ButtonRemote_SpawnButton")
            if remote and RemoteProxy then
                pcall(function()
                    RemoteProxy:FireServer(remote)
                end)
                Notify("Vehicle Spawner", "Triggered vehicle spawn (" .. tostring(self.SelectedVehicleColourToSpawn) .. ").")
            end
        else
            Notify("Vehicle Spawner", "Clicked object is not a valid Vehicle Spot.")
        end
    end)
end

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Aldrin UI GUI V1",
    Icon = 0,
    LoadingTitle = "Aldrin UI GUI V1",
    LoadingSubtitle = "Client • Game • Troll • Misc",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AldrinUIGUIV1",
        FileName = "AldrinConfig"
    },
    KeySystem = false
})

-- ==========================================
-- [TAB] CLIENT OPTIONS
-- ==========================================
local ClientTab = Window:CreateTab("Client Options", 4483362458)

ClientTab:CreateSection("Humanoid Options")

ClientTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 400},
    Increment = 1,
    Suffix = " WS",
    CurrentValue = GUISettings.WalkSpeed,
    Flag = "Client_WalkSpeed",
    Callback = function(Value)
        GUISettings.WalkSpeed = Value
    end
})

ClientTab:CreateSlider({
    Name = "Sprint Speed",
    Range = {20, 200},
    Increment = 1,
    Suffix = " SS",
    CurrentValue = GUISettings.SprintSpeed,
    Flag = "Client_SprintSpeed",
    Callback = function(Value)
        GUISettings.SprintSpeed = Value
    end
})

ClientTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 400},
    Increment = 1,
    Suffix = " JP",
    CurrentValue = GUISettings.JumpPower,
    Flag = "Client_JumpPower",
    Callback = function(Value)
        GUISettings.JumpPower = Value
    end
})

ClientTab:CreateSlider({
    Name = "Hip Height",
    Range = {0, 200},
    Increment = 1,
    Suffix = " HH",
    CurrentValue = GUISettings.HipHeight,
    Flag = "Client_HipHeight",
    Callback = function(Value)
        GUISettings.HipHeight = Value
    end
})

ClientTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 800},
    Increment = 5,
    Suffix = " FS",
    CurrentValue = GUISettings.FlySpeed,
    Flag = "Client_FlySpeed",
    Callback = function(Value)
        GUISettings.FlySpeed = Value
    end
})

ClientTab:CreateKeybind({
    Name = "Fly Keybind",
    CurrentKeybind = GUISettings.FlyKey,
    HoldToInteract = false,
    Flag = "Client_FlyKey",
    Callback = function()
        GUISettings.FlyKey = GUISettings.FlyKey
        Ancestor.IsClientFlying = not Ancestor.IsClientFlying
        if Ancestor.IsClientFlying then
            Ancestor:Fly()
        end
    end
})

ClientTab:CreateKeybind({
    Name = "Noclip Keybind",
    CurrentKeybind = GUISettings.NoclipKey,
    HoldToInteract = false,
    Flag = "Client_NoclipKey",
    Callback = function()
        GUISettings.Noclip = not GUISettings.Noclip
        Notify("Noclip", GUISettings.Noclip and "Enabled" or "Disabled")
    end
})

ClientTab:CreateKeybind({
    Name = "Key-TP",
    CurrentKeybind = GUISettings.KeyTP,
    HoldToInteract = false,
    Flag = "Client_KeyTP",
    Callback = function()
        if Mouse and Mouse.Hit then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp or (hrp.Position - Mouse.Hit.Position).Magnitude < 5000 then
                Ancestor:Teleport(CFrame.new(Mouse.Hit.Position) + Vector3.new(0, 3, 0))
            end
        end
    end
})

ClientTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = GUISettings.InfiniteJump,
    Flag = "Client_InfiniteJump",
    Callback = function(Value)
        GUISettings.InfiniteJump = Value
    end
})

ClientTab:CreateToggle({
    Name = "Head Light",
    CurrentValue = GUISettings.Light,
    Flag = "Client_Light",
    Callback = function(Value)
        GUISettings.Light = Value
        Ancestor:ApplyLight()
    end
})

ClientTab:CreateToggle({
    Name = "Invincibility / Invisibility",
    CurrentValue = false,
    Flag = "Client_GodMode",
    Callback = function(Value)
        Ancestor.CharacterGodMode = (not Ancestor_Loaded and "FirstTimeExecutionProtection") or Value
        Ancestor:GodMode(true, Value)
    end
})

ClientTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = GUISettings.AntiAFK,
    Flag = "Client_AntiAFK",
    Callback = function(Value)
        GUISettings.AntiAFK = Value
        Ancestor:AntiAFK(Value)
    end
})

ClientTab:CreateButton({
    Name = "Safe Suicide",
    Callback = function()
        Ancestor:SafeSuicide()
    end
})

ClientTab:CreateButton({
    Name = "BTools",
    Callback = function()
        Ancestor:BTools()
    end
})

ClientTab:CreateSection("Camera & Teleports")

ClientTab:CreateSlider({
    Name = "Camera FOV",
    Range = {1, 120},
    Increment = 1,
    Suffix = " FOV",
    CurrentValue = GUISettings.FOV,
    Flag = "Client_FOV",
    Callback = function(Value)
        GUISettings.FOV = Value
        Camera.FieldOfView = Value
    end
})

ClientTab:CreateButton({
    Name = "Reset FOV",
    Callback = function()
        GUISettings.FOV = 70
        Camera.FieldOfView = 70
        Notify("Camera", "FOV reset to 70.")
    end
})

local Locations = {
    ["Wood R Us"]         = CFrame.new(270, 4, 60),
    ["Spawn"]             = CFrame.new(174, 10.5, 66),
    ["Land Store"]        = CFrame.new(270, 3, -98),
    ["Bridge"]            = CFrame.new(112, 37, -892),
    ["Dock"]              = CFrame.new(1136, 0, -206),
    ["Palm"]              = CFrame.new(2614, -4, -34),
    ["Cave"]              = CFrame.new(3590, -177, 415),
    ["Volcano"]           = CFrame.new(-1588, 623, 1069),
    ["Swamp"]             = CFrame.new(-1216, 131, -822),
    ["Fancy Furnishings"] = CFrame.new(486, 3, -1722),
    ["Boxed Cars"]        = CFrame.new(509, 3, -1458),
    ["Ice Mountain"]      = CFrame.new(1487, 415, 3259),
    ["Links Logic"]       = CFrame.new(4615, 7, -794),
    ["Bob's Shack"]       = CFrame.new(292, 8, -2544),
    ["Fine Arts Store"]   = CFrame.new(5217, -166, 721),
    ["Shrine Of Sight"]   = CFrame.new(-1608, 195, 928),
    ["Strange Man"]       = CFrame.new(1071, 16, 1141),
    ["Volcano Win"]       = CFrame.new(-1667, 349, 147),
    ["Ski Lodge"]         = CFrame.new(1244, 59, 2290),
    ["Fur Wood"]          = CFrame.new(-1080, -5, -942),
    ["The Den"]           = CFrame.new(330, 45, 1943)
}

local LocationNames = {}
for k in pairs(Locations) do
    LocationNames[#LocationNames + 1] = k
end
table.sort(LocationNames)

ClientTab:CreateDropdown({
    Name = "Teleport To Location",
    Options = LocationNames,
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "Client_TeleportLoc",
    Callback = function(Selected)
        local choice = type(Selected) == "table" and Selected[1] or Selected
        if choice and Locations[choice] then
            Ancestor:Teleport(Locations[choice])
        end
    end
})

local function GetPlayerNames()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            list[#list + 1] = plr.Name
        end
    end
    return list
end

local SelectedTPPlayerName
local TPPlayerDropdown = ClientTab:CreateDropdown({
    Name = "Teleport To Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "Client_TPPlayer",
    Callback = function(Selected)
        SelectedTPPlayerName = type(Selected) == "table" and Selected[1] or Selected
        local target = SelectedTPPlayerName and Players:FindFirstChild(SelectedTPPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Ancestor:Teleport(CFrame.new(target.Character.HumanoidRootPart.Position) + Vector3.new(0, 5, 0))
        end
    end
})

ClientTab:CreateButton({
    Name = "Refresh Player List (Teleport)",
    Callback = function()
        TPPlayerDropdown:Refresh(GetPlayerNames(), true)
        Notify("Players", "Refreshed player list.")
    end
})

ClientTab:CreateToggle({
    Name = "Re-Execute Upon Rejoin",
    CurrentValue = GUISettings.RejoinExecute,
    Flag = "Client_RejoinExec",
    Callback = function(Value)
        GUISettings.RejoinExecute = Value
    end
})

ClientTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        Ancestor:Rejoin()
    end
})

-- ==========================================
-- [TAB] GAME OPTIONS
-- ==========================================
local GameTab = Window:CreateTab("Game Options", 4483362458)

GameTab:CreateSection("Graphical Options")

GameTab:CreateToggle({
    Name = "Always Day",
    CurrentValue = GUISettings.AlwaysDay,
    Flag = "Game_AlwaysDay",
    Callback = function(Value)
        GUISettings.AlwaysDay = Value
        if Value then GUISettings.AlwaysNight = false end
    end
})

GameTab:CreateToggle({
    Name = "Always Night",
    CurrentValue = GUISettings.AlwaysNight,
    Flag = "Game_AlwaysNight",
    Callback = function(Value)
        GUISettings.AlwaysNight = Value
        if Value then GUISettings.AlwaysDay = false end
    end
})

GameTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = GUISettings.NoFog,
    Flag = "Game_NoFog",
    Callback = function(Value)
        GUISettings.NoFog = Value
    end
})

GameTab:CreateToggle({
    Name = "Spook Mode",
    CurrentValue = GUISettings.Spook,
    Flag = "Game_Spook",
    Callback = function(Value)
        GUISettings.Spook = Value
        local spookVal = Lighting:FindFirstChild("Spook")
        if spookVal and spookVal:IsA("ValueBase") then
            spookVal.Value = Value
        end
    end
})

GameTab:CreateToggle({
    Name = "Global Shadows",
    CurrentValue = GUISettings.GlobalShadows,
    Flag = "Game_GlobalShadows",
    Callback = function(Value)
        GUISettings.GlobalShadows = Value
        Lighting.GlobalShadows = Value
    end
})

GameTab:CreateToggle({
    Name = "Better Graphics",
    CurrentValue = GUISettings.BetterGraphics,
    Flag = "Game_BetterGraphics",
    Callback = function(Value)
        GUISettings.BetterGraphics = Value
        Ancestor:BetterGraphics()
    end
})

GameTab:CreateSlider({
    Name = "Brightness",
    Range = {1, 5},
    Increment = 0.1,
    Suffix = " Lux",
    CurrentValue = GUISettings.Brightness,
    Flag = "Game_Brightness",
    Callback = function(Value)
        GUISettings.Brightness = Value
        Lighting.Brightness = Value
    end
})

GameTab:CreateSection("Water & Dragging Options")

GameTab:CreateToggle({
    Name = "Water Walk",
    CurrentValue = GUISettings.WaterWalk,
    Flag = "Game_WaterWalk",
    Callback = function(Value)
        GUISettings.WaterWalk = Value
        local waterFolder = workspace:FindFirstChild("Water")
        if waterFolder then
            for _, part in ipairs(waterFolder:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = Value end
            end
        end
    end
})

GameTab:CreateToggle({
    Name = "Water Float",
    CurrentValue = GUISettings.WaterFloat,
    Flag = "Game_WaterFloat",
    Callback = function(Value)
        GUISettings.WaterFloat = Value
    end
})

GameTab:CreateToggle({
    Name = "Water Godmode",
    CurrentValue = GUISettings.WaterGodMode,
    Flag = "Game_WaterGodMode",
    Callback = function(Value)
        GUISettings.WaterGodMode = Value
    end
})

GameTab:CreateSlider({
    Name = "X Axis Rotate Speed",
    Range = {1, 5},
    Increment = 0.25,
    Suffix = "x",
    CurrentValue = GUISettings.XRotate,
    Flag = "Game_XRotate",
    Callback = function(Value)
        GUISettings.XRotate = Value
        Ancestor:FastRotate(GUISettings.FastRotate)
    end
})

GameTab:CreateSlider({
    Name = "Y Axis Rotate Speed",
    Range = {1, 5},
    Increment = 0.25,
    Suffix = "x",
    CurrentValue = GUISettings.YRotate,
    Flag = "Game_YRotate",
    Callback = function(Value)
        GUISettings.YRotate = Value
        Ancestor:FastRotate(GUISettings.FastRotate)
    end
})

GameTab:CreateToggle({
    Name = "Fast Rotate",
    CurrentValue = GUISettings.FastRotate,
    Flag = "Game_FastRotate",
    Callback = function(Value)
        GUISettings.FastRotate = Value
        Ancestor:FastRotate(Value)
    end
})

GameTab:CreateToggle({
    Name = "Hard Dragger",
    CurrentValue = GUISettings.HardDragger,
    Flag = "Game_HardDragger",
    Callback = function(Value)
        GUISettings.HardDragger = Value
        Ancestor:HardDragger(Value)
    end
})

-- ==========================================
-- [TAB] TROLL OPTIONS
-- ==========================================
local TrollTab = Window:CreateTab("Troll Options", 4483362458)

TrollTab:CreateSection("Player Moderation / Trolling")

TrollTab:CreateDropdown({
    Name = "Troll Action",
    Options = {"Kill", "Hard Kill", "Bring", "Fling"},
    CurrentOption = {Ancestor.ModerationAction},
    MultipleOptions = false,
    Flag = "Troll_Action",
    Callback = function(Selected)
        Ancestor.ModerationAction = type(Selected) == "table" and Selected[1] or Selected
    end
})

TrollTab:CreateDropdown({
    Name = "Method Type",
    Options = {"Vehicle", "Axe"},
    CurrentOption = {Ancestor.ModerationType},
    MultipleOptions = false,
    Flag = "Troll_Method",
    Callback = function(Selected)
        Ancestor.ModerationType = type(Selected) == "table" and Selected[1] or Selected
    end
})

local TrollTargetDropdown = TrollTab:CreateDropdown({
    Name = "Target Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "Troll_TargetPlayer",
    Callback = function(Selected)
        local pName = type(Selected) == "table" and Selected[1] or Selected
        Ancestor.PlayerToModerate = pName and Players:FindFirstChild(pName) or nil
    end
})

TrollTab:CreateButton({
    Name = "Refresh Target Players",
    Callback = function()
        TrollTargetDropdown:Refresh(GetPlayerNames(), true)
        Notify("Troll Options", "Refreshed target player list.")
    end
})

TrollTab:CreateButton({
    Name = "Perform Action",
    Callback = function()
        Ancestor:ModeratePlayer(Ancestor.ModerationAction)
    end
})

TrollTab:CreateSection("Server Troll Tools")

TrollTab:CreateToggle({
    Name = "Stop Players From Loading",
    CurrentValue = GUISettings.StopPlayersLoading,
    Flag = "Troll_StopLoading",
    Callback = function(Value)
        GUISettings.StopPlayersLoading = Value
    end
})

TrollTab:CreateToggle({
    Name = "Force Whitelist",
    CurrentValue = GUISettings.ForceWhitelist,
    Flag = "Troll_ForceWhitelist",
    Callback = function(Value)
        GUISettings.ForceWhitelist = Value
        Ancestor:ForceWhitelist()
    end
})

TrollTab:CreateToggle({
    Name = "Close Store Doors Loop",
    CurrentValue = GUISettings.CloseStores,
    Flag = "Troll_CloseStores",
    Callback = function(Value)
        GUISettings.CloseStores = Value
    end
})

TrollTab:CreateButton({
    Name = "Fire All Scoobis",
    Callback = function()
        Ancestor:FireAll("Scoobis")
    end
})

TrollTab:CreateButton({
    Name = "Fire All Bold & Brash",
    Callback = function()
        Ancestor:FireAll("Painting4")
    end
})

-- ==========================================
-- [TAB] MISCELLANEOUS FEATURES
-- ==========================================
local MiscTab = Window:CreateTab("Miscellaneous Features", 4483362458)

-- [+] Property Options
MiscTab:CreateSection("[+] Property Options")

MiscTab:CreateSlider({
    Name = "Slot To Load / Save",
    Range = {1, 6},
    Increment = 1,
    Suffix = " Slot",
    CurrentValue = GUISettings.SelectedProperty,
    Flag = "Misc_SelectedSlot",
    Callback = function(Value)
        GUISettings.SelectedProperty = Value
    end
})

MiscTab:CreateButton({
    Name = "Load Selected Slot",
    Callback = function()
        Ancestor:LoadSlot(GUISettings.SelectedProperty)
    end
})

MiscTab:CreateButton({
    Name = "Save Current Slot",
    Callback = function()
        Ancestor:SaveSlot()
    end
})

MiscTab:CreateButton({
    Name = "Unload Current Slot",
    Callback = function()
        Ancestor:UnloadSlot()
    end
})

MiscTab:CreateButton({
    Name = "Delete Selected Slot",
    Callback = function()
        Ancestor:DeleteSlot(GUISettings.SelectedProperty)
    end
})

MiscTab:CreateButton({
    Name = "Free Land",
    Callback = function()
        Ancestor:FreeLand()
    end
})

MiscTab:CreateButton({
    Name = "Max Land",
    Callback = function()
        Ancestor:MaxLand()
    end
})

-- [+] Tree Options
MiscTab:CreateSection("[+] Tree Options")

local TreeTypes = {
    "Generic", "GoldSwampy", "CaveCrawler", "Cherry", "Frost", "Volcano",
    "Oak", "Walnut", "Birch", "SnowGlow", "Fir", "Pine", "GreenSwampy",
    "Koa", "Palm", "Spooky", "SpookyNeon", "LoneCave"
}

MiscTab:CreateDropdown({
    Name = "Select Tree Type",
    Options = TreeTypes,
    CurrentOption = {Ancestor.SelectedTreeType},
    MultipleOptions = false,
    Flag = "Misc_TreeType",
    Callback = function(Selected)
        Ancestor.SelectedTreeType = type(Selected) == "table" and Selected[1] or Selected
    end
})

MiscTab:CreateDropdown({
    Name = "Bring Tree Destination",
    Options = {"Current Position", "Spawn", "To Property", "Sell Point"},
    CurrentOption = {Ancestor.BringTreeSelectedPosition},
    MultipleOptions = false,
    Flag = "Misc_BringTreePos",
    Callback = function(Selected)
        Ancestor.BringTreeSelectedPosition = type(Selected) == "table" and Selected[1] or Selected
    end
})

MiscTab:CreateSlider({
    Name = "Bring Tree Quantity",
    Range = {1, 10},
    Increment = 1,
    Suffix = " Trees",
    CurrentValue = Ancestor.BringTreeAmount,
    Flag = "Misc_TreeQty",
    Callback = function(Value)
        Ancestor.BringTreeAmount = Value
    end
})

MiscTab:CreateToggle({
    Name = "Teleport Player With Tree",
    CurrentValue = GUISettings.TeleportBackAfterBringTree,
    Flag = "Misc_TPWithTree",
    Callback = function(Value)
        GUISettings.TeleportBackAfterBringTree = Value
    end
})

MiscTab:CreateButton({
    Name = "Bring Selected Tree",
    Callback = function()
        Ancestor:BringTree()
    end
})

-- [+] Shop Options
MiscTab:CreateSection("[+] Shop Options")

local StoreItems = {
    "Basic Hatchet", "Switch Conveyor", "Funnel Conveyor", "Fair Sawmill",
    "Basic Door", "Steep Stairs", "Stairs", "Mundane Chair", "Shabby Sawmill",
    "Wood Sweeper", "Conveyor Supports", "Tilted Conveyor", "Work Light",
    "Straight Conveyor", "Tight Turn Conveyor", "Sawmax 01", "Plain Axe",
    "Steel Axe", "Hardened Axe", "Sawmax 02", "Chop Saw", "Silver Axe",
    "Sawmax 02L", "Utility Vehicle", "Utility Vehicle XL", "Small Trailer",
    "Val's All-Purpose Hauler", "531 Hauler", "Dynamite", "Can of Worms"
}

MiscTab:CreateDropdown({
    Name = "Select Shop Item",
    Options = StoreItems,
    CurrentOption = {Ancestor.AutobuySelectedItem},
    MultipleOptions = false,
    Flag = "Misc_ShopItem",
    Callback = function(Selected)
        Ancestor.AutobuySelectedItem = type(Selected) == "table" and Selected[1] or Selected
    end
})

MiscTab:CreateSlider({
    Name = "Autobuy Amount",
    Range = {1, 100},
    Increment = 1,
    Suffix = "x",
    CurrentValue = Ancestor.AutobuyAmount,
    Flag = "Misc_AutobuyAmt",
    Callback = function(Value)
        Ancestor.AutobuyAmount = Value
    end
})

MiscTab:CreateToggle({
    Name = "Auto Unbox After Purchase",
    CurrentValue = GUISettings.UnboxItems,
    Flag = "Misc_AutoUnbox",
    Callback = function(Value)
        GUISettings.UnboxItems = Value
    end
})

MiscTab:CreateToggle({
    Name = "Faster NPC Dialogue",
    CurrentValue = GUISettings.FastCheckout,
    Flag = "Misc_FastCheckout",
    Callback = function(Value)
        GUISettings.FastCheckout = Value
        pcall(function()
            if NPCChattingClient and NPCChattingClient.advanceChat and setconstant then
                setconstant(NPCChattingClient.advanceChat, 19, Value and 0.5 or 1.5)
            end
        end)
    end
})

-- [+] Axe Options/Exploits
MiscTab:CreateSection("[+] Axe Options/Exploits")

MiscTab:CreateSlider({
    Name = "Axe Range",
    Range = {1, 400},
    Increment = 1,
    Suffix = " Studs",
    CurrentValue = GUISettings.AxeRange,
    Flag = "Misc_AxeRange",
    Callback = function(Value)
        GUISettings.AxeRange = Value
    end
})

MiscTab:CreateToggle({
    Name = "Activate Axe Range",
    CurrentValue = GUISettings.AxeRangeActive,
    Flag = "Misc_AxeRangeActive",
    Callback = function(Value)
        GUISettings.AxeRangeActive = Value
    end
})

MiscTab:CreateToggle({
    Name = "No Axe Cooldown",
    CurrentValue = GUISettings.AxeSwingActive,
    Flag = "Misc_NoAxeCooldown",
    Callback = function(Value)
        GUISettings.AxeSwingActive = Value
    end
})

MiscTab:CreateToggle({
    Name = "Instant Drop Axes (Respawn)",
    CurrentValue = GUISettings.InstantDropAxes,
    Flag = "Misc_InstantDropAxes",
    Callback = function(Value)
        GUISettings.InstantDropAxes = Value
    end
})

MiscTab:CreateButton({
    Name = "Drop All Axes",
    Callback = function()
        Ancestor:DropTools()
    end
})

-- [+] Vehicle Options/Exploits
MiscTab:CreateSection("[+] Vehicle Options/Exploits")

MiscTab:CreateSlider({
    Name = "Vehicle Speed",
    Range = {1, 5},
    Increment = 0.25,
    Suffix = "x",
    CurrentValue = GUISettings.CarSpeed,
    Flag = "Misc_CarSpeed",
    Callback = function(Value)
        GUISettings.CarSpeed = Value
    end
})

MiscTab:CreateSlider({
    Name = "Vehicle Pitch",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = GUISettings.CarPitch,
    Flag = "Misc_CarPitch",
    Callback = function(Value)
        GUISettings.CarPitch = Value
    end
})

MiscTab:CreateToggle({
    Name = "Activate Vehicle Modifications",
    CurrentValue = GUISettings.ActivateVehicleModifications,
    Flag = "Misc_VehModsActive",
    Callback = function(Value)
        GUISettings.ActivateVehicleModifications = Value
    end
})

MiscTab:CreateToggle({
    Name = "Sit In Any Vehicle",
    CurrentValue = GUISettings.SitInAnyVehicle,
    Flag = "Misc_SitAnyVeh",
    Callback = function(Value)
        GUISettings.SitInAnyVehicle = Value
        Ancestor:SitInAnyVehicle()
    end
})

MiscTab:CreateDropdown({
    Name = "Vehicle Spawner Colour",
    Options = VehicleColours,
    CurrentOption = {Ancestor.SelectedVehicleColourToSpawn},
    MultipleOptions = false,
    Flag = "Misc_VehColor",
    Callback = function(Selected)
        Ancestor.SelectedVehicleColourToSpawn = type(Selected) == "table" and Selected[1] or Selected
    end
})

MiscTab:CreateToggle({
    Name = "Auto Stop On Pink",
    CurrentValue = GUISettings.AutoStopOnPinkVehicle,
    Flag = "Misc_StopPink",
    Callback = function(Value)
        GUISettings.AutoStopOnPinkVehicle = Value
    end
})

MiscTab:CreateToggle({
    Name = "Delete Spawn Pad After Spawn",
    CurrentValue = GUISettings.DeleteSpawnPadAfterVehicleSpawn,
    Flag = "Misc_DelPad",
    Callback = function(Value)
        GUISettings.DeleteSpawnPadAfterVehicleSpawn = Value
    end
})

MiscTab:CreateButton({
    Name = "Spawn Vehicle",
    Callback = function()
        Ancestor:SpawnVehicle()
    end
})

-- [+] Settings/Configs
MiscTab:CreateSection("[+] Settings/Configs")

MiscTab:CreateToggle({
    Name = "Autosave Config",
    CurrentValue = GUISettings.AutoSaveGUIConfiguration,
    Flag = "Misc_AutoSaveCfg",
    Callback = function(Value)
        GUISettings.AutoSaveGUIConfiguration = Value
    end
})

MiscTab:CreateButton({
    Name = "Save Configuration",
    Callback = function()
        Ancestor:SaveConfigurationFile(false)
    end
})

MiscTab:CreateButton({
    Name = "Delete Configuration",
    Callback = function()
        Ancestor:DeleteConfigurationFile()
    end
})

for i = 1, 6 do
    local slotKey = "Slot" .. tostring(i)
    MiscTab:CreateInput({
        Name = "Rename " .. slotKey,
        CurrentValue = SlotNames[slotKey] or slotKey,
        PlaceholderText = "Enter custom slot name...",
        RemoveTextAfterFocusLost = false,
        Flag = "Misc_" .. slotKey,
        Callback = function(Text)
            if Text and Text ~= "" then
                SlotNames[slotKey] = Text
            end
        end
    })
end

MiscTab:CreateButton({
    Name = "Save Slot Names",
    Callback = function()
        Ancestor:SaveSlotNames()
    end
})

-- [+] Many More Features And Scripts Inside UI
MiscTab:CreateSection("[+] Many More Features And Scripts Inside UI")

MiscTab:CreateLabel("Executor: " .. tostring(Executor) .. " | PlaceVersion: V" .. tostring(game.PlaceVersion))

MiscTab:CreateButton({
    Name = "Execute Toads GUI",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://bit.ly/3x90l99"))("TOADS")
        end)
    end
})

MiscTab:CreateButton({
    Name = "Destroy Aldrin UI GUI V1",
    Callback = function()
        getgenv().Ancestor_Loaded = false
        Ancestor.IsClientFlying = false
        for connName in pairs(Connections) do
            Ancestor:GetConnection(connName, true)
        end
        Rayfield:Destroy()
    end
})

-- ==========================================
-- BACKGROUND RUNTIME LOOPS
-- ==========================================
Connections.InfiniteJump = {
    Function = UIS.JumpRequest:Connect(function()
        if GUISettings.InfiniteJump then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
}

local VehiclesDefaultSpeed = {
    UtilityTruck_Vehicle  = 1.4,
    UtilityTruck2_Vehicle = 1.15,
    Pickup_Vehicle        = 1.15
}

Connections.MainLoop = {
    Function = RunService.Stepped:Connect(function()
        if not getgenv().Ancestor_Loaded then return end

        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local targetWS = GUISettings.WalkSpeed
        if GUISettings.SprintKey and Enum.KeyCode[GUISettings.SprintKey] and UIS:IsKeyDown(Enum.KeyCode[GUISettings.SprintKey]) then
            targetWS = GUISettings.WalkSpeed + GUISettings.SprintSpeed
        end

        if hum then
            pcall(function()
                hum.WalkSpeed = targetWS
                hum.JumpPower = GUISettings.JumpPower
                hum.HipHeight = GUISettings.HipHeight
            end)
        end

        if GUISettings.Noclip and char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        if GUISettings.AlwaysDay then
            Lighting.TimeOfDay = "12:00:00"
        elseif GUISettings.AlwaysNight then
            Lighting.TimeOfDay = "02:00:00"
        end

        Lighting.GlobalShadows = GUISettings.GlobalShadows
        if GUISettings.NoFog then
            Lighting.FogEnd = 1000000
        end

        if hum and hum.SeatPart and hum.SeatPart.Parent then
            local veh = hum.SeatPart.Parent
            local cfg = veh:FindFirstChild("Configuration")
            local maxSpd = cfg and cfg:FindFirstChild("MaxSpeed")
            local itemNameObj = veh:FindFirstChild("ItemName")
            if maxSpd and maxSpd:IsA("ValueBase") then
                local defSpd = (itemNameObj and VehiclesDefaultSpeed[tostring(itemNameObj.Value)]) or maxSpd.Value
                maxSpd.Value = GUISettings.ActivateVehicleModifications and GUISettings.CarSpeed or defSpd
            end
        end
    end)
}

task.spawn(function()
    while task.wait(5) do
        if not getgenv().Ancestor_Loaded then break end
        if GUISettings.AutoSaveGUIConfiguration then
            Ancestor:SaveConfigurationFile(true)
        end
        if GUISettings.StopPlayersLoading and PropertiesFolder and ClientPurchasedProperty and RequestLoad then
            for _, prop in ipairs(PropertiesFolder:GetChildren()) do
                local owner = prop:FindFirstChild("Owner")
                local sq = prop:FindFirstChild("OriginSquare")
                if owner and owner.Value == nil and sq then
                    pcall(function()
                        ClientPurchasedProperty:FireServer(prop, sq.CFrame)
                        RequestLoad:InvokeServer(math.huge, Player)
                    end)
                    task.wait(0.2)
                end
            end
        end
        if GUISettings.CloseStores and StoresFolder and RemoteProxy then
            local doors = {
                StoresFolder:FindFirstChild("FurnitureStore") and StoresFolder.FurnitureStore:FindFirstChild("LDoor"),
                StoresFolder:FindFirstChild("FurnitureStore") and StoresFolder.FurnitureStore:FindFirstChild("RDoor"),
                StoresFolder:FindFirstChild("LogicStore") and StoresFolder.LogicStore:FindFirstChild("LDoor"),
                StoresFolder:FindFirstChild("LogicStore") and StoresFolder.LogicStore:FindFirstChild("RDoor"),
                StoresFolder:FindFirstChild("CarStore") and StoresFolder.CarStore:FindFirstChild("LDoor"),
                StoresFolder:FindFirstChild("CarStore") and StoresFolder.CarStore:FindFirstChild("RDoor")
            }
            for _, door in ipairs(doors) do
                local btn = door and door:FindFirstChild("ButtonRemote_Toggle")
                local prompt = btn and btn:FindFirstChild("ButtonPrompt")
                if btn and prompt and tostring(prompt.Value):match("Close") then
                    pcall(function() RemoteProxy:FireServer(btn) end)
                end
            end
        end
    end
end)

Connections.CharAdded = {
    Function = Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        Ancestor:ApplyLight()
        if Ancestor.IsClientFlying then
            Ancestor:Fly()
        end
    end)
}

getgenv().Ancestor_Loaded = true
Notify("Aldrin UI GUI V1", "Loaded successfully!")
