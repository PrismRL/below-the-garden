prism.registerActor("Sqeeto", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Sqeeto"),
      prism.components.Drawable {
         index = 257,
         color = prism.Color4.YELLOW,
      },
      prism.components.SqeetoController(),
      prism.components.Mover { "fly" },
      prism.components.Position(),
      prism.components.Collider(),
   }
end)
