local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local chunksFolder = workspace:WaitForChild("Chunks")

local THEME = {
    accent = Color3.fromRGB(72, 100, 255),
    shell = Color3.fromRGB(21, 24, 34),
    sidebar = Color3.fromRGB(35, 37, 46),
    content = Color3.fromRGB(83, 87, 99),
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

local CONFIG = {
    ignore = { "Baseplate", "SpawnLocation" },
    radius = 500,
    labelDistance = 6,
    updateInterval = 0.05,
    lineThickness = 0.08,
    lineOffset = Vector3.new(0, 0, 2),
    defaultColor = Color3.fromRGB(255, 255, 255),
    partColors = {
        OreNode = Color3.fromRGB(0, 200, 255),
        Crystal = Color3.fromRGB(180, 0, 255),
    },
}

local GUI_SETTINGS = {
    accentColor = THEME.accent,
    titleTextSize = 26,
    bodyTextSize = 12,
    buttonTextSize = 16,
    animationsEnabled = true,
    toggleKey = Enum.KeyCode.RightShift,
}

local VERSION_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/version.json"
local APP_VERSION = "v1.0.0"
local FINAL_SIZE = UDim2.new(0, 800, 0, 456)
local FINAL_POSITION = UDim2.new(0.5, 0, 0.5, 0)

local espEnabled = false
local destroyed = false
local currentPage = "esp"
local trackedParts = {}
local connections = {}
local heartbeatAccumulator = 0
local pageButtons = {}
local pages = {}
local dragging = false
local dragStart = nil
local startPos = nil
local sectionHeaders = {}
local bodyTextLabels = {}
local titleTextLabels = {}
local buttonTextLabels = {}
local inputTextBoxes = {}
local updatePageButtons
local guiVisible = true

local function trim(text)
    return (text or ""):match("^%s*(.-)%s*$")
end

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function tween(instance, info, properties)
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

local function safeTween(instance, info, properties)
    if GUI_SETTINGS.animationsEnabled then
        return tween(instance, info, properties)
    end

    for property, value in pairs(properties) do
        instance[property] = value
    end

    return nil
end

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = instance
    return corner
end

local function addStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or THEME.border
    stroke.Thickness = thickness or 2
    stroke.Parent = instance
    return stroke
end

local function registerTitleText(instance)
    table.insert(titleTextLabels, instance)
    return instance
end

local function registerBodyText(instance)
    table.insert(bodyTextLabels, instance)
    return instance
end

local function registerButtonText(instance)
    table.insert(buttonTextLabels, instance)
    return instance
end

local function animateValue(instance, property, value)
    if GUI_SETTINGS.animationsEnabled then
        tween(instance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { [property] = value })
    else
        instance[property] = value
    end
end

local function enableButtonMotion(button, hoverScale, pressScale)
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

local function colorFromHex(hex)
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

local function colorToHex(color)
    return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

local function keyCodeFromText(text)
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

local function fetchVersion()
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

local function isIgnored(partName)
    return table.find(CONFIG.ignore, partName) ~= nil
end

local function addToIgnore(partName)
    partName = trim(partName)
    if partName == "" or isIgnored(partName) then
        return false
    end
    table.insert(CONFIG.ignore, partName)
    return true
end

local function removeFromIgnore(partName)
    local index = table.find(CONFIG.ignore, partName)
    if not index then
        return false
    end
    table.remove(CONFIG.ignore, index)
    return true
end

local function getColor(partName)
    return CONFIG.partColors[partName] or CONFIG.defaultColor
end

local function createLinePart()
    local line = Instance.new("Part")
    line.Name = "MagnetoLine"
    line.Anchored = true
    line.CanCollide = false
    line.CanTouch = false
    line.CanQuery = false
    line.CastShadow = false
    line.Transparency = 1
    line.Material = Enum.Material.Neon
    line.Size = Vector3.new(CONFIG.lineThickness, CONFIG.lineThickness, 1)
    line.Parent = workspace
    return line
end

local function createLabelAnchor()
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

local function createBillboard(anchor, text, color, parent)
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MagnetoZzGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local guiScale = Instance.new("UIScale")
guiScale.Scale = 1

local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = FINAL_POSITION
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = THEME.shell
mainFrame.BackgroundTransparency = 0.03
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 18)
local mainStroke = addStroke(mainFrame, THEME.outline, 2)
guiScale.Parent = mainFrame

local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1, 0, 0, 38)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = mainFrame

local introLine = Instance.new("Frame")
introLine.AnchorPoint = Vector2.new(0, 0.5)
introLine.Position = UDim2.new(0.08, 0, 0.5, 0)
introLine.Size = UDim2.new(0, 0, 0, 18)
introLine.BackgroundColor3 = THEME.white
introLine.BorderSizePixel = 0
introLine.Parent = mainFrame

local introTitle = Instance.new("TextLabel")
introTitle.AnchorPoint = Vector2.new(0.5, 0.5)
introTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
introTitle.Size = UDim2.new(0, 210, 0, 28)
introTitle.BackgroundColor3 = THEME.shell
introTitle.BackgroundTransparency = 0
introTitle.Font = Enum.Font.GothamBold
introTitle.Text = "MagnetoZz"
introTitle.TextSize = 26
introTitle.TextColor3 = THEME.white
introTitle.TextTransparency = 1
introTitle.Parent = mainFrame
introTitle.ZIndex = 2
introTitle.TextYAlignment = Enum.TextYAlignment.Center
addCorner(introTitle, 8)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, -180, 0, 12)
sidebar.Size = UDim2.new(0, 165, 1, -24)
sidebar.BackgroundColor3 = THEME.sidebar
sidebar.BorderSizePixel = 0
sidebar.Visible = false
sidebar.Parent = mainFrame
addCorner(sidebar, 18)
addStroke(sidebar, THEME.border, 2)

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(1, 30, 0, 12)
contentFrame.Size = UDim2.new(1, -205, 1, -24)
contentFrame.BackgroundColor3 = THEME.content
contentFrame.BorderSizePixel = 0
contentFrame.Visible = false
contentFrame.Parent = mainFrame
addCorner(contentFrame, 18)
addStroke(contentFrame, THEME.border, 2)

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -18, 0, 34)
sidebarTitle.Position = UDim2.new(0, 9, 0, 8)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "MagnetoZz"
sidebarTitle.TextColor3 = THEME.white
sidebarTitle.TextSize = 22
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
sidebarTitle.Parent = sidebar
registerTitleText(sidebarTitle)

local sidebarAccent = Instance.new("Frame")
sidebarAccent.Position = UDim2.new(0, 9, 0, 44)
sidebarAccent.Size = UDim2.new(1, -18, 0, 4)
sidebarAccent.BackgroundColor3 = THEME.accent
sidebarAccent.BorderSizePixel = 0
sidebarAccent.Parent = sidebar
addCorner(sidebarAccent, 4)

local sidebarVersion = Instance.new("TextLabel")
sidebarVersion.Size = UDim2.new(1, -18, 0, 18)
sidebarVersion.Position = UDim2.new(0, 9, 0, 52)
sidebarVersion.BackgroundTransparency = 1
sidebarVersion.Text = APP_VERSION
sidebarVersion.TextColor3 = THEME.muted
sidebarVersion.TextSize = 12
sidebarVersion.Font = Enum.Font.Gotham
sidebarVersion.TextXAlignment = Enum.TextXAlignment.Left
sidebarVersion.Parent = sidebar
registerBodyText(sidebarVersion)

local buttonHolder = Instance.new("Frame")
buttonHolder.Size = UDim2.new(1, -18, 0, 296)
buttonHolder.Position = UDim2.new(0, 9, 0, 88)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = sidebar

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Padding = UDim.new(0, 12)
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Parent = buttonHolder

local sidebarFooter = Instance.new("TextLabel")
sidebarFooter.Size = UDim2.new(1, -18, 0, 24)
sidebarFooter.AnchorPoint = Vector2.new(0, 1)
sidebarFooter.Position = UDim2.new(0, 9, 1, -12)
sidebarFooter.BackgroundTransparency = 1
sidebarFooter.Text = "gui accent #4864FF"
sidebarFooter.TextColor3 = THEME.muted
sidebarFooter.TextSize = 12
sidebarFooter.Font = Enum.Font.Gotham
sidebarFooter.TextXAlignment = Enum.TextXAlignment.Left
sidebarFooter.Parent = sidebar
registerBodyText(sidebarFooter)

local contentHeader = Instance.new("Frame")
contentHeader.Size = UDim2.new(1, -24, 0, 48)
contentHeader.Position = UDim2.new(0, 12, 0, 12)
contentHeader.BackgroundTransparency = 1
contentHeader.Parent = contentFrame

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(1, -78, 0, 30)
contentTitle.BackgroundTransparency = 1
contentTitle.TextColor3 = THEME.white
contentTitle.TextSize = 26
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader
registerTitleText(contentTitle)

local contentSubtitle = Instance.new("TextLabel")
contentSubtitle.Size = UDim2.new(1, -90, 0, 18)
contentSubtitle.Position = UDim2.new(0, 2, 0, 28)
contentSubtitle.BackgroundTransparency = 1
contentSubtitle.TextColor3 = THEME.muted
contentSubtitle.TextSize = 12
contentSubtitle.Font = Enum.Font.Gotham
contentSubtitle.TextXAlignment = Enum.TextXAlignment.Left
contentSubtitle.Parent = contentHeader
registerBodyText(contentSubtitle)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 42, 0, 42)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -8, 0, 0)
closeBtn.AutoButtonColor = false
closeBtn.BackgroundColor3 = THEME.danger
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = THEME.white
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = contentHeader
addCorner(closeBtn, 12)
addStroke(closeBtn, Color3.fromRGB(160, 25, 25), 2)
registerButtonText(closeBtn)
enableButtonMotion(closeBtn, 1.03, 0.95)

local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -24, 1, -84)
pageHolder.Position = UDim2.new(0, 12, 0, 72)
pageHolder.BackgroundTransparency = 1
pageHolder.Parent = contentFrame

local function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pageHolder
    pages[name] = page
    return page
end

local function makePageButton(id, label, order)
    local button = Instance.new("TextButton")
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 44)
    button.AutoButtonColor = false
    button.BackgroundColor3 = THEME.panelAlt
    button.BorderSizePixel = 0
    button.Text = label
    button.TextColor3 = THEME.white
    button.TextSize = GUI_SETTINGS.buttonTextSize
    button.Font = Enum.Font.GothamBold
    button.Parent = buttonHolder
    addCorner(button, 12)
    addStroke(button, THEME.border, 2)
    registerButtonText(button)
    enableButtonMotion(button, 1.04, 0.95)
    pageButtons[id] = button
    connect(button.MouseEnter, function()
        if currentPage ~= id then
            button.BackgroundColor3 = Color3.fromRGB(44, 46, 56)
        end
    end)
    connect(button.MouseLeave, function()
        if currentPage ~= id then
            button.BackgroundColor3 = THEME.panelAlt
        end
    end)
    return button
end

local function makeSection(parent, title, y, height)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, height)
    section.Position = UDim2.new(0, 0, 0, y)
    section.BackgroundColor3 = THEME.panel
    section.BorderSizePixel = 0
    section.Parent = parent
    addCorner(section, 16)
    addStroke(section, THEME.border, 2)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -24, 0, 22)
    header.Position = UDim2.new(0, 12, 0, 10)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = THEME.white
    header.TextSize = math.max(16, GUI_SETTINGS.bodyTextSize + 4)
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = section
    table.insert(sectionHeaders, header)
    return section
end

local function makeLabel(parent, text, x, y, width)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, width, 0, 18)
    label.Position = UDim2.new(0, x, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = THEME.muted
    label.TextSize = GUI_SETTINGS.bodyTextSize
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    registerBodyText(label)
    return label
end

local function makeInput(parent, placeholder, x, y, width)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, width, 0, 34)
    box.Position = UDim2.new(0, x, 0, y)
    box.BackgroundColor3 = THEME.panelAlt
    box.BorderSizePixel = 0
    box.TextColor3 = THEME.white
    box.Text = ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = THEME.muted
    box.TextSize = GUI_SETTINGS.bodyTextSize + 1
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = parent
    addCorner(box, 10)
    addStroke(box, THEME.border, 2)
    table.insert(inputTextBoxes, box)
    return box
end

local function makeActionButton(parent, text, x, y, width, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, width, 0, 34)
    button.Position = UDim2.new(0, x, 0, y)
    button.AutoButtonColor = false
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = THEME.white
    button.TextSize = math.max(13, GUI_SETTINGS.buttonTextSize - 1)
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    addCorner(button, 10)
    addStroke(button, THEME.border, 2)
    registerButtonText(button)
    enableButtonMotion(button)
    connect(button.MouseEnter, function()
        button.BackgroundTransparency = 0.12
    end)
    connect(button.MouseLeave, function()
        button.BackgroundTransparency = 0
    end)
    return button
end

local function makeStatusLabel(parent, x, y, width)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, width, 0, 18)
    label.Position = UDim2.new(0, x, 0, y)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextColor3 = THEME.muted
    label.TextSize = GUI_SETTINGS.bodyTextSize
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    registerBodyText(label)
    return label
end

local function setStatus(label, text, color)
    label.Text = text
    label.TextColor3 = color or THEME.muted
end

local function setGuiVisible(visible)
    if destroyed or guiVisible == visible then
        return
    end

    guiVisible = visible
    mainFrame.Active = visible
    if visible then
        mainFrame.Visible = true
    end

    local targetScale = visible and 1 or 0.86
    local targetTransparency = visible and 0.03 or 1
    local targetStrokeTransparency = visible and 0 or 1
    local easingDirection = visible and Enum.EasingDirection.In or Enum.EasingDirection.Out

    local scaleTween = safeTween(
        guiScale,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, easingDirection),
        { Scale = targetScale }
    )
    safeTween(
        mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, easingDirection),
        { BackgroundTransparency = targetTransparency }
    )
    safeTween(
        mainStroke,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, easingDirection),
        { Transparency = targetStrokeTransparency }
    )

    if not visible then
        if scaleTween then
            scaleTween.Completed:Wait()
        end
        if not guiVisible then
            mainFrame.Visible = false
        end
    end
end

local espPage = makePage("esp")
local configPage = makePage("config")
local blacklistPage = makePage("blacklist")
local guiPage = makePage("gui")
local profilesPage = makePage("profiles")

local espSection = makeSection(espPage, "Runtime", 0, 126)
local espToggleBtn = makeActionButton(espSection, "ESP OFF", 12, 44, 146, THEME.danger)
local espStatus = makeStatusLabel(espSection, 172, 52, 300)
local espInfo = makeStatusLabel(espSection, 12, 92, 450)
espInfo.Size = UDim2.new(1, -24, 0, 24)
espInfo.TextWrapped = true
espInfo.Text = "Labels stay close to the player and point toward the tracked part."
espInfo.TextColor3 = THEME.white

local themeSection = makeSection(espPage, "Visual Theme", 142, 134)
local lineColorPreview = Instance.new("TextButton")
lineColorPreview.Size = UDim2.new(0, 64, 0, 64)
lineColorPreview.Position = UDim2.new(0, 14, 0, 44)
lineColorPreview.AutoButtonColor = false
lineColorPreview.BackgroundColor3 = CONFIG.defaultColor
lineColorPreview.BorderSizePixel = 0
lineColorPreview.Text = ""
lineColorPreview.Parent = themeSection
addCorner(lineColorPreview, 16)
addStroke(lineColorPreview, THEME.border, 2)
enableButtonMotion(lineColorPreview, 1.04, 0.95)
local accentName = makeStatusLabel(themeSection, 90, 46, 240)
accentName.Text = "Default line color"
accentName.TextColor3 = THEME.white
accentName.TextSize = 16
accentName.Font = Enum.Font.GothamBold
local accentHex = makeStatusLabel(themeSection, 90, 76, 260)
accentHex.Text = "#FFFFFF click square to change"
local accentHint = makeStatusLabel(themeSection, 90, 96, 300)
accentHint.Text = "GUI accent is separate from line color."
accentHint.TextColor3 = THEME.white

local configTop = makeSection(configPage, "Settings", 0, 118)
makeLabel(configTop, "Radius", 18, 42, 80)
local radiusInput = makeInput(configTop, "500", 18, 62, 108)
radiusInput.Text = tostring(CONFIG.radius)
makeLabel(configTop, "Default Color", 148, 42, 100)
local defaultColorInput = makeInput(configTop, "FFFFFF", 148, 62, 108)
defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
makeLabel(configTop, "Label Distance", 278, 42, 110)
local labelDistanceInput = makeInput(configTop, "6", 278, 62, 108)
labelDistanceInput.Text = tostring(CONFIG.labelDistance)
local applyBtn = makeActionButton(configTop, "Apply", 410, 62, 92, THEME.accent)
local applyStatus = makeStatusLabel(configTop, 18, 98, 360)

local partColorSection = makeSection(configPage, "Per Part Colors", 134, 184)
local partColorList = Instance.new("ScrollingFrame")
partColorList.Size = UDim2.new(1, -24, 0, 104)
partColorList.Position = UDim2.new(0, 12, 0, 42)
partColorList.BackgroundColor3 = THEME.panelAlt
partColorList.BorderSizePixel = 0
partColorList.ScrollBarThickness = 4
partColorList.CanvasSize = UDim2.new(0, 0, 0, 0)
partColorList.Parent = partColorSection
addCorner(partColorList, 12)
addStroke(partColorList, THEME.border, 2)
local partColorLayout = Instance.new("UIListLayout")
partColorLayout.Padding = UDim.new(0, 6)
partColorLayout.Parent = partColorList
local addNameInput = makeInput(partColorSection, "Part name", 12, 150, 170)
local addColorInput = makeInput(partColorSection, "HEX", 192, 150, 90)
local addColorBtn = makeActionButton(partColorSection, "Add Color", 292, 150, 102, THEME.success)
local partColorStatus = makeStatusLabel(partColorSection, 12, 166, 390)

local blacklistSection = makeSection(blacklistPage, "Ignored Parts", 0, 320)
local blacklistList = Instance.new("ScrollingFrame")
blacklistList.Size = UDim2.new(1, -24, 0, 194)
blacklistList.Position = UDim2.new(0, 12, 0, 42)
blacklistList.BackgroundColor3 = THEME.panelAlt
blacklistList.BorderSizePixel = 0
blacklistList.ScrollBarThickness = 4
blacklistList.CanvasSize = UDim2.new(0, 0, 0, 0)
blacklistList.Parent = blacklistSection
addCorner(blacklistList, 12)
addStroke(blacklistList, THEME.border, 2)
local blacklistLayout = Instance.new("UIListLayout")
blacklistLayout.Padding = UDim.new(0, 6)
blacklistLayout.Parent = blacklistList
local blacklistInput = makeInput(blacklistSection, "Part to ignore", 12, 246, 220)
local addBlacklistBtn = makeActionButton(blacklistSection, "Add", 242, 246, 86, THEME.success)
local blacklistStatus = makeStatusLabel(blacklistSection, 12, 286, 360)

local guiMainSection = makeSection(guiPage, "Gui Settings", 0, 190)
makeLabel(guiMainSection, "GUI Accent", 12, 42, 100)
local guiAccentInput = makeInput(guiMainSection, "4864FF", 12, 62, 110)
guiAccentInput.Text = colorToHex(GUI_SETTINGS.accentColor)
makeLabel(guiMainSection, "Title Size", 142, 42, 100)
local guiTitleSizeInput = makeInput(guiMainSection, "26", 142, 62, 92)
guiTitleSizeInput.Text = tostring(GUI_SETTINGS.titleTextSize)
makeLabel(guiMainSection, "Body Size", 252, 42, 100)
local guiBodySizeInput = makeInput(guiMainSection, "12", 252, 62, 92)
guiBodySizeInput.Text = tostring(GUI_SETTINGS.bodyTextSize)
local guiAnimationToggle = makeActionButton(guiMainSection, "Animations: ON", 362, 62, 140, THEME.success)
makeLabel(guiMainSection, "Toggle Key", 12, 102, 100)
local guiKeybindInput = makeInput(guiMainSection, "RightShift", 12, 122, 130)
guiKeybindInput.Text = GUI_SETTINGS.toggleKey.Name
local guiApplyBtn = makeActionButton(guiMainSection, "Apply GUI", 12, 112, 120, THEME.accent)
guiApplyBtn.Position = UDim2.new(0, 158, 0, 122)
local guiResetBtn = makeActionButton(guiMainSection, "Reset GUI", 290, 122, 120, THEME.panelAlt)
local guiStatus = makeStatusLabel(guiMainSection, 12, 166, 470)

local guiExtraSection = makeSection(guiPage, "What Changes", 206, 96)
local guiInfo = makeStatusLabel(guiExtraSection, 12, 36, 480)
guiInfo.Size = UDim2.new(1, -24, 0, 40)
guiInfo.TextWrapped = true
guiInfo.Text = "Accent color affects the menu highlight only. Default line color is managed separately from the ESP page."
guiInfo.TextColor3 = THEME.white

local profilesSection = makeSection(profilesPage, "Profiles WIP", 0, 190)
local profilesHint = makeStatusLabel(profilesSection, 12, 46, 500)
profilesHint.Size = UDim2.new(1, -24, 0, 56)
profilesHint.TextWrapped = true
profilesHint.Text = "Profile save / load is paused for now while the ESP and GUI systems keep changing. We can wire it back in once the structure is settled."
profilesHint.TextColor3 = THEME.white
local exportBtn = makeActionButton(profilesSection, "Export WIP", 12, 120, 136, THEME.panelAlt)
local importBtn = makeActionButton(profilesSection, "Import WIP", 160, 120, 136, THEME.panelAlt)
local resetPathBtn = makeActionButton(profilesSection, "Later", 308, 120, 110, THEME.panelAlt)
local profilesStatus = makeStatusLabel(profilesSection, 12, 162, 450)

local lineColorPrompt = Instance.new("Frame")
lineColorPrompt.Size = UDim2.new(0, 300, 0, 170)
lineColorPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
lineColorPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
lineColorPrompt.BackgroundColor3 = THEME.panel
lineColorPrompt.BorderSizePixel = 0
lineColorPrompt.Visible = false
lineColorPrompt.ZIndex = 20
lineColorPrompt.Parent = mainFrame
addCorner(lineColorPrompt, 16)
addStroke(lineColorPrompt, THEME.border, 2)
local lineColorPromptScale = Instance.new("UIScale")
lineColorPromptScale.Name = "PromptScale"
lineColorPromptScale.Scale = 1
lineColorPromptScale.Parent = lineColorPrompt

local promptTitle = makeStatusLabel(lineColorPrompt, 18, 14, 250)
promptTitle.Text = "Default Line Color"
promptTitle.TextColor3 = THEME.white
promptTitle.TextSize = 18
promptTitle.Font = Enum.Font.GothamBold
promptTitle.ZIndex = 21

local promptHint = makeStatusLabel(lineColorPrompt, 18, 44, 250)
promptHint.Size = UDim2.new(1, -32, 0, 32)
promptHint.TextWrapped = true
promptHint.Text = "Enter a HEX color like FFFFFF."
promptHint.TextColor3 = THEME.white
promptHint.ZIndex = 21

local lineColorPromptInput = makeInput(lineColorPrompt, "FFFFFF", 18, 88, 118)
lineColorPromptInput.ZIndex = 21
local lineColorPromptApply = makeActionButton(lineColorPrompt, "Apply", 148, 88, 64, THEME.accent)
lineColorPromptApply.ZIndex = 21
local lineColorPromptCancel = makeActionButton(lineColorPrompt, "Close", 222, 88, 58, THEME.panelAlt)
lineColorPromptCancel.ZIndex = 21
local lineColorPromptStatus = makeStatusLabel(lineColorPrompt, 18, 132, 250)
lineColorPromptStatus.ZIndex = 21

local partColorRows = {}
local blacklistRows = {}

local function refreshUiInputs()
    radiusInput.Text = tostring(CONFIG.radius)
    defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
    labelDistanceInput.Text = tostring(CONFIG.labelDistance)
    guiAccentInput.Text = colorToHex(GUI_SETTINGS.accentColor)
    guiTitleSizeInput.Text = tostring(GUI_SETTINGS.titleTextSize)
    guiBodySizeInput.Text = tostring(GUI_SETTINGS.bodyTextSize)
    guiKeybindInput.Text = GUI_SETTINGS.toggleKey.Name
    guiAnimationToggle.Text = GUI_SETTINGS.animationsEnabled and "Animations: ON" or "Animations: OFF"
    guiAnimationToggle.BackgroundColor3 = GUI_SETTINGS.animationsEnabled and THEME.success or THEME.danger
end

local function applyGuiSettings()
    THEME.accent = GUI_SETTINGS.accentColor
    sidebarAccent.BackgroundColor3 = GUI_SETTINGS.accentColor
    sidebarFooter.Text = "gui accent #" .. colorToHex(GUI_SETTINGS.accentColor)
    sidebarTitle.TextSize = math.max(20, GUI_SETTINGS.titleTextSize - 4)
    contentTitle.TextSize = GUI_SETTINGS.titleTextSize

    for _, header in ipairs(sectionHeaders) do
        if header.Parent then
            header.TextSize = math.max(16, GUI_SETTINGS.bodyTextSize + 4)
        end
    end

    for _, label in ipairs(bodyTextLabels) do
        if label.Parent then
            label.TextSize = GUI_SETTINGS.bodyTextSize
        end
    end

    for _, label in ipairs(titleTextLabels) do
        if label.Parent and label ~= contentTitle and label ~= sidebarTitle then
            label.TextSize = math.max(16, GUI_SETTINGS.titleTextSize - 8)
        end
    end

    for _, button in ipairs(buttonTextLabels) do
        if button.Parent then
            button.TextSize = math.max(13, GUI_SETTINGS.buttonTextSize - (button == closeBtn and -2 or 0))
        end
    end

    for _, box in ipairs(inputTextBoxes) do
        if box.Parent then
            box.TextSize = GUI_SETTINGS.bodyTextSize + 1
        end
    end

    accentName.TextSize = math.max(16, GUI_SETTINGS.bodyTextSize + 4)
    promptTitle.TextSize = math.max(18, GUI_SETTINGS.bodyTextSize + 6)
    applyBtn.BackgroundColor3 = GUI_SETTINGS.accentColor
    guiApplyBtn.BackgroundColor3 = GUI_SETTINGS.accentColor
    lineColorPromptApply.BackgroundColor3 = GUI_SETTINGS.accentColor

    updatePageButtons()
end

local function applyConfigPayload(payload)
    if typeof(payload) ~= "table" then
        return false, "Config invalid."
    end
    if typeof(payload.radius) == "number" then
        CONFIG.radius = math.max(0, payload.radius)
    end
    if typeof(payload.labelDistance) == "number" then
        CONFIG.labelDistance = math.max(2, payload.labelDistance)
    end
    if typeof(payload.defaultColor) == "string" then
        local loadedColor = colorFromHex(payload.defaultColor)
        if loadedColor then
            CONFIG.defaultColor = loadedColor
        end
    end
    if typeof(payload.ignore) == "table" then
        CONFIG.ignore = {}
        for _, partName in ipairs(payload.ignore) do
            if typeof(partName) == "string" and trim(partName) ~= "" then
                table.insert(CONFIG.ignore, trim(partName))
            end
        end
    end
    if typeof(payload.partColors) == "table" then
        CONFIG.partColors = {}
        for partName, hex in pairs(payload.partColors) do
            if typeof(partName) == "string" and typeof(hex) == "string" then
                local loadedColor = colorFromHex(hex)
                if loadedColor then
                    CONFIG.partColors[partName] = loadedColor
                end
            end
        end
    end
    refreshUiInputs()
    return true, "Config loaded."
end

local function saveConfig()
    return false, "Profiles are WIP for now."
end

local function loadConfig()
    return false, "Profiles are WIP for now."
end

local function destroyEntry(entry)
    if entry.label then
        entry.label:Destroy()
        entry.label = nil
    end
    entry.labelText = nil
    if entry.anchor then
        entry.anchor:Destroy()
        entry.anchor = nil
    end
    if entry.line then
        entry.line:Destroy()
        entry.line = nil
    end
    entry.visible = false
end

local function ensureEntryVisuals(entry)
    if entry.line and entry.anchor and entry.label and entry.labelText then
        return
    end
    entry.line = createLinePart()
    entry.anchor = createLabelAnchor()
    entry.label, entry.labelText = createBillboard(entry.anchor, entry.part.Name, getColor(entry.part.Name), screenGui)
end

local function refreshEntryAppearance(entry)
    if not entry.part or not entry.part.Parent then
        return
    end
    local color = getColor(entry.part.Name)
    if entry.line then
        entry.line.Color = color
    end
    if entry.labelText then
        entry.labelText.Text = entry.part.Name
        entry.labelText.TextColor3 = color
    end
end

local function refreshAllAppearances()
    lineColorPreview.BackgroundColor3 = CONFIG.defaultColor
    defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
    accentHex.Text = "#" .. colorToHex(CONFIG.defaultColor) .. " click square to change"
    for _, entry in pairs(trackedParts) do
        refreshEntryAppearance(entry)
    end
end

local function setEntryVisible(entry, visible)
    if visible then
        ensureEntryVisuals(entry)
        refreshEntryAppearance(entry)
    end
    if entry.line then
        entry.line.Transparency = visible and 0 or 1
    end
    if entry.label then
        entry.label.Enabled = visible
    end
    entry.visible = visible
end

local function registerPart(part)
    if destroyed or trackedParts[part] or not part:IsA("BasePart") then
        return
    end
    trackedParts[part] = { part = part, visible = false, line = nil, anchor = nil, label = nil, labelText = nil }
end

local function unregisterPart(part)
    local entry = trackedParts[part]
    if not entry then
        return
    end
    destroyEntry(entry)
    trackedParts[part] = nil
end

local function hideAllEntries()
    for _, entry in pairs(trackedParts) do
        if entry.visible then
            setEntryVisible(entry, false)
        end
    end
end

local function updateEntry(entry, playerPos)
    local part = entry.part
    if not part or not part.Parent then
        unregisterPart(part)
        return
    end
    local fromPos = playerPos + CONFIG.lineOffset
    local toPos = part.Position + CONFIG.lineOffset
    local direction = toPos - fromPos
    local distance = direction.Magnitude
    local shouldShow = not isIgnored(part.Name) and (CONFIG.radius == 0 or distance <= CONFIG.radius)
    if not shouldShow or distance <= 0.05 then
        if entry.visible then
            setEntryVisible(entry, false)
        end
        return
    end
    ensureEntryVisuals(entry)
    refreshEntryAppearance(entry)
    local midpoint = fromPos + direction / 2
    local labelOffset = math.min(CONFIG.labelDistance, math.max(2, distance * 0.25))
    entry.line.Size = Vector3.new(CONFIG.lineThickness, CONFIG.lineThickness, distance)
    entry.line.CFrame = CFrame.lookAt(midpoint, toPos)
    entry.anchor.CFrame = CFrame.new(fromPos + direction.Unit * labelOffset)
    setEntryVisible(entry, true)
end

local function updateEsp()
    if destroyed or not espEnabled then
        return
    end
    local character = player.Character
    if not character then
        hideAllEntries()
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hideAllEntries()
        return
    end
    local playerPos = hrp.Position
    for part, entry in pairs(trackedParts) do
        if not part or not part.Parent then
            unregisterPart(part)
        else
            updateEntry(entry, playerPos)
        end
    end
end

local function rebuildPartColorList()
    for _, row in ipairs(partColorRows) do
        row:Destroy()
    end
    table.clear(partColorRows)
    for partName, color in pairs(CONFIG.partColors) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 30)
        row.BackgroundColor3 = THEME.panel
        row.BorderSizePixel = 0
        row.Parent = partColorList
        addCorner(row, 10)
        addStroke(row, THEME.border, 2)
        local nameLabel = makeStatusLabel(row, 8, 6, 185)
        nameLabel.Text = partName
        nameLabel.TextColor3 = THEME.white
        local swatch = Instance.new("Frame")
        swatch.Size = UDim2.new(0, 18, 0, 18)
        swatch.Position = UDim2.new(0, 204, 0.5, -9)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.Parent = row
        addCorner(swatch, 6)
        local hexLabel = makeStatusLabel(row, 230, 6, 78)
        hexLabel.Text = "#" .. colorToHex(color)
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 26, 0, 22)
        removeBtn.Position = UDim2.new(1, -34, 0.5, -11)
        removeBtn.AutoButtonColor = false
        removeBtn.BackgroundColor3 = THEME.danger
        removeBtn.BorderSizePixel = 0
        removeBtn.Text = "X"
        removeBtn.TextColor3 = THEME.white
        removeBtn.TextSize = 12
        removeBtn.Font = Enum.Font.GothamBold
        removeBtn.Parent = row
        addCorner(removeBtn, 8)
        addStroke(removeBtn, Color3.fromRGB(160, 25, 25), 2)
        enableButtonMotion(removeBtn, 1.04, 0.94)
        connect(removeBtn.MouseButton1Click, function()
            CONFIG.partColors[partName] = nil
            rebuildPartColorList()
            refreshAllAppearances()
            setStatus(partColorStatus, "Removed color for " .. partName, THEME.muted)
        end)
        table.insert(partColorRows, row)
    end
end

local function rebuildBlacklistList()
    for _, row in ipairs(blacklistRows) do
        row:Destroy()
    end
    table.clear(blacklistRows)
    for _, partName in ipairs(CONFIG.ignore) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 30)
        row.BackgroundColor3 = THEME.panel
        row.BorderSizePixel = 0
        row.Parent = blacklistList
        addCorner(row, 10)
        addStroke(row, THEME.border, 2)
        local nameLabel = makeStatusLabel(row, 8, 6, 240)
        nameLabel.Text = partName
        nameLabel.TextColor3 = THEME.white
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 26, 0, 22)
        removeBtn.Position = UDim2.new(1, -34, 0.5, -11)
        removeBtn.AutoButtonColor = false
        removeBtn.BackgroundColor3 = THEME.danger
        removeBtn.BorderSizePixel = 0
        removeBtn.Text = "X"
        removeBtn.TextColor3 = THEME.white
        removeBtn.TextSize = 12
        removeBtn.Font = Enum.Font.GothamBold
        removeBtn.Parent = row
        addCorner(removeBtn, 8)
        addStroke(removeBtn, Color3.fromRGB(160, 25, 25), 2)
        enableButtonMotion(removeBtn, 1.04, 0.94)
        connect(removeBtn.MouseButton1Click, function()
            removeFromIgnore(partName)
            rebuildBlacklistList()
            setStatus(blacklistStatus, "Removed " .. partName, THEME.muted)
        end)
        table.insert(blacklistRows, row)
    end
end

connect(partColorLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    partColorList.CanvasSize = UDim2.new(0, 0, 0, partColorLayout.AbsoluteContentSize.Y + 8)
end)
connect(blacklistLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    blacklistList.CanvasSize = UDim2.new(0, 0, 0, blacklistLayout.AbsoluteContentSize.Y + 8)
end)

updatePageButtons = function()
    for pageName, button in pairs(pageButtons) do
        button.BackgroundColor3 = currentPage == pageName and GUI_SETTINGS.accentColor or THEME.panelAlt
    end
end

local function showPage(pageName)
    currentPage = pageName
    for name, page in pairs(pages) do
        page.Visible = name == pageName
    end
    if pageName == "esp" then
        contentTitle.Text = "ESP"
        contentSubtitle.Text = "Fast line renderer with labels that sit near the player."
    elseif pageName == "config" then
        contentTitle.Text = "Config"
        contentSubtitle.Text = "Radius, label distance, default color, and part overrides."
    elseif pageName == "blacklist" then
        contentTitle.Text = "Blacklist"
        contentSubtitle.Text = "Ignore unwanted parts without rebuilding the cache."
    elseif pageName == "gui" then
        contentTitle.Text = "Gui Settings"
        contentSubtitle.Text = "Menu accent, text sizes, and interface animations."
    else
        contentTitle.Text = "Profiles"
        contentSubtitle.Text = "Profile save/load is WIP for now."
    end
    updatePageButtons()
end

local function shutdown()
    if destroyed then
        return
    end
    destroyed = true
    espEnabled = false
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    for part, entry in pairs(trackedParts) do
        destroyEntry(entry)
        trackedParts[part] = nil
    end
    if screenGui.Parent then
        screenGui:Destroy()
    end
    pcall(function() script:Destroy() end)
end

makePageButton("esp", "ESP", 1)
makePageButton("config", "Config", 2)
makePageButton("blacklist", "Blacklist", 3)
makePageButton("gui", "Gui Settings", 4)
makePageButton("profiles", "Profiles", 5)
for pageName, button in pairs(pageButtons) do
    connect(button.MouseButton1Click, function() showPage(pageName) end)
end

connect(closeBtn.MouseButton1Click, shutdown)
connect(closeBtn.MouseEnter, function() closeBtn.BackgroundTransparency = 0.12 end)
connect(closeBtn.MouseLeave, function() closeBtn.BackgroundTransparency = 0 end)

local function openLineColorPrompt()
    lineColorPromptInput.Text = colorToHex(CONFIG.defaultColor)
    lineColorPromptStatus.Text = ""
    lineColorPrompt.Visible = true
    lineColorPrompt.ZIndex = 20
    if GUI_SETTINGS.animationsEnabled then
        local promptScale = lineColorPrompt:FindFirstChild("PromptScale")
        if promptScale then
            promptScale.Scale = 0.92
            tween(promptScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        end
    end
end

local function closeLineColorPrompt()
    lineColorPrompt.Visible = false
end

connect(lineColorPreview.MouseButton1Click, openLineColorPrompt)
connect(lineColorPromptCancel.MouseButton1Click, closeLineColorPrompt)
connect(lineColorPromptApply.MouseButton1Click, function()
    local loadedColor = colorFromHex(lineColorPromptInput.Text)
    if not loadedColor then
        setStatus(lineColorPromptStatus, "Invalid HEX color.", THEME.danger)
        return
    end
    CONFIG.defaultColor = loadedColor
    refreshAllAppearances()
    closeLineColorPrompt()
end)

connect(dragHandle.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
connect(dragHandle.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if input.KeyCode == GUI_SETTINGS.toggleKey then
        task.spawn(function()
            setGuiVisible(not guiVisible)
        end)
    end
end)

connect(espToggleBtn.MouseButton1Click, function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggleBtn.Text = "ESP ON"
        espToggleBtn.BackgroundColor3 = THEME.success
        setStatus(espStatus, "ESP enabled. Cached parts update on heartbeat.", THEME.white)
    else
        espToggleBtn.Text = "ESP OFF"
        espToggleBtn.BackgroundColor3 = THEME.danger
        setStatus(espStatus, "ESP disabled. All lines hidden.", THEME.muted)
        hideAllEntries()
    end
end)

connect(applyBtn.MouseButton1Click, function()
    local radius = tonumber(trim(radiusInput.Text))
    local labelDistance = tonumber(trim(labelDistanceInput.Text))
    local loadedColor = colorFromHex(defaultColorInput.Text)
    if radius then
        CONFIG.radius = math.max(0, radius)
        radiusInput.Text = tostring(CONFIG.radius)
    end
    if labelDistance then
        CONFIG.labelDistance = math.max(2, labelDistance)
        labelDistanceInput.Text = tostring(CONFIG.labelDistance)
    end
    if loadedColor then
        CONFIG.defaultColor = loadedColor
        defaultColorInput.Text = colorToHex(loadedColor)
    end
    refreshAllAppearances()
    setStatus(applyStatus, "Settings applied.", THEME.success)
end)

connect(guiAnimationToggle.MouseButton1Click, function()
    GUI_SETTINGS.animationsEnabled = not GUI_SETTINGS.animationsEnabled
    refreshUiInputs()
    setStatus(guiStatus, GUI_SETTINGS.animationsEnabled and "GUI animations enabled." or "GUI animations disabled.", THEME.success)
end)

connect(guiApplyBtn.MouseButton1Click, function()
    local accentColor = colorFromHex(guiAccentInput.Text)
    local titleSize = tonumber(trim(guiTitleSizeInput.Text))
    local bodySize = tonumber(trim(guiBodySizeInput.Text))
    local toggleKey = keyCodeFromText(guiKeybindInput.Text)

    if not accentColor then
        setStatus(guiStatus, "GUI accent HEX is invalid.", THEME.danger)
        return
    end

    if not toggleKey then
        setStatus(guiStatus, "Toggle key is invalid.", THEME.danger)
        return
    end

    GUI_SETTINGS.accentColor = accentColor
    GUI_SETTINGS.titleTextSize = math.clamp(titleSize or GUI_SETTINGS.titleTextSize, 20, 34)
    GUI_SETTINGS.bodyTextSize = math.clamp(bodySize or GUI_SETTINGS.bodyTextSize, 11, 18)
    GUI_SETTINGS.buttonTextSize = math.clamp(GUI_SETTINGS.bodyTextSize + 4, 14, 20)
    GUI_SETTINGS.toggleKey = toggleKey
    applyGuiSettings()
    refreshUiInputs()
    setStatus(guiStatus, "GUI settings applied.", THEME.success)
end)

connect(guiResetBtn.MouseButton1Click, function()
    GUI_SETTINGS.accentColor = Color3.fromRGB(72, 100, 255)
    GUI_SETTINGS.titleTextSize = 26
    GUI_SETTINGS.bodyTextSize = 12
    GUI_SETTINGS.buttonTextSize = 16
    GUI_SETTINGS.animationsEnabled = true
    GUI_SETTINGS.toggleKey = Enum.KeyCode.RightShift
    applyGuiSettings()
    refreshUiInputs()
    setStatus(guiStatus, "GUI settings reset.", THEME.success)
end)

connect(addColorBtn.MouseButton1Click, function()
    local partName = trim(addNameInput.Text)
    local loadedColor = colorFromHex(addColorInput.Text)
    if partName == "" then
        setStatus(partColorStatus, "Part name required.", THEME.danger)
        return
    end
    if not loadedColor then
        setStatus(partColorStatus, "Hex color invalid.", THEME.danger)
        return
    end
    CONFIG.partColors[partName] = loadedColor
    addNameInput.Text = ""
    addColorInput.Text = ""
    rebuildPartColorList()
    refreshAllAppearances()
    setStatus(partColorStatus, "Color saved for " .. partName, THEME.success)
end)

connect(addBlacklistBtn.MouseButton1Click, function()
    local partName = trim(blacklistInput.Text)
    if partName == "" then
        setStatus(blacklistStatus, "Part name required.", THEME.danger)
        return
    end
    if addToIgnore(partName) then
        blacklistInput.Text = ""
        rebuildBlacklistList()
        setStatus(blacklistStatus, "Added " .. partName, THEME.success)
    else
        setStatus(blacklistStatus, partName .. " already ignored.", THEME.muted)
    end
end)

connect(exportBtn.MouseButton1Click, function()
    setStatus(profilesStatus, "Profiles are WIP for now.", THEME.muted)
end)
connect(importBtn.MouseButton1Click, function()
    setStatus(profilesStatus, "Profiles are WIP for now.", THEME.muted)
end)
connect(resetPathBtn.MouseButton1Click, function()
    setStatus(profilesStatus, "We'll wire this back in later.", THEME.muted)
end)

for _, descendant in ipairs(chunksFolder:GetDescendants()) do
    registerPart(descendant)
end
connect(chunksFolder.DescendantAdded, function(descendant) registerPart(descendant) end)
connect(chunksFolder.DescendantRemoving, function(descendant) unregisterPart(descendant) end)
connect(RunService.Heartbeat, function(deltaTime)
    heartbeatAccumulator = heartbeatAccumulator + deltaTime
    if heartbeatAccumulator < CONFIG.updateInterval then
        return
    end
    heartbeatAccumulator = 0
    updateEsp()
end)

local function playIntro()
    mainFrame.Position = FINAL_POSITION
    local introGrow = tween(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 420, 0, 200) })
    introGrow.Completed:Wait()
    local lineTween = tween(introLine, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.84, 0, 0, 18) })
    lineTween.Completed:Wait()
    local titleTween = tween(introTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
    titleTween.Completed:Wait()
    task.wait(0.18)
    sidebar.Visible = true
    contentFrame.Visible = true
    local openTween = tween(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = FINAL_SIZE })
    tween(sidebar, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 12, 0, 12) })
    tween(contentFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 197, 0, 12) })
    tween(introLine, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    tween(introTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
    openTween.Completed:Wait()
    introLine.Visible = false
    introTitle.Visible = false
end

fetchVersion()
sidebarVersion.Text = APP_VERSION
rebuildPartColorList()
rebuildBlacklistList()
refreshUiInputs()
applyGuiSettings()
refreshAllAppearances()
showPage("esp")
task.spawn(playIntro)
