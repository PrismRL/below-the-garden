local controls = require "controls"
local settings = require "settings"

--- @class GameLevelState : LevelState
--- A custom game level state responsible for initializing the level map,
--- handling input, and drawing the state to the screen.
---
--- @overload fun(display: Display, overlay: Display): GameLevelState
local GameLevelState = spectrum.gamestates.LevelState:extend "GameLevelState"

local hud = love.graphics.newImage("display/hud.png")

--- @param display Display
--- @param overlay Display
function GameLevelState:__new(display, overlay, testing)
   -- Construct a simple test map using MapBuilder.
   -- In a complete game, you'd likely extract this logic to a separate module
   -- and pass in an existing player object between levels.
   self.overlay = overlay
   self.hudPosition = prism.Vector2(self.overlay.width - 8, 9)
   self.hudPositions = {
      held = self.hudPosition + prism.Vector2(3, 6),
      pocket = self.hudPosition + prism.Vector2(6, 6),
      weapon = self.hudPosition + prism.Vector2(3, 11),
      amulet = self.hudPosition + prism.Vector2(6, 11),
      health = self.hudPosition + prism.Vector2(6, 2),
      attack = self.hudPosition + prism.Vector2(6, 3),
      shift = self.hudPosition + prism.Vector2(2, 4),
      throw = self.hudPosition + prism.Vector2(2, 8),
      upon = self.hudPosition + prism.Vector2(3, 17),
      cycle = self.hudPosition + prism.Vector2(2, 19),
      drop = self.hudPosition + prism.Vector2(2, 13),
      pickup = self.hudPosition + prism.Vector2(2, 15),
      pickupSlot = self.hudPosition + prism.Vector2(7, 18),
      pickupSwap = self.hudPosition + prism.Vector2(6, 17),
   }

   self.useActions = {
      prism.actions.Eat,
      prism.actions.Gaze,
   }

   local player = prism.actors.Player()
   local builder
   if testing then
      builder = prism.LevelBuilder()
      builder:rectangle("line", 0, 0, 32, 32, prism.cells.Wall)
      -- Fill the interior with floor tiles
      builder:rectangle("fill", 1, 1, 31, 31, prism.cells.Floor)
      -- Add a small block of walls within the map
      builder:rectangle("fill", 5, 5, 7, 7, prism.cells.Wall)
      -- Add a pit area to the southeast
      builder:rectangle("fill", 20, 20, 25, 25, prism.cells.Pit)
      builder:addActor(prism.actors.Player(), 16, 16)
      builder:addActor(prism.actors.Torch(), 12, 12)
   else
      assert(player)
      print("Player", player)
      builder = prism.generators.FirstThird.generate({
         seed = love.timer.getTime(),
         w = 50,
         h = 30,
         depth = 1,
      }, player)
   end

   -- Add systems
   --- @type LightSystem
   self.lightSystem = prism.systems.LightSystem()
   builder:addSystems(
      prism.systems.SlimeTrailSystem(),
      prism.systems.SmokeSystem(),
      prism.systems.SensesSystem(),
      prism.systems.LastSeenSystem(),
      prism.systems.LightSightSystem(),
      prism.systems.TelepathySystem(),
      self.lightSystem,
      prism.systems.ModulateLightSystem(),
      prism.systems.AutoTileSystem(),
      prism.systems.EquipmentSystem(),
      prism.systems.NestingSystem(),
      prism.systems.FallSystem()
   )
   builder:addTurnHandler(require "modules.base.quickturnhandler")

   -- Initialize with the created level and display, the heavy lifting is done by
   -- the parent class.
   self.super.__new(self, builder:build(prism.cells.Wall), display)
end

function GameLevelState:handleMessage(message)
   self.super.handleMessage(self, message)

   if prism.messages.LoseMessage:is(message) then
      self.manager:enter(spectrum.gamestates.GameOverState(self.overlay))
   end

   if prism.messages.DescendMessage:is(message) then self.manager:enter(GameLevelState(self.display, self.overlay)) end
   -- Handle any messages sent to the level state from the level. LevelState
   -- handles a few built-in messages for you, like the decision you fill out
   -- here.

   -- This is where you'd process custom messages like advancing to the next
   -- level or triggering a game over.
end

function GameLevelState:update(dt)
   GameLevelState.super.update(self, dt)
   self.lightSystem:update()
end

-- updateDecision is called whenever there's an ActionDecision to handle.
function GameLevelState:updateDecision(dt, owner, decision)
   local idle
   local held
   local pocket
   for slot, equipped in pairs(owner:expect(prism.components.Equipper).equipped) do
      if equipped then
         idle = equipped:get(prism.components.IdleAnimation)
         if idle then idle.animation:update(dt) end
      end
      if slot == "held" then held = equipped end
      if slot == "pocket" then pocket = equipped end
   end
   self.upon = self.level:query(prism.components.Equipment):at(owner:expectPosition():decompose()):gather()
   if not self.uponIndex or #self.upon < self.uponIndex then self.uponIndex = 1 end

   -- Controls need to be updated each frame.
   controls:update()

   if controls.next.pressed and self.upon and #self.upon > 1 then
      self.uponIndex = self.uponIndex + 1
      if self.uponIndex > #self.upon then self.uponIndex = 1 end
   end

   -- Controls are accessed directly via table index.
   if controls.move.pressed then
      local destination = owner:getPosition() + controls.move.vector

      local chest = self.level:query(prism.components.Chest):at(destination:decompose()):first()
      local open = prism.actions.Open(owner, chest)
      if self:setAction(open) then return end

      local move = prism.actions.Move(owner, destination)
      if self:setAction(move) then return end

      local target = self.level:query(prism.components.Health):at(destination:decompose()):first()
      local attack = prism.actions.Attack(owner, target)
      if self:setAction(attack) then return end

      local stair = self.level:query(prism.components.Stair):at(destination:decompose()):first()
      local descend = prism.actions.Descend(owner, stair)
      if self:setAction(descend) then return end
   end

   if controls.pickup.pressed then
      local target = self.upon and self.upon[self.uponIndex]

      local pickup = prism.actions.Pickup(owner, target)
      if self:setAction(pickup) then return end
   end

   if controls.use.pressed and held then
      for _, action in ipairs(self.useActions) do
         if self:setAction(action(owner, held)) then return end
      end

      if held:has(prism.components.Tonguer) then
         self.targets = { nil }
         self.selectedAction = prism.actions.Tongue
         self.manager:push(
            spectrum.gamestates.DirectionalTargetHandler(
               self.overlay,
               self,
               self.targets,
               self.selectedAction:getTarget(2)
            )
         )
      end
   end

   if controls.swap.pressed then
      local swap = prism.actions.Swap(owner, pocket)
      if self:setAction(swap) then return end
   end

   if held and controls.throw.pressed then
      self.targets = {}
      self.selectedAction = prism.actions.Throw
      self.manager:push(
         spectrum.gamestates.ThrowTargetHandler(self.overlay, self, self.targets, self.selectedAction:getTarget(1))
      )
   end

   if controls.drop.pressed then
      self.targets = {}
      self.selectedAction = prism.actions.Drop
      self.manager:push(spectrum.gamestates.DropState(self, owner, self.targets))
   end

   if controls.wait.pressed then self:setAction(prism.actions.Wait(owner)) end

   if controls.zoom_in.pressed then
      settings.scale = settings.scale + 1
      love.window.setMode(
         settings.windowWidth * 8 * settings.scale,
         settings.windowHeight * 8 * settings.scale,
         { usedpiscale = false }
      )
   end

   if controls.zoom_out.pressed then
      settings.scale = settings.scale - 1
      love.window.setMode(
         settings.windowWidth * 8 * settings.scale,
         settings.windowHeight * 8 * settings.scale,
         { usedpiscale = false }
      )
   end
end

--- @param item? Actor
function GameLevelState:putItem(item, x, y)
   if item and item:has(prism.components.IdleAnimation) then
      item:expect(prism.components.IdleAnimation).animation:draw(self.overlay, x, y)
   elseif item then
      self.overlay:putActor(x, y, item)
   end
end

local windowBorder = { color = prism.Color4.DARK, cornerColor = prism.Color4.PURPLE }

--- @param player Actor
function GameLevelState:putHUD(player)
   love.graphics.push()
   love.graphics.scale(settings.scale, settings.scale)
   love.graphics.draw(hud, self.hudPosition.x * self.overlay.cellSize.x, self.hudPosition.y * self.overlay.cellSize.y)
   love.graphics.pop()

   self.overlay:border(1, 1, self.overlay.width - 7, self.overlay.height, windowBorder)

   local positions = self.hudPositions

   local hp = player:expect(prism.components.Health).hp
   self.overlay:print(
      positions.health.x,
      positions.health.y,
      (hp < 10 and "0" or "") .. tostring(hp),
      prism.Color4.RED,
      prism.Color4.BLACK
   )

   local attack = player:expect(prism.components.Attacker):getDamageAndKnockback()
   self.overlay:print(
      positions.attack.x,
      positions.attack.y,
      (attack < 10 and "0" or "") .. tostring(attack),
      prism.Color4.GOLD,
      prism.Color4.BLACK
   )

   local equipper = player:expect(prism.components.Equipper)

   local upon = self.upon and self.upon[self.uponIndex] or nil
   local held = equipper:get("held")
   local weapon = equipper:get("weapon")
   local amulet = equipper:get("amulet")
   local pocket = equipper:get("pocket")

   self:putItem(held, positions.held:decompose())
   self:putItem(pocket, positions.pocket:decompose())
   self:putItem(weapon, positions.weapon:decompose())
   self:putItem(amulet, positions.amulet:decompose())
   self:putItem(upon, positions.upon:decompose())

   if held or weapon or amulet or pocket then
      self.overlay:print(positions.drop.x, positions.drop.y, "V", prism.Color4.CORNFLOWER)
   end

   if upon and prism.actions.Pickup:validateTarget(1, self.level, player, upon) then
      self.overlay:print(positions.pickup.x, positions.pickup.y, "P", prism.Color4.CORNFLOWER)
      local slot = next(upon:get(prism.components.Equipment).requiredCategories)
      self.overlay:put(positions.pickupSlot.x, positions.pickupSlot.y, slot, prism.Color4.TEXT)
      self:putItem(equipper:get(slot), positions.pickupSwap:decompose())
   end

   if held or pocket then self.overlay:print(positions.shift.x, positions.shift.y, "SHFT", prism.Color4.CORNFLOWER) end
   if held then
      local extraAction = false
      for _, action in ipairs(self.useActions) do
         if action:validateTarget(1, self.level, player, held) then
            self.overlay:print(positions.throw.x, positions.throw.y, "P", prism.Color4.CORNFLOWER)
            self.overlay:print(positions.throw.x + 2, positions.throw.y, action.name, prism.Color4.TEXT)
            extraAction = true
            break
         end
      end

      if held:has(prism.components.Tonguer) then
         self.overlay:print(positions.throw.x, positions.throw.y, "P", prism.Color4.CORNFLOWER)
         self.overlay:print(positions.throw.x + 2, positions.throw.y, prism.actions.Tongue.name, prism.Color4.TEXT)
         extraAction = true
      end

      self.overlay:print(positions.throw.x, positions.throw.y + (extraAction and 1 or 0), "T", prism.Color4.CORNFLOWER)
      self.overlay:print(positions.throw.x + 2, positions.throw.y + (extraAction and 1 or 0), "thrw", prism.Color4.TEXT)
   end

   if self.upon and #self.upon > 1 then
      self.overlay:print(positions.cycle.x, positions.cycle.y, "TAB", prism.Color4.CORNFLOWER)
   end
end

local dummy = prism.Color4()
function GameLevelState:draw()
   self.display:clear()
   self.overlay:clear()

   local player = self.level:query(prism.components.PlayerController):first()

   if not player then
      -- You would normally transition to a game over state
      self.display:putLevel(self.level)
   else
      -- local x, y = self.display:getCenterOffset(position:decompose())
      -- self.display:setCamera(x, y)

      local primary, secondary = self:getSenses()
      -- Render the level using the player’s senses
      -- local x, y = self.display:getCenterOffset(player:expectPosition():decompose())
      -- self.display:setCamera(x, y)
      self.display:beginCamera()
      self.display:pushModifier(self.lightPass)
      self.display:pushModifier(function(entity, x, y, drawable)
         --- @cast entity Entity
         --- @cast x integer
         --- @cast y integer
         --- @cast drawable Drawable
         local sight = player:get(prism.components.Sight)
         local darkvision = sight and sight.darkvision or 0

         local light = self.lightSystem:getRTValuePerspective(x, y, player)
         light = light or dummy

         -- Preserve original color
         local base = drawable.color:copy()
         local baseBackground = drawable.background:copy()

         -- Apply lighting normally
         if prism.Actor:is(entity) then
            local value = math.min(light:average(), 1)
            drawable.color = drawable.color * value
            drawable.background = drawable.background * value
         else
            drawable.color.r = drawable.color.r * light.r
            drawable.color.g = drawable.color.g * light.g
            drawable.color.b = drawable.color.b * light.b

            drawable.background.r = drawable.background.r * light.r
            drawable.background.g = drawable.background.g * light.g
            drawable.background.b = drawable.background.b * light.b
         end

         -- Linear darkness (no perceptual luminance)
         local brightness = drawable.color:average()
         local darkness = math.min(math.max(1 - brightness, 0), 1)
         darkness = math.max(darkness - darkvision, 0)

         -- Knee at 0.25: everything below stays bright
         if darkness <= 0.6 then
            darkness = 0
         else
            -- Remap [0.25 .. 1] → [0 .. 1]
            darkness = (darkness - 0.6) / 0.4
         end

         -- Shape the curve (optional but recommended)
         local restore = math.pow(darkness, 1.5)
         local alphaLoss = darkness * 0.70

         -- Lerp back toward base color
         drawable.color = drawable.color:lerp(base, restore)
         drawable.background = drawable.background:lerp(baseBackground, restore)
         -- Fade opacity as darkness increases
         drawable.color.a = base.a * (1 - alphaLoss)
      end)
      self.display:putSenses(primary, secondary, self.level)

      for entity, _ in pairs(player:getRelations(prism.relations.TelepathedRelation)) do
         local position = entity:get(prism.components.Position):getVector()
         if not player:hasRelation(prism.relations.SeesRelation, entity) then
            self.display:putActor(position.x, position.y, entity, prism.Color4.CORNFLOWER)
         end
      end
      self.display:popModifier()
      self.display:endCamera()

      self:putHUD(player)
   end

   -- custom terminal drawing goes here!

   -- Actually render the terminal out and present it to the screen.
   -- You could use love2d to translate and say center a smaller terminal or
   -- offset it for custom non-terminal UI elements. If you do scale the UI
   -- just remember that display:getCellUnderMouse expects the mouse in the
   -- display's local pixel coordinates
   -- love.graphics.push()
   love.graphics.translate(8 * settings.scale, 8 * settings.scale)
   love.graphics.scale(settings.scale, settings.scale)
   self.display:draw()
   love.graphics.translate(-8, -8)
   self.overlay:draw()
   -- love.graphics.pop()

   -- custom love2d drawing goes here!
   love.graphics.print(love.timer.getFPS())
end

function GameLevelState:resume()
   -- Run senses when we resume from e.g. Geometer.
   self.level:getSystem(prism.systems.SensesSystem):postInitialize(self.level)
   -- self.level:getSystem(prism.systems.AutoTileSystem):initialize(self.level)

   if self.targets then
      print(unpack(self.targets))
      local action = self.selectedAction(self.decision.actor, unpack(self.targets))
      local success, err = self:setAction(action)
      if not success then prism.logger.info(err) end
      self.targets = nil
   end
end

return GameLevelState
