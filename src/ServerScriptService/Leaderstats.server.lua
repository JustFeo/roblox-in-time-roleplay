--!strict

-- Show remaining time (minutes) on leaderboards

local Players = game:GetService("Players")

local TimeService = require(script.Parent:WaitForChild("TimeService"))

local function ensureLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	local timeMin = leaderstats:FindFirstChild("TimeMin")
	if not timeMin then
		timeMin = Instance.new("IntValue")
		timeMin.Name = "TimeMin"
		timeMin.Parent = leaderstats
	end
	return leaderstats, timeMin :: IntValue
end

local function update(player: Player)
	local profile = TimeService.getProfile(player)
	if not profile then return end
	local _, timeMin = ensureLeaderstats(player)
	timeMin.Value = math.floor(profile.TimeSeconds / 60)
end

Players.PlayerAdded:Connect(function(player)
	ensureLeaderstats(player)
	while player.Parent == Players do
		update(player)
		task.wait(2)
	end
end)


