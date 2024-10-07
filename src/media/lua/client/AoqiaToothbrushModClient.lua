-- -------------------------------------------------------------------------- --
--                      The main entry point for the mod.                     --
-- -------------------------------------------------------------------------- --

local getActivatedMods = getActivatedMods

local events = require("AoqiaToothbrushModClient/events")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------- Entrypoint ------------------------------- --

local activated_mods = getActivatedMods()
if activated_mods:contains("MoodleFramework") == false then
    logger:error("Failed to find MoodleFramework.")
    return
end

events.register()

logger:debug("Lua init done!")
