local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteDefinitions = require(ReplicatedStorage:WaitForChild("PlayTogetherModules"):WaitForChild("RemoteDefinitions"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local PartyService = require(script.Parent:WaitForChild("PartyService"))

local remotes = RemoteDefinitions.register()
local dataService = PlayerDataService.new()
local partyService = PartyService.new()

local function broadcastParty(party)
    if not party then
        return
    end

    for _, member in ipairs(party.members) do
        remotes.PartyUpdate:FireClient(member, partyService:getSnapshot(member))
    end
end

local function syncCoins(player)
    remotes.CoinUpdate:FireClient(player, dataService:getCoins(player))
end

Players.PlayerAdded:Connect(function(player)
    dataService:loadProfile(player)
    syncCoins(player)
end)

Players.PlayerRemoving:Connect(function(player)
    local party = partyService:getParty(player)
    partyService:leaveParty(player)

    if party then
        broadcastParty(party)
    end

    dataService:removePlayer(player)
end)

remotes.RequestCoinReward.OnServerEvent:Connect(function(player)
    local ok, reward = dataService:claimDailyReward(player)
    if ok then
        syncCoins(player)
    end

    remotes.RequestCoinReward:FireClient(player, {
        Success = ok,
        Reward = reward,
        Coins = dataService:getCoins(player),
    })
end)

remotes.PartyInvite.OnServerEvent:Connect(function(player, targetUserId)
    local target = Players:GetPlayerByUserId(targetUserId)
    if not target then
        remotes.PartyInvite:FireClient(player, { Success = false, Message = "Không tìm thấy người chơi." })
        return
    end

    local ok, result = partyService:inviteToParty(player, target)
    if not ok then
        remotes.PartyInvite:FireClient(player, { Success = false, Message = result })
        return
    end

    local party = result
    broadcastParty(party)
    remotes.PartyInvite:FireClient(player, { Success = true, Message = "Mời party thành công." })
    remotes.PartyInvite:FireClient(target, { Success = true, Message = player.Name .. " đã thêm bạn vào party." })
end)

remotes.GetSocialState.OnServerInvoke = function(player)
    return {
        Coins = dataService:getCoins(player),
        Party = partyService:getSnapshot(player),
    }
end
