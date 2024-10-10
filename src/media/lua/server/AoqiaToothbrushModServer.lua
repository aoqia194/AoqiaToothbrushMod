-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local constants = require("AoqiaZomboidUtilsShared/constants")
local events = require("AoqiaToothbrushModServer/events")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------- Entrypoint ------------------------------- --

if constants.IS_CLIENT and constants.IS_SINGLEPLAYER == false then
    logger:debug_server("Prevented server entrypoint from being executed.")
    return
end

events.register()

logger:debug_server("Lua init done!")
