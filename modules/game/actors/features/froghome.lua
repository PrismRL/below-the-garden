prism.registerActor("FrogHome", function()
   return prism.Actor.fromComponents {
      prism.components.Name("FrogHome"),
      prism.components.Position(),
      prism.components.FrogHome(),
   }
end)