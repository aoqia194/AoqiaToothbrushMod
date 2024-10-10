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

--- @type Callback_OnInitGlobalModData
function events.init_global_moddata()
    trait_manager.init()
    tweaks.init()
end

function events.register()
    logger:debug_shared("Registering events...")

    Events.OnInitGlobalModData.Add(events.init_global_moddata)
end

return events
