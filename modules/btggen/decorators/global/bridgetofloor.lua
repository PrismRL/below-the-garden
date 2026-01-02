local util = prism.levelgen.util
local BridgeToFloorDecorator = prism.levelgen.Decorator:extend "BridgeToFloorDecorator"

function BridgeToFloorDecorator.tryDecorate(rng, builder, room)
   local changed = false

   ----------------------------------------------------------------
   -- Pass 1: widen bridges with >2 walkable neighbors
   ----------------------------------------------------------------
   local toFloor = {}

   for x, y in builder:each() do
      local cell = builder:get(x, y)
      if cell and cell:has(prism.components.BridgeComponent) then
         local walkableNeighbors = 0

         for _, d in ipairs(prism.Vector2.neighborhood4) do
            local nx, ny = x + d.x, y + d.y

            if util.isWalkable(builder, nx, ny) and not builder:get(nx, ny):has(prism.components.BridgeComponent) then
               walkableNeighbors = walkableNeighbors + 1
            end
         end

         if walkableNeighbors > 2 then toFloor[#toFloor + 1] = { x = x, y = y } end
      end
   end

   for _, p in ipairs(toFloor) do
      builder:set(p.x, p.y, prism.cells.Floor())
      changed = true
   end

   ----------------------------------------------------------------
   -- Pass 2: remove isolated 1-tile bridges
   ----------------------------------------------------------------
   local isolated = {}

   for x, y in builder:each() do
      local cell = builder:get(x, y)
      if cell and cell:has(prism.components.BridgeComponent) then
         local hasNeighborBridge = false

         for _, d in ipairs(prism.Vector2.neighborhood4) do
            local nx, ny = x + d.x, y + d.y
            local ncell = builder:get(nx, ny)

            if ncell and ncell:has(prism.components.BridgeComponent) then
               hasNeighborBridge = true
               break
            end
         end

         if not hasNeighborBridge then isolated[#isolated + 1] = { x = x, y = y } end
      end
   end

   for _, p in ipairs(isolated) do
      builder:set(p.x, p.y, prism.cells.Floor())
      changed = true
   end

   if changed then return true end
end

return BridgeToFloorDecorator
