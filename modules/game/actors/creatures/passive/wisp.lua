local Animation = spectrum.Animation
spectrum.registerAnimation("WispIdle", function()
   local animation = Animation(Animation.buildFrames { range = "275-276", color = prism.Color4.BLUE, layer = 2 }, 0.4)
   animation:update(love.math.random())
   return animation
end)

prism.registerActor("Wisp", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Wisp"),
      prism.components.Drawable {
         index = 275,
         color = prism.Color4.BLUE,
         layer = 2,
      },
      prism.components.Senses(),
      prism.components.LightSight { range = 3, fov = true },
      prism.components.Mover { "fly" },
      prism.components.Position(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly", "swim" } },
      prism.components.Light(prism.Color4.BLUE, 4, prism.lighteffects.HeartbeatEffect()),
      prism.components.IdleAnimation("WispIdle"),
      prism.components.FireflyController(),
      prism.components.Equipment("held"),
   }
end)
