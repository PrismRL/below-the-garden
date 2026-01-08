--- A relation representing that an entity sees another entity.
--- This is the inverse of the `SeenBy` relation
--- @class EquippedRelation : Relation
--- @overload fun(): EquippedRelation
local EquippedRelation = prism.Relation:extend "EquippedRelation"

--- Generates the inverse relation of this one.
--- @return Relation seenby inverse `SeenBy` relation.
function EquippedRelation:generateInverse()
   return prism.relations.EquippedBy
end

return EquippedRelation
