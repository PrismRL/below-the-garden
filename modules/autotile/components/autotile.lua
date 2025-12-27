--- @class AutoTileRule
--- @field drawable? string
--- @field pattern? integer[]
--- @field mirrorX? boolean
--- @field mirrorY? boolean
--- @field variations? table<number, string>
--- @field totalWeight number

--- @class AutoTile : Component
--- @field drawables table<string, Drawable>
--- @field default Drawable
--- @field rules AutoTileRule[]
--- @field id integer
--- @overload fun(options: {id: integer, drawables: table<string, Drawable>, default: string, rules: AutoTileRule[]}): AutoTile
local AutoTile = prism.Component:extend("AutoTile")

function AutoTile:__new(options)
   self.id = options.id
   self.default = options.default
   self.rules = options.rules
   self.drawables = options.drawables

   for _, rule in ipairs(self.rules) do
      local sum = 0
      for _, weight in pairs(rule.variations or {}) do
         sum = sum + weight
      end
      rule.totalWeight = sum
   end
end

return AutoTile
