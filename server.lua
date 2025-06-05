local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local msgNoPermission = {
    locale('lang_1'),
    locale('lang_2'),
    locale('lang_3'),
    locale('lang_4'),
    locale('lang_5'),
    locale('lang_6'),
    locale('lang_7'),

}

local msgTitle = {locale('title_1'), locale('title_2')}
local msgOnline = locale('text_1')

local fToken = 'Bot '..Config.Discord.botToken

local function discordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = fToken})

    while data == nil do
        Wait(0)
    end
    return data
end

-- Function to get Discord ID from player identifiers
local function GetDiscordId(source)
    local discId = nil
    for _, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(v, 'discord:') then
            discId = string.gsub(v, 'discord:', '')
            break
        end
    end
    return discId
end

-- Function to check if user has a specific role
local function HasRole(userRoles, roleName)
    if not Config.Roles[roleName] then
        if Config.Discord.Debug then print("[Discord Debug] Role not found in config:", roleName) end
        return false
    end

    local roleId = Config.Roles[roleName].roleId
    if type(userRoles) ~= 'table' then return false end

    for _, role in ipairs(userRoles) do
        if tostring(role) == tostring(roleId) then
            return true
        end
    end
    return false
end

RegisterNetEvent('scoreboard:requestPlayers')
AddEventHandler('scoreboard:requestPlayers', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local playerJob = Player.PlayerData.job.type
    local discordId = GetDiscordId(src)
    if not discordId then
        if Config.Discord.Debug then print("[Discord Debug] No Discord ID found for player") end
        return
    end
    local endpoint = ('guilds/%s/members/%s'):format(Config.Discord.guildID, discordId)
    local member = discordRequest("GET", endpoint, {})

    if member.code ~= 200 then
        if Config.Discord.Debug then print("[Discord Debug] Failed to fetch member data") end
        return
    end
    local data = json.decode(member.data)
    local userRoles = data.roles
    local isAdmin = HasRole(userRoles, "admin")
    local roleName = nil
    if isAdmin then
        roleName = Config.Roles["admin"].name
    end
    -- local playerPerms = isAdmin or "user"
    local playeronDuty = Player.PlayerData.job.onduty == true

    local viewerPerms = {
        canViewJobs = (playerJob == "leo" or playerJob == "medic" or isAdmin),
        isAdmin = isAdmin,
        isLEO = (playerJob == "leo"),
        isMedic = (playerJob == "medic"),
        isOnDuty = (playeronDuty == true)
    }

    local players = {}
    local lawmen = 0
    local medics = 0
    local totalPlayers = 0

    for _, playerId in ipairs(GetPlayers()) do
        local targetSrc = tonumber(playerId)
        local targetPlayer = RSGCore.Functions.GetPlayer(targetSrc)
        if targetPlayer then
            totalPlayers = totalPlayers + 1
            local jobData = targetPlayer.PlayerData.job or {}
            local charinfo = targetPlayer.PlayerData.charinfo or {}
            local jobType = jobData.type
            local onDuty = jobData.onduty == true

            if jobType == "leo" and onDuty then
                lawmen = lawmen + 1
            elseif jobType == "medic" and onDuty then
                medics = medics + 1
            end

            table.insert(players, {
                id = targetPlayer.PlayerData.source,
                name = (charinfo.firstname or "John") .. " " .. (charinfo.lastname or "Doe"),
                job = jobData.grade and jobData.grade.name or "Unranked"
            })
        end
    end

    -- Luego envía los datos:
    TriggerClientEvent('scoreboard:update', src, {
        players = players,
        viewerPerms = viewerPerms,
        total = totalPlayers,
        lawmen = lawmen,
        medics = medics,
        msg = {
            no = msgNoPermission,
            title = msgTitle,
            online = msgOnline,
            roleName = roleName
        }
    })
end)

-- Test Discord connection when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    local testEndpoint = 'users/@me'
    local test = discordRequest("GET", testEndpoint, {})

    if test.code == 200 then
        if Config.Discord.Debug then print('[Discord] Bot successfully connected!') end
    else
        if Config.Discord.Debug then print('[Discord] Failed to connect bot. Check your token.') end
    end
end)