-- MagnetoZz modular chunk: 05_esp.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
function setEntryVisible(entry, visible)
    if visible then
        ensureEntryVisuals(entry)
        if not entry.visible then
            refreshEntryAppearance(entry)
        end
    end

    if entry.visible == visible then
        return
    end

    if entry.line then
        entry.line.Transparency = visible and 0 or 1
    end
    if entry.label then
        entry.label.Enabled = visible
    end
    if entry.drawLine then
        entry.drawLine.Visible = visible
    end
    if entry.drawText then
        entry.drawText.Visible = visible and CONFIG.showLabels
    end
    entry.visible = visible
end

function registerPart(part)
    if destroyed or trackedParts[part] or not part:IsA("BasePart") then
        return
    end
    trackedParts[part] = {
        part = part,
        visible = false,
        line = nil,
        anchor = nil,
        label = nil,
        labelText = nil,
        drawLine = nil,
        drawText = nil,
    }
    requestTargetRefresh()
end

function clearActiveEntries()
    table.clear(activeEntries)
end

function unregisterPart(part)
    local entry = trackedParts[part]
    if not entry then
        return
    end
    if unregisterTrackerPart then
        unregisterTrackerPart(part)
    end
    destroyEntry(entry)
    trackedParts[part] = nil
    requestTargetRefresh()
end

function hideAllEntries()
    for _, entry in pairs(trackedParts) do
        if entry.visible then
            setEntryVisible(entry, false)
        end
    end
    clearActiveEntries()
end

function setEspState(enabled)
    espEnabled = enabled
    if espEnabled then
        espToggleBtn.Text = "ESP ON"
        espToggleBtn.BackgroundColor3 = THEME.success
        setStatus(espStatus, "ESP enabled. Rendering only the closest part for each name.", THEME.white)
        requestTargetRefresh()
    else
        espToggleBtn.Text = "ESP OFF"
        espToggleBtn.BackgroundColor3 = THEME.danger
        setStatus(espStatus, "ESP disabled. All lines hidden.", THEME.muted)
        hideAllEntries()
    end
    updateEspPill()
end

function updateEntry(entry, playerPos)
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

    if USE_DRAWING and entry.drawLine and entry.drawText then
        local camera = workspace.CurrentCamera
        if not camera then
            setEntryVisible(entry, false)
            return
        end

        local fromScreen, fromVisible = camera:WorldToViewportPoint(fromPos)
        local toScreen, toVisible = camera:WorldToViewportPoint(toPos)
        if fromScreen.Z <= 0 or toScreen.Z <= 0 or ((not fromVisible) and (not toVisible)) then
            setEntryVisible(entry, false)
            return
        end

        local labelOffset = math.min(CONFIG.labelDistance, math.max(2, distance * 0.25))
        local labelScreen = camera:WorldToViewportPoint(fromPos + direction.Unit * labelOffset)

        entry.drawLine.From = Vector2.new(fromScreen.X, fromScreen.Y)
        entry.drawLine.To = Vector2.new(toScreen.X, toScreen.Y)
        entry.drawLine.Thickness = getTracerThickness(part.Name)
        entry.drawText.Position = Vector2.new(labelScreen.X, labelScreen.Y - 12)
        entry.drawText.Size = math.max(12, GUI_SETTINGS.bodyTextSize + 1)
        setEntryVisible(entry, true)
        return
    end

    local midpoint = fromPos + direction / 2
    local labelOffset = math.min(CONFIG.labelDistance, math.max(2, distance * 0.25))
    local worldThickness = getWorldTracerThickness(part.Name)
    entry.line.Size = Vector3.new(worldThickness, worldThickness, distance)
    entry.line.CFrame = CFrame.lookAt(midpoint, toPos)
    entry.anchor.CFrame = CFrame.new(fromPos + direction.Unit * labelOffset)
    setEntryVisible(entry, true)
end

function updateEsp()
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

    for index = #activeEntries, 1, -1 do
        local entry = activeEntries[index]
        local part = entry.part
        if not part or not part.Parent or isIgnored(part.Name) then
            setEntryVisible(entry, false)
            table.remove(activeEntries, index)
        else
            local distance = (part.Position - playerPos).Magnitude
            if CONFIG.radius ~= 0 and distance > CONFIG.radius then
                setEntryVisible(entry, false)
                table.remove(activeEntries, index)
            else
                updateEntry(entry, playerPos)
            end
        end
    end
end

function rebuildEspTargets()
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
    local selectedEntries = {}
    local selectedLookup = {}
    local nearestByName = {}
    local candidates = {}
    local staleParts = {}

    for part, entry in pairs(trackedParts) do
        if not part or not part.Parent then
            table.insert(staleParts, part)
        elseif isIgnored(part.Name) then
            if entry.visible then
                setEntryVisible(entry, false)
            end
        else
            local distance = (part.Position - playerPos).Magnitude
            if CONFIG.radius == 0 or distance <= CONFIG.radius then
                if CONFIG.closestPerName then
                    local existing = nearestByName[part.Name]
                    if not existing or distance < existing.distance then
                        nearestByName[part.Name] = {
                            entry = entry,
                            distance = distance,
                        }
                    end
                else
                    table.insert(candidates, {
                        entry = entry,
                        distance = distance,
                    })
                end
            elseif entry.visible then
                setEntryVisible(entry, false)
            end
        end
    end

    for _, part in ipairs(staleParts) do
        unregisterPart(part)
    end

    if CONFIG.closestPerName then
        for _, candidate in pairs(nearestByName) do
            table.insert(candidates, candidate)
        end
    end

    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)

    local maxVisible = math.min(CONFIG.maxVisible or #candidates, #candidates)
    for index = 1, maxVisible do
        local entry = candidates[index].entry
        selectedEntries[index] = entry
        selectedLookup[entry] = true
    end

    for _, entry in pairs(trackedParts) do
        if entry.visible and not selectedLookup[entry] then
            setEntryVisible(entry, false)
        end
    end

    activeEntries = selectedEntries
    updateEsp()
end

rebuildPartColorList = function()
    for _, row in ipairs(partColorRows) do
        row:Destroy()
    end
    table.clear(partColorRows)
    for partName, color in pairs(CONFIG.partColors) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, -18, 0, 30)
        row.AutoButtonColor = false
        row.BackgroundColor3 = THEME.panel
        row.BorderSizePixel = 0
        row.Text = ""
        row.Parent = partColorList
        addCorner(row, 10)
        local rowStroke = addStroke(row, THEME.border, 2)
        enableButtonMotion(row, 1.01, 0.98)
        connect(row.MouseEnter, function()
            rowStroke.Color = THEME.white
        end)
        connect(row.MouseLeave, function()
            rowStroke.Color = THEME.border
        end)
        local nameLabel = makeStatusLabel(row, 8, 6, 160)
        nameLabel.Text = partName
        nameLabel.TextColor3 = THEME.white
        local swatch = Instance.new("Frame")
        swatch.Size = UDim2.new(0, 18, 0, 18)
        swatch.Position = UDim2.new(0, 184, 0.5, -9)
        swatch.BackgroundColor3 = color
        swatch.BorderSizePixel = 0
        swatch.Parent = row
        addCorner(swatch, 6)
        local hexLabel = makeStatusLabel(row, 210, 6, 78)
        hexLabel.Text = "#" .. colorToHex(color)
        local thicknessLabel = makeStatusLabel(row, 308, 6, 100)
        thicknessLabel.Text = "thick " .. tostring(CONFIG.partThickness[partName] or CONFIG.screenLineThickness)
        connect(row.MouseButton1Click, function()
            if openTracerEditPrompt then
                openTracerEditPrompt(partName)
            end
        end)
        table.insert(partColorRows, row)
    end

    captureGuiTransparency()
end

rebuildBlacklistList = function()
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

    captureGuiTransparency()
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

