local util = prism.levelgen.util
local PruneMisalignedDoorsDecorator = prism.levelgen.Decorator:extend "PruneMisalignedDoorsDecorator"

function PruneMisalignedDoorsDecorator.tryDecorate(generatorInfo, rng, builder)
   local toRemove = {}

   ----------------------------------------------------------------
   -- A valid door must have:
   --  - 2 walls on opposite sides
   --  - 2 floors on the other opposite sides
   ----------------------------------------------------------------
   local function isValidDoor(x, y)
      local north = util.isWall(builder, x, y - 1)
      local south = util.isWall(builder, x, y + 1)
      local west = util.isWall(builder, x - 1, y)
      local east = util.isWall(builder, x + 1, y)

      local floorN = util.isFloor(builder, x, y - 1)
      local floorS = util.isFloor(builder, x, y + 1)
      local floorW = util.isFloor(builder, x - 1, y)
      local floorE = util.isFloor(builder, x + 1, y)

      -- Vertical corridor: walls E/W, floors N/S
      if west and east and floorN and floorS then return true end

      -- Horizontal corridor: walls N/S, floors E/W
      if north and south and floorW and floorE then return true end

      return false
   end

   ----------------------------------------------------------------
   -- Collect invalid doors
   ----------------------------------------------------------------
   for door in builder:query(prism.components.Door):iter() do
      local x, y = door:expectPosition():decompose()
      if not isValidDoor(x, y) then
         print(prism.components.Name.get(door))
         toRemove[#toRemove + 1] = door
      end
   end

   ----------------------------------------------------------------
   -- Remove them
   ----------------------------------------------------------------
   for _, door in ipairs(toRemove) do
      builder:removeActor(door)
   end

   if #toRemove > 0 then return true end
end

return PruneMisalignedDoorsDecorator
