--- @class BlockChanceModifier : ConditionModifier
--- @field blockChance number
local BlockChanceModifier = prism.condition.ConditionModifier:extend "BlockChanceModifier"

function BlockChanceModifier:__new(blockChance)
   self.blockChance = blockChance
end

return BlockChanceModifier
