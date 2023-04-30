local components = script.Parent.Parent.components

local hotbar = require(components.hotbar)
local inventory = require(components.inventory)

local abstractPlayer = {}
abstractPlayer.interface = {}
abstractPlayer.behavior = {}
abstractPlayer.metatable = {__index = abstractPlayer.behavior}

function abstractPlayer.interface.new(instance: Player)
    local self = setmetatable({}, abstractPlayer.metatable)
    self.instance = instance
    self.hotbar = hotbar.new()
    self.inventory = inventory.new()
    return self
end

function abstractPlayer.behavior.abstractMethod(self: abstractPlayer)
    return true
end

type abstractPlayer = typeof(abstractPlayer.interface.new(...))

return abstractPlayer