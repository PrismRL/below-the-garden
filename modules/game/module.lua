local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.Collision.assignNextAvailableMovetype("walk")
prism.Collision.assignNextAvailableMovetype("fly")
prism.Collision.assignNextAvailableMovetype("swim")

prism.register(prism.Component:extend "Camp")
prism.register(prism.Component:extend "Prism")
prism.register(prism.Component:extend "Stair")
prism.register(prism.Component:extend "Tonguer")
prism.register(prism.Component:extend "Void")
prism.register(prism.Component:extend "Weapon")
prism.register(prism.Component:extend "Torch")

--- @module "modules.game.game"
prism.Game = require(basePath .. ".game")