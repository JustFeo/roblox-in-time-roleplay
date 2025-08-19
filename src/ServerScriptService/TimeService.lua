--!strict

-- Server-authoritative time currency system as a ModuleScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
	RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
	RequestPurchase = RemotesFolder:WaitForChild("RequestPurchase") :: RemoteEvent,
	SubmitPromoCode = RemotesFolder:WaitForChild("SubmitPromoCode") :: RemoteEvent,
	TimeChanged = RemotesFolder:WaitForChild("TimeChanged") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
	HudState = RemotesFolder:FindFirstChild("HudState") or Instance.new("RemoteEvent", RemotesFolder),
	GetProfile = RemotesFolder:WaitForChild("GetProfile") :: RemoteFunction,
}
Remotes.HudState.Name = "HudState"

local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local RateLimiter = require(script.Parent:WaitForChild("RateLimiter"))

local PlayerProfiles: {[Player]: Types.PlayerTimeProfile} = {}
local playerRate = RateLimiter.new(12, 3)

local STARTER_TIME_SECONDS = 15 * 60 -- 15 minutes to visibly verify changes
local MIN_TICK = 1
local WANTED_DURATION = 120

local function fireHud(player: Player)
	local profile = PlayerProfiles[player]
	if not profile then return end
	local hud = {
		banked = profile.BankedSeconds or 0,
		wanted = (profile.WantedEndClock or 0) > os.clock(),
	}
	Remotes.HudState:FireClient(player, hud)
end

local function sendTime(player: Player)
	local profile = PlayerProfiles[player]
	if profile then
		Remotes.TimeChanged:FireClient(player, profile.TimeSeconds)
		fireHud(player)
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

-- Banking
local function depositTime(player: Player, seconds: number): boolean
	if not trySpendTime(player, seconds) then return false end
	local profile = PlayerProfiles[player]
	if not profile then return false end
	profile.BankedSeconds = (profile.BankedSeconds or 0) + seconds
	Remotes.Notify:FireClient(player, string.format("Deposited %ds", seconds))
	sendTime(player)
	return true
end

local function withdrawTime(player: Player, seconds: number): boolean
	local profile = PlayerProfiles[player]
	if not profile then return false end
	local banked = profile.BankedSeconds or 0
	if banked < seconds then
		Remotes.Notify:FireClient(player, "Not enough in bank")
		return false
	end
	profile.BankedSeconds = banked - seconds
	profile.TimeSeconds += seconds
	sendTime(player)
	return true
end

-- Public API
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

function TimeService.deposit(player: Player, seconds: number): boolean
	return depositTime(player, seconds)
end

function TimeService.withdraw(player: Player, seconds: number): boolean
	return withdrawTime(player, seconds)
end

-- Expose GetProfile RemoteFunction
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

-- Passive countdown loop
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
		BankedSeconds = 0,
		LastDailyClaimISO = nil,
		WantedEndClock = nil,
	}
	sendTime(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerProfiles[player] = nil
end)

return TimeService


