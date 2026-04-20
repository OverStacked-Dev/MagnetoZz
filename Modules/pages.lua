-- MagnetoZz modular chunk: 03_pages.lua -- Generated from MagnetoZz.lua. Edit the source carefully or regenerate chunks. 
espPage = makePage("esp")
configPage = makePage("config")
blacklistPage = makePage("blacklist")
guiPage = makePage("gui")
profilesPage = makePage("profiles")

espSection = makeSection(espPage, "Runtime", 0, 176)
espToggleBtn = makeActionButton(espSection, "ESP OFF", 12, 44, 146, THEME.danger)
espStatus = makeStatusLabel(espSection, 172, 52, 300)
trackerToggleBtn = makeActionButton(espSection, "Tracker ESP OFF", 12, 84, 146, THEME.danger)
trackerConfigBtn = makeActionButton(espSection, string.char(226, 154, 153), 170, 84, 34, THEME.panelAlt)
trackerStatus = makeStatusLabel(espSection, 218, 92, 300)
trackerStatus.Text = "Whitelist tracker. Click the gear to choose ores."
espInfo = makeStatusLabel(espSection, 12, 132, 450)
espInfo.Size = UDim2.new(1, -24, 0, 24)
espInfo.TextWrapped = true
espInfo.Text = "Labels stay close to the player and point toward the tracked part."
espInfo.TextColor3 = THEME.white

themeSection = makeSection(espPage, "Visual Theme", 192, 134)
lineColorPreview = Instance.new("TextButton")
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
accentName = makeStatusLabel(themeSection, 90, 46, 240)
accentName.Text = "Default line color"
accentName.TextColor3 = THEME.white
accentName.TextSize = 16
accentName.Font = Enum.Font.GothamBold
accentHex = makeStatusLabel(themeSection, 90, 76, 260)
accentHex.Text = "#FFFFFF click square to change"
accentHint = makeStatusLabel(themeSection, 90, 96, 300)
accentHint.Text = "GUI accent is separate from line color."
accentHint.TextColor3 = THEME.white

configTop = makeSection(configPage, "Settings", 0, 96)
makeLabel(configTop, "Radius", 96, 34, 80)
radiusInput = makeInput(configTop, "500", 96, 54, 108)
radiusInput.Text = tostring(CONFIG.radius)
defaultColorLabel = makeLabel(configTop, "Default Color", 148, 42, 100)
defaultColorLabel.Visible = false
defaultColorInput = makeInput(configTop, "FFFFFF", 148, 62, 108)
defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
defaultColorInput.Visible = false
makeLabel(configTop, "Label Distance", 244, 34, 110)
labelDistanceInput = makeInput(configTop, "6", 244, 54, 108)
labelDistanceInput.Text = tostring(CONFIG.labelDistance)
applyBtn = makeActionButton(configTop, "Apply", 392, 54, 92, THEME.accent)
applyStatus = makeStatusLabel(configTop, 18, 78, 360)

partColorSection = makeSection(configPage, "Manual Tracer Settings", 112, 270)
mtsSearchInput = makeInput(partColorSection, "Search tracer", 354, 8, 176)
partColorList = Instance.new("ScrollingFrame")
partColorList.Size = UDim2.new(1, -24, 0, 160)
partColorList.Position = UDim2.new(0, 12, 0, 50)
partColorList.BackgroundColor3 = THEME.panelAlt
partColorList.BorderSizePixel = 0
partColorList.ScrollBarThickness = 4
partColorList.CanvasSize = UDim2.new(0, 0, 0, 0)
partColorList.Parent = partColorSection
addCorner(partColorList, 12)
addStroke(partColorList, THEME.border, 2)
partColorLayout = Instance.new("UIListLayout")
partColorLayout.Padding = UDim.new(0, 6)
partColorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
partColorLayout.Parent = partColorList
addNameInput = makeInput(partColorSection, "Ore Name", 51, 222, 145)
addColorInput = makeInput(partColorSection, "Color", 206, 222, 90)
addThicknessInput = makeInput(partColorSection, "Thickness", 306, 222, 92)
addThicknessInput.Text = tostring(CONFIG.screenLineThickness)
addColorBtn = makeActionButton(partColorSection, "Add Tracer", 410, 222, 110, THEME.success)
partColorStatus = makeStatusLabel(partColorSection, 51, 252, 430)

blacklistSection = makeSection(blacklistPage, "Ignored Ores", 0, 320)
blacklistList = Instance.new("ScrollingFrame")
blacklistList.Size = UDim2.new(1, -24, 0, 194)
blacklistList.Position = UDim2.new(0, 12, 0, 42)
blacklistList.BackgroundColor3 = THEME.panelAlt
blacklistList.BorderSizePixel = 0
blacklistList.ScrollBarThickness = 4
blacklistList.CanvasSize = UDim2.new(0, 0, 0, 0)
blacklistList.Parent = blacklistSection
addCorner(blacklistList, 12)
addStroke(blacklistList, THEME.border, 2)
blacklistLayout = Instance.new("UIListLayout")
blacklistLayout.Padding = UDim.new(0, 6)
blacklistLayout.Parent = blacklistList
blacklistInput = makeInput(blacklistSection, "Ore to ignore", 127, 246, 220)
addBlacklistBtn = makeActionButton(blacklistSection, "Add", 357, 246, 86, THEME.success)
blacklistStatus = makeStatusLabel(blacklistSection, 12, 286, 360)

guiMainSection = makeSection(guiPage, "Gui Settings", 0, 232)
makeLabel(guiMainSection, "GUI Accent", 12, 42, 100)
guiAccentInput = makeInput(guiMainSection, "4864FF", 12, 62, 110)
guiAccentInput.Text = colorToHex(GUI_SETTINGS.accentColor)
makeLabel(guiMainSection, "Title Size", 142, 42, 100)
guiTitleSizeInput = makeInput(guiMainSection, "26", 142, 62, 92)
guiTitleSizeInput.Text = tostring(GUI_SETTINGS.titleTextSize)
makeLabel(guiMainSection, "Body Size", 252, 42, 100)
guiBodySizeInput = makeInput(guiMainSection, "12", 252, 62, 92)
guiBodySizeInput.Text = tostring(GUI_SETTINGS.bodyTextSize)
guiAnimationToggle = makeActionButton(guiMainSection, "Animations: ON", 362, 62, 140, THEME.success)
makeLabel(guiMainSection, "Toggle Key", 12, 102, 100)
guiKeybindInput = makeInput(guiMainSection, "RightShift", 12, 122, 130)
guiKeybindInput.Text = GUI_SETTINGS.toggleKey.Name
makeLabel(guiMainSection, "ESP Toggle Key", 160, 102, 120)
guiEspKeybindInput = makeInput(guiMainSection, "RightControl", 160, 122, 130)
guiEspKeybindInput.Text = GUI_SETTINGS.espToggleKey.Name
makeLabel(guiMainSection, "Tracker Key", 308, 102, 110)
guiTrackerKeybindInput = makeInput(guiMainSection, "RightAlt", 308, 122, 116)
guiTrackerKeybindInput.Text = GUI_SETTINGS.trackerToggleKey.Name
guiApplyBtn = makeActionButton(guiMainSection, "Apply GUI", 12, 172, 128, THEME.accent)
guiResetBtn = makeActionButton(guiMainSection, "Reset GUI", 152, 172, 118, THEME.panelAlt)
guiStatus = makeStatusLabel(guiMainSection, 292, 180, 250)

guiExtraSection = makeSection(guiPage, "What Changes", 248, 96)
guiInfo = makeStatusLabel(guiExtraSection, 12, 36, 480)
guiInfo.Size = UDim2.new(1, -24, 0, 40)
guiInfo.TextWrapped = true
guiInfo.Text = "Accent color affects the menu highlight only. Default line color is managed separately from the ESP page."
guiInfo.TextColor3 = THEME.white

profilesSection = makeSection(profilesPage, "Save / Load Profile", 0, 190)
profilesHint = makeStatusLabel(profilesSection, 12, 46, 500)
profilesHint.Size = UDim2.new(1, -24, 0, 56)
profilesHint.TextWrapped = true
profilesHint.Text = "Save and load your profile from Supabase. Blacklist, Tracker Whitelist, and Manual Tracer Settings use your Roblox UserId."
profilesHint.TextColor3 = THEME.white
exportBtn = makeActionButton(profilesSection, "Save", 12, 120, 136, THEME.success)
importBtn = makeActionButton(profilesSection, "Load", 160, 120, 136, THEME.accent)
resetPathBtn = makeActionButton(profilesSection, "DataBase Info", 308, 120, 132, THEME.panelAlt)
profilesStatus = makeStatusLabel(profilesSection, 12, 162, 450)

lineColorPrompt = Instance.new("Frame")
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
lineColorPromptScale = Instance.new("UIScale")
lineColorPromptScale.Name = "PromptScale"
lineColorPromptScale.Scale = 1
lineColorPromptScale.Parent = lineColorPrompt

promptTitle = makeStatusLabel(lineColorPrompt, 18, 14, 250)
promptTitle.Text = "Default Line Color"
promptTitle.TextColor3 = THEME.white
promptTitle.TextSize = 18
promptTitle.Font = Enum.Font.GothamBold
promptTitle.ZIndex = 21

promptHint = makeStatusLabel(lineColorPrompt, 18, 44, 250)
promptHint.Size = UDim2.new(1, -32, 0, 32)
promptHint.TextWrapped = true
promptHint.Text = "Enter a HEX color like FFFFFF."
promptHint.TextColor3 = THEME.white
promptHint.ZIndex = 21

lineColorPromptInput = makeInput(lineColorPrompt, "FFFFFF", 18, 88, 118)
lineColorPromptInput.ZIndex = 21
lineColorPromptApply = makeActionButton(lineColorPrompt, "Apply", 148, 88, 64, THEME.accent)
lineColorPromptApply.ZIndex = 21
lineColorPromptCancel = makeActionButton(lineColorPrompt, "Close", 222, 88, 58, THEME.panelAlt)
lineColorPromptCancel.ZIndex = 21
lineColorPromptStatus = makeStatusLabel(lineColorPrompt, 18, 132, 250)
lineColorPromptStatus.ZIndex = 21

tracerEditPrompt = Instance.new("Frame")
tracerEditPrompt.Size = UDim2.new(0, 340, 0, 224)
tracerEditPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
tracerEditPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
tracerEditPrompt.BackgroundColor3 = THEME.panel
tracerEditPrompt.BorderSizePixel = 0
tracerEditPrompt.Visible = false
tracerEditPrompt.ZIndex = 20
tracerEditPrompt.Parent = mainFrame
addCorner(tracerEditPrompt, 16)
addStroke(tracerEditPrompt, THEME.border, 2)
tracerEditScale = Instance.new("UIScale")
tracerEditScale.Name = "PromptScale"
tracerEditScale.Scale = 1
tracerEditScale.Parent = tracerEditPrompt

tracerEditTitle = makeStatusLabel(tracerEditPrompt, 18, 14, 260)
tracerEditTitle.Text = "Edit Tracer"
tracerEditTitle.TextColor3 = THEME.white
tracerEditTitle.TextSize = 18
tracerEditTitle.Font = Enum.Font.GothamBold
tracerEditTitle.ZIndex = 21

tracerEditNameLabel = makeLabel(tracerEditPrompt, "Ore Name", 18, 48, 100)
tracerEditNameLabel.ZIndex = 21
tracerEditNameInput = makeInput(tracerEditPrompt, "Ore Name", 18, 68, 142)
tracerEditNameInput.ZIndex = 21
tracerEditColorLabel = makeLabel(tracerEditPrompt, "Color", 178, 48, 80)
tracerEditColorLabel.ZIndex = 21
tracerEditColorInput = makeInput(tracerEditPrompt, "Color", 178, 68, 110)
tracerEditColorInput.ZIndex = 21

tracerEditThicknessLabel = makeLabel(tracerEditPrompt, "Thickness", 18, 106, 100)
tracerEditThicknessLabel.ZIndex = 21
tracerEditThicknessInput = makeInput(tracerEditPrompt, "Thickness", 18, 126, 110)
tracerEditThicknessInput.ZIndex = 21

tracerSaveBtn = makeActionButton(tracerEditPrompt, "Save", 18, 166, 74, THEME.success)
tracerSaveBtn.ZIndex = 21
tracerCancelBtn = makeActionButton(tracerEditPrompt, "Cancel", 104, 166, 82, THEME.panelAlt)
tracerCancelBtn.ZIndex = 21
tracerDeleteBtn = makeActionButton(tracerEditPrompt, "Delete", 198, 166, 82, THEME.danger)
tracerDeleteBtn.ZIndex = 21
tracerEditStatus = makeStatusLabel(tracerEditPrompt, 18, 200, 300)
tracerEditStatus.ZIndex = 21

trackerConfigPrompt = Instance.new("Frame")
trackerConfigPrompt.Size = UDim2.new(0, 380, 0, 342)
trackerConfigPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
trackerConfigPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
trackerConfigPrompt.BackgroundColor3 = THEME.panel
trackerConfigPrompt.BorderSizePixel = 0
trackerConfigPrompt.Visible = false
trackerConfigPrompt.ZIndex = 20
trackerConfigPrompt.Parent = mainFrame
addCorner(trackerConfigPrompt, 16)
addStroke(trackerConfigPrompt, THEME.border, 2)
trackerConfigScale = Instance.new("UIScale")
trackerConfigScale.Name = "PromptScale"
trackerConfigScale.Scale = 1
trackerConfigScale.Parent = trackerConfigPrompt

trackerConfigTitle = makeStatusLabel(trackerConfigPrompt, 18, 14, 260)
trackerConfigTitle.Text = "Tracker Whitelist"
trackerConfigTitle.TextColor3 = THEME.white
trackerConfigTitle.TextSize = 18
trackerConfigTitle.Font = Enum.Font.GothamBold
trackerConfigTitle.ZIndex = 21

trackerConfigHint = makeStatusLabel(trackerConfigPrompt, 18, 42, 340)
trackerConfigHint.Size = UDim2.new(1, -36, 0, 34)
trackerConfigHint.TextWrapped = true
trackerConfigHint.Text = "Add ore names here. Tracker ESP renders only the closest match for each whitelisted ore."
trackerConfigHint.TextColor3 = THEME.white
trackerConfigHint.ZIndex = 21

trackerAutoTraceBtn = makeActionButton(trackerConfigPrompt, "[ ] Trace un-added ores to MTS", 18, 84, 236, THEME.panelAlt)
trackerAutoTraceBtn.ZIndex = 21
trackerAutoTraceLabel = makeLabel(trackerConfigPrompt, "Minimum Recognized Thickness", 18, 124, 190)
trackerAutoTraceLabel.ZIndex = 21
trackerMinThicknessInput = makeInput(trackerConfigPrompt, "5", 214, 120, 72)
trackerMinThicknessInput.Text = tostring(CONFIG.trackerMinRecognizedThickness)
trackerMinThicknessInput.ZIndex = 21
trackerMinThicknessApplyBtn = makeActionButton(trackerConfigPrompt, "Apply", 296, 120, 64, THEME.accent)
trackerMinThicknessApplyBtn.ZIndex = 21

trackerWhitelistList = Instance.new("ScrollingFrame")
trackerWhitelistList.Size = UDim2.new(1, -36, 0, 94)
trackerWhitelistList.Position = UDim2.new(0, 18, 0, 164)
trackerWhitelistList.BackgroundColor3 = THEME.panelAlt
trackerWhitelistList.BorderSizePixel = 0
trackerWhitelistList.ScrollBarThickness = 4
trackerWhitelistList.CanvasSize = UDim2.new(0, 0, 0, 0)
trackerWhitelistList.ZIndex = 21
trackerWhitelistList.Parent = trackerConfigPrompt
addCorner(trackerWhitelistList, 12)
addStroke(trackerWhitelistList, THEME.border, 2)
trackerWhitelistLayout = Instance.new("UIListLayout")
trackerWhitelistLayout.Padding = UDim.new(0, 6)
trackerWhitelistLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
trackerWhitelistLayout.Parent = trackerWhitelistList

trackerWhitelistInput = makeInput(trackerConfigPrompt, "Ore to track", 18, 270, 208)
trackerWhitelistInput.ZIndex = 21
trackerWhitelistAddBtn = makeActionButton(trackerConfigPrompt, "Add", 236, 270, 56, THEME.success)
trackerWhitelistAddBtn.ZIndex = 21
trackerWhitelistCloseBtn = makeActionButton(trackerConfigPrompt, "Close", 302, 270, 58, THEME.panelAlt)
trackerWhitelistCloseBtn.ZIndex = 21
trackerWhitelistStatus = makeStatusLabel(trackerConfigPrompt, 18, 306, 340)
trackerWhitelistStatus.ZIndex = 21

partColorRows = {}
blacklistRows = {}
trackerWhitelistRows = {}
selectedTracerName = nil
refreshAllAppearances = nil
rebuildPartColorList = nil
rebuildBlacklistList = nil
rebuildTrackerWhitelistList = nil
openTracerEditPrompt = nil
openTrackerConfigPrompt = nil

function refreshUiInputs()
    radiusInput.Text = tostring(CONFIG.radius)
    defaultColorInput.Text = colorToHex(CONFIG.defaultColor)
    labelDistanceInput.Text = tostring(CONFIG.labelDistance)
    guiAccentInput.Text = colorToHex(GUI_SETTINGS.accentColor)
    guiTitleSizeInput.Text = tostring(GUI_SETTINGS.titleTextSize)
    guiBodySizeInput.Text = tostring(GUI_SETTINGS.bodyTextSize)
    guiKeybindInput.Text = GUI_SETTINGS.toggleKey.Name
    guiEspKeybindInput.Text = GUI_SETTINGS.espToggleKey.Name
    guiTrackerKeybindInput.Text = GUI_SETTINGS.trackerToggleKey.Name
    guiAnimationToggle.Text = GUI_SETTINGS.animationsEnabled and "Animations: ON" or "Animations: OFF"
    guiAnimationToggle.BackgroundColor3 = GUI_SETTINGS.animationsEnabled and THEME.success or THEME.danger
    trackerAutoTraceBtn.Text = CONFIG.trackerTraceUnlisted and "[x] Trace un-added ores to MTS" or "[ ] Trace un-added ores to MTS"
    trackerAutoTraceBtn.BackgroundColor3 = CONFIG.trackerTraceUnlisted and THEME.success or THEME.panelAlt
    trackerMinThicknessInput.Text = tostring(CONFIG.trackerMinRecognizedThickness)
end

function applyGuiSettings()
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
    tracerEditTitle.TextSize = math.max(18, GUI_SETTINGS.bodyTextSize + 6)
    applyBtn.BackgroundColor3 = GUI_SETTINGS.accentColor
    guiApplyBtn.BackgroundColor3 = GUI_SETTINGS.accentColor
    lineColorPromptApply.BackgroundColor3 = GUI_SETTINGS.accentColor

    updatePageButtons()
end

