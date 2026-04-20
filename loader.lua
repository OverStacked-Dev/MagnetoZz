local MAIN_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/main.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

if not math.clamp then
    function math.clamp(value, minValue, maxValue)
        return math.max(minValue, math.min(maxValue, value))
    end
end

local waitFn = (task and task.wait) or wait
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("MagnetoZzLoaderGui")
if existingGui then
    existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MagnetoZzLoaderGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 340, 0, 118)
frame.BackgroundColor3 = Color3.fromRGB(21, 24, 34)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local scale = Instance.new("UIScale")
scale.Scale = 0.78
scale.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(72, 100, 255)
stroke.Thickness = 2
stroke.Transparency = 1
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -32, 0, 34)
title.Position = UDim2.new(0, 16, 0, 14)
title.BackgroundTransparency = 1
title.Text = "MagnetoZz"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextTransparency = 1
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -32, 0, 22)
status.Position = UDim2.new(0, 16, 0, 48)
status.BackgroundTransparency = 1
status.Text = "Started"
status.TextColor3 = Color3.fromRGB(188, 194, 214)
status.TextTransparency = 1
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(1, -32, 0, 10)
barBack.Position = UDim2.new(0, 16, 0, 84)
barBack.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
barBack.BackgroundTransparency = 1
barBack.BorderSizePixel = 0
barBack.Parent = frame

local barBackCorner = Instance.new("UICorner")
barBackCorner.CornerRadius = UDim.new(0, 10)
barBackCorner.Parent = barBack

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(72, 100, 255)
barFill.BackgroundTransparency = 1
barFill.BorderSizePixel = 0
barFill.Parent = barBack

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 10)
barFillCorner.Parent = barFill

local function tween(instance, info, properties)
    local tweenObject = TweenService:Create(instance, info, properties)
    tweenObject:Play()
    return tweenObject
end

local function showLoader()
    tween(scale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    tween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 })
    tween(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0 })
    tween(title, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
    tween(status, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
    tween(barBack, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.25 })
    tween(barFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
end

local function hideLoader()
    local scaleTween = tween(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.78 })
    tween(frame, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    tween(stroke, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 })
    tween(title, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
    tween(status, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
    tween(barBack, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    tween(barFill, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    scaleTween.Completed:Wait()
    screenGui:Destroy()
end

local loaderApi = {}

function loaderApi.SetProgress(loaded, total)
    loaded = tonumber(loaded) or 0
    total = tonumber(total) or 0

    if total <= 0 then
        status.Text = "Started"
        tween(barFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 1, 0) })
        return
    end

    local progress = math.clamp(loaded / total, 0, 1)
    status.Text = "Loaded " .. tostring(loaded) .. "/" .. tostring(total) .. " modules"
    tween(barFill, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(progress, 0, 1, 0) })
end

function loaderApi.Finish()
    status.Text = "Finished"
    tween(barFill, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
    waitFn(0.45)
    hideLoader()
end

function loaderApi.Fail()
    status.Text = "Failed"
    barFill.BackgroundColor3 = Color3.fromRGB(224, 72, 72)
end

local rootEnv = (getgenv and getgenv()) or _G
rootEnv.MagnetoZzLoader = loaderApi
shared.MagnetoZzLoader = loaderApi

showLoader()
loaderApi.SetProgress(0, 0)

local okFetch, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not okFetch or type(source) ~= "string" then
    loaderApi.Fail()
    error("MagnetoZz loader failed to fetch main.lua: " .. tostring(source))
end

local mainFn, compileErr = loadstring(source)
if not mainFn then
    loaderApi.Fail()
    error("MagnetoZz loader failed to compile main.lua: " .. tostring(compileErr))
end

local okRun, runErr = pcall(mainFn)
if not okRun then
    loaderApi.Fail()
    error("MagnetoZz loader runtime error: " .. tostring(runErr))
end
