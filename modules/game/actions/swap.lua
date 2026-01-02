--- @class SwapHeld : Action
--- @overload fun(owner: Actor, ...): SwapHeld
local SwapHeld = prism.actions.QuickAction:extend "Swap"
SwapHeld.abstract = false
SwapHeld.requiredComponents = { prism.components.Equipper }
SwapHeld.targets = { prism.targets.EquippedTarget("pocket"):optional() }

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
   local equipper = self.owner:expect(prism.components.Equipper)
   equipper.equipped["pocket"] = equipper:get("held")
   equipper.equipped["held"] = item
end

return SwapHeld
