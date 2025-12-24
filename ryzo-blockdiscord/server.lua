local json = json
local resourceName = GetCurrentResourceName()

local function loadBannedFile()
    local content = LoadResourceFile(resourceName, Config.BannedListFile)
    if not content then
        return {}
    end
    local ok, parsed = pcall(json.decode, content)
    if not ok or type(parsed) ~= 'table' then
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
    for k,_ in pairs(tbl) do
        table.insert(arr, k)
    end
    local ok, encoded = pcall(json.encode, arr)
    if not ok then return false end
    SaveResourceFile(resourceName, Config.BannedListFile, encoded, -1)
    return true
end

local bannedMap = loadBannedFile()

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    local identifiers = GetPlayerIdentifiers(src) or {}
    for _, id in ipairs(identifiers) do
        if bannedMap[tostring(id)] then
            deferrals.done("You are blocked for this server, for support join the discord: discord.gg/yourlink")
            return
        end
    end

    if Config.BlockByPlayerName and Config.BlockedPlayerNames then
        for _, blockedName in ipairs(Config.BlockedPlayerNames) do
            if playerName == blockedName then
                deferrals.done("You are blocked for this server, for support join the discord: discord.gg/yourlink")
                return
            end
        end
    end

    deferrals.done()
end)

RegisterCommand('ryzo_removediscordban', function(source, args, raw)
    if source ~= 0 then
        print("This command must be run from server console.")
        return
    end
    local id = args[1]
    if not id then
        print("Usage: ryzo_removediscordban discord:123456789012345678")
        return
    end
    bannedMap[tostring(id)] = nil
    if saveBannedFile(bannedMap) then
        print("Removed and saved: " .. id)
    else
        print("Failed to save file.")
    end
end, true)

RegisterCommand('ryzo_listbans', function(source, args, raw)
    if source ~= 0 then
        print("This command must be run from server console.")
        return
    end
    print("Current banned discord IDs:")
    for k,_ in pairs(bannedMap) do
        print(k)
    end
end, true)