--- @class Open : Action
local Open = prism.Action:extend "Open"
Open.targets = { prism.Target(prism.components.Chest):range(1, "8way") }

--- @param level Level
function Open:perform(level, chest)
   local chestComponent = chest:expect(prism.components.Chest)
   if chestComponent.toSpawn then
      level:addActor(chestComponent.toSpawn(), chest:expectPosition():decompose())
   end

   level:removeActor(chest)
end

return Open