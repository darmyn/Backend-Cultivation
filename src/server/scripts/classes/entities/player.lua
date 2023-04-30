local replicatedStorage = game:GetService("ReplicatedStorage")

local components = script.Parent.Parent.components
local abstract = replicatedStorage.darmynShared.classes.abstract

local abstractPlayer = require(abstract.player)
local Profile = require(components.profile)

local profileTemplate = {
    qi = 0,
    level = 1,
    items = {}
}

local profile = Profile("PLAYER_DATA", profileTemplate)

local player = {}
player.interface = {}
player.behavior = {}
player.metatable = {__index = player.behavior}

function player.interface.new(instance: Player)
    local self = setmetatable(abstractPlayer.interface.new(instance), player.metatable)
    self.profile = profile.new(instance)
    self.profile.data = self.profile.data :: typeof(profileTemplate)
    return self :: typeof(self)
end

function player.behavior.testMethod(self: player)

end

type player = typeof(player.interface.new(...))

return player.interface