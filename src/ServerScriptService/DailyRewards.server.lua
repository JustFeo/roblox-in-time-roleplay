--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	SubmitPromoCode = RemotesFolder:WaitForChild("SubmitPromoCode") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}
local TimeService = require(script.Parent:WaitForChild("TimeService"))

local function isNewDay(lastIso: string?): boolean
	if not lastIso then return true end
	local last = DateTime.fromIsoDate(lastIso)
	local now = DateTime.now()
	return last.Date.Year ~= now.Date.Year or last.Date.Day ~= now.Date.Day or last.Date.Month ~= now.Date.Month
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

Players.PlayerAdded:Connect(function(player)
	-- Simple in-memory daily reward (resets per server); production should persist
	local profile = TimeService.getProfile(player)
	if not profile then return end
	if isNewDay(profile.LastDailyClaimISO) then
		TimeService.addTime(player, 180, "Daily Login")
		profile.LastDailyClaimISO = DateTime.now():ToIsoDate()
	end
end)


