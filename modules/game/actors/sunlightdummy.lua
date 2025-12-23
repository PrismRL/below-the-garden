prism.registerActor("Sunlight", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Sunlight"),
      prism.components.Position(),
      prism.components.Light(prism.Color4(255 / 255, 244 / 255, 214 / 255), 8),
   }
end)
