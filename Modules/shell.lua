-- MagnetoZz modular chunk: 02_shell.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
screenGui = Instance.new("ScreenGui")
screenGui.Name = "MagnetoZzGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

statusDockOpen = true
statusDockOpenWidth = 376
statusDockClosedWidth = 42

statusDock = Instance.new("Frame")
statusDock.Size = UDim2.new(0, statusDockOpenWidth, 0, 34)
statusDock.Position = UDim2.new(0, 158, 0, 14)
statusDock.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
statusDock.BackgroundTransparency = 0.06
statusDock.BorderSizePixel = 0
statusDock.ClipsDescendants = true
statusDock.ZIndex = 6
statusDock.Parent = screenGui
addCorner(statusDock, 18)
addStroke(statusDock, Color3.fromRGB(23, 27, 38), 2)

statusDockArrow = Instance.new("TextButton")
statusDockArrow.Size = UDim2.new(0, 28, 0, 26)
statusDockArrow.Position = UDim2.new(0, 6, 0, 4)
statusDockArrow.AutoButtonColor = false
statusDockArrow.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
statusDockArrow.BackgroundTransparency = 0.02
statusDockArrow.BorderSizePixel = 0
statusDockArrow.Text = "<"
statusDockArrow.TextColor3 = THEME.white
statusDockArrow.TextSize = 14
statusDockArrow.Font = Enum.Font.GothamBold
statusDockArrow.ZIndex = 7
statusDockArrow.Parent = statusDock
addCorner(statusDockArrow, 14)
addStroke(statusDockArrow, Color3.fromRGB(18, 22, 32), 2)
enableButtonMotion(statusDockArrow, 1.05, 0.92)

function makeTopPill(x, text, width)
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, width or 96, 0, 26)
    pill.Position = UDim2.new(0, x, 0, 4)
    pill.AutoButtonColor = false
    pill.BackgroundColor3 = THEME.success
    pill.BackgroundTransparency = 0.04
    pill.BorderSizePixel = 0
    pill.Text = ""
    pill.ZIndex = 7
    pill.Parent = statusDock
    addCorner(pill, 14)
    addStroke(pill, Color3.fromRGB(18, 22, 32), 2)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 11, 0.5, -3)
    dot.BackgroundColor3 = THEME.white
    dot.BackgroundTransparency = 0.05
    dot.BorderSizePixel = 0
    dot.ZIndex = 8
    dot.Parent = pill
    addCorner(dot, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -26, 1, 0)
    label.Position = UDim2.new(0, 24, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = THEME.white
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = pill

    enableButtonMotion(pill, 1.04, 0.94)
    return pill, label, dot
end

statusPill, statusText, statusDot = makeTopPill(42, "Opened", 96)
espPill, espPillText, espPillDot = makeTopPill(142, "ESP OFF", 96)
espPill.BackgroundColor3 = THEME.danger
trackerPill, trackerPillText, trackerPillDot = makeTopPill(242, "Tracker OFF", 118)
trackerPill.BackgroundColor3 = THEME.danger

function setStatusDockOpen(open)
    statusDockOpen = open
    statusDockArrow.Text = open and "<" or ">"

    if open then
        statusPill.Visible = true
        espPill.Visible = true
        trackerPill.Visible = true
        safeTween(statusDock, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, statusDockOpenWidth, 0, 34),
        })
    else
        statusPill.Visible = false
        espPill.Visible = false
        trackerPill.Visible = false
        safeTween(statusDock, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, statusDockClosedWidth, 0, 34),
        })
    end
end

connect(statusDockArrow.MouseButton1Click, function()
    setStatusDockOpen(not statusDockOpen)
end)

guiScale = Instance.new("UIScale")
guiScale.Scale = 1

mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = FINAL_POSITION
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = THEME.shell
mainFrame.BackgroundTransparency = 0.03
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 18)
mainStroke = addStroke(mainFrame, THEME.outline, 2)
guiScale.Parent = mainFrame

dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1, 0, 0, 38)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = mainFrame

introLine = Instance.new("Frame")
introLine.AnchorPoint = Vector2.new(0, 0.5)
introLine.Position = UDim2.new(0.08, 0, 0.5, 0)
introLine.Size = UDim2.new(0, 0, 0, 18)
introLine.BackgroundColor3 = THEME.white
introLine.BorderSizePixel = 0
introLine.Parent = mainFrame

introTitle = Instance.new("TextLabel")
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

sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, -180, 0, 12)
sidebar.Size = UDim2.new(0, 165, 1, -24)
sidebar.BackgroundColor3 = THEME.sidebar
sidebar.BorderSizePixel = 0
sidebar.Visible = false
sidebar.Parent = mainFrame
addCorner(sidebar, 18)
addStroke(sidebar, THEME.border, 2)

contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(1, 30, 0, 12)
contentFrame.Size = UDim2.new(1, -205, 1, -24)
contentFrame.BackgroundColor3 = THEME.content
contentFrame.BorderSizePixel = 0
contentFrame.Visible = false
contentFrame.Parent = mainFrame
addCorner(contentFrame, 18)
addStroke(contentFrame, THEME.border, 2)

sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -18, 0, 34)
sidebarTitle.Position = UDim2.new(0, 9, 0, 8)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "MagnetoZz"
sidebarTitle.TextColor3 = THEME.white
sidebarTitle.TextSize = 22
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Center
sidebarTitle.Parent = sidebar
registerTitleText(sidebarTitle)

sidebarAccent = Instance.new("Frame")
sidebarAccent.Position = UDim2.new(0, 9, 0, 44)
sidebarAccent.Size = UDim2.new(1, -18, 0, 4)
sidebarAccent.BackgroundColor3 = THEME.accent
sidebarAccent.BorderSizePixel = 0
sidebarAccent.Parent = sidebar
addCorner(sidebarAccent, 4)

sidebarVersion = Instance.new("TextLabel")
sidebarVersion.Size = UDim2.new(1, -18, 0, 18)
sidebarVersion.Position = UDim2.new(0, 9, 0, 52)
sidebarVersion.BackgroundTransparency = 1
sidebarVersion.Text = APP_VERSION .. " | By OverStacked-Dev"
sidebarVersion.TextColor3 = THEME.muted
sidebarVersion.TextSize = 12
sidebarVersion.Font = Enum.Font.Gotham
sidebarVersion.TextXAlignment = Enum.TextXAlignment.Center
sidebarVersion.Parent = sidebar
registerBodyText(sidebarVersion)

buttonHolder = Instance.new("Frame")
buttonHolder.Size = UDim2.new(1, -18, 0, 296)
buttonHolder.Position = UDim2.new(0, 9, 0, 88)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = sidebar

buttonLayout = Instance.new("UIListLayout")
buttonLayout.Padding = UDim.new(0, 12)
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Parent = buttonHolder

sidebarFooter = Instance.new("TextLabel")
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

contentHeader = Instance.new("Frame")
contentHeader.Size = UDim2.new(1, -24, 0, 48)
contentHeader.Position = UDim2.new(0, 12, 0, 12)
contentHeader.BackgroundTransparency = 1
contentHeader.Parent = contentFrame

contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(1, -78, 0, 30)
contentTitle.BackgroundTransparency = 1
contentTitle.TextColor3 = THEME.white
contentTitle.TextSize = 26
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader
registerTitleText(contentTitle)

contentSubtitle = Instance.new("TextLabel")
contentSubtitle.Size = UDim2.new(1, -90, 0, 18)
contentSubtitle.Position = UDim2.new(0, 2, 0, 28)
contentSubtitle.BackgroundTransparency = 1
contentSubtitle.TextColor3 = THEME.muted
contentSubtitle.TextSize = 12
contentSubtitle.Font = Enum.Font.Gotham
contentSubtitle.TextXAlignment = Enum.TextXAlignment.Left
contentSubtitle.Parent = contentHeader
registerBodyText(contentSubtitle)

closeBtn = Instance.new("TextButton")
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

pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -24, 1, -84)
pageHolder.Position = UDim2.new(0, 12, 0, 72)
pageHolder.BackgroundTransparency = 1
pageHolder.Parent = contentFrame

function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pageHolder
    pages[name] = page
    return page
end

function makePageButton(id, label, order)
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

function makeSection(parent, title, y, height)
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

function makeLabel(parent, text, x, y, width)
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

function makeInput(parent, placeholder, x, y, width)
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

function makeActionButton(parent, text, x, y, width, color)
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

function makeStatusLabel(parent, x, y, width)
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

function setStatus(label, text, color)
    label.Text = text
    label.TextColor3 = color or THEME.muted
end

function updateStatusPill()
    if guiVisible then
        statusPill.BackgroundColor3 = THEME.success
        statusDot.BackgroundColor3 = Color3.fromRGB(218, 255, 232)
        statusText.Text = "Opened"
    else
        statusPill.BackgroundColor3 = THEME.danger
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 224, 224)
        statusText.Text = "Closed"
    end
end

function updateEspPill()
    if espEnabled then
        espPill.BackgroundColor3 = THEME.success
        espPillDot.BackgroundColor3 = Color3.fromRGB(218, 255, 232)
        espPillText.Text = "ESP ON"
    else
        espPill.BackgroundColor3 = THEME.danger
        espPillDot.BackgroundColor3 = Color3.fromRGB(255, 224, 224)
        espPillText.Text = "ESP OFF"
    end
end

function updateTrackerPill()
    if trackerEnabled then
        trackerPill.BackgroundColor3 = THEME.success
        trackerPillDot.BackgroundColor3 = Color3.fromRGB(218, 255, 232)
        trackerPillText.Text = "Tracker ON"
    else
        trackerPill.BackgroundColor3 = THEME.danger
        trackerPillDot.BackgroundColor3 = Color3.fromRGB(255, 224, 224)
        trackerPillText.Text = "Tracker OFF"
    end
end


function captureGuiTransparency()
    table.clear(guiOriginalTransparency)

    local function capture(instance)
        local props = {}
        if instance:IsA("GuiObject") then
            props.BackgroundTransparency = instance.BackgroundTransparency
        end
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            props.TextTransparency = instance.TextTransparency
        end
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            props.ImageTransparency = instance.ImageTransparency
        end
        if instance:IsA("UIStroke") then
            props.Transparency = instance.Transparency
        end
        if next(props) then
            guiOriginalTransparency[instance] = props
        end
    end

    capture(mainFrame)
    for _, descendant in ipairs(mainFrame:GetDescendants()) do
        capture(descendant)
    end
end

function tweenGuiTransparency(hidden)
    for instance, props in pairs(guiOriginalTransparency) do
        if instance.Parent then
            local goal = {}
            for prop, originalValue in pairs(props) do
                goal[prop] = hidden and 1 or originalValue
            end
            safeTween(instance, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        end
    end
end

function setGuiVisible(visible)
    if destroyed or guiVisible == visible then
        return
    end

    guiVisible = visible
    mainFrame.Active = visible
    updateStatusPill()
    if visible then
        mainFrame.Visible = true
    end

    local targetScale = visible and 1 or 0.985
    local easingDirection = visible and Enum.EasingDirection.Out or Enum.EasingDirection.In

    local scaleTween = safeTween(
        guiScale,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, easingDirection),
        { Scale = targetScale }
    )
    tweenGuiTransparency(not visible)

    if not visible then
        if scaleTween then
            scaleTween.Completed:Wait()
        end
        if not guiVisible then
            mainFrame.Visible = false
        end
    end
end

