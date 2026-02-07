prism.registerActor("HelmLight", function()
   return prism.Actor.fromComponents {
      prism.components.Name("HelmLight"),
      prism.components.Position(),
      prism.components.Light(
         prism.Color4.GOLD,
         8,
         prism.lighteffects.SineEffect { spatialScale = 0, amplitude = 0.3, speed = 30, noiseScale = 0 }
      ),
   }
end)

prism.registerActor("UndyingHelm", function()
   return prism.Actor.fromComponents {
      prism.components.Name("UndyingHelm"),
      prism.components.Drawable {
         index = 223,
         color = prism.Color4.GOLD,
      },
      prism.components.Equipment("amulet", prism.conditions.Undying()),
      prism.components.Position(),
   }
end)
