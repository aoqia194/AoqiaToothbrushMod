-- -------------------------------------------------------------------------- --
--                    Defines and adds moodles to the game.                   --
-- -------------------------------------------------------------------------- --

-- Dependency requires.
require("MF_ISMoodle")
-- My mod requires.
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

-- Dependencies globals cache.
local moodle_factory = MF

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local moodle_manager = {}

---@param sbvars SandboxVarsDummy
---@param player IsoPlayer
---@return integer new_max
--- Calculates the new BrushTeethMaxValue based on the player's current traits.
function moodle_manager.calc_newmax(sbvars, player)
    local max = sbvars.BrushTeethMaxValue

    if player:HasTrait("GoldenBrusher") then
        max = math.floor(max / 2)
    elseif player:HasTrait("FoulBrusher") then
        max = max * 2
    end

    return max
end

function moodle_manager.init()
    logger:debug("Creating moodles...")

    moodle_factory.createMoodle("DirtyTeeth")
end

return moodle_manager
