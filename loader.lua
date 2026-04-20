local MAIN_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/main.lua"

print("MagnetoZz EXEC debug: loader started")

local okFetch, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not okFetch or type(source) ~= "string" then
    error("MagnetoZz loader failed to fetch main.lua: " .. tostring(source))
end

local mainFn, compileErr = loadstring(source)
if not mainFn then
    error("MagnetoZz loader failed to compile main.lua: " .. tostring(compileErr))
end

local okRun, runErr = pcall(mainFn)
if not okRun then
    error("MagnetoZz loader runtime error: " .. tostring(runErr))
end
