prism.registerActor("Gobbig", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gobbig"),
      -- prism.components.IdleAnimation("Gob"),
      prism.components.Drawable {
         indices = { 324, 325, 340, 341 },
         index = 221,
         color = prism.Color4.LIME,
         background = prism.Color4.BLACK,
         layer = 3,
         size = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.Position(),
      prism.components.Collider({ size = 2 }),
      prism.components.Senses(),
      prism.components.LightSight { fov = true, range = 12, darkvision = 0 },
      prism.components.Inventory { limitCount = 1, limitWeight = 1, limitVolume = 1 },
      prism.components.Equipper { "weapon", "held" },
      prism.components.FireflyController(),
      prism.components.Attacker(1),
      prism.components.Health(6),
      prism.components.Nesting(prism.components.GobHome),
      prism.components.GobFaction(),
   }
end)
