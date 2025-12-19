prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = 239, color = prism.Color4.BLUE, background = prism.Color4.BLACK, layer = 4 },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Sight { range = 8, fov = true },
      prism.components.Mover { "walk" },
      prism.components.Health(5),
      prism.components.Inventory { limitCount = 1 },
      prism.components.Equipper { "weapon", "held", "amulet" },
   }
end)
