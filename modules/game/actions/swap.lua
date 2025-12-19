--- @class SwapHeld : Action
--- @overload fun(owner: Actor, ...): SwapHeld
local SwapHeld = prism.actions.QuickAction:extend "Swap"
SwapHeld.abstract = false
SwapHeld.requiredComponents = { prism.components.Equipper, prism.components.Inventory }
SwapHeld.targets = { prism.targets.InventoryTarget(prism.components.Equipment):optional() }

--- @param level Level
function SwapHeld:canPerform(level, item)
   local equipper = self.owner:expect(prism.components.Equipper)
   -- if we have an item in the inventory it must be equippable
   if item then return equipper:canEquip(item, true) end
   -- otherwise we must have something in the held slot
   return not not equipper:get("held")
end

--- @param level Level
function SwapHeld:perform(level, item)
   local inventory = self.owner:expect(prism.components.Inventory)
   local held = self.owner:expect(prism.components.Equipper):get("held")
   level:tryPerform(prism.actions.Unequip(self.owner, held))
   if item then
      inventory:removeItem(item)
      level:perform(prism.actions.Equip(self.owner, item))
   end
   if held then self.owner:expect(prism.components.Inventory):addItem(held) end
end

return SwapHeld
