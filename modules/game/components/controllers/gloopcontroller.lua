--- @class GloopController : Controller
local GloopController = prism.components.Controller:extend("GloopController")

function GloopController:checkDirection(level, owner, direction)
   if not direction then return false end

   local pos = owner:expectPosition()
   local nx, ny = (pos + direction):decompose()
   return level:getCellPassableByActor(nx, ny, owner, prism.Collision.getMovetypeByName("walk")) 
end

function GloopController:act(level, owner)
   if not self.blackboard then self.blackboard = {} end
   if not self:checkDirection(level, owner, self.blackboard.direction) then
      local candidates = {}
      for _, neighbor in ipairs(prism.Vector2.neighborhood8) do
         if self:checkDirection(level, owner, neighbor) then
            table.insert(candidates, neighbor)
         end
      end

      self.blackboard.direction = candidates[level.RNG:random(#candidates)]
   end


   local move = prism.actions.Move(owner, owner:expectPosition() + self.blackboard.direction)
   if level:canPerform(move) then
      return move
   end

   return prism.actions.Wait(owner)
end

return GloopController
