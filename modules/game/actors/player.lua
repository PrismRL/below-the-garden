prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = 239, color = prism.Color4.BLUE, background = prism.Color4.BLACK, layer = 4 },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Mover { "walk" },
      prism.components.Health(5),
      prism.components.Inventory { limitCount = 1 },
      prism.components.Equipper { "weapon", "held", "amulet" },
      prism.components.Thrower(5),
      prism.components.ConditionHolder(),
      prism.components.Light(prism.Color4(1, 0.5, 0.2), 8, prism.lighteffects.Flicker()),
      prism.components.LightSight { range = 8, fov = true, darkvision = 2/16},
   }
end)
