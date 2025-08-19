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
local ShopItems = require(script.Parent:WaitForChild("ShopItems"))

-- Use shared ShopItems registry

type ShopItem = ShopItems.ShopItem

Remotes.RequestPurchase.OnServerEvent:Connect(function(player: Player, itemId: string)
	local item = ShopItems.get(itemId)
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


