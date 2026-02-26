local PartyService = {}
PartyService.__index = PartyService

function PartyService.new()
    local self = setmetatable({}, PartyService)
    self.partyByLeader = {}
    self.memberToLeader = {}
    return self
end

local function removeValue(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
            return true
        end
    end
    return false
end

function PartyService:getParty(player)
    local leader = self.memberToLeader[player]
    if not leader then
        return nil
    end

    return self.partyByLeader[leader]
end

function PartyService:createParty(leader)
    if self.memberToLeader[leader] then
        return self.partyByLeader[self.memberToLeader[leader]]
    end

    local party = {
        leader = leader,
        members = { leader },
    }

    self.partyByLeader[leader] = party
    self.memberToLeader[leader] = leader
    return party
end

function PartyService:inviteToParty(leader, target)
    local party = self:createParty(leader)

    if self.memberToLeader[target] then
        return false, "Người chơi đã ở trong party khác."
    end

    table.insert(party.members, target)
    self.memberToLeader[target] = leader
    return true, party
end

function PartyService:leaveParty(player)
    local leader = self.memberToLeader[player]
    if not leader then
        return
    end

    local party = self.partyByLeader[leader]
    if not party then
        self.memberToLeader[player] = nil
        return
    end

    removeValue(party.members, player)
    self.memberToLeader[player] = nil

    if player == leader then
        if #party.members == 0 then
            self.partyByLeader[leader] = nil
            return
        end

        local newLeader = party.members[1]
        party.leader = newLeader
        self.partyByLeader[leader] = nil
        self.partyByLeader[newLeader] = party

        for _, member in ipairs(party.members) do
            self.memberToLeader[member] = newLeader
        end
    elseif #party.members == 0 then
        self.partyByLeader[leader] = nil
    end
end

function PartyService:getSnapshot(player)
    local party = self:getParty(player)
    if not party then
        return nil
    end

    local memberNames = {}
    for _, member in ipairs(party.members) do
        table.insert(memberNames, member.Name)
    end

    return {
        Leader = party.leader.Name,
        Members = memberNames,
        Size = #party.members,
    }
end

return PartyService
