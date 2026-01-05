prism.registerActor("Smoke", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Smoke"),
      prism.components.Drawable{
         index = 17,
         color = prism.Color4.GREY,
      },
      prism.components.Smoke(),
      prism.components.Position(),
      prism.components.Opaque()
   }
end)