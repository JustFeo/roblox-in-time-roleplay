--!strict

-- Server-authoritative time currency system.
-- Counts down every second. Players can earn time via missions and spend time in shops.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
	RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
	RequestPurchase = RemotesFolder:WaitForChild("RequestPurchase") :: RemoteEvent,
	SubmitPromoCode = RemotesFolder:WaitForChild("SubmitPromoCode") :: RemoteEvent,
	TimeChanged = RemotesFolder:WaitForChild("TimeChanged") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
	GetProfile = RemotesFolder:WaitForChild("GetProfile") :: RemoteFunction,
}
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local PlayerProfiles: {[Player]: Types.PlayerTimeProfile} = {}
local playerRate = require(script.Parent:WaitForChild("RateLimiter")).new(12, 3)

local STARTER_TIME_SECONDS = 5 * 60 -- 5 minutes starter time
local MIN_TICK = 1

local function isoNow(): string
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function clamp(n: number, min: number, max: number): number
	if n < min then return min end
	if n > max then return max end
	return n
end

local function sendTime(player: Player)
	local profile = PlayerProfiles[player]
	if profile then
		Remotes.TimeChanged:FireClient(player, profile.TimeSeconds)
	end
end

local function setTime(player: Player, seconds: number)
	local profile = PlayerProfiles[player]
	if not profile then return end
	profile.TimeSeconds = math.max(0, math.floor(seconds))
	if profile.TimeSeconds == 0 then
		Remotes.Notify:FireClient(player, "You ran out of time. Respawning...")
		player:LoadCharacter()
		profile.TimeSeconds = STARTER_TIME_SECONDS
	end
	sendTime(player)
end

local function addTime(player: Player, seconds: number, reason: string?)
	if seconds <= 0 then return end
	local profile = PlayerProfiles[player]
	if not profile then return end
	profile.TimeSeconds += math.floor(seconds)
	Remotes.Notify:FireClient(player, string.format("+%ds %s", seconds, reason or ""))
	sendTime(player)
end

local function trySpendTime(player: Player, seconds: number): boolean
	local profile = PlayerProfiles[player]
	if not profile then return false end
	seconds = math.floor(seconds)
	if seconds <= 0 then return true end
	if profile.TimeSeconds < seconds then
		Remotes.Notify:FireClient(player, "Not enough time.")
		return false
	end
	profile.TimeSeconds -= seconds
	sendTime(player)
	return true
end

-- Expose API table for other server scripts
local TimeService = {}

function TimeService.getProfile(player: Player): Types.PlayerTimeProfile?
	return PlayerProfiles[player]
end

function TimeService.addTime(player: Player, seconds: number, reason: string?)
	addTime(player, seconds, reason)
end

function TimeService.trySpendTime(player: Player, seconds: number): boolean
	return trySpendTime(player, seconds)
end

-- Remotes
Remotes.GetProfile.OnServerInvoke = function(player: Player)
	local p = PlayerProfiles[player]
	if not p then return nil end
	return {
		UserId = p.UserId,
		DisplayName = p.DisplayName,
		TimeSeconds = p.TimeSeconds,
		LastDailyClaimISO = p.LastDailyClaimISO,
	}
end

-- Mission completion will be validated in MissionService; this just awards time
Remotes.RequestMissionComplete.OnServerEvent:Connect(function(player: Player, payload)
	-- Do nothing here. MissionService performs validation and awards time.
	if not playerRate:allow(player) then return end
end)

-- Main countdown loop
task.spawn(function()
	while true do
		for player, profile in pairs(PlayerProfiles) do
			if player.Parent == Players then
				setTime(player, profile.TimeSeconds - MIN_TICK)
			end
		end
		task.wait(MIN_TICK)
	end
end)

Players.PlayerAdded:Connect(function(player: Player)
	PlayerProfiles[player] = {
		UserId = player.UserId,
		DisplayName = player.DisplayName,
		TimeSeconds = STARTER_TIME_SECONDS,
		LastDailyClaimISO = nil,
	}
	sendTime(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerProfiles[player] = nil
end)

return TimeService


