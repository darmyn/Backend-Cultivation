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
    storagePosition: number
}

local hotbar = {}
hotbar.interface = {}
hotbar.behavior = {}
hotbar.metatable = {__index = hotbar.behavior}

function hotbar.interface.new(size: number?)
    local self = setmetatable({}, hotbar.metatable)
    self.size = size or 9
    self.layout = table.create(size, false)
    return self
end

function hotbar.behavior.add(self: hotbar, item: baseItemInfo, position: number)
    local storedItem = item :: storedItem
    local layout = self.layout
    
    if position and layout[position] == false then
        storedItem.storagePosition = position
        layout[position]  = storedItem
    else
        for position, existingItem: storedItem in ipairs(self.layout) do
            if existingItem == false then
                storedItem.storagePosition = position
                layout[position] = storedItem
            end
        end
    end
end

function hotbar.behavior.remove(self: hotbar, position: number)
    self.layout[position] = false
end

function hotbar.behavior.move(self: hotbar, position: number, newPosition: number)
    self.layout[position], self.layout[newPosition] = self.layout[newPosition], self.layout[position]
end

function hotbar.behavior.has(self: hotbar, itemName: string)
    for _, existingItem: storedItem in pairs(self.layout) do
        if existingItem.name == itemName then
            return true
        end
    end
end

function hotbar.interface.getItem(self: hotbar, position: number)
    return self.layout[position]
end

function hotbar.behavior.getTagged(self: hotbar, tag: string)
    local result = {}
    for _, existingItem: storedItem in pairs(self.layout) do
        if table.find(existingItem.tags, tag) then
            table.insert(result, existingItem)
        end
    end
    return result
end

function hotbar.behavior.getItemsByName(self: hotbar, name: string)
    local result = {}
    for _, existingItem: storedItem in pairs(self.layout) do
        if existingItem.name == name then
            table.insert(result, existingItem)
        end
    end
    return result
end

type hotbar = typeof(hotbar.interface.new(...))

return hotbar.interface