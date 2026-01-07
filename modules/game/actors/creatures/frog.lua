local function makeTongueFrame(direction, length, stage, skipFirst)
   -- direction: Vector2
   -- stage: 1 = base, 2..length = extending, length+1 = full, length+2.. = retracting
   return function(display, x, y)
      local base, tip, mid, full
      if direction == prism.Vector2.RIGHT then
         base, tip, mid, full = 293, 292, 291, 130
      elseif direction == prism.Vector2.LEFT then
         base, tip, mid, full = 296, 295, 294, 130
      elseif direction == prism.Vector2.DOWN then
         base, tip, mid, full = 299, 298, 297, 129
      else -- prism.Vector2.UP
         base, tip, mid, full = 302, 301, 300, 129
      end
      -- Draw base
      if not skipFirst then
         if stage > 1 then
            display:put(x, y, mid, prism.Color4.GREEN)
         else
            display:put(x, y, base, prism.Color4.GREEN)
         end
      end

      if stage > 1 then display:put(x + direction.x, y + direction.y, tip, prism.Color4.PEACH) end
      if stage > 2 and length > 2 then
         display:put(x + direction.x * 2, y + direction.y * 2, tip, prism.Color4.PEACH)
         display:put(x + direction.x, y + direction.y, full, prism.Color4.PEACH)
      end
      if stage > 3 and length > 3 then
         display:put(x + direction.x * 3, y + direction.y * 3, tip, prism.Color4.PEACH)
         display:put(x + direction.x * 2, y + direction.y * 2, full, prism.Color4.PEACH)
         display:put(x + direction.x, y + direction.y, full, prism.Color4.PEACH)
      end
   end
end

spectrum.registerAnimation("FrogTongue", function(direction, length, skipFirst)
   local frames = {}
   local times = {}

   -- Extend
   for stage = 1, length do
      table.insert(frames, makeTongueFrame(direction, length, stage, skipFirst))
      table.insert(times, 0.05)
   end
   -- Full
   table.insert(frames, makeTongueFrame(direction, length, length + 1, skipFirst))
   table.insert(times, 0.5)
   -- Retract
   for stage = length, 1, -1 do
      table.insert(frames, makeTongueFrame(direction, length, stage, skipFirst))
      table.insert(times, 0.05)
   end

   return spectrum.Animation(frames, times, "pauseAtEnd")
end)

spectrum.registerAnimation("FrogIdle", function()
   return spectrum.Animation(spectrum.Animation.buildFrames({ range = "263-264", color = prism.Color4.GREEN }), 1)
end)

prism.registerActor("FrogTongue", function()
   return prism.Actor.fromComponents {
      prism.components.Name("FrogTongue"),
      prism.components.Equipment("held"),
      prism.components.Drawable {
         index = 308,
         color = prism.Color4.PEACH,
      },
      prism.components.Tonguer(),
   }
end)

prism.registerActor("Frog", function()
   local equipper = prism.components.Equipper { "held" }
   equipper.equipped["held"] = prism.actors.FrogTongue()

   return prism.Actor.fromComponents {
      prism.components.Name("Frog"),
      prism.components.Drawable { index = 293, layer = 3 },
      prism.components.IdleAnimation("FrogIdle"),
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Mover { "walk", "swim" },
      prism.components.Senses(),
      prism.components.LightSight { range = 4, fov = false, darkvision = 0 },
      prism.components.FrogController(),
      prism.components.Health(6),
      prism.components.Attacker(1),
      prism.components.Slow(),
      prism.components.ConditionHolder(),
      prism.components.Tonguer(),
      equipper,
      prism.components.Nesting(prism.components.FrogHome),
   }
end)
