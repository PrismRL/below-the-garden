prism.registerActor("Skink", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Skink"),
      prism.components.Drawable {
         index = "S",
         color = prism.Color4.BLUE,
         layer = 3,
      },
      prism.components.Mover { "walk" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Senses(),
      prism.components.Sight { fov = true, range = 12 },
      prism.components.ThrumbleController(),
      prism.components.Attacker(2),
      prism.components.ThrumbleFaction(),
      prism.components.LastSeen(prism.components.PlayerController),
      prism.components.Health(6),
   }
end)
