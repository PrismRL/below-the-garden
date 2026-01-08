local Game = prism.Object:extend "Game"

function Game:__new(seed)
   self.player = prism.actors.Player()
   self.depth = 1
   self.rng = prism.RNG(seed)
end

function Game:generate(depth)
   local w = 30 + (math.min(depth, 3) - 1) * 10

   return prism.generators.FirstThird.generate({
      seed = self.rng:random(),
      w = w,
      h = 30,
      depth = depth,
   }, self.player)
end

return Game