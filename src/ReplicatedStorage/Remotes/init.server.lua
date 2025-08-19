--!strict

-- Server creates all RemoteEvents/Functions under ReplicatedStorage/Remotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local container = Instance.new("Folder")
container.Name = "Remotes"
container.Parent = ReplicatedStorage

local function newEvent(name: string)
	local e = Instance.new("RemoteEvent")
	e.Name = name
	e.Parent = container
	return e
end

local function newFunc(name: string)
	local f = Instance.new("RemoteFunction")
	f.Name = name
	f.Parent = container
	return f
end

newEvent("RequestMissionStart")
newEvent("RequestMissionComplete")
newEvent("RequestPurchase")
newEvent("SubmitPromoCode")

newEvent("TimeChanged")
newEvent("Notify")

newFunc("GetProfile")


