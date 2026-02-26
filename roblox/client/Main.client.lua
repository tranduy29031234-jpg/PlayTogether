local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local RemoteDefinitions = require(ReplicatedStorage:WaitForChild("PlayTogetherModules"):WaitForChild("RemoteDefinitions"))
local remotes = RemoteDefinitions.register()

local function buildGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PlayTogetherHUD"
    gui.ResetOnSpawn = false

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(320, 180)
    panel.Position = UDim2.fromScale(0.02, 0.05)
    panel.BackgroundTransparency = 0.25
    panel.Parent = gui

    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.fromOffset(300, 40)
    coinsLabel.Position = UDim2.fromOffset(10, 10)
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Text = "Coins: 0"
    coinsLabel.Parent = panel

    local partyLabel = Instance.new("TextLabel")
    partyLabel.Name = "PartyLabel"
    partyLabel.Size = UDim2.fromOffset(300, 60)
    partyLabel.Position = UDim2.fromOffset(10, 55)
    partyLabel.TextWrapped = true
    partyLabel.TextXAlignment = Enum.TextXAlignment.Left
    partyLabel.TextYAlignment = Enum.TextYAlignment.Top
    partyLabel.Text = "Party: chưa có"
    partyLabel.Parent = panel

    local claimButton = Instance.new("TextButton")
    claimButton.Size = UDim2.fromOffset(300, 40)
    claimButton.Position = UDim2.fromOffset(10, 125)
    claimButton.Text = "Nhận thưởng điểm danh"
    claimButton.Parent = panel

    return gui, coinsLabel, partyLabel, claimButton
end

local gui, coinsLabel, partyLabel, claimButton = buildGui()
gui.Parent = player:WaitForChild("PlayerGui")

local function updateParty(party)
    if not party then
        partyLabel.Text = "Party: chưa có"
        return
    end

    partyLabel.Text = string.format("Party (%d): %s", party.Size, table.concat(party.Members, ", "))
end

claimButton.MouseButton1Click:Connect(function()
    remotes.RequestCoinReward:FireServer()
end)

remotes.CoinUpdate.OnClientEvent:Connect(function(coins)
    coinsLabel.Text = "Coins: " .. tostring(coins)
end)

remotes.PartyUpdate.OnClientEvent:Connect(function(party)
    updateParty(party)
end)

remotes.RequestCoinReward.OnClientEvent:Connect(function(payload)
    if payload.Success then
        claimButton.Text = string.format("Đã nhận +%d coins", payload.Reward)
    else
        claimButton.Text = "Bạn đã nhận thưởng hôm nay"
    end
end)

remotes.PartyInvite.OnClientEvent:Connect(function(payload)
    if payload and payload.Message then
        print("[Party]", payload.Message)
    end
end)

local socialState = remotes.GetSocialState:InvokeServer()
coinsLabel.Text = "Coins: " .. tostring(socialState.Coins or 0)
updateParty(socialState.Party)
