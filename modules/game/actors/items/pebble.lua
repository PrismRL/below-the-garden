prism.registerActor("Pebble", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Pebble"),
      prism.components.Drawable {
         index = 267,
         color = prism.Color4.GREY,
      },
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Position(),
      prism.components.Attacker(1),
   }
end)
