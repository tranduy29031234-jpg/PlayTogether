local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteDefinitions = {}

local function getOrCreateFolder(folderName)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    if folder and folder:IsA("Folder") then
        return folder
    end

    folder = Instance.new("Folder")
    folder.Name = folderName
    folder.Parent = ReplicatedStorage
    return folder
end

local function getOrCreateRemote(remoteName, className, folder)
    local remote = folder:FindFirstChild(remoteName)
    if remote and remote.ClassName == className then
        return remote
    end

    remote = Instance.new(className)
    remote.Name = remoteName
    remote.Parent = folder
    return remote
end

function RemoteDefinitions.register()
    local remotesFolder = getOrCreateFolder("PlayTogetherRemotes")

    return {
        PartyInvite = getOrCreateRemote("PartyInvite", "RemoteEvent", remotesFolder),
        PartyUpdate = getOrCreateRemote("PartyUpdate", "RemoteEvent", remotesFolder),
        CoinUpdate = getOrCreateRemote("CoinUpdate", "RemoteEvent", remotesFolder),
        RequestCoinReward = getOrCreateRemote("RequestCoinReward", "RemoteEvent", remotesFolder),
        GetSocialState = getOrCreateRemote("GetSocialState", "RemoteFunction", remotesFolder),
    }
end

return RemoteDefinitions
