prism.registerActor("Sqeeto", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Sqeeto"),
      prism.components.Drawable {
         index = 257,
         color = prism.Color4.YELLOW,
         background = prism.Color4.BLACK,
         layer = 3,
      },
      prism.components.Senses(),
      prism.components.LightSight { range = 5, fov = true },
      prism.components.SqeetoController(),
      prism.components.Mover { "fly" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Health(3),
      prism.components.Attacker(1),
      prism.components.SqeetoFaction(),
   }
end)
