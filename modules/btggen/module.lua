local path = ...
local basePath = path:match("^(.*)%.") or ""

--- @module "modules.btggen.util"
prism.levelgen.util = require(basePath .. ".util")

--- @module "modules.btggen.roommanager"
prism.levelgen.RoomManager = require(basePath .. ".roommanager")

--- @module "modules.btggen.roomgenerator"
prism.levelgen.RoomGenerator = require(basePath .. ".roomgenerator")

print "REGISTERING ROOM GENS"
prism.registerRegistry("roomgenerators", prism.levelgen.RoomGenerator)
