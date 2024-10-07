-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

-- Vanilla Global Tables/Variables
local Events = Events

-- My Mod Modules
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")
local trait_manager = require("AoqiaToothbrushModShared/trait_manager")
local tweaks = require("AoqiaToothbrushModShared/tweaks")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local events = {}

function events.on_game_boot()
    trait_manager.init()
    tweaks.init()
end

function events.register()
    logger:debug_shared("Registering events...")

    Events.OnGameBoot.Add(events.on_game_boot)
end

return events
