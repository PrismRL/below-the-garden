local util = require "generation.util"
local creatures = {}

--- Spawns a Thrumble camp at a spawnpoint that is
--- in a reasonably open area, favoring median-sized open spaces.
--- @param builder LevelBuilder
--- @param rng RNG
--- @param wallDistanceField SparseGrid
--- @return boolean
function creatures.spawnThrumbleCamp(builder, rng, wallDistanceField)
   local player = builder:query(prism.components.PlayerController):first()
   if not player then return false end

   local spawnpoints = builder:query(prism.components.Spawner):gather()
   local candidates = {}

   local MIN_WALL_DIST = 3

   -- Collect valid candidates and wall distances
   for _, sp in ipairs(spawnpoints) do
      local x, y = sp:expectPosition():decompose()
      local wallDist = wallDistanceField:get(x, y)

      -- Hard cutoff: must be at least somewhat open
      if wallDist and wallDist >= MIN_WALL_DIST then
         local player = builder:query(prism.components.PlayerController):first()
         local pp = player:expectPosition()

         local astar = prism.astar(sp:expectPosition(), pp, function(x, y)
            return util.isFloor(builder, x, y)
         end)

         if astar then
            local pathLength = astar:length()
            candidates[#candidates + 1] = {
               sp = sp,
               wallDist = wallDist,
               pathLength = pathLength,
            }
         end
      end
   end

   local n = #candidates
   if n == 0 then return false end

   -- Sort candidates by pathLength (ascending)
   table.sort(candidates, function(a, b)
      return a.pathLength < b.pathLength
   end)

   -- Pick median path length (favoring the middle, not extremes)
   local mid = math.floor(#candidates / 2)
   local chosen = candidates[#candidates]
   local pos = chosen.sp:expectPosition()
   local cx, cy = pos:decompose()

   -- Stamp floor around the campfire (3x3)
   for dx = -1, 1 do
      for dy = -1, 1 do
         if not util.isFloor(builder, cx + dx, cy + dy) then builder:set(cx + dx, cy + dy, prism.cells.Floor()) end
      end
   end

   builder:addActor(prism.actors.Fire(), cx, cy)
   builder:addActor(prism.actors.Log(), cx, cy + 1)
   builder:removeActor(chosen.sp)

   ----------------------------------------------------------------
   -- Spawn Thrumbles around the campfire (radius 1)
   ----------------------------------------------------------------
   local thrumbleSpots = {}

   for dx = -1, 1 do
      for dy = -1, 1 do
         if not (dx == 0 and dy == 0) then
            local x = cx + dx
            local y = cy + dy
            if util.isEmptyFloor(builder, x, y) then thrumbleSpots[#thrumbleSpots + 1] = { x = x, y = y } end
         end
      end
   end

   -- Shuffle spots
   for i = #thrumbleSpots, 2, -1 do
      local j = rng:random(1, i)
      thrumbleSpots[i], thrumbleSpots[j] = thrumbleSpots[j], thrumbleSpots[i]
   end

   local numThrumbles = math.min(#thrumbleSpots, rng:random(2, 3))
   for i = 1, numThrumbles do
      local p = thrumbleSpots[i]
      builder:addActor(prism.actors.Thrumble(), p.x, p.y)
   end

   ----------------------------------------------------------------
   -- Spawn swords in radius-2 area
   ----------------------------------------------------------------
   local swordSpots = {}

   for dx = -3, 3 do
      for dy = -3, 3 do
         if not (dx == 0 and dy == 0) and not (math.abs(dx) == 1 or math.abs(dy) == 1) and (dx * dx + dy * dy <= 4) then
            local x = cx + dx
            local y = cy + dy
            if util.isEmptyFloor(builder, x, y) then swordSpots[#swordSpots + 1] = { x = x, y = y } end
         end
      end
   end

   -- Shuffle sword spots
   for i = #swordSpots, 2, -1 do
      local j = rng:random(1, i)
      swordSpots[i], swordSpots[j] = swordSpots[j], swordSpots[i]
   end

   local numSwords = math.min(#swordSpots, rng:random(1, 2))
   builder:addActor(prism.actors.Torch(), swordSpots[1].x, swordSpots[1].y)
   for i = 2, numSwords do
      local p = swordSpots[i]
      builder:addActor(prism.actors.Sword(), p.x, p.y)
   end

   return true
end

return creatures
