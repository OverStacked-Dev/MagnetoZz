-- MagnetoZz modular chunk: 01_bootstrap.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
HttpService = game:GetService("HttpService")

if not math.clamp then
    function math.clamp(value, minValue, maxValue)
        return math.max(minValue, math.min(maxValue, value))
    end
end

player = Players.LocalPlayer
playerGui = player:WaitForChild("PlayerGui")
chunksFolder = workspace:WaitForChild("Chunks")

THEME = {
    accent = Color3.fromRGB(72, 100, 255),
    shell = Color3.fromRGB(21, 24, 34),
    sidebar = Color3.fromRGB(35, 37, 46),
    content = Color3.fromRGB(70, 78, 104),
    panel = Color3.fromRGB(37, 39, 48),
    panelAlt = Color3.fromRGB(24, 25, 32),
    text = Color3.fromRGB(245, 246, 255),
    muted = Color3.fromRGB(188, 194, 214),
    white = Color3.fromRGB(255, 255, 255),
    success = Color3.fromRGB(82, 195, 126),
    danger = Color3.fromRGB(224, 72, 72),
    border = Color3.fromRGB(16, 17, 21),
    outline = Color3.fromRGB(111, 119, 146),
}

CONFIG = {
    ignore = { "Baseplate", "SpawnLocation" },
    radius = 500,
    labelDistance = 6,
    updateInterval = 0.03,
    targetRefreshInterval = 0.35,
    lineThickness = 0.08,
    screenLineThickness = 1.5,
    lineOffset = Vector3.new(0, 0, 2),
    maxVisible = 60,
    closestPerName = true,
    showLabels = true,
    defaultColor = Color3.fromRGB(255, 255, 255),
    partColors = {
        OreNode = Color3.fromRGB(0, 200, 255),
        Crystal = Color3.fromRGB(180, 0, 255),
    },
    partThickness = {},
}

GUI_SETTINGS = {
    accentColor = THEME.accent,
    titleTextSize = 26,
    bodyTextSize = 12,
    buttonTextSize = 16,
    animationsEnabled = true,
    toggleKey = Enum.KeyCode.RightShift,
    espToggleKey = Enum.KeyCode.RightControl,
}

VERSION_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/version.json"
SUPABASE_URL = "https://xvdrhzgfjjsmosjlwtwr.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2ZHJoemdmampzbW9zamx3dHdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MTI4NzksImV4cCI6MjA5MjE4ODg3OX0.NuJXJsJ_fAgaOKD_l-ZSwlIIAVDPJiZhPbIDRQ1rWas"
APP_VERSION = "v1.0.0"
FINAL_SIZE = UDim2.new(0, 800, 0, 456)
FINAL_POSITION = UDim2.new(0.5, 0, 0.5, 0)

espEnabled = false
trackerWipEnabled = false
destroyed = false
currentPage = "esp"
trackedParts = {}
activeEntries = {}
connections = {}
heartbeatAccumulator = 0
targetRefreshAccumulator = 999
pageButtons = {}
pages = {}
dragging = false
dragStart = nil
startPos = nil
sectionHeaders = {}
bodyTextLabels = {}
titleTextLabels = {}
buttonTextLabels = {}
inputTextBoxes = {}
updatePageButtons = nil
guiVisible = true
guiOriginalTransparency = {}
USE_DRAWING = type(Drawing) == "table" and type(Drawing.new) == "function"

function trim(text)
    return (text or ""):match("^%s*(.-)%s*$")
end

function requestTargetRefresh()
    targetRefreshAccumulator = CONFIG.targetRefreshInterval
end

function runAsync(callback)
    if task and type(task.spawn) == "function" then
        return task.spawn(callback)
    end

    local thread = coroutine.create(callback)
    local ok, err = coroutine.resume(thread)
    if not ok then
        error(err)
    end
    return thread
end

function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

function tween(instance, info, properties)
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

function safeTween(instance, info, properties)
    if GUI_SETTINGS.animationsEnabled then
        return tween(instance, info, properties)
    end

    for property, value in pairs(properties) do
        instance[property] = value
    end

    return nil
end

function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = instance
    return corner
end

function addStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or THEME.border
    stroke.Thickness = thickness or 2
    stroke.Parent = instance
    return stroke
end

function registerTitleText(instance)
    table.insert(titleTextLabels, instance)
    return instance
end

function registerBodyText(instance)
    table.insert(bodyTextLabels, instance)
    return instance
end

function registerButtonText(instance)
    table.insert(buttonTextLabels, instance)
    return instance
end

function animateValue(instance, property, value)
    if GUI_SETTINGS.animationsEnabled then
        tween(instance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { [property] = value })
    else
        instance[property] = value
    end
end

function enableButtonMotion(button, hoverScale, pressScale)
    local scale = Instance.new("UIScale")
    scale.Name = "MotionScale"
    scale.Scale = 1
    scale.Parent = button

    local hovering = false
    local pressed = false
    hoverScale = hoverScale or 1.035
    pressScale = pressScale or 0.96

    local function updateScale()
        local target = 1
        if pressed then
            target = pressScale
        elseif hovering then
            target = hoverScale
        end
        animateValue(scale, "Scale", target)
    end

    connect(button.MouseEnter, function()
        hovering = true
        updateScale()
    end)

    connect(button.MouseLeave, function()
        hovering = false
        pressed = false
        updateScale()
    end)

    if button:IsA("GuiButton") then
        connect(button.MouseButton1Down, function()
            pressed = true
            updateScale()
        end)

        connect(button.MouseButton1Up, function()
            pressed = false
            updateScale()
        end)
    end
end

function colorFromHex(hex)
    hex = trim(hex):gsub("#", ""):upper()
    if #hex ~= 6 then
        return nil
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return nil
    end
    return Color3.fromRGB(r, g, b)
end

function colorToHex(color)
    return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

function keyCodeFromText(text)
    text = trim(text):gsub("%s+", "")
    if text == "" then
        return nil
    end

    local lowered = text:lower()
    for _, keyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
        if keyCode.Name:lower() == lowered then
            return keyCode
        end
    end

    return nil
end

function fetchVersion()
    local ok, raw = pcall(function()
        return game:HttpGet(VERSION_URL)
    end)

    if not ok or type(raw) ~= "string" then
        return
    end

    local decodeOk, payload = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if decodeOk and typeof(payload) == "table" and typeof(payload.version) == "string" then
        local version = payload.version
        if version:sub(1, 1):lower() ~= "v" then
            version = "v" .. version
        end
        APP_VERSION = version
    end
end

function isIgnored(partName)
    return table.find(CONFIG.ignore, partName) ~= nil
end

function addToIgnore(partName)
    partName = trim(partName)
    if partName == "" or isIgnored(partName) then
        return false
    end
    table.insert(CONFIG.ignore, partName)
    requestTargetRefresh()
    return true
end

function removeFromIgnore(partName)
    local index = table.find(CONFIG.ignore, partName)
    if not index then
        return false
    end
    table.remove(CONFIG.ignore, index)
    requestTargetRefresh()
    return true
end

function getColor(partName)
    return CONFIG.partColors[partName] or CONFIG.defaultColor
end

function getTracerThickness(partName)
    local thickness = tonumber(CONFIG.partThickness and CONFIG.partThickness[partName]) or CONFIG.screenLineThickness
    return math.clamp(thickness, 0.5, 12)
end

function getWorldTracerThickness(partName)
    local screenThickness = getTracerThickness(partName)
    local scale = CONFIG.lineThickness / CONFIG.screenLineThickness
    return math.clamp(screenThickness * scale, 0.02, 1)
end

function createLinePart()
    local line = Instance.new("Part")
    line.Name = "MagnetoLine"
    line.Anchored = true
    line.CanCollide = false
    line.CanTouch = false
    line.CanQuery = false
    line.CastShadow = false
    line.Transparency = 1
    line.Material = Enum.Material.SmoothPlastic
    line.Size = Vector3.new(CONFIG.lineThickness, CONFIG.lineThickness, 1)
    line.Parent = workspace
    return line
end

function createDrawingLine()
    local ok, line = pcall(function()
        return Drawing.new("Line")
    end)
    if not ok or not line then
        return nil
    end

    line.Visible = false
    line.Thickness = CONFIG.screenLineThickness
    line.Transparency = 1
    line.Color = CONFIG.defaultColor
    return line
end

function createDrawingText(text, color)
    local ok, drawingText = pcall(function()
        return Drawing.new("Text")
    end)
    if not ok or not drawingText then
        return nil
    end

    drawingText.Visible = false
    drawingText.Text = text
    drawingText.Color = color
    drawingText.Size = 13
    drawingText.Center = true
    drawingText.Outline = true
    pcall(function()
        drawingText.Font = 2
    end)
    return drawingText
end

function createLabelAnchor()
    local anchor = Instance.new("Part")
    anchor.Name = "MagnetoAnchor"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.CastShadow = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Parent = workspace
    return anchor
end

function createBillboard(anchor, text, color, parent)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 24)
    billboard.StudsOffset = Vector3.new(0, 0.85, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Adornee = anchor
    billboard.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    addStroke(label, Color3.fromRGB(10, 10, 10), 1)
    return billboard, label
end
