local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local groundDistance = 8
local dragging, dragInput, dragStart, startPos
local farmEnabled = false
local globalTarget = nil

-- Fungsi cari musuh terdekat
local function getNearest()
    local nearest, dist = nil, 99999
    for _,v in pairs(game.Workspace.BossFolder:GetChildren()) do
        if v:FindFirstChild("Head") then
            local m = (Player.Character.Head.Position - v.Head.Position).magnitude
            if m < dist then
                dist = m
                nearest = v
            end
        end
    end
    for _,v in pairs(game.Workspace.enemies:GetChildren()) do
        if v:FindFirstChild("Head") then
            local m = (Player.Character.Head.Position - v.Head.Position).magnitude
            if m < dist then
                dist = m
                nearest = v
            end
        end
    end
    return nearest
end

-- Notif
local function notif(teks)
    game.StarterGui:SetCore("SendNotification", {
        Title = "AutoFarm",
        Text = teks,
        Duration = 3
    })
end

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 140, 0, 50)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, 0, 1, 0)
button.Text = "Auto: OFF"
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)

button.MouseButton1Click:Connect(function()
    farmEnabled = not farmEnabled
    button.Text = "Auto: " .. (farmEnabled and "ON" or "OFF")
    notif("Auto Farm " .. (farmEnabled and "Aktif" or "Nonaktif"))
end)

-- Auto lock target
RunService.RenderStepped:Connect(function()
    if farmEnabled then
        local target = getNearest()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.Position)
            Player.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, groundDistance, 9)
            globalTarget = target
        end
    end
end)

-- Anti sliding
spawn(function()
    while true do
        task.wait()
        if farmEnabled then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Torso") then
                char.HumanoidRootPart.Velocity = Vector3.zero
                char.Torso.Velocity = Vector3.zero
            end
        end
    end
end)

-- Auto nembak
spawn(function()
    while true do
        task.wait()
        if farmEnabled and globalTarget and globalTarget:FindFirstChild("Head") and Player.Character:FindFirstChildOfClass("Tool") then
            local tool = Player.Character:FindFirstChildOfClass("Tool")
            game.ReplicatedStorage.Gun:FireServer({
                ["Normal"] = Vector3.zero,
                ["Direction"] = globalTarget.Head.Position,
                ["Name"] = tool.Name,
                ["Hit"] = globalTarget.Head,
                ["Origin"] = globalTarget.Head.Position,
                ["Pos"] = globalTarget.Head.Position,
            })
        end
    end
end)
