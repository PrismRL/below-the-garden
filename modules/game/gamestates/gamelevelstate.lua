local controls = require "controls"

--- @class GameLevelState : LevelState
--- A custom game level state responsible for initializing the level map,
--- handling input, and drawing the state to the screen.
---
--- @overload fun(display: Display, overlay: Display): GameLevelState
local GameLevelState = spectrum.gamestates.LevelState:extend "GameLevelState"

--- @param display Display
--- @param overlay Display
function GameLevelState:__new(display, overlay)
   -- Construct a simple test map using MapBuilder.
   -- In a complete game, you'd likely extract this logic to a separate module
   -- and pass in an existing player object between levels.
   self.overlay = overlay
   local builder = prism.LevelBuilder()

   builder:rectangle("line", 0, 0, display.width - 1, display.height - 1, prism.cells.Wall)
   -- Fill the interior with floor tiles
   builder:rectangle("fill", 1, 1, display.width - 2, display.height - 2, prism.cells.Floor)
   -- Add a small block of walls within the map
   builder:rectangle("fill", 5, 5, 7, 7, prism.cells.Wall)

   -- Place the player character at a starting location
   builder:addActor(prism.actors.Player(), 12, 12)
   builder:addActor(prism.actors.Prism(), 12, 13)
   builder:addActor(prism.actors.Sqeeto(), 13, 12)
   builder:addActor(prism.actors.Sqeeto(), 13, 17)
   builder:addActor(prism.actors.Sqeeto(), 12, 13)
   builder:addActor(prism.actors.Sqeeto(), 10, 12)
   builder:addActor(prism.actors.Sqeeto(), 9, 9)

   local camp = prism.LevelBuilder.fromLz4("camp.lz4")
   builder:blit(camp, 13, 13)

   -- Add systems
   builder:addSystems(prism.systems.SensesSystem(), prism.systems.SightSystem())

   -- Initialize with the created level and display, the heavy lifting is done by
   -- the parent class.
   self.super.__new(self, builder:build(prism.cells.Wall), display)
   print(self.level:query(prism.components.Camp):first())
   self.level:query(prism.components.Inventory):each(function(thrumble)
      if thrumble:getName() == "Thrumble" then
         local campFire = thrumble:expect(prism.components.Senses):query(self.level, prism.components.Camp):first()
         if campFire then thrumble:addRelation(prism.relations.Home, campFire) end
      end
   end)
end

function GameLevelState:handleMessage(message)
   self.super.handleMessage(self, message)

   if prism.messages.LoseMessage:is(message) then
      self.manager:enter(spectrum.gamestates.GameOverState(self.display))
   end
   -- Handle any messages sent to the level state from the level. LevelState
   -- handles a few built-in messages for you, like the decision you fill out
   -- here.

   -- This is where you'd process custom messages like advancing to the next
   -- level or triggering a game over.
end

-- updateDecision is called whenever there's an ActionDecision to handle.
function GameLevelState:updateDecision(dt, owner, decision)
   -- Controls need to be updated each frame.
   controls:update()

   -- Controls are accessed directly via table index.
   if controls.move.pressed then
      local destination = owner:getPosition() + controls.move.vector
      local move = prism.actions.Move(owner, destination)
      if self:setAction(move) then return end
   end

   if controls.pickup.pressed then
      local target = self.level:query(prism.components.Item):at(owner:getPosition():decompose()):first()

      local pickup = prism.actions.Pickup(owner, target)
      if self:setAction(pickup) then return end
   end

   if controls.wait.pressed then self:setAction(prism.actions.Wait(owner)) end
end

local borderConfig = { color = prism.Color4.DARKGREY, cornerColor = prism.Color4.PURPLE }
function GameLevelState:draw()
   self.display:clear()
   self.overlay:clear()

   local player = self.level:query(prism.components.PlayerController):first()

   if not player then
      -- You would normally transition to a game over state
      self.display:putLevel(self.level)
   else
      local position = player:expectPosition()

      -- local x, y = self.display:getCenterOffset(position:decompose())
      -- self.display:setCamera(x, y)

      local primary, secondary = self:getSenses()
      -- Render the level using the player’s senses
      self.display:beginCamera()
      self.display:putSenses(primary, secondary, self.level)
      self.display:endCamera()

      local inventory = player:expect(prism.components.Inventory)
      local item = inventory:query():first()
      if item then self.overlay:putActor(2, self.overlay.height - 1, item) end
   end

   self.overlay:border(1, 1, self.overlay.width, self.overlay.height, borderConfig)
   self.overlay:border(1, self.overlay.height - 2, 3, 3, borderConfig)

   -- custom terminal drawing goes here!

   -- Actually render the terminal out and present it to the screen.
   -- You could use love2d to translate and say center a smaller terminal or
   -- offset it for custom non-terminal UI elements. If you do scale the UI
   -- just remember that display:getCellUnderMouse expects the mouse in the
   -- display's local pixel coordinates
   love.graphics.translate(32, 32)
   love.graphics.scale(4, 4)
   self.display:draw()
   love.graphics.translate(-8, -8)
   self.overlay:draw()

   -- custom love2d drawing goes here!
end

function GameLevelState:resume()
   -- Run senses when we resume from e.g. Geometer.
   self.level:getSystem(prism.systems.SensesSystem):postInitialize(self.level)
end

return GameLevelState
