local util = require "generation.util"

local isFloor = util.isFloor
local isWall = util.isWall

local room = {}

----------------------------------------------------------------
-- Finds valid door positions and spawns DoorProxy actors.
----------------------------------------------------------------
--- Works for any carved room shape.
--- @param builder LevelBuilder
--- @param rng RNG
function room.addDoors(builder, rng)
   local candidates = {}

   local tl, br = builder:getBounds()
   for x = tl.x - 1, br.x + 1 do
      for y = tl.y - 1, br.y + 1 do
         if isWall(builder, x, y) then
            local count = 0

            for _, d in ipairs(prism.Vector2.neighborhood4) do
               local nx, ny = x + d.x, y + d.y
               if isFloor(builder, nx, ny) then count = count + 1 end
            end

            if count == 1 then candidates[#candidates + 1] = { x = x, y = y } end
         end
      end
   end

   if #candidates == 0 then return end

   for _ = 1, 7 do
      local idx = rng:random(1, #candidates)
      local d = table.remove(candidates, idx)
      if d then builder:addActor(prism.actors.DoorProxy(), d.x, d.y) end
   end
end

----------------------------------------------------------------
-- Rectangular room
----------------------------------------------------------------
function room.makeRoom(rng)
   local b = prism.LevelBuilder()

   local w = rng:random(2, 9)
   local h = rng:random(2, 9)

   b:rectangle("fill", 2, 2, 2 + w, 2 + h, prism.cells.Floor)

   room.addDoors(b, rng)
   return b
end

----------------------------------------------------------------
-- L-shaped hallway
----------------------------------------------------------------
--- @param rng RNG
--- @return LevelBuilder
function room.makeHallwayL(rng)
   local b = prism.LevelBuilder()

   local t = rng:random(2, 3)
   local lenA = rng:random(4, 8)
   local lenB = rng:random(4, 8)

   local horizFirst = rng:random() < 0.5
   local ox, oy = 2, 2

   if horizFirst then
      b:rectangle("fill", ox, oy, ox + lenA, oy + t - 1, prism.cells.Floor)
      b:rectangle("fill", ox + lenA - (t - 1), oy, ox + lenA, oy + lenB, prism.cells.Floor)
   else
      b:rectangle("fill", ox, oy, ox + t - 1, oy + lenA, prism.cells.Floor)
      b:rectangle("fill", ox, oy + lenA - (t - 1), ox + lenB, oy + lenA, prism.cells.Floor)
   end

   room.addDoors(b, rng)
   return b
end

----------------------------------------------------------------
-- Circular room
----------------------------------------------------------------
--- @param rng RNG
--- @return LevelBuilder
function room.makeCircleRoom(rng)
   local b = prism.LevelBuilder()

   local r = rng:random(3, 6)
   local cx = r + 2
   local cy = r + 2

   b:ellipse("fill", cx, cy, r, r, prism.cells.Floor)

   room.addDoors(b, rng)
   return b
end

----------------------------------------------------------------
-- Elliptical room
----------------------------------------------------------------
--- @param rng RNG
--- @return LevelBuilder
function room.makeEllipseRoom(rng)
   local b = prism.LevelBuilder()

   local rx = rng:random(3, 7)
   local ry = rng:random(3, 6)

   local cx = rx + 2
   local cy = ry + 2

   b:ellipse("fill", cx, cy, rx, ry, prism.cells.Floor)

   room.addDoors(b, rng)
   return b
end

--- @param rng RNG
--- @return LevelBuilder
function room.makeRingRoom(rng)
   local b = prism.LevelBuilder()

   local rOuter = rng:random(5, 8)
   local thickness = rng:random(3, 4)

   local rWall = rOuter - thickness
   local rInner = rWall - 1

   local cx = rOuter + 2
   local cy = rOuter + 2

   -- Outer walkable ring
   b:ellipse("fill", cx, cy, rOuter, rOuter, prism.cells.Floor)

   -- Wall ring
   b:ellipse("fill", cx, cy, rWall, rWall, prism.cells.Wall)

   -- Hollow inner void
   if rInner > 0 then b:ellipse("fill", cx, cy, rInner, rInner, prism.cells.Floor) end

   ----------------------------------------------------------------
   -- Carve a random opening through the wall ring
   ----------------------------------------------------------------
   local dirs = prism.Vector2.neighborhood4
   local d = dirs[rng:random(1, #dirs)]

   -- carve radially through the wall band
   for i = rInner + 1, rOuter - 1 do
      local x = cx + d.x * i
      local y = cy + d.y * i
      b:setCell(x, y, prism.cells.Floor())
   end

   room.addDoors(b, rng)
   return b
end

----------------------------------------------------------------
-- Random room dispatcher
----------------------------------------------------------------
--- @param rng RNG
--- @return LevelBuilder
function room.makeRandomRoom(rng)
   local roomTypes = {
      room.makeHallwayL,
      room.makeCircleRoom,
      room.makeEllipseRoom,
      room.makeRingRoom,
      room.makeRoom,
   }

   local fn = roomTypes[rng:random(1, #roomTypes)]
   return fn(rng)
end

----------------------------------------------------------------

return room
