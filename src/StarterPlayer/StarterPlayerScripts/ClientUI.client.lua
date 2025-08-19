--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
    RequestMissionStart = RemotesFolder:WaitForChild("RequestMissionStart") :: RemoteEvent,
    RequestMissionComplete = RemotesFolder:WaitForChild("RequestMissionComplete") :: RemoteEvent,
    RequestPurchase = RemotesFolder:WaitForChild("RequestPurchase") :: RemoteEvent,
    SubmitPromoCode = RemotesFolder:WaitForChild("SubmitPromoCode") :: RemoteEvent,
    RequestDailyClaim = RemotesFolder:WaitForChild("RequestDailyClaim") :: RemoteEvent,
    RequestSpin = RemotesFolder:WaitForChild("RequestSpin") :: RemoteEvent,
    TimeChanged = RemotesFolder:WaitForChild("TimeChanged") :: RemoteEvent,
    Notify = RemotesFolder:WaitForChild("Notify") :: RemoteEvent,
    GetProfile = RemotesFolder:WaitForChild("GetProfile") :: RemoteFunction,
}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "HUD"
screen.ResetOnSpawn = false
screen.Parent = playerGui

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.AnchorPoint = Vector2.new(0,0)
timeLabel.Position = UDim2.fromScale(0.02, 0.03)
timeLabel.Size = UDim2.fromOffset(280, 48)
timeLabel.BackgroundTransparency = 0.2
timeLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
timeLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextScaled = true
timeLabel.Text = "--:--:--"
timeLabel.Parent = screen

local notifyFrame = Instance.new("TextLabel")
notifyFrame.Name = "Notify"
notifyFrame.AnchorPoint = Vector2.new(0.5, 0)
notifyFrame.Position = UDim2.fromScale(0.5, 0.04)
notifyFrame.Size = UDim2.fromOffset(640, 36)
notifyFrame.BackgroundTransparency = 0.25
notifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
notifyFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyFrame.Font = Enum.Font.Gotham
notifyFrame.TextScaled = true
notifyFrame.Text = ""
notifyFrame.Parent = screen

local missionFrame = Instance.new("Frame")
missionFrame.Name = "Missions"
missionFrame.AnchorPoint = Vector2.new(1, 0)
missionFrame.Position = UDim2.fromScale(0.98, 0.15)
missionFrame.Size = UDim2.fromOffset(320, 220)
missionFrame.BackgroundTransparency = 0.2
missionFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
missionFrame.Parent = screen

local missionTitle = Instance.new("TextLabel")
missionTitle.Size = UDim2.new(1, 0, 0, 28)
missionTitle.BackgroundTransparency = 1
missionTitle.Text = "Missions"
missionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
missionTitle.Font = Enum.Font.GothamBold
missionTitle.TextScaled = true
missionTitle.Parent = missionFrame

local function formatSeconds(s: number): string
    local hours = math.floor(s / 3600)
    local minutes = math.floor((s % 3600) / 60)
    local seconds = math.floor(s % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function updateTimeLabel(seconds: number)
    timeLabel.Text = formatSeconds(seconds)
end

Remotes.TimeChanged.OnClientEvent:Connect(updateTimeLabel)

Remotes.Notify.OnClientEvent:Connect(function(message: string)
    notifyFrame.Text = message
    task.delay(2.5, function()
        if notifyFrame and notifyFrame.Parent then
            notifyFrame.Text = ""
        end
    end)
end)

-- Simple mission buttons
local function createButton(text: string, y: number, onClick: () -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Text = text
    btn.Parent = missionFrame
    btn.MouseButton1Click:Connect(onClick)
end

createButton("Start Courier Run", 36, function()
    Remotes.RequestMissionStart:FireServer("courier_1")
end)

createButton("Complete Courier Run", 72, function()
    Remotes.RequestMissionComplete:FireServer("courier_1")
end)

createButton("Street Cleaner", 108, function()
    Remotes.RequestMissionStart:FireServer("cleaner_1")
end)

createButton("Redeem WELCOME code", 144, function()
    Remotes.SubmitPromoCode:FireServer("WELCOME")
end)

createButton("Claim Daily", 180, function()
    Remotes.RequestDailyClaim:FireServer()
end)

-- Spin wheel quick key: press 2
local UserInputService = game:GetService("UserInputService")

-- Shop UI shortcut keys
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.One then
        Remotes.RequestPurchase:FireServer("speed_boost")
    elseif input.KeyCode == Enum.KeyCode.Two then
        Remotes.RequestSpin:FireServer()
    end
end)

-- Fetch initial profile
local profile = Remotes.GetProfile:InvokeServer()
if profile ~= nil and typeof(profile) == "table" and profile.TimeSeconds ~= nil then
    updateTimeLabel(profile.TimeSeconds)
end


