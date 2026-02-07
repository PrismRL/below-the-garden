spectrum.registerAnimation("CrystalIdle", function()
   return spectrum.Animation({
      {
         indices = { 353, 354, 355, 369, 370, 371, 385, 386, 387 },
         size = 3,
         color = prism.Color4.WHITE,
         background = prism.Color4.BLACK,
         layer = 3,
      },
   }, 1)
end)

prism.registerActor("Crystal", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Crystal"),
      prism.components.Position(),
      prism.components.Drawable {
         index = 353,
         indices = { 353, 354, 355, 369, 370, 371, 385, 386, 387 },
         size = 3,
         color = prism.Color4.WHITE,
         background = prism.Color4.BLACK,
         layer = 3,
      },
      prism.components.Crystal(),
      prism.components.IdleAnimation("CrystalIdle"),
      prism.components.Collider { size = 3 },
      prism.components.Light(
         prism.Color4.PRISM,
         24,
         prism.lighteffects.HeartbeatEffect { sharpness = 10, amplitude = 0.5 }
      ),
   }
end)
