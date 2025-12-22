local util = require "generation.util"

local passive = {}

--- Spawns fireflies in the darkest sampled areas.
--- Uses random sampling instead of full-map scans.
--- @param builder LevelBuilder
--- @param lightDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.count integer?    -- default 5
---    opts.samples integer?  -- default 200
function passive.addFireflies(builder, lightDistanceField, rng, opts)
   opts = opts or {}
   local count   = opts.count   or 1
   local samples = opts.samples or 200

   local best = {} -- unsorted top candidates

   local function tryInsert(x, y, d)
      if #best < count then
         best[#best + 1] = { x = x, y = y, d = d }
         return
      end

      -- find weakest current candidate
      local weakest = 1
      for i = 2, #best do
         if best[i].d < best[weakest].d then
            weakest = i
         end
      end

      if d > best[weakest].d then
         best[weakest] = { x = x, y = y, d = d }
      end
   end

   for i = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isFloor(builder, x, y) then
         if #builder:query():at(x, y):gather() == 0 then
            local d = lightDistanceField:get(x, y)
            if d then
               tryInsert(x, y, d)
            end
         end
      end
   end

   for _, c in ipairs(best) do
      builder:addActor(prism.actors.Firefly(), c.x, c.y)
   end
end


return passive