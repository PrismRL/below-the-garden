--- @class AutoTileSystem : System
local AutoTileSystem = prism.System:extend("AutoTileSystem")

--- @param level Level
function AutoTileSystem:initialize(level)
   for x, y, cell in level:eachCell() do
      local autotile = cell:get(prism.components.AutoTile)
      if autotile then
         ---@cast autotile AutoTile
         cell:give(self:getDrawableFor(x, y, autotile))
      end
   end
end

--- @param pattern integer[]
--- @return integer[]
local function flipPatternHorizontally(pattern)
   -- stylua: ignore start
   return {
      pattern[3], pattern[2], pattern[1],
      pattern[6], pattern[5], pattern[4],
      pattern[9], pattern[8], pattern[7],
   }
   -- stylua: ignore end
end

--- @param pattern integer[]
--- @return integer[]
local function flipPatternVertically(pattern)
   -- stylua: ignore start
   return {
      pattern[7], pattern[8], pattern[9],
      pattern[4], pattern[5], pattern[6],
      pattern[1], pattern[2], pattern[3],
   }
   -- stylua: ignore end
end

--- @param autotileId integer
--- @param pattern integer[]
--- @param x integer
--- @param y integer
--- @return boolean
function AutoTileSystem:testPattern(autotileId, pattern, x, y)
   local dx, dy = -1, -1
   local ruleIsValid = true

   for i, value in ipairs(pattern) do
      local cellToTest = self.owner:getCell(x + dx, y + dy)

      if not cellToTest then
         -- There is no cell and we needed either the same cell or a specific group.
         if value == 2 or value > 3 then return false end
      else
         local autotileToTest = cellToTest:get(prism.components.AutoTile)
         local sameLayer = autotileToTest and (autotileId == autotileToTest.id)

         -- We needed the same layer but it's a different one.
         if value == 2 and not sameLayer then return false end

         -- We needed a different layer but it's the same one.
         if value == 1 and sameLayer then return false end

         -- We needed a specific layer but it's a different one.
         local otherId = autotileToTest and autotileToTest.id
         if value > 3 and otherId ~= value then return false end
      end

      dx = dx + 1
      if i % 3 == 0 then
         dy = dy + 1
         dx = -1
      end
   end

   return ruleIsValid
end

--- @param x integer
--- @param y integer
--- @param autotile AutoTile
--- @return Drawable
function AutoTileSystem:getDrawableFor(x, y, autotile)
   -- 0 can be anything
   -- 1 is NOT the same Cell
   -- 2 is the SAME Cell
   -- 3 is the middle
   -- > 3 is a specific other Cell

   for _, rule in ipairs(autotile.rules) do
      local pattern = rule.pattern
      local dx, dy = -1, -1
      local ruleIsValid = true
      print("hello")

      if not pattern then return self:getVariationForRule(autotile, rule) end

      if self:testPattern(autotile.id, rule.pattern, x, y) then return self:getVariationForRule(autotile, rule) end

      if rule.mirrorX and self:testPattern(autotile.id, flipPatternHorizontally(pattern), x, y) then
         return self:getVariationForRule(autotile, rule)
      end

      if rule.mirrorY and self:testPattern(autotile.id, flipPatternVertically(pattern), x, y) then
         return self:getVariationForRule(autotile, rule)
      end

      if rule.mirrorX and rule.mirrorY then
         local flipped = flipPatternHorizontally(flipPatternVertically(pattern))
         if self:testPattern(autotile.id, flipped, x, y) then return self:getVariationForRule(autotile, rule) end
      end
   end

   return autotile.drawables["default"]
end

function AutoTileSystem:getVariationForRule(autotile, rule)
   local random = love.math.random(rule.totalWeight)
   print(random)

   local sum = 0
   for value, weight in pairs(rule.variations) do
      sum = sum + weight
      if random <= sum then return autotile.drawables[value] end
   end
end

return AutoTileSystem
