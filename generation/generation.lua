local util = require "generation.util"
local rooms = require "generation.rooms"
local vegetation = require "generation.vegetation"
local passive = require "generation.passivecreatures"
local creatures = require "generation.creatures"

LEVELGENBOUNDSX = 56 -- 1..60
LEVELGENBOUNDSY = 25 -- 1..30

------------------------------------------------------------
-- Door normal (cardinal only)
------------------------------------------------------------
local function doorNormal(builder, x, y)
   for _, d in ipairs(prism.Vector2.neighborhood4) do
      if util.isFloor(builder, x + d.x, y + d.y) then
         return prism.Vector2(-d.x, -d.y) -- outward
      end
   end
end

------------------------------------------------------------
-- Attempt to attach a room via a specific door
------------------------------------------------------------
local function tryDoor(
   builder,
   room,
   rs, rf,
   ax, ay,
   normal,
   rdoor,
   rng
)
   local rx, ry = rdoor:expectPosition():decompose()

   -- hallway length (0 = direct attach)
   local hallLen = (rng:random() < 0.2) and rng:random(1, 6) or 0

   -- offset room so its door aligns with anchor + hallway
   local ox = ax + normal.x * hallLen - (rx - rs.x)
   local oy = ay + normal.y * hallLen - (ry - rs.y)

   ----------------------------------------------------------------
   -- validate hallway (no touching floors, incl diagonals)
   ----------------------------------------------------------------
   local hx, hy = ax, ay
   for i = 1, hallLen do
      hx = hx + normal.x
      hy = hy + normal.y

      if hx < 1 or hx > LEVELGENBOUNDSX or hy < 1 or hy > LEVELGENBOUNDSY then
         return false
      end

      for _, d in ipairs(prism.Vector2.neighborhood8) do
         if util.isFloor(builder, hx + d.x, hy + d.y) then
            return false
         end
      end
   end

   ----------------------------------------------------------------
   -- validate room placement (no touching existing floors)
   ----------------------------------------------------------------
   for x = rs.x, rf.x do
      for y = rs.y, rf.y do
         if room:get(x, y) then
            local gx = ox + (x - rs.x)
            local gy = oy + (y - rs.y)

            if gx <= 1 or gx >= LEVELGENBOUNDSX or gy <= 1 or gy >= LEVELGENBOUNDSY then
               return false
            end

            for _, d in ipairs(prism.Vector2.neighborhood8) do
               if util.isFloor(builder, gx + d.x, gy + d.y) then
                  return false
               end
            end
         end
      end
   end

   ----------------------------------------------------------------
   -- commit
   ----------------------------------------------------------------
   builder:blit(room, ox, oy)

   hx, hy = ax, ay
   for i = 1, hallLen do
      hx = hx + normal.x
      hy = hy + normal.y
      builder:set(hx, hy, prism.cells.Floor())
   end

   builder:set(ax, ay, prism.cells.Floor())

   -- remove consumed door proxies
   for _, door in ipairs(
      builder:query(prism.components.DoorProxy):at(ax, ay):gather()
   ) do
      builder:removeActor(door)
   end

   for _, door in ipairs(
      builder:query(prism.components.DoorProxy):at(ox, oy):gather()
   ) do
      builder:removeActor(door)
   end

   builder:addActor(prism.actors.Door(), ax, ay)

   return true
end

------------------------------------------------------------
-- Try to accrete a new room onto an existing door
------------------------------------------------------------
local function tryAccrete(builder, rng)
   local anchors = builder:query(prism.components.DoorProxy):gather()
   if #anchors == 0 then return false end

   local room = rooms.makeRandomRoom(rng)
   local rs, rf = room:getBounds()

   assert(#room:query(prism.components.DoorProxy):gather() > 0)

   for _, anchor in ipairs(anchors) do
      local ax, ay = anchor:expectPosition():decompose()
      local normal = doorNormal(builder, ax, ay)

      if normal then
         for rdoor in room:query(prism.components.DoorProxy):iter() do
            if tryDoor(
               builder,
               room,
               rs, rf,
               ax, ay,
               normal,
               rdoor,
               rng
            ) then
               return true
            end
         end
      end
   end

   return false
end


------------------------------------------------------------
-- Level generator entry point
------------------------------------------------------------
return function(seed, player)
   local builder = prism.LevelBuilder()
   builder:addSeed(seed)

   local rng = prism.RNG(seed)

   builder:rectangle(
      "line",
      1, 1,
      LEVELGENBOUNDSX,
      LEVELGENBOUNDSY,
      prism.cells.Wall
   )

   -- first room
   local first = rooms.makeRoom(rng)
   local x = rng:random(10, LEVELGENBOUNDSX - 10)
   local y = rng:random(10, LEVELGENBOUNDSY - 10)
   builder:blit(first, x, y)

   -- accretion loop
   local failures = 0
   while true do
      if not tryAccrete(builder, rng) then
         failures = failures + 1
         if failures > 4000 then break end
      else
         --util.pruneInvalidDoors(builder)
      end
   end

   util.pruneMisalignedDoors(builder)
   util.collapseIsolatedFloors(builder, 3)
   util.collapseThinWalls(rng, builder)
   util.pruneMisalignedDoors(builder)

   local heatmap = util.doorPathHeatmap(builder)
   local distanceField = util.buildWallDistanceField(builder)
   vegetation.addTallGrass(builder, heatmap, distanceField, rng)
   vegetation.addGlowStalks(builder, heatmap, distanceField, rng)
   vegetation.addGrassPatch(builder, heatmap, distanceField, rng)
   vegetation.thinTouchingGlowStalks(builder)

   local query = builder:query(prism.components.Light)

   for _ = 1, 5 do
      local lightDistanceField = util.buildDistanceField(builder,
         function (builder, x, y)
            query:at(x, y)
            return query:first() ~= nil
         end,
         util.isFloor
      )
      passive.addFireflies(builder, lightDistanceField, rng)
   end

   local wallDistanceField = util.buildWallDistanceField(builder)
   util.addSpawnpoints(builder, wallDistanceField, rng)

   local importantSpawns = util.getImportantSpawnpoints(builder)
   assert(#importantSpawns >= 3)
   -- place player
   local p = importantSpawns[1]:expectPosition()
   builder:addActor(player, p.x, p.y)
   builder:addActor(prism.actors.Prism(), importantSpawns[2]:expectPosition():decompose())
   builder:addActor(prism.actors.Stairs(), importantSpawns[3]:expectPosition():decompose())

   builder:removeActor(importantSpawns[1])
   builder:removeActor(importantSpawns[2])
   builder:removeActor(importantSpawns[3])

   creatures.spawnThrumbleCamp(builder, rng, wallDistanceField)
   -- fill remaining nils with walls
   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if not builder:get(x, y) then
            builder:set(x, y, prism.cells.Wall())
         end
      end
   end

   for _, actor in ipairs(builder:query():gather()) do
      local pos = actor:getPosition()
      if pos then
         local x, y = pos:decompose()
         if x < 1 or x > LEVELGENBOUNDSX
         or y < 1 or y > LEVELGENBOUNDSY then
            builder:removeActor(actor)
         end
      end
   end

   for _, actor in ipairs(builder:query(prism.components.DoorProxy):gather()) do
      builder:removeActor(actor)
   end

   for _, actor in ipairs(builder:query(prism.components.Spawner):gather()) do
      builder:addActor(prism.actors.Sqeeto(), actor:expectPosition():decompose())
      builder:removeActor(actor)
   end

   return builder
end
