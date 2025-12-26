prism.registerActor("Gloop", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gloop"),
      prism.components.Drawable {
         index = 261,
         color = prism.Color4.PEACH,
         background = prism.Color4.BLACK,
         layer = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Senses(),
      prism.components.Sight { range = 4, fov = true, darkvision = 2 / 16 },
      prism.components.Eatable(1),
   }
end)
