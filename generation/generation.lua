local util = require "generation.util"
local rooms = require "generation.rooms"
local vegetation = require "generation.vegetation"
local passive = require "generation.passivecreatures"
local creatures = require "generation.creatures"

LEVELGENBOUNDSX = 60 -- 1..60
LEVELGENBOUNDSY = 30 -- 1..30

------------------------------------------------------------
-- Door normal (cardinal only)
------------------------------------------------------------

------------------------------------------------------------
-- Attempt to attach a room via a specific door
------------------------------------------------------------

------------------------------------------------------------
-- Try to accrete a new room onto an existing door
------------------------------------------------------------

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
   -- place player
   local p = importantSpawns[1]:expectPosition()
   builder:addActor(player, p.x, p.y)
   builder:addActor(prism.actors.Torch(), p.x, p.y)
   builder:addActor(prism.actors.Prism(), importantSpawns[2]:expectPosition():decompose())
   builder:addActor(prism.actors.Stairs(), importantSpawns[3]:expectPosition():decompose())

   builder:removeActor(importantSpawns[1])
   builder:removeActor(importantSpawns[2])
   builder:removeActor(importantSpawns[3])

   wallDistanceField = util.buildWallDistanceField(builder)
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

      if cell and (cell:has(prism.components.Wet) or cell:has(prism.components.Vegetation)) then return true end

      return false
   end, util.isFloor)

   local offset = prism.Vector2(rng:random(1, 10000), rng:random(1, 10000))
   for x, y in builder:each() do
      local d = (veggieDistanceField:get(x, y) or 32) + 1
      print(d)
      -- chance falls off with distance
      local chance = math.pow(0.6, d) -- tweak 0.5 to taste

      chance = chance
      if util.isFloor(builder, x, y) and love.math.noise(x / 25 + offset.x, y / 25 + offset.y) < chance then
         builder:set(x, y, prism.cells.Grass())
      end
   end

   return builder
end
