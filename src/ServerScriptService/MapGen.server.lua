--!strict

-- Minimal blocky city block map generator for MVP

local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local base = Instance.new("Part")
base.Anchored = true
base.Size = Vector3.new(300, 2, 300)
base.Position = Vector3.new(0, 0, 0)
base.Name = "Baseplate"
base.Material = Enum.Material.Concrete
base.Color = Color3.fromRGB(70, 70, 70)
base.Parent = Workspace

local function makeBuilding(pos: Vector3, size: Vector3, color: Color3)
    local p = Instance.new("Part")
    p.Anchored = true
    p.Size = size
    p.Position = pos + Vector3.new(0, size.Y/2, 0)
    p.Material = Enum.Material.SmoothPlastic
    p.Color = color
    p.Name = "Building"
    p.Parent = Workspace
end

for x = -120, 120, 60 do
    for z = -120, 120, 60 do
        if math.abs(x) > 20 or math.abs(z) > 20 then
            makeBuilding(Vector3.new(x, 1, z), Vector3.new(30, math.random(20,50), 30), Color3.fromRGB(180, 180, 200))
        end
    end
end

-- Simple mission markers (invisible trigger parts)
local function makeTrigger(name: string, pos: Vector3)
    local t = Instance.new("Part")
    t.Anchored = true
    t.Transparency = 1
    t.CanCollide = false
    t.Size = Vector3.new(6, 6, 6)
    t.Position = pos + Vector3.new(0, 3, 0)
    t.Name = name
    t.Parent = Workspace
    return t
end

local startA = makeTrigger("CourierStart", Vector3.new(-40, 1, 0))
local endB = makeTrigger("CourierEnd", Vector3.new(60, 1, 60))

-- Optional: visualize markers
local function markerBillboard(parent: BasePart, text: string)
    local b = Instance.new("BillboardGui")
    b.Size = UDim2.fromOffset(120, 24)
    b.StudsOffset = Vector3.new(0, 4, 0)
    b.AlwaysOnTop = true
    b.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1,1)
    lbl.BackgroundTransparency = 0.3
    lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Text = text
    lbl.Parent = b
end

markerBillboard(startA, "Courier A")
markerBillboard(endB, "Courier B")


