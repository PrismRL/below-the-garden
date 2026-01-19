prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable {
         index = 237,
         color = prism.Color4.BLUE * 1.5,
         background = prism.Color4.BLACK,
         layer = 4,
      },
      prism.components.ConditionHolder(),
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Mover { "walk", "swim" },
      prism.components.Health(10),
      -- prism.components.Inventory { limitCount = 1 },
      prism.components.Equipper { "weapon", "held", "amulet", "pocket" },
      prism.components.Thrower(5),
      prism.components.LightSight { range = 15, fov = true, darkvision = 2 / 16 },
      prism.components.WarmBlooded(),
      prism.components.PlayerFaction(),
      prism.components.Attacker(2),
   }
end)
