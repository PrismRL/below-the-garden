local color = (prism.Color4.ORANGE + prism.Color4.ORANGE) / 2
prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = 278, color = prism.Color4.BLUE, background = prism.Color4.BLACK, layer = 4 },
      prism.components.ConditionHolder(),
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Mover { "walk" },
      prism.components.Health(5),
      prism.components.Inventory { limitCount = 1 },
      prism.components.Equipper { "weapon", "held", "amulet" },
      prism.components.Thrower(5),
      prism.components.Light(color, 5, prism.lighteffects.Flicker { speed = 2, colorShift = 0.1 }),
      prism.components.LightSight { range = 15, fov = true, darkvision = 2 / 16 },
      prism.components.WarmBlooded(),
      prism.components.Attacker(1),
   }
end)
