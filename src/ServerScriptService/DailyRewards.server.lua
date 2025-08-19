--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	SubmitPromoCode = RemotesFolder:WaitForChild("SubmitPromoCode") :: RemoteEvent,
	RequestDailyClaim = RemotesFolder:WaitForChild("RequestDailyClaim") :: RemoteEvent,
	RequestSpin = RemotesFolder:WaitForChild("RequestSpin") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}
local TimeService = require(script.Parent:WaitForChild("TimeService"))

local function ymd(dt: DateTime)
	local u = dt:ToUniversalTime()
	return u.Year, u.Month, u.Day
end

local function isNewDay(lastIso: string?): boolean
	if not lastIso then return true end
	local last = DateTime.fromIsoDate(lastIso)
	local now = DateTime.now()
	local ly, lm, ld = ymd(last)
	local ny, nm, nd = ymd(now)
	return ly ~= ny or lm ~= nm or ld ~= nd
end

Remotes.SubmitPromoCode.OnServerEvent:Connect(function(player: Player, code: string)
	code = string.lower(code or "")
	if code == "welcome" then
		TimeService.addTime(player, 120, "Promo: WELCOME")
	elseif code == "grind" then
		TimeService.addTime(player, 300, "Promo: GRIND")
	else
		Remotes.Notify:FireClient(player, "Invalid code")
	end
end)

Players.PlayerAdded:Connect(function(player) end)

Remotes.RequestDailyClaim.OnServerEvent:Connect(function(player: Player)
	local profile = TimeService.getProfile(player)
	if not profile then return end
	if isNewDay(profile.LastDailyClaimISO) then
		TimeService.addTime(player, 240, "Daily Login")
		profile.LastDailyClaimISO = DateTime.now():ToIsoDate()
	else
		Remotes.Notify:FireClient(player, "Already claimed today")
	end
end)

local SPIN_REWARDS = { 60, 90, 120, 180, 240, 300 }
Remotes.RequestSpin.OnServerEvent:Connect(function(player: Player)
	local reward = SPIN_REWARDS[math.random(1, #SPIN_REWARDS)]
	TimeService.addTime(player, reward, "Spin Wheel")
end)


