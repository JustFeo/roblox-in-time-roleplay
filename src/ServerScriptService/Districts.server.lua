--!strict

-- Districts & toll gates (poor -> rich zone) consuming time

local Workspace = game:GetService("Workspace")

local TimeService = require(script.Parent:WaitForChild("TimeService"))
local WantedService = require(script.Parent:WaitForChild("WantedService"))

local function makeGate(name: string, cframe: CFrame, charge: number)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = Vector3.new(16, 10, 1)
    p.Anchored = true
    p.CFrame = cframe
    p.Color = Color3.fromRGB(80, 80, 120)
    p.Material = Enum.Material.Metal
    p.Parent = Workspace
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(160, 30)
    bb.StudsOffset = Vector3.new(0, 6, 0)
    bb.AlwaysOnTop = true
    bb.Parent = p
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 0.2
    label.BackgroundColor3 = Color3.fromRGB(0,0,0)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = string.format("Toll: %ds", charge)
    label.Parent = bb
    p.Touched:Connect(function(part)
        local model = part:FindFirstAncestorOfClass("Model")
        local player = model and game:GetService("Players"):GetPlayerFromCharacter(model)
        if not player then return end
        if TimeService.trySpendTime(player, charge) then
            -- ok
        else
            -- can't pay => set wanted
            WantedService.setWanted(player, 60)
        end
    end)
    return p
end

-- Create two gates separating blocks
makeGate("TollGate_1", CFrame.new(0, 5, 0), 30)
makeGate("TollGate_2", CFrame.new(120, 5, 120), 60)


