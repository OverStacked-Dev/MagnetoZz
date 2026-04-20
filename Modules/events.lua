-- MagnetoZz modular chunk: 06_events.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
function showPage(pageName)
    currentPage = pageName
    for name, page in pairs(pages) do
        page.Visible = name == pageName
    end
    if pageName == "esp" then
        contentTitle.Text = "Main"
        contentSubtitle.Text = "Fast line renderer with quick runtime controls."
    elseif pageName == "config" then
        contentTitle.Text = "ESP Config"
        contentSubtitle.Text = "Tune range, label spacing, and Manual Tracer Settings."
    elseif pageName == "blacklist" then
        contentTitle.Text = "Blacklist"
        contentSubtitle.Text = "Hide ores you do not want MagnetoZz to trace."
    elseif pageName == "gui" then
        contentTitle.Text = "Gui Settings"
        contentSubtitle.Text = "Menu accent, text sizes, and interface animations."
    else
        contentTitle.Text = "Profiles"
        contentSubtitle.Text = "Sync blacklist and Manual Tracer Settings with Supabase."
    end
    updatePageButtons()
end

function shutdown()
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

makePageButton("esp", "Main", 1)
makePageButton("config", "ESP Config", 2)
makePageButton("blacklist", "Blacklist", 3)
makePageButton("gui", "Gui Settings", 4)
makePageButton("profiles", "Profiles", 5)
for pageName, button in pairs(pageButtons) do
    connect(button.MouseButton1Click, function() showPage(pageName) end)
end

connect(closeBtn.MouseButton1Click, shutdown)
connect(closeBtn.MouseEnter, function() closeBtn.BackgroundTransparency = 0.12 end)
connect(closeBtn.MouseLeave, function() closeBtn.BackgroundTransparency = 0 end)

function openLineColorPrompt()
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

function closeLineColorPrompt()
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

openTracerEditPrompt = function(oreName)
    local color = CONFIG.partColors[oreName]
    selectedTracerName = oreName
    tracerEditTitle.Text = "Edit " .. oreName
    tracerEditNameInput.Text = oreName
    tracerEditColorInput.Text = color and colorToHex(color) or colorToHex(CONFIG.defaultColor)
    tracerEditThicknessInput.Text = tostring(CONFIG.partThickness[oreName] or CONFIG.screenLineThickness)
    tracerEditStatus.Text = ""
    tracerEditPrompt.Visible = true

    if GUI_SETTINGS.animationsEnabled then
        local promptScale = tracerEditPrompt:FindFirstChild("PromptScale")
        if promptScale then
            promptScale.Scale = 0.92
            tween(promptScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        end
    end
end

function closeTracerEditPrompt()
    tracerEditPrompt.Visible = false
    selectedTracerName = nil
end

connect(tracerCancelBtn.MouseButton1Click, closeTracerEditPrompt)
connect(tracerDeleteBtn.MouseButton1Click, function()
    if not selectedTracerName then
        return
    end

    local deletedName = selectedTracerName
    CONFIG.partColors[deletedName] = nil
    CONFIG.partThickness[deletedName] = nil
    rebuildPartColorList()
    refreshAllAppearances()
    setStatus(partColorStatus, "Deleted tracer for " .. deletedName, THEME.muted)
    closeTracerEditPrompt()
end)
connect(tracerSaveBtn.MouseButton1Click, function()
    if not selectedTracerName then
        return
    end

    local newName = trim(tracerEditNameInput.Text)
    local loadedColor = colorFromHex(tracerEditColorInput.Text)
    local thickness = tonumber(trim(tracerEditThicknessInput.Text))
    if newName == "" then
        setStatus(tracerEditStatus, "Ore name required.", THEME.danger)
        return
    end
    if not loadedColor then
        setStatus(tracerEditStatus, "Color HEX is invalid.", THEME.danger)
        return
    end
    if not thickness then
        setStatus(tracerEditStatus, "Thickness must be a number.", THEME.danger)
        return
    end

    CONFIG.partColors[selectedTracerName] = nil
    CONFIG.partThickness[selectedTracerName] = nil
    CONFIG.partColors[newName] = loadedColor
    CONFIG.partThickness[newName] = math.clamp(thickness, 0.5, 12)

    rebuildPartColorList()
    refreshAllAppearances()
    requestTargetRefresh()
    setStatus(partColorStatus, "Updated tracer for " .. newName, THEME.success)
    closeTracerEditPrompt()
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
    elseif input.KeyCode == GUI_SETTINGS.espToggleKey then
        setEspState(not espEnabled)
    end
end)

connect(statusPill.MouseButton1Click, function()
    task.spawn(function()
        setGuiVisible(not guiVisible)
    end)
end)

connect(espPill.MouseButton1Click, function()
    setEspState(not espEnabled)
end)

connect(espToggleBtn.MouseButton1Click, function()
    setEspState(not espEnabled)
end)

connect(trackerToggleBtn.MouseButton1Click, function()
    trackerWipEnabled = not trackerWipEnabled
    trackerToggleBtn.Text = trackerWipEnabled and "Tracker ESP ON WIP" or "Tracker ESP OFF WIP"
    trackerToggleBtn.BackgroundColor3 = trackerWipEnabled and THEME.success or THEME.danger
    setStatus(trackerStatus, "WIP placeholder only. No tracker rendering yet.", THEME.muted)
end)

connect(applyBtn.MouseButton1Click, function()
    local radius = tonumber(trim(radiusInput.Text))
    local labelDistance = tonumber(trim(labelDistanceInput.Text))
    if radius then
        CONFIG.radius = math.max(0, radius)
        radiusInput.Text = tostring(CONFIG.radius)
    end
    if labelDistance then
        CONFIG.labelDistance = math.max(2, labelDistance)
        labelDistanceInput.Text = tostring(CONFIG.labelDistance)
    end
    requestTargetRefresh()
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
    local espToggleKey = keyCodeFromText(guiEspKeybindInput.Text)

    if not accentColor then
        setStatus(guiStatus, "GUI accent HEX is invalid.", THEME.danger)
        return
    end

    if not toggleKey then
        setStatus(guiStatus, "Toggle key is invalid.", THEME.danger)
        return
    end

    if not espToggleKey then
        setStatus(guiStatus, "ESP toggle key is invalid.", THEME.danger)
        return
    end

    GUI_SETTINGS.accentColor = accentColor
    GUI_SETTINGS.titleTextSize = math.clamp(titleSize or GUI_SETTINGS.titleTextSize, 20, 34)
    GUI_SETTINGS.bodyTextSize = math.clamp(bodySize or GUI_SETTINGS.bodyTextSize, 11, 18)
    GUI_SETTINGS.buttonTextSize = math.clamp(GUI_SETTINGS.bodyTextSize + 4, 14, 20)
    GUI_SETTINGS.toggleKey = toggleKey
    GUI_SETTINGS.espToggleKey = espToggleKey
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
    GUI_SETTINGS.espToggleKey = Enum.KeyCode.RightControl
    applyGuiSettings()
    refreshUiInputs()
    setStatus(guiStatus, "GUI settings reset.", THEME.success)
end)

connect(addColorBtn.MouseButton1Click, function()
    local partName = trim(addNameInput.Text)
    local loadedColor = colorFromHex(addColorInput.Text)
    local thickness = tonumber(trim(addThicknessInput.Text))
    if partName == "" then
        setStatus(partColorStatus, "Ore name required.", THEME.danger)
        return
    end
    if not loadedColor then
        setStatus(partColorStatus, "Color HEX is invalid.", THEME.danger)
        return
    end
    if not thickness then
        setStatus(partColorStatus, "Thickness must be a number.", THEME.danger)
        return
    end
    CONFIG.partColors[partName] = loadedColor
    CONFIG.partThickness[partName] = math.clamp(thickness, 0.5, 12)
    addNameInput.Text = ""
    addColorInput.Text = ""
    addThicknessInput.Text = tostring(CONFIG.screenLineThickness)
    rebuildPartColorList()
    refreshAllAppearances()
    setStatus(partColorStatus, "Tracer saved for " .. partName, THEME.success)
end)

connect(addBlacklistBtn.MouseButton1Click, function()
    local partName = trim(blacklistInput.Text)
    if partName == "" then
        setStatus(blacklistStatus, "Ore name required.", THEME.danger)
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
    setStatus(profilesStatus, "Saving to Supabase...", THEME.white)
    task.spawn(function()
        local ok, message = saveConfig()
        setStatus(profilesStatus, message, ok and THEME.success or THEME.danger)
    end)
end)
connect(importBtn.MouseButton1Click, function()
    setStatus(profilesStatus, "Loading from Supabase...", THEME.white)
    task.spawn(function()
        local ok, message = loadConfig()
        setStatus(profilesStatus, message, ok and THEME.success or THEME.danger)
    end)
end)
connect(resetPathBtn.MouseButton1Click, function()
    setStatus(profilesStatus, "Profile key: " .. tostring(player.UserId) .. "_data", THEME.muted)
end)

for _, descendant in ipairs(chunksFolder:GetDescendants()) do
    registerPart(descendant)
end
connect(chunksFolder.DescendantAdded, function(descendant) registerPart(descendant) end)
connect(chunksFolder.DescendantRemoving, function(descendant) unregisterPart(descendant) end)

connect(RunService.Heartbeat, function(deltaTime)
    local rebuiltTargets = false

    targetRefreshAccumulator = targetRefreshAccumulator + deltaTime
    if targetRefreshAccumulator >= CONFIG.targetRefreshInterval then
        targetRefreshAccumulator = 0
        rebuildEspTargets()
        rebuiltTargets = true
    end

    heartbeatAccumulator = heartbeatAccumulator + deltaTime
    if rebuiltTargets then
        heartbeatAccumulator = 0
        return
    end

    if heartbeatAccumulator < CONFIG.updateInterval then
        return
    end
    heartbeatAccumulator = 0
    updateEsp()
end)

function playIntro()
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
    introTitle.Visible = false
    local openTween = tween(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = FINAL_SIZE })
    tween(sidebar, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 12, 0, 12) })
    tween(contentFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 197, 0, 12) })
    tween(introLine, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
    openTween.Completed:Wait()
    introLine.Visible = false
    captureGuiTransparency()
end

fetchVersion()
sidebarVersion.Text = APP_VERSION .. " | By OverStacked-Dev"
updateStatusPill()
updateEspPill()
rebuildPartColorList()
rebuildBlacklistList()
refreshUiInputs()
applyGuiSettings()
refreshAllAppearances()
showPage("esp")
captureGuiTransparency()
task.spawn(playIntro)
