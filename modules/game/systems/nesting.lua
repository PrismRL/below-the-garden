--- @class NestingSystem : System
local NestingSystem = prism.System:extend "NestingSystem"

--- @param level Level
function NestingSystem:postInitialize(level)
   level:query(prism.components.Nesting):each(function(nester, nesting)
      --- @cast nesting Nesting
      local candidates = level:query(nesting.nestType)
      print(nesting.nestType)

      local bestHome
      local bestRange = math.huge

      for candidate in candidates:iter() do
         if candidate ~= nester then
            local r = candidate:getRange(nester)
            if r < bestRange then
               bestRange = r
               bestHome = candidate
            end
         end
      end

      if bestHome then
         nester:addRelation(prism.relations.Home, bestHome)
      end
   end)
end

return NestingSystem

