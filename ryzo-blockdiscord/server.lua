local resourceName = GetCurrentResourceName()
local bannedMap = {}

local function loadBannedFile()
    local content = LoadResourceFile(resourceName, Config.BannedListFile)
    if not content or content == "" then
        print("^3[Warning] Banned file not found or empty, creating new map.^7")
        return {}
    end
    
    local ok, parsed = pcall(json.decode, content)
    if not ok or type(parsed) ~= 'table' then
        print("^1[Error] Failed to decode JSON. Check format in " .. Config.BannedListFile .. "^7")
        return {}
    end
    
    local map = {}
    for _, v in ipairs(parsed) do
        map[tostring(v)] = true
    end
    return map
end

local function saveBannedFile(tbl)
    local arr = {}
    for k, _ in pairs(tbl) do
        table.insert(arr, k)
    end
    
    local encoded = json.encode(arr, { indent = true })
    local saveStatus = SaveResourceFile(resourceName, Config.BannedListFile, encoded, -1)
    
    if not saveStatus then
        print("^1[Error] Could not save to " .. Config.BannedListFile .. ". Make sure the folder exists!^7")
    end
    return saveStatus
end

bannedMap = loadBannedFile()

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    
    Wait(100)
    
    deferrals.update(string.format("Hello %s, checking entry permissions...", playerName))

    local identifiers = GetPlayerIdentifiers(src)
    local isBanned = false
    local reason = "You are blocked from this server, for support join the discord: https://discord.gg/yourlink"

    if identifiers then
        for _, id in ipairs(identifiers) do
            if bannedMap[tostring(id)] then
                isBanned = true
                break
            end
        end
    end

    if not isBanned and Config.BlockByPlayerName then
        for _, blockedName in ipairs(Config.BlockedPlayerNames) do
            if playerName == blockedName then
                isBanned = true
                break
            end
        end
    end

    if isBanned then
        deferrals.done(reason)
    else
        deferrals.done()
    end
end)

RegisterCommand('ryzo_removediscordban', function(source, args, raw)
    if source ~= 0 then return print("Command for console only.") end
    
    local id = args[1]
    if not id then return print("Usage: ryzo_removediscordban discord:ID") end
    
    if bannedMap[id] then
        bannedMap[id] = nil
        if saveBannedFile(bannedMap) then
            print("^2Successfully removed and saved: " .. id .. "^7")
        end
    else
        print("^3ID not found in ban list.^7")
    end
end, true)

RegisterCommand('listbans', function(source, args, raw)
    if source ~= 0 then return print("Command for console only.") end
    
    print("^1--- Banned Discord IDs ---^7")
    local count = 0
    for k, _ in pairs(bannedMap) do
        print(k)
        count = count + 1
    end
    print("^1Total: " .. count .. "^7")
end, true)
