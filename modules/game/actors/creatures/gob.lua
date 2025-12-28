local Animation = spectrum.Animation
spectrum.registerAnimation("Gob", function()
   local animation = Animation(Animation.buildFrames { range = "269-270", color = prism.Color4.RED }, { 3, 0.2 })
   animation:update(love.math.random())
   return animation
end)

prism.registerActor("Gob", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gob"),
      -- prism.components.IdleAnimation("Gob"),
      prism.components.Drawable {
         index = 221,
         color = prism.Color4.LIME,
         background = prism.Color4.BLACK,
         layer = 3,
      },
      prism.components.Mover { "walk" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { fov = true, range = 12 },
      prism.components.Inventory { limitCount = 1, limitWeight = 1, limitVolume = 1 },
      prism.components.Equipper { "weapon" },
      prism.components.FireflyController(),
      prism.components.Attacker(1),
      prism.components.WarmBlooded(),
      prism.components.ThrumbleFaction(),
      prism.components.Health(6),
   }
end)
