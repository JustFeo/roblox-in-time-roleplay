--!strict

-- Simple persistence for player time using DataStoreService

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local TimeService = require(script.Parent:WaitForChild("TimeService"))

local STORE_NAME = "InTimeRoleplay_PlayerTime_v1"
local store = DataStoreService:GetDataStore(STORE_NAME)

local function loadPlayer(player: Player)
	local key = "p_" .. player.UserId
	local ok, data = pcall(function()
		return store:GetAsync(key)
	end)
	if ok and data and type(data) == "table" and type(data.t) == "number" then
		-- Set profile time to stored value, clamp to at least 60s
		local profile = TimeService.getProfile(player)
		if profile then
			profile.TimeSeconds = math.max(60, math.floor(data.t))
		end
	end
end

local function savePlayer(player: Player)
	local profile = TimeService.getProfile(player)
	if not profile then return end
	local key = "p_" .. player.UserId
	local data = { t = profile.TimeSeconds, last = profile.LastDailyClaimISO }
	pcall(function()
		store:SetAsync(key, data)
	end)
end

Players.PlayerAdded:Connect(function(player)
	loadPlayer(player)
	-- save a few seconds later to ensure initial sync
	task.delay(5, function()
		savePlayer(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)


