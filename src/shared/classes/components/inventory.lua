type primative = string | number | boolean
type itemId = string

type baseItemInfo = {
    name: string,
    tags: {string},
    saved: {
        [string]: primative
    }?
}

type storedItem = baseItemInfo & {
    id: string,
}

type storedItemDict = {
    [itemId]: storedItem
}

local function findOrCreateTable(parent, key)
    if parent[key] then
        return parent[key]
    else
        local output = {}
        parent[key] = output
        return output
    end
end

local inventory = {}
inventory.interface = {}
inventory.behavior = {}
inventory.metatable = {__index = inventory.behavior}

function inventory.interface.new()
    local self = setmetatable({}, inventory.metatable)
    self.items = {} :: storedItemDict
    self.lookups = {
        byName = {} :: {[string]: storedItemDict},
        byTag = {} :: {[string]: storedItemDict},
    }
    self.size = 30
    self.numItems = 0
    self._nextId = 1
    return self
end

function inventory.behavior.add(self: inventory, item: baseItemInfo)
    local id = tostring(self._nextId)
    local storedItem = item :: storedItem
    storedItem.id = id
    self.items[id] = item
    local lookup = self.lookups
    findOrCreateTable(lookup.byName, item.name)[id] = item

    for _, tag in pairs(lookup.byTag) do
        findOrCreateTable(lookup.byTag, tag)[id] = item
    end
    
    self.numItems += 1
    self._nextId += 1
end

function inventory.behavior.remove(self: inventory, itemId: itemId)
    local items = self.items
    local item = items[itemId]
    if not item then
        return
    end

    local id = item.id
    items[id] = nil
    local lookup = self.lookups
    lookup.byName[item.name][id] = nil

    for _, tag in pairs(lookup.byTag) do
        lookup.byTag[tag][id] = nil
    end
    
    self.numItems -= 1
end

function inventory.behavior.getItemsByTag(self: inventory, tag: string)
    return self.lookups[tag]
end

function inventory.behavior.getItem(self: inventory, id: itemId)
    return self.items[id]
end

function inventory.behavior.getItemsByName(self: inventory, name: string)
    return self.lookups[name]
end

function inventory.behavior.has(self: inventory, name: string)
    if self.lookups[name] then
        return true
    else
        return false
    end
end

type inventory = typeof(inventory.interface.new(...))

return inventory.interface