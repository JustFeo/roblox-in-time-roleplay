--!strict

local TimeService = require(script.Parent:WaitForChild("TimeService"))

export type Mission = {
	Id: string,
	Name: string,
	Description: string,
	RewardSeconds: number,
	CooldownSeconds: number?,
}

local MissionCore = {}

MissionCore.missions = {
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

local playerMissionState: {[Player]: {[string]: { LastCompletedAt: number }}} = {}

local function getMissionById(id: string): Mission?
	for _, m in ipairs(MissionCore.missions) do
		if m.Id == id then return m end
	end
	return nil
end

function MissionCore.canComplete(player: Player, missionId: string): (boolean, string?)
	local m = getMissionById(missionId)
	if not m then return false, "Mission not found" end
	local state = playerMissionState[player]
	if not state then return true, nil end
	local ms = state[missionId]
	if ms then
		local since = os.clock() - ms.LastCompletedAt
		local cd = m.CooldownSeconds or 0
		if since < cd then
			return false, string.format("On cooldown: %ds", math.ceil(cd - since))
		end
	end
	return true, nil
end

function MissionCore.markCompleted(player: Player, missionId: string)
	playerMissionState[player] = playerMissionState[player] or {}
	playerMissionState[player][missionId] = { LastCompletedAt = os.clock() }
end

function MissionCore.complete(player: Player, missionId: string): boolean
	local m = getMissionById(missionId)
	if not m then return false end
	local ok, reason = MissionCore.canComplete(player, missionId)
	if not ok then return false end
	MissionCore.markCompleted(player, missionId)
	TimeService.addTime(player, m.RewardSeconds, m.Name)
	return true
end

function MissionCore.cleanup(player: Player)
	playerMissionState[player] = nil
end

return MissionCore


