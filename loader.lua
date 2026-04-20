local StarterGui = game:GetService("StarterGui")
local MAIN_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/main.lua"

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MagnetoZz",
            Text = text,
            Duration = 5,
        })
    end)
end

notify("Loader started")

local okFetch, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not okFetch or type(source) ~= "string" then
    notify("Failed to fetch main.lua")
    error("MagnetoZz loader failed to fetch main.lua: " .. tostring(source))
end

notify("main.lua fetched")

local mainFn, compileErr = loadstring(source)
if not mainFn then
    notify("main.lua compile failed")
    error("MagnetoZz loader failed to compile main.lua: " .. tostring(compileErr))
end

notify("main.lua running")

local okRun, runErr = pcall(mainFn)
if not okRun then
    notify("main.lua runtime failed")
    error("MagnetoZz loader runtime error: " .. tostring(runErr))
end

notify("MagnetoZz ready")
