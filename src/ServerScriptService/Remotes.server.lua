--!strict

-- Create RemoteEvents and RemoteFunctions under ReplicatedStorage/Remotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local container = ReplicatedStorage:FindFirstChild("Remotes")
if not container then
	container = Instance.new("Folder")
	container.Name = "Remotes"
	container.Parent = ReplicatedStorage
end

local function ensureEvent(name: string)
	local e = container:FindFirstChild(name)
	if not e then
		e = Instance.new("RemoteEvent")
		e.Name = name
		e.Parent = container
	end
	return e :: RemoteEvent
end

local function ensureFunc(name: string)
	local f = container:FindFirstChild(name)
	if not f then
		f = Instance.new("RemoteFunction")
		f.Name = name
		f.Parent = container
	end
	return f :: RemoteFunction
end

ensureEvent("RequestMissionStart")
ensureEvent("RequestMissionComplete")
ensureEvent("RequestPurchase")
ensureEvent("SubmitPromoCode")
ensureEvent("RequestDailyClaim")
ensureEvent("RequestSpin")
ensureEvent("TimeChanged")
ensureEvent("Notify")
ensureFunc("GetProfile")


