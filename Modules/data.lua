-- MagnetoZz modular chunk: 04_data.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
function applyConfigPayload(payload)
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
        applyPartColorPayload(payload.partColors)
    end
    if typeof(payload.partThickness) == "table" then
        for partName, thickness in pairs(payload.partThickness) do
            if typeof(partName) == "string" and tonumber(thickness) then
                CONFIG.partThickness[partName] = math.clamp(tonumber(thickness), 0.5, 12)
            end
        end
    end
    if typeof(payload.trackerWhitelist) == "table" then
        CONFIG.trackerWhitelist = {}
        for _, oreName in ipairs(payload.trackerWhitelist) do
            if typeof(oreName) == "string" and trim(oreName) ~= "" then
                table.insert(CONFIG.trackerWhitelist, trim(oreName))
            end
        end
    end
    if typeof(payload.trackerTraceUnlisted) == "boolean" then
        CONFIG.trackerTraceUnlisted = payload.trackerTraceUnlisted
    end
    if typeof(payload.trackerMinRecognizedThickness) == "number" then
        CONFIG.trackerMinRecognizedThickness = math.clamp(payload.trackerMinRecognizedThickness, 0.5, 12)
    end
    refreshUiInputs()
    if rebuildTrackerWhitelistList then
        rebuildTrackerWhitelistList()
    end
    requestTargetRefresh()
    return true, "Config loaded."
end

function getHttpRequest()
    if typeof(request) == "function" then
        return request
    end
    if typeof(http_request) == "function" then
        return http_request
    end
    if typeof(syn) == "table" and typeof(syn.request) == "function" then
        return syn.request
    end
    if typeof(http) == "table" and typeof(http.request) == "function" then
        return http.request
    end
    if typeof(fluxus) == "table" and typeof(fluxus.request) == "function" then
        return fluxus.request
    end
    return nil
end

function supabaseHeaders(prefer)
    local headers = {
        apikey = SUPABASE_ANON_KEY,
        Authorization = "Bearer " .. SUPABASE_ANON_KEY,
    }
    if prefer then
        headers.Prefer = prefer
    end
    return headers
end

function supabaseRequest(method, path, body, prefer)
    local requestFn = getHttpRequest()
    if not requestFn then
        return false, "Executor HTTP request is not available."
    end

    local headers = supabaseHeaders(prefer)
    if body ~= nil then
        headers["Content-Type"] = "application/json"
    end

    local requestOk, response = pcall(function()
        return requestFn({
            Url = SUPABASE_URL .. "/rest/v1/" .. path,
            Method = method,
            Headers = headers,
            Body = body ~= nil and HttpService:JSONEncode(body) or nil,
        })
    end)

    if not requestOk then
        return false, "Supabase request failed: " .. tostring(response)
    end

    local rawStatus = response and (response.StatusCode or response.status_code or response.Status or response.status)
    local status = tonumber(rawStatus) or tonumber(tostring(rawStatus):match("%d+")) or 0
    local responseBody = response and (response.Body or response.body) or ""
    if status < 200 or status >= 300 then
        return false, "Supabase HTTP " .. tostring(status) .. ": " .. tostring(responseBody)
    end

    if responseBody == "" then
        return true, nil
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(responseBody)
    end)
    if not ok then
        return true, nil
    end
    return true, decoded
end

function applyPartColorPayload(partColors)
    CONFIG.partColors = {}
    CONFIG.partThickness = {}
    CONFIG.trackerWhitelist = {}

    for partName, value in pairs(partColors) do
        if partName == "__trackerWhitelist" and typeof(value) == "table" and typeof(value.whitelist) == "table" then
            for _, oreName in ipairs(value.whitelist) do
                if typeof(oreName) == "string" and trim(oreName) ~= "" then
                    table.insert(CONFIG.trackerWhitelist, trim(oreName))
                end
            end
            if typeof(value.traceUnlisted) == "boolean" then
                CONFIG.trackerTraceUnlisted = value.traceUnlisted
            end
            if typeof(value.minRecognizedThickness) == "number" then
                CONFIG.trackerMinRecognizedThickness = math.clamp(value.minRecognizedThickness, 0.5, 12)
            end
        elseif partName == "__guiSettings" and typeof(value) == "table" then
            applyGuiSettingsPayload(value)
        elseif typeof(partName) == "string" then
            local hex = nil
            local thickness = nil

            if typeof(value) == "string" then
                hex = value
            elseif typeof(value) == "table" then
                hex = value.color or value.hex
                thickness = tonumber(value.thickness)
            end

            if typeof(hex) == "string" then
                local loadedColor = colorFromHex(hex)
                if loadedColor then
                    CONFIG.partColors[partName] = loadedColor
                    if thickness then
                        CONFIG.partThickness[partName] = math.clamp(thickness, 0.5, 12)
                    end
                end
            end
        end
    end
end

function buildGuiSettingsPayload()
    return {
        accentColor = colorToHex(GUI_SETTINGS.accentColor),
        titleTextSize = GUI_SETTINGS.titleTextSize,
        bodyTextSize = GUI_SETTINGS.bodyTextSize,
        buttonTextSize = GUI_SETTINGS.buttonTextSize,
        animationsEnabled = GUI_SETTINGS.animationsEnabled,
        toggleKey = GUI_SETTINGS.toggleKey.Name,
        espToggleKey = GUI_SETTINGS.espToggleKey.Name,
        trackerToggleKey = GUI_SETTINGS.trackerToggleKey.Name,
    }
end

function applyGuiSettingsPayload(payload)
    if typeof(payload) ~= "table" then
        return
    end

    if typeof(payload.accentColor) == "string" then
        local loadedAccent = colorFromHex(payload.accentColor)
        if loadedAccent then
            GUI_SETTINGS.accentColor = loadedAccent
        end
    end

    if typeof(payload.titleTextSize) == "number" then
        GUI_SETTINGS.titleTextSize = math.clamp(payload.titleTextSize, 20, 34)
    end
    if typeof(payload.bodyTextSize) == "number" then
        GUI_SETTINGS.bodyTextSize = math.clamp(payload.bodyTextSize, 11, 18)
    end
    if typeof(payload.buttonTextSize) == "number" then
        GUI_SETTINGS.buttonTextSize = math.clamp(payload.buttonTextSize, 14, 20)
    else
        GUI_SETTINGS.buttonTextSize = math.clamp(GUI_SETTINGS.bodyTextSize + 4, 14, 20)
    end
    if typeof(payload.animationsEnabled) == "boolean" then
        GUI_SETTINGS.animationsEnabled = payload.animationsEnabled
    end

    if typeof(payload.toggleKey) == "string" then
        local loadedKey = keyCodeFromText(payload.toggleKey)
        if loadedKey then
            GUI_SETTINGS.toggleKey = loadedKey
        end
    end
    if typeof(payload.espToggleKey) == "string" then
        local loadedKey = keyCodeFromText(payload.espToggleKey)
        if loadedKey then
            GUI_SETTINGS.espToggleKey = loadedKey
        end
    end
    if typeof(payload.trackerToggleKey) == "string" then
        local loadedKey = keyCodeFromText(payload.trackerToggleKey)
        if loadedKey then
            GUI_SETTINGS.trackerToggleKey = loadedKey
        end
    end
end

function buildPartColorPayload()
    local payload = {}
    for partName, color in pairs(CONFIG.partColors) do
        payload[partName] = {
            color = colorToHex(color),
            thickness = CONFIG.partThickness[partName] or CONFIG.screenLineThickness,
        }
    end
    payload.__trackerWhitelist = {
        whitelist = CONFIG.trackerWhitelist,
        traceUnlisted = CONFIG.trackerTraceUnlisted,
        minRecognizedThickness = CONFIG.trackerMinRecognizedThickness,
    }
    payload.__guiSettings = buildGuiSettingsPayload()
    return payload
end

function saveConfig()
    local playerId = player.UserId
    local configPayload = {
        {
            player_id = playerId,
            player_name = player.Name,
            radius = CONFIG.radius,
            label_distance = CONFIG.labelDistance,
            default_line_color = colorToHex(CONFIG.defaultColor),
            gui_accent = colorToHex(GUI_SETTINGS.accentColor),
            part_colors = buildPartColorPayload(),
            updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        },
    }

    local ok, result = supabaseRequest(
        "POST",
        "magnetozz_config?on_conflict=player_id",
        configPayload,
        "resolution=merge-duplicates,return=minimal"
    )
    if not ok then
        return false, result
    end

    ok, result = supabaseRequest(
        "DELETE",
        "magnetozz_blacklist?player_id=eq." .. tostring(playerId),
        nil,
        "return=minimal"
    )
    if not ok then
        return false, result
    end

    local blacklistRows = {}
    for _, partName in ipairs(CONFIG.ignore) do
        if typeof(partName) == "string" and trim(partName) ~= "" then
            table.insert(blacklistRows, {
                player_id = playerId,
                player_name = player.Name,
                part_name = trim(partName),
            })
        end
    end

    if #blacklistRows > 0 then
        ok, result = supabaseRequest(
            "POST",
            "magnetozz_blacklist",
            blacklistRows,
            "return=minimal"
        )
        if not ok then
            return false, result
        end
    end

    return true, "Saved config, blacklist, and tracker whitelist to Supabase."
end

function loadConfig()
    local playerId = player.UserId
    local ok, configRows = supabaseRequest(
        "GET",
        "magnetozz_config?player_id=eq." .. tostring(playerId) .. "&select=*"
    )
    if not ok then
        return false, configRows
    end

    local config = typeof(configRows) == "table" and configRows[1] or nil
    if config then
        if typeof(config.radius) == "number" then
            CONFIG.radius = math.max(0, config.radius)
        end
        if typeof(config.label_distance) == "number" then
            CONFIG.labelDistance = math.max(2, config.label_distance)
        end
        if typeof(config.default_line_color) == "string" then
            local loadedColor = colorFromHex(config.default_line_color)
            if loadedColor then
                CONFIG.defaultColor = loadedColor
            end
        end
        if typeof(config.gui_accent) == "string" then
            local loadedAccent = colorFromHex(config.gui_accent)
            if loadedAccent then
                GUI_SETTINGS.accentColor = loadedAccent
            end
        end
        if typeof(config.gui_settings) == "table" then
            applyGuiSettingsPayload(config.gui_settings)
        end
        if typeof(config.part_colors) == "table" then
            applyPartColorPayload(config.part_colors)
        end
    end

    local blacklistOk, blacklistRows = supabaseRequest(
        "GET",
        "magnetozz_blacklist?player_id=eq." .. tostring(playerId) .. "&select=part_name"
    )
    if not blacklistOk then
        return false, blacklistRows
    end

    if typeof(blacklistRows) == "table" then
        CONFIG.ignore = {}
        for _, row in ipairs(blacklistRows) do
            if typeof(row) == "table" and typeof(row.part_name) == "string" and trim(row.part_name) ~= "" then
                table.insert(CONFIG.ignore, trim(row.part_name))
            end
        end
    end

    refreshUiInputs()
    applyGuiSettings()
    rebuildPartColorList()
    rebuildBlacklistList()
    if rebuildTrackerWhitelistList then
        rebuildTrackerWhitelistList()
    end
    refreshAllAppearances()
    requestTargetRefresh()

    if config then
        return true, "Loaded Supabase profile."
    end
    return false, "No Supabase config found yet. Save first."
end

function destroyEntry(entry)
    if entry.drawLine then
        pcall(function()
            entry.drawLine:Remove()
        end)
        entry.drawLine = nil
    end
    if entry.drawText then
        pcall(function()
            entry.drawText:Remove()
        end)
        entry.drawText = nil
    end
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

function ensureEntryVisuals(entry)
    if USE_DRAWING then
        if entry.drawLine and entry.drawText then
            return
        end

        entry.drawLine = createDrawingLine()
        entry.drawText = createDrawingText(entry.part.Name, getColor(entry.part.Name))
        if not entry.drawLine or not entry.drawText then
            if entry.drawLine then
                pcall(function()
                    entry.drawLine:Remove()
                end)
                entry.drawLine = nil
            end
            if entry.drawText then
                pcall(function()
                    entry.drawText:Remove()
                end)
                entry.drawText = nil
            end
            USE_DRAWING = false
        else
            return
        end
    end

    if entry.line and entry.anchor and entry.label and entry.labelText then
        return
    end
    entry.line = createLinePart()
    entry.anchor = createLabelAnchor()
    entry.label, entry.labelText = createBillboard(entry.anchor, entry.part.Name, getColor(entry.part.Name), screenGui)
end

function refreshEntryAppearance(entry)
    if not entry.part or not entry.part.Parent then
        return
    end
    local color = getColor(entry.part.Name)
    if entry.drawLine then
        entry.drawLine.Color = color
        entry.drawLine.Thickness = getTracerThickness(entry.part.Name)
    end
    if entry.drawText then
        entry.drawText.Text = entry.part.Name
        entry.drawText.Color = color
    end
    if entry.line then
        entry.line.Color = color
    end
    if entry.labelText then
        entry.labelText.Text = entry.part.Name
        entry.labelText.TextColor3 = color
    end
end

refreshAllAppearances = function()
    lineColorPreview.BackgroundColor3 = CONFIG.defaultColor
    defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
    accentHex.Text = "#" .. colorToHex(CONFIG.defaultColor) .. " click square to change"
    for _, entry in pairs(trackedParts) do
        refreshEntryAppearance(entry)
    end
    for _, entry in pairs(trackerEntries) do
        refreshEntryAppearance(entry)
    end
end
