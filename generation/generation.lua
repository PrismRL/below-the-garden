local util = require "generation.util"
local rooms = require "generation.rooms"
local vegetation = require "generation.vegetation"
local passive = require "generation.passivecreatures"
local creatures = require "generation.creatures"
local features = require "generation.features"

LEVELGENBOUNDSX = 60 -- 1..60
LEVELGENBOUNDSY = 30 -- 1..30

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
local function tryDoor(builder, room, rs, rf, ax, ay, normal, rdoor, rng)
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

      if hx < 1 or hx > LEVELGENBOUNDSX or hy < 1 or hy > LEVELGENBOUNDSY then return false end

      for _, d in ipairs(prism.Vector2.neighborhood8) do
         if util.isFloor(builder, hx + d.x, hy + d.y) then return false end
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

            if gx <= 1 or gx >= LEVELGENBOUNDSX or gy <= 1 or gy >= LEVELGENBOUNDSY then return false end

            for _, d in ipairs(prism.Vector2.neighborhood8) do
               if util.isFloor(builder, gx + d.x, gy + d.y) then return false end
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
   for _, door in ipairs(builder:query(prism.components.DoorProxy):at(ax, ay):gather()) do
      builder:removeActor(door)
   end

   for _, door in ipairs(builder:query(prism.components.DoorProxy):at(ox, oy):gather()) do
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
            if tryDoor(builder, room, rs, rf, ax, ay, normal, rdoor, rng) then return true end
         end
      end
   end

   return false
end

local featureList = {
   features.addMeadow,
   features.addGraveyard,
   features.addGrassPatch,
   features.addPit,
   features.addWaterPit,
   features.addTallGrassClearing,
}

local function spawnFeature(rooms, builder, heatmap, distanceField, rng)
   if #featureList == 0 then return end

   local feature = featureList[rng:random(1, #featureList)]
   feature(rooms, builder, heatmap, distanceField, rng)
end

------------------------------------------------------------
-- Level generator entry point
------------------------------------------------------------
return function(seed, player)
   local builder

   local rng = prism.RNG(seed)

   local importantSpawns, wallDistanceField, query
   while true do
      builder = prism.LevelBuilder()
      builder:addSeed(seed)
      builder:rectangle("line", 1, 1, LEVELGENBOUNDSX, LEVELGENBOUNDSY, prism.cells.Wall)

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
            if failures > 500 then break end
         else
            --util.pruneInvalidDoors(builder)
         end
      end

      util.pruneMisalignedDoors(builder)
      util.collapseIsolatedFloors(builder, 3)
      util.collapseThinWalls(rng, builder)
      util.pruneMisalignedDoors(builder)

      query = builder:query(prism.components.Light)
      local heatmap = util.doorPathHeatmap(builder)
      local distanceField = util.buildWallDistanceField(builder)
      local rooms = util.findRooms(builder, distanceField, 2)
      util.buildRoomGraph(rooms)
      print(#rooms, "FOUND THIS MANY ROOMS")
      for _, room in ipairs(rooms) do
         for x, y in room.tiles:each() do
            --builder:addActor(prism.Actor.fromComponents{prism.components.Drawable{index="!", layer = math.huge, color=room.color}, prism.components.Position()}, x, y)
         end
      end

      vegetation.addTallGrass(builder, heatmap, distanceField, rng)
      vegetation.addGlowStalks(builder, heatmap, distanceField, rng)
      for i = 1, rng:random(4) do
         spawnFeature(rooms, builder, heatmap, distanceField, rng)
         distanceField = util.buildWallDistanceField(builder)
      end
      vegetation.thinTouchingGlowStalks(builder)

      wallDistanceField = util.buildWallDistanceField(builder)
      util.addSpawnpoints(builder, wallDistanceField, rng)
      util.addItemSpawns(builder, wallDistanceField, rng)

      importantSpawns = util.getImportantSpawnpoints(builder)
      print(#importantSpawns)
      if #importantSpawns == 3 then
         print "YEYEYE"
         break
      end
   end

   -- place player
   local p = importantSpawns[1]:expectPosition()
   builder:addActor(player, p.x, p.y)
   builder:addActor(prism.actors.Torch(), p.x, p.y)
   builder:addActor(prism.actors.Prism(), importantSpawns[2]:expectPosition():decompose())
   builder:addActor(prism.actors.Stairs(), importantSpawns[3]:expectPosition():decompose())

   builder:removeActor(importantSpawns[1])
   builder:removeActor(importantSpawns[2])
   builder:removeActor(importantSpawns[3])

   creatures.spawnThrumbleCamp(builder, rng, wallDistanceField)
   -- fill remaining nils with walls
   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if not builder:get(x, y) then builder:set(x, y, prism.cells.Wall()) end
      end
   end

   for _, actor in ipairs(builder:query():gather()) do
      local pos = actor:getPosition()
      if pos then
         local x, y = pos:decompose()
         if x < 1 or x > LEVELGENBOUNDSX or y < 1 or y > LEVELGENBOUNDSY then builder:removeActor(actor) end
      end
   end

   for _, actor in ipairs(builder:query(prism.components.DoorProxy):gather()) do
      builder:removeActor(actor)
   end

   for _, actor in ipairs(builder:query(prism.components.Spawner):gather()) do
      builder:addActor(prism.actors.Sqeeto(), actor:expectPosition():decompose())
      builder:removeActor(actor)
   end

   local lootTable = {
      prism.actors.Sword,
      prism.actors.Hammer,
      prism.actors.Sling,
      prism.actors.Snip,
      prism.actors.Pebble,
      prism.actors.Torch,
      prism.actors.Gloop,
      prism.actors.Snail,
   }

   for _, actor in ipairs(builder:query(prism.components.ItemSpawner):gather()) do
      local factory = lootTable[rng:random(#lootTable)]
      builder:addActor(factory(), actor:expectPosition():decompose())
      builder:removeActor(actor)
   end

   for _ = 1, 5 do
      local lightDistanceField = util.buildDistanceField(builder, function(builder, x, y)
         query:at(x, y)
         return query:first() ~= nil
      end, util.isFloor)
      passive.addFireflies(builder, lightDistanceField, rng)
   end

   local veggieDistanceField = util.buildDistanceField(builder, function(builder, x, y)
      local cell = builder:get(x, y)

      if cell and (cell:has(prism.components.Wet) or cell:has(prism.components.Vegetation)) then
         return true
      end

      return false
   end, util.isFloor)

   local offset = prism.Vector2(rng:random(1, 10000), rng:random(1, 10000))
   for x, y in builder:each() do
      local d = (veggieDistanceField:get(x, y) or 32) + 1
      -- chance falls off with distance
      local chance = math.pow(0.6, d)     -- tweak 0.5 to taste

      chance = chance 
      if util.isFloor(builder, x, y) and love.math.noise(x/25 + offset.x, y/25 + offset.y) < chance then
         builder:set(x, y, prism.cells.Grass())
      end
   end


   return builder
end
