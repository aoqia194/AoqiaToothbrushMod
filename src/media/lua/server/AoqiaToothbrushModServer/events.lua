-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

-- Vanilla Global Tables/Variables
local Events = Events

-- My Mod Modules
local distributions = require("AoqiaToothbrushModServer/distributions")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local events = {}

function events.on_game_boot()
    distributions.init()
end

function events.register()
    logger:debug_server("Registering events...")

    Events.OnGameBoot.Add(events.on_game_boot)
end

return events
