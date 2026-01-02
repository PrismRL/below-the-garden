local util = prism.levelgen.util
local TallGrassNearWallsDecorator = prism.levelgen.Decorator:extend "TallGrassNearWallsDecorator"

function TallGrassNearWallsDecorator.tryDecorate(rng, builder)
   local attempts = 200
   local maxTotal = 4
   local maxWallDistance = 2
   local radiusMin = 1
   local radiusMax = 2

   local wallDistanceField = util.buildWallDistanceField(builder)
   local total = 0

   ----------------------------------------------------------------
   -- Attempts to place a single tall grass patch
   ----------------------------------------------------------------
   local function tryPlace()
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if not util.isFloor(builder, x, y) then return 0 end

      local d = wallDistanceField:get(x, y)
      if not d or d > maxWallDistance then return 0 end

      local r = rng:random(radiusMin, radiusMax)

      local blob = prism.LevelBuilder()
      blob:ellipse("fill", x, y, r, r, prism.cells.TallGrass)

      for bx, by in blob:each() do
         if util.isFloor(builder, bx, by) then builder:set(bx, by, prism.cells.TallGrass()) end
      end

      return 1
   end

   ----------------------------------------------------------------
   -- Placement loop
   ----------------------------------------------------------------
   for i = 1, attempts do
      if total >= maxTotal then break end
      total = total + tryPlace()
   end

   if total > 0 then return true end
end

return TallGrassNearWallsDecorator
