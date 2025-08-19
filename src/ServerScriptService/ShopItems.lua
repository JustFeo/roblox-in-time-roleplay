--!strict

local ShopItems = {}

export type ShopItem = {
	Id: string,
	Name: string,
	CostSeconds: number,
	Grant: (player: Player) -> (),
}

local function grantSpeedBoost(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local original = humanoid.WalkSpeed
	humanoid.WalkSpeed = original + 8
	local tag = Instance.new("BoolValue")
	tag.Name = "SpeedBoostActive"
	tag.Parent = humanoid
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
	task.delay(120, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = original
		end
		if tag then tag:Destroy() end
	end)
end

ShopItems.Items = {
	{
		Id = "speed_boost",
		Name = "Speed Boost (2m)",
		CostSeconds = 60,
		Grant = grantSpeedBoost,
	},
}

function ShopItems.get(id: string): ShopItem?
	for _, item in ipairs(ShopItems.Items) do
		if item.Id == id then return item end
	end
	return nil
end

return ShopItems


