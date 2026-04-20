-- MagnetoZz modular chunk: 05b_tracker.lua -- Separate whitelist-based Tracker ESP.
function isTrackerWhitelisted(partName)
    for _, oreName in ipairs(CONFIG.trackerWhitelist) do
        if oreName == partName then
            return true
        end
    end
    return false
end

function trackerShouldTrace(partName)
    if isTrackerWhitelisted(partName) then
        return true
    end

    if not CONFIG.trackerTraceUnlisted or isIgnored(partName) then
        return false
    end

    if CONFIG.partColors[partName] == nil then
        return true
    end

    return getTracerThickness(partName) >= CONFIG.trackerMinRecognizedThickness
end

function addTrackerWhitelist(oreName)
    oreName = trim(oreName)
    if oreName == "" or isTrackerWhitelisted(oreName) then
        return false
    end

    table.insert(CONFIG.trackerWhitelist, oreName)
    requestTargetRefresh()
    return true
end

function removeTrackerWhitelist(oreName)
    for index, existingName in ipairs(CONFIG.trackerWhitelist) do
        if existingName == oreName then
            table.remove(CONFIG.trackerWhitelist, index)
            requestTargetRefresh()
            return true
        end
    end

    return false
end

function createTrackerEntry(part)
    return {
        part = part,
        visible = false,
        line = nil,
        anchor = nil,
        label = nil,
        labelText = nil,
        drawLine = nil,
        drawText = nil,
    }
end

function getTrackerEntry(part)
    if not trackerEntries[part] then
        trackerEntries[part] = createTrackerEntry(part)
    end
    return trackerEntries[part]
end

function unregisterTrackerPart(part)
    local entry = trackerEntries[part]
    if not entry then
        return
    end

    destroyEntry(entry)
    trackerEntries[part] = nil
    requestTargetRefresh()
end

function clearTrackerActiveEntries()
    table.clear(trackerActiveEntries)
end

function hideTrackerEntries()
    for _, entry in pairs(trackerEntries) do
        if entry.visible then
            setEntryVisible(entry, false)
        end
    end
    clearTrackerActiveEntries()
end

function setTrackerState(enabled)
    trackerEnabled = enabled
    if trackerEnabled then
        trackerToggleBtn.Text = "Tracker ESP ON"
        trackerToggleBtn.BackgroundColor3 = THEME.success
        if #CONFIG.trackerWhitelist == 0 and not CONFIG.trackerTraceUnlisted then
            setStatus(trackerStatus, "Tracker enabled. Add ores with the gear first.", THEME.muted)
        elseif CONFIG.trackerTraceUnlisted then
            setStatus(trackerStatus, "Tracker enabled. Auto-tracing unlisted/thick MTS ores.", THEME.white)
        else
            setStatus(trackerStatus, "Tracker enabled for " .. tostring(#CONFIG.trackerWhitelist) .. " whitelisted ores.", THEME.white)
        end
        requestTargetRefresh()
    else
        trackerToggleBtn.Text = "Tracker ESP OFF"
        trackerToggleBtn.BackgroundColor3 = THEME.danger
        setStatus(trackerStatus, "Tracker disabled. Whitelist stays saved.", THEME.muted)
        hideTrackerEntries()
    end
    updateTrackerPill()
end

function updateTrackerEntry(entry, playerPos)
    local part = entry.part
    if not part or not part.Parent then
        unregisterTrackerPart(part)
        return
    end

    local fromPos = playerPos + CONFIG.lineOffset
    local toPos = part.Position + CONFIG.lineOffset
    local direction = toPos - fromPos
    local distance = direction.Magnitude
    local shouldShow = trackerShouldTrace(part.Name) and (CONFIG.radius == 0 or distance <= CONFIG.radius)
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

function updateTrackerEsp()
    if destroyed or not trackerEnabled then
        return
    end

    local character = player.Character
    if not character then
        hideTrackerEntries()
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hideTrackerEntries()
        return
    end

    local playerPos = hrp.Position
    for index = #trackerActiveEntries, 1, -1 do
        local entry = trackerActiveEntries[index]
        local part = entry.part
        if not part or not part.Parent or not trackerShouldTrace(part.Name) then
            setEntryVisible(entry, false)
            table.remove(trackerActiveEntries, index)
        else
            local distance = (part.Position - playerPos).Magnitude
            if CONFIG.radius ~= 0 and distance > CONFIG.radius then
                setEntryVisible(entry, false)
                table.remove(trackerActiveEntries, index)
            else
                updateTrackerEntry(entry, playerPos)
            end
        end
    end
end

function rebuildTrackerTargets()
    if destroyed or not trackerEnabled then
        return
    end

    if #CONFIG.trackerWhitelist == 0 and not CONFIG.trackerTraceUnlisted then
        hideTrackerEntries()
        return
    end

    local character = player.Character
    if not character then
        hideTrackerEntries()
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hideTrackerEntries()
        return
    end

    local playerPos = hrp.Position
    local selectedEntries = {}
    local selectedLookup = {}
    local nearestByName = {}
    local candidates = {}

    for part, _ in pairs(trackedParts) do
        if part and part.Parent and trackerShouldTrace(part.Name) then
            local distance = (part.Position - playerPos).Magnitude
            if CONFIG.radius == 0 or distance <= CONFIG.radius then
                local existing = nearestByName[part.Name]
                if not existing or distance < existing.distance then
                    nearestByName[part.Name] = {
                        entry = getTrackerEntry(part),
                        distance = distance,
                    }
                end
            end
        end
    end

    for _, candidate in pairs(nearestByName) do
        table.insert(candidates, candidate)
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

    for _, entry in pairs(trackerEntries) do
        if entry.visible and not selectedLookup[entry] then
            setEntryVisible(entry, false)
        end
    end

    trackerActiveEntries = selectedEntries
    updateTrackerEsp()
end

rebuildTrackerWhitelistList = function()
    for _, row in ipairs(trackerWhitelistRows) do
        row:Destroy()
    end
    table.clear(trackerWhitelistRows)

    for _, oreName in ipairs(CONFIG.trackerWhitelist) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -18, 0, 30)
        row.BackgroundColor3 = THEME.panel
        row.BorderSizePixel = 0
        row.ZIndex = 22
        row.Parent = trackerWhitelistList
        addCorner(row, 10)
        addStroke(row, THEME.border, 2)

        local nameLabel = makeStatusLabel(row, 8, 6, 210)
        nameLabel.Text = oreName
        nameLabel.TextColor3 = THEME.white
        nameLabel.ZIndex = 23

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
        removeBtn.ZIndex = 23
        removeBtn.Parent = row
        addCorner(removeBtn, 8)
        addStroke(removeBtn, Color3.fromRGB(160, 25, 25), 2)
        enableButtonMotion(removeBtn, 1.04, 0.94)

        connect(removeBtn.MouseButton1Click, function()
            removeTrackerWhitelist(oreName)
            rebuildTrackerWhitelistList()
            hideTrackerEntries()
            requestTargetRefresh()
            setStatus(trackerWhitelistStatus, "Removed " .. oreName, THEME.muted)
            if trackerEnabled then
                setStatus(trackerStatus, "Tracker enabled for " .. tostring(#CONFIG.trackerWhitelist) .. " whitelisted ores.", THEME.white)
            end
        end)

        table.insert(trackerWhitelistRows, row)
    end

    captureGuiTransparency()
end

connect(trackerWhitelistLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    trackerWhitelistList.CanvasSize = UDim2.new(0, 0, 0, trackerWhitelistLayout.AbsoluteContentSize.Y + 8)
end)
