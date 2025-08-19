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

local courierStart = Workspace:WaitForChild("CourierStart") :: BasePart
local courierEnd = Workspace:WaitForChild("CourierEnd") :: BasePart

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


