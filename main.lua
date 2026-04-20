local BASE_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/"
local StarterGui = game:GetService("StarterGui")

local MODULES = {
    "Modules/bootstrap.lua",
    "Modules/shell.lua",
    "Modules/pages.lua",
    "Modules/data.lua",
    "Modules/esp.lua",
    "Modules/events.lua",
}

print("MagnetoZz EXEC debug: main started")

local function notify(text)
    print("MagnetoZz Loader: " .. text)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MagnetoZz",
            Text = text,
            Duration = 3,
        })
    end)
end

local rootEnv = (getgenv and getgenv()) or (getfenv and getfenv()) or _G or {}

local env = setmetatable({
    game = game,
    workspace = workspace,
    script = script,
    shared = shared,
    Drawing = Drawing,
    getgenv = getgenv,
    request = request,
    http_request = http_request,
    syn = syn,
    http = http,
    fluxus = fluxus,
    loadstring = loadstring,
    print = print,
    warn = warn,
    error = error,
    tostring = tostring,
    tonumber = tonumber,
    type = type,
    typeof = typeof,
    pairs = pairs,
    ipairs = ipairs,
    pcall = pcall,
    xpcall = xpcall,
    table = table,
    string = string,
    math = math,
    os = os,
    task = task,
    Color3 = Color3,
    Vector2 = Vector2,
    Vector3 = Vector3,
    UDim = UDim,
    UDim2 = UDim2,
    CFrame = CFrame,
    Enum = Enum,
    Instance = Instance,
    TweenInfo = TweenInfo,
}, {
    __index = rootEnv,
})

env._G = env

local function fetchModule(path)
    local url = BASE_URL .. path
    print("MagnetoZz EXEC debug: fetching " .. path)

    local okFetch, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not okFetch or type(source) ~= "string" then
        error("MagnetoZz failed to fetch " .. path .. " from " .. url .. ": " .. tostring(source))
    end

    if source:find("^404") or source:find("Not Found", 1, true) then
        error("MagnetoZz got 404 for " .. path .. ". Check GitHub path/case: " .. url)
    end

    return source
end

local function runModule(path)
    local source = fetchModule(path)
    local fn, compileErr = loadstring(source)

    if not fn then
        error("MagnetoZz compile failed in " .. path .. ": " .. tostring(compileErr))
    end

    if setfenv then
        setfenv(fn, env)
    end

    print("MagnetoZz EXEC debug: running " .. path)

    local okRun, runErr = pcall(fn)
    if not okRun then
        error("MagnetoZz runtime failed in " .. path .. ": " .. tostring(runErr))
    end
end

for _, path in ipairs(MODULES) do
    runModule(path)
end

notify("Finished")
print("MagnetoZz EXEC debug: ready")
