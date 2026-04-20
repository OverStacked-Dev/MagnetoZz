local BASE_URL = "https://raw.githubusercontent.com/OverStacked-Dev/MagnetoZz/main/"

local MODULES = {
    "Modules/bootstrap.lua",
    "Modules/shell.lua",
    "Modules/pages.lua",
    "Modules/data.lua",
    "Modules/esp.lua",
    "Modules/events.lua",
}

local rootEnv = getfenv and getfenv() or _G or {}

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

local function runModule(path)
    local source = game:HttpGet(BASE_URL .. path)
    local fn, err = loadstring(source)

    if not fn then
        error("MagnetoZz compile failed in " .. path .. ": " .. tostring(err))
    end

    if setfenv then
        setfenv(fn, env)
    end

    return fn()
end

for _, path in ipairs(MODULES) do
    runModule(path)
end
