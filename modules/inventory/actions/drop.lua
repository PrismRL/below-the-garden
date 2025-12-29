local sf = string.format
local Name = prism.components.Name

local DropTarget = prism.Target():filter(function(level, owner, targetObject, previousTargets)
   local equipped = owner:expect(prism.components.Equipper):isEquipped(targetObject)
   local pocketed = owner:hasRelation(prism.relations.InventoryRelation, targetObject)
   return equipped or pocketed
end)

---@class Drop : Action
local Drop = prism.Action:extend("Drop")
Drop.targets = { DropTarget }
Drop.requiredComponents = {
   prism.components.Controller,
   prism.components.Equipper,
}

--- @param actor Actor
function Drop:perform(level, actor)
   local removed = actor
   if not level:tryPerform(prism.actions.Unequip(self.owner, actor)) then
      local item = actor:expect(prism.components.Item)
      local inventory = self.owner:expect(prism.components.Inventory)

      removed = inventory:removeQuantity(actor, item.stackCount or 1)
   end

   removed:give(prism.components.Position(self.owner:getPosition()))

   if prism.components.Log then
      Log = prism.components.Log
      Log.addMessage(self.owner, sf("You drop the %s", Name.get(actor)))
      Log.addMessageSensed(level, self, sf("%s drops the %s", Name.get(self.owner), Name.get(actor)))
   end
end

return Drop
