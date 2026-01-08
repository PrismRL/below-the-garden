--- A relation representing that an entity sees another entity.
--- This is the inverse of the `SeenBy` relation
--- @class EquippedByRelation : Relation
--- @overload fun(): EquippedByRelation
local EquippedByRelation = prism.Relation:extend "EquippedByRelation"

--- Generates the inverse relation of this one.
--- @return Relation seenby inverse `SeenBy` relation.
function EquippedByRelation:generateInverse()
   return prism.relations.EquippedBy
end

return EquippedByRelation
