local Generator = prism.Object:extend "Generator"

function Generator.generate(seed, w, h, depth)
   error("This must be overriden!")
end

return Generator
