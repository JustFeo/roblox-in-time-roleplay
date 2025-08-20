--!strict

-- Simple wanted system with police drone pursuer per wanted player

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TimeService = require(script.Parent:WaitForChild("TimeService"))

local WantedService = {}

local playerToDrone: {[Player]: BasePart} = {}

local function createDrone(): BasePart
    local p = Instance.new("Part")
    p.Name = "PoliceDrone"
    p.Size = Vector3.new(2, 1, 2)
    p.Shape = Enum.PartType.Block
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(255, 60, 60)
    p.Anchored = true
    p.CanCollide = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = Workspace
    return p
end

local function removeDrone(player: Player)
    local d = playerToDrone[player]
    if d then
        d:Destroy()
        playerToDrone[player] = nil
    end
end

local function ensureDrone(player: Player)
    if playerToDrone[player] then return end
    local d = createDrone()
    playerToDrone[player] = d
end

function WantedService.setWanted(player: Player, seconds: number)
    local profile = TimeService.getProfile(player)
    if not profile then return end
    profile.WantedEndClock = math.max(os.clock(), profile.WantedEndClock or 0) + math.max(1, seconds)
end

-- Chase loop
RunService.Heartbeat:Connect(function(dt)
    for _, player in ipairs(Players:GetPlayers()) do
        local profile = TimeService.getProfile(player)
        if profile then
            local wanted = (profile.WantedEndClock or 0) > os.clock()
            if wanted then
                ensureDrone(player)
                local d = playerToDrone[player]
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if d and hrp then
                    local pos = hrp.Position + Vector3.new(0, 6, 0)
                    d.Position = d.Position:Lerp(pos, math.clamp(dt * 2.0, 0, 1))
                    -- simple touch damage
                    if (d.Position - hrp.Position).Magnitude < 3 then
                        TimeService.trySpendTime(player, 5) -- 5s penalty per tick near drone
                    end
                end
            else
                removeDrone(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeDrone(player)
end)

return WantedService


