local BASE_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/"

local MODULES = {
    "Modules/bootstrap.lua",
    "Modules/shell.lua",
    "Modules/pages.lua",
    "Modules/data.lua",
    "Modules/esp.lua",
    "Modules/events.lua",
}

local rootEnv = getfenv and getfenv(0) or _G
local env = setmetatable({}, {
    __index = rootEnv,
})
env._G = env
env.script = script
env.shared = shared

local function runModule(path)
    local url = BASE_URL .. path
    local source = game:HttpGet(url)
    local fn, err = loadstring(source)
    if not fn then
        error("MagnetoZz failed to compile " .. path .. ": " .. tostring(err))
    end
    if setfenv then
        setfenv(fn, env)
    end
    return fn()
end

for _, path in ipairs(MODULES) do
    runModule(path)
end
