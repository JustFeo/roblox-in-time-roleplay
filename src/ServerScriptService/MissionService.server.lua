--!strict

-- Simple mission system with validation and cooldowns (delegates to MissionCore)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
	RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}

local MissionCore = require(script.Parent:WaitForChild("MissionCore"))

Remotes.RequestMissionStart.OnServerEvent:Connect(function(player: Player, missionId: string)
	local ok, reason = MissionCore.canComplete(player, missionId)
	if not ok then
		Remotes.Notify:FireClient(player, reason or "Unavailable")
		return
	end
	Remotes.Notify:FireClient(player, "Mission started: " .. (missionId or ""))
end)

Remotes.RequestMissionComplete.OnServerEvent:Connect(function(player: Player, missionId: string)
	local ok = MissionCore.complete(player, missionId)
	if not ok then
		Remotes.Notify:FireClient(player, "Mission unavailable or on cooldown")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	MissionCore.cleanup(player)
end)


