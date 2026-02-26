local DataStoreService = game:GetService("DataStoreService")

local PlayerDataService = {}
PlayerDataService.__index = PlayerDataService

local PROFILE_STORE = DataStoreService:GetDataStore("PlayTogetherProfile_v1")
local DEFAULT_PROFILE = {
    Coins = 0,
    DailyStreak = 0,
    LastClaimDay = 0,
}

local function getDayId()
    return math.floor(os.time() / 86400)
end

local function cloneDefault()
    return {
        Coins = DEFAULT_PROFILE.Coins,
        DailyStreak = DEFAULT_PROFILE.DailyStreak,
        LastClaimDay = DEFAULT_PROFILE.LastClaimDay,
    }
end

function PlayerDataService.new()
    local self = setmetatable({}, PlayerDataService)
    self.profiles = {}
    return self
end

function PlayerDataService:loadProfile(player)
    local key = tostring(player.UserId)
    local profile = cloneDefault()

    local ok, result = pcall(function()
        return PROFILE_STORE:GetAsync(key)
    end)

    if ok and type(result) == "table" then
        profile.Coins = tonumber(result.Coins) or profile.Coins
        profile.DailyStreak = tonumber(result.DailyStreak) or profile.DailyStreak
        profile.LastClaimDay = tonumber(result.LastClaimDay) or profile.LastClaimDay
    end

    self.profiles[player] = profile
    return profile
end

function PlayerDataService:saveProfile(player)
    local profile = self.profiles[player]
    if not profile then
        return
    end

    local key = tostring(player.UserId)
    pcall(function()
        PROFILE_STORE:SetAsync(key, profile)
    end)
end

function PlayerDataService:getCoins(player)
    local profile = self.profiles[player]
    return profile and profile.Coins or 0
end

function PlayerDataService:addCoins(player, amount)
    local profile = self.profiles[player]
    if not profile then
        return 0
    end

    profile.Coins = math.max(0, profile.Coins + amount)
    return profile.Coins
end

function PlayerDataService:claimDailyReward(player)
    local profile = self.profiles[player]
    if not profile then
        return false, 0
    end

    local dayId = getDayId()
    if profile.LastClaimDay == dayId then
        return false, 0
    end

    if profile.LastClaimDay == dayId - 1 then
        profile.DailyStreak += 1
    else
        profile.DailyStreak = 1
    end

    profile.LastClaimDay = dayId
    local reward = math.min(150, 30 + profile.DailyStreak * 10)
    profile.Coins += reward

    return true, reward
end

function PlayerDataService:removePlayer(player)
    self:saveProfile(player)
    self.profiles[player] = nil
end

return PlayerDataService
