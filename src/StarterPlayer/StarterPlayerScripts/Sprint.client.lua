--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local BASE_SPEED = 22
local SPRINT_SPEED = 32

local function applyBaseSpeed()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = BASE_SPEED
	end
end

player.CharacterAdded:Connect(function()
	applyBaseSpeed()
end)

applyBaseSpeed()

local sprinting = false

local function setSprint(active: boolean)
	sprinting = active
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = active and SPRINT_SPEED or BASE_SPEED
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		setSprint(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		setSprint(false)
	end
end)


