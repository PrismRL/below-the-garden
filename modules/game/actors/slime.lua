prism.registerActor("Slime", function(lifetime)
   return prism.Actor.fromComponents {
      prism.components.Name("SlimeTrail"),
      prism.components.Drawable {
         index = ".",
         color = prism.Color4.YELLOW,
      },
      prism.components.Slime(lifetime),
      prism.components.Position(),
   }
end)
