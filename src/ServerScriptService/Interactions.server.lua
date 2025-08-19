--!strict

-- Mission interaction triggers for courier job

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
    RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
    RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
    Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}

local function waitForOrCreate(name: string, pos: Vector3)
    local t = Workspace:FindFirstChild(name)
    if t and t:IsA("BasePart") then
        return t
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 1
    p.Size = Vector3.new(6,6,6)
    p.Position = pos
    p.Parent = Workspace
    return p
end

local courierStart = waitForOrCreate("CourierStart", Vector3.new(-80, 3, -40))
local courierEnd = waitForOrCreate("CourierEnd", Vector3.new(160, 3, 160))

local carrying: {[Player]: boolean} = {}

local function touchedStart(part: BasePart)
    local character = part:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return end
    if carrying[player] then return end
    carrying[player] = true
    Remotes.Notify:FireClient(player, "Picked up package. Go to B (marker)")
    Remotes.RequestMissionStart:FireServer("courier_1")
end

local function touchedEnd(part: BasePart)
    local character = part:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return end
    if not carrying[player] then return end
    carrying[player] = nil
    Remotes.Notify:FireClient(player, "Delivered!")
    Remotes.RequestMissionComplete:FireServer("courier_1")
end

courierStart.Touched:Connect(touchedStart)
courierEnd.Touched:Connect(touchedEnd)

Players.PlayerRemoving:Connect(function(player)
    carrying[player] = nil
end)


