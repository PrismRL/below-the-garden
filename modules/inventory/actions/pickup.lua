local sf = string.format
local Name = prism.components.Name

local PickupTarget = prism.Target(prism.components.Equipment):range(0):filter(function(level, owner, target)
   --- @cast target Actor
   local equipper = owner:expect(prism.components.Equipper)
   return equipper:canEquip(target, not target:has(prism.components.Item))
end)

---@class Pickup : Action
local Pickup = prism.Action:extend("Pickup")
Pickup.targets = { PickupTarget }
Pickup.requiredComponents = {
   prism.components.Controller,
   prism.components.Equipper,
}

--- @param item Actor
function Pickup:perform(level, item)
   local equipper = self.owner:expect(prism.components.Equipper)
   local equipment = item:expect(prism.components.Equipment)

   local slot, _ = next(equipment.requiredCategories)
   local equipped = equipper:get(slot)
   level:removeActor(item)
   level:tryPerform(prism.actions.Unequip(self.owner, equipped))
   if equipped then level:addActor(equipped, self.owner:expectPosition():decompose()) end
   level:perform(prism.actions.Equip(self.owner, item))

   if prism.components.Log then
      Log = prism.components.Log
      Log.addMessage(self.owner, sf("You pick up the %s", Name.get(item)))
      Log.addMessageSensed(level, self, sf("%s picks up the %s", Name.get(self.owner), Name.get(item)))
   end
end

return Pickup
