prism.register(prism.Component:extend "GobHome")

prism.registerActor("GobHome", function()
   return prism.Actor.fromComponents {
      prism.components.Name("GobHome"),
      prism.components.GobHome(),
      prism.components.Position()
   }
end)

prism.registerActor("Gob", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gob"),
      -- prism.components.IdleAnimation("Gob"),
      prism.components.Drawable {
         index = 221,
         color = prism.Color4.LIME,
         background = prism.Color4.BLACK,
         layer = 3,
      },
      prism.components.Mover { "walk" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { fov = true, range = 12 },
      prism.components.Inventory { limitCount = 1, limitWeight = 1, limitVolume = 1 },
      prism.components.Equipper { "weapon", "held" },
      prism.components.GobController(),
      prism.components.Attacker(1),
      prism.components.ThrumbleFaction(),
      prism.components.Health(6),
      prism.components.Nesting(prism.components.GobHome)
   }
end)
