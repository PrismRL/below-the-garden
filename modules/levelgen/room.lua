--- @class Room : Object
--- @field tiles SparseGrid<Cell>
--- @field size integer
--- @field center Vector2
--- @field color Color4
--- @field neighbors table<Room, boolean>
local Room = prism.Object:extend "Room"

function Room:__new(tiles, size, center, color)
   self.tiles = tiles
   self.size = size
   self.center = center
   self.color = color or prism.Color4(math.random(), math.random(), math.random())
   self.neighbors = {}
end

function Room:addNeighbor(room)
   self.neighbors[room] = true
   room.neighbors[self] = true
end

function Room:removeNeighbor(room)
   self.neighbors[room] = false
   room.neighbors[self] = false
end
