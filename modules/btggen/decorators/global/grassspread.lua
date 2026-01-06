local util = prism.levelgen.util

local GrassSpreadDecorator = prism.levelgen.Decorator:extend "GrassSpreadDecorator"

function GrassSpreadDecorator.tryDecorate(generatorInfo, rng, builder, _)
   local changed = false
   -- Run several growth iterations
   for _ = 1, 3 do
      -- Collect existing grass tiles
      local grassTiles = {}
      for x, y in builder:each() do
         local cell = builder:get(x, y)
         if cell and cell:has(prism.components.Vegetation) then
            table.insert(grassTiles, { x = x, y = y })
         end
      end

      -- Shuffle so growth isn't directional
      for i = #grassTiles, 2, -1 do
         local j = rng:random(i)
         grassTiles[i], grassTiles[j] = grassTiles[j], grassTiles[i]
      end

      for _, pos in ipairs(grassTiles) do
         local x, y = pos.x, pos.y

         -- Collect non-grass neighbors
         local candidates = {}
         for _, d in ipairs(prism.Vector2.neighborhood4) do
            local nx, ny = x + d.x, y + d.y

            if util.isFloor(builder, nx, ny) then
               local cell = builder:get(nx, ny)
               if cell and not cell:has(prism.components.Vegetation) then
                  table.insert(candidates, { x = nx, y = ny })
               end
            end
         end

         -- Spread into one random valid neighbor
         if #candidates > 0 then
            local target = candidates[rng:random(#candidates)]
            if rng:random() > 0.5 then
               builder:set(target.x, target.y, prism.cells.Grass())
               changed = true
            end
         end
      end
   end

   return changed
end

return GrassSpreadDecorator
