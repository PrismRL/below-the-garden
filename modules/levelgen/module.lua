local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.levelgen = {}

--- @module "modules.levelgen.room"
prism.levelgen.Room = require(basePath .. ".room")

--- @module "modules.levelgen.decorator"
prism.levelgen.Decorator = require(basePath .. ".decorator")

--- @module "modules.levelgen.generator"
prism.levelgen.Generator = require(basePath .. ".generator")

prism.registerRegistry("decorators", prism.levelgen.Decorator)
prism.registerRegistry("generators", prism.levelgen.Generator)
