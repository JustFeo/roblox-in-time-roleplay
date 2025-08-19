--!strict

-- Simple time shop: items purchased with time; grants a tool or effect.

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
	RequestPurchase = RemotesFolder:WaitForChild("RequestPurchase") :: RemoteEvent,
	Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
}
local TimeService = require(script.Parent:WaitForChild("TimeService"))

type ShopItem = {
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
	humanoid.WalkSpeed = original + 6
	Remotes.Notify:FireClient(player, "+Speed for 120s")
	task.delay(120, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = original
		end
	end)
end

local items: {ShopItem} = {
	{
		Id = "speed_boost",
		Name = "Speed Boost (2m)",
		CostSeconds = 60,
		Grant = grantSpeedBoost,
	},
}

local function getItem(id: string): ShopItem?
	for _, i in ipairs(items) do
		if i.Id == id then return i end
	end
	return nil
end

Remotes.RequestPurchase.OnServerEvent:Connect(function(player: Player, itemId: string)
	local item = getItem(itemId)
	if not item then
		Remotes.Notify:FireClient(player, "Item not found")
		return
	end
	if not TimeService.trySpendTime(player, item.CostSeconds) then
		return
	end
	item.Grant(player)
	Remotes.Notify:FireClient(player, "Purchased: " .. item.Name)
end)

return {}


