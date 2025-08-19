--!strict

-- Simple mission system with validation and cooldowns

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
	RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}
local TimeService = require(script.Parent:WaitForChild("TimeService"))

type MissionState = {
	LastCompletedAt: number,
}

local missions = {
	{
		Id = "courier_1",
		Name = "Courier Run",
		Description = "Deliver the package from Point A to Point B",
		RewardSeconds = 90,
		CooldownSeconds = 60,
	},
	{
		Id = "cleaner_1",
		Name = "Street Cleaner",
		Description = "Clean litter in the block",
		RewardSeconds = 60,
		CooldownSeconds = 45,
	},
}

local playerMissionState: {[Player]: {[string]: MissionState}} = {}

local function getMissionById(id: string)
	for _, m in ipairs(missions) do
		if m.Id == id then return m end
	end
	return nil
end

local function canComplete(player: Player, missionId: string): (boolean, string?)
	local m = getMissionById(missionId)
	if not m then return false, "Mission not found" end
	local state = playerMissionState[player]
	if not state then return true, nil end
	local ms = state[missionId]
	if ms then
		local since = os.clock() - ms.LastCompletedAt
		if since < (m.CooldownSeconds or 0) then
			return false, string.format("On cooldown: %ds", math.ceil((m.CooldownSeconds or 0) - since))
		end
	end
	return true, nil
end

local function markCompleted(player: Player, missionId: string)
	playerMissionState[player] = playerMissionState[player] or {}
	playerMissionState[player][missionId] = { LastCompletedAt = os.clock() }
end

Remotes.RequestMissionStart.OnServerEvent:Connect(function(player: Player, missionId: string)
	local m = getMissionById(missionId)
	if not m then
		Remotes.Notify:FireClient(player, "Mission not found")
		return
	end
	local ok, reason = canComplete(player, missionId)
	if not ok then
		Remotes.Notify:FireClient(player, reason or "Unavailable")
		return
	end
	Remotes.Notify:FireClient(player, "Mission started: " .. m.Name)
end)

Remotes.RequestMissionComplete.OnServerEvent:Connect(function(player: Player, missionId: string)
	local m = getMissionById(missionId)
	if not m then
		Remotes.Notify:FireClient(player, "Mission not found")
		return
	end
	local ok, reason = canComplete(player, missionId)
	if not ok then
		Remotes.Notify:FireClient(player, reason or "Unavailable")
		return
	end
	markCompleted(player, missionId)
	TimeService.addTime(player, m.RewardSeconds, m.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	playerMissionState[player] = nil
end)


