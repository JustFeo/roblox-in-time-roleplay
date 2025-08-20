--!strict

-- Time bank deposit/withdraw via ProximityPrompts or UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestDeposit = Remotes:WaitForChild("RequestDeposit") :: RemoteEvent
local RequestWithdraw = Remotes:WaitForChild("RequestWithdraw") :: RemoteEvent

local TimeService = require(script.Parent:WaitForChild("TimeService"))

RequestDeposit.OnServerEvent:Connect(function(player: Player, seconds: number)
    seconds = tonumber(seconds) or 0
    seconds = math.clamp(math.floor(seconds), 0, 60 * 60)
    if seconds <= 0 then return end
    TimeService.deposit(player, seconds)
end)

RequestWithdraw.OnServerEvent:Connect(function(player: Player, seconds: number)
    seconds = tonumber(seconds) or 0
    seconds = math.clamp(math.floor(seconds), 0, 60 * 60)
    if seconds <= 0 then return end
    TimeService.withdraw(player, seconds)
end)


