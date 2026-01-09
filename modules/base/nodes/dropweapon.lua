--- @class DropWeaponBehavior : BehaviorTree.Node
local DropWeaponBehavior = prism.BehaviorTree.Conditional:extend("DropWeaponBehavior")

--- @param slot
function DropWeaponBehavior:__new(slot)
   self.slot = slot
end

function DropWeaponBehavior:run(level, actor)
   local home = actor:getRelation(prism.relations.Home)
   if home then
      local distance = actor:getRange(home)
      if distance <= 2 then
         local equipper = actor:expect(prism.components.Equipper)
         if level:canPerform(prism.actions.Drop(actor, equipper:get(self.slot or "weapon"))) then
            print "DROPPING"
            return prism.actions.Drop(actor, equipper:get(self.slot or "weapon"))
         end
      end
   end

   return true
end

return DropWeaponBehavior
