-- -------------------------------------------------------------------------- --
--                   Stores constants to be used everywhere.                  --
-- -------------------------------------------------------------------------- --

local logger = require("AoqiaZomboidUtilsShared/logger")

-- ------------------------------ Module Start ------------------------------ --

local mod_constants = {}

mod_constants.MOD_ID = "AoqiaToothbrushMod"
mod_constants.MOD_VERSION = "2.0.0"

mod_constants.LOGGER = logger:new(mod_constants.MOD_ID)

--- @class (exact) ModDataDummy
--- @field public _MOD_VERSION string Tracks what version of the mod belongs to the mod data.
--- @field brush_newmax integer Tracks the sandbox option "Brush Teeth Max Value" based on if the player has one of the traits.
--- @field days_brushed integer Tracks the number of days CONSECUTIVELY the player has brushed their teeth at least once.
--- @field days_brushed_max integer Tracks how many times player CONSECUTIVELY brushed teeth >= sandbox Max Value for n days.
--- @field days_notbrushed integer Tracks how many CONSECUTIVE times player didn't brush teeth total.
--- @field time_lastbrush_mins integer Tracks how much time (in 10 minute intervals) since the last brush.
--- @field today_brush_count integer Tracks how many times player brushed teeth today.
--- @field total_brush_count integer Tracks how many times player brushed teeth total.
mod_constants.ModDataDummy = {
    _MOD_VERSION = mod_constants.MOD_VERSION,
    brush_newmax = 0,
    days_brushed = 0,
    days_brushed_max = 0,
    days_notbrushed = 0,
    time_lastbrush_mins = 0,
    today_brush_count = 0,
    total_brush_count = 0,
}

--- @class (exact) SandboxVarsDummy
--- @field DoTransferItemsOnUse boolean
--- @field DoDailyEffect boolean
--- @field DailyEffectType integer
--- @field DailyEffectExponent number
--- @field DailyEffectAlternateExponent number
--- @field DailyEffectMaxValue integer
--- @field DailyEffectAlternateMaxValue integer
--- @field DailyEffectGracePeriod integer
--- @field DoBrushTeethEffect boolean
--- @field BrushTeethEffectType integer
--- @field BrushTeethEffectAmount integer
--- @field BrushTeethEffectAlternateAmount integer
--- @field BrushTeethTime integer
--- @field BrushTeethMaxValue integer
--- @field BrushTeethRequiredWater integer
--- @field BrushTeethRequiredToothpaste integer
--- @field GoodTraitCount number
--- @field BadTraitCount number
mod_constants.SandboxVarsDummy = {
    DoTransferItemsOnUse = true,
    -- Daily Effect
    DoDailyEffect = true,
    DailyEffectType = 1,
    DailyEffectExponent = 0.12,
    DailyEffectAlternateExponent = 0.12,
    DailyEffectMaxValue = 25,
    DailyEffectAlternateMaxValue = 25,
    DailyEffectGracePeriod = 2,
    -- Brush Teeth Effect
    DoBrushTeethEffect = true,
    BrushTeethEffectType = 1,
    BrushTeethEffectAmount = 10,
    BrushTeethEffectAlternateAmount = 10,
    -- Brush Teeth Vars
    BrushTeethTime = 600,
    BrushTeethMaxValue = 2,
    BrushTeethRequiredWater = 1,
    BrushTeethRequiredToothpaste = 1,
    -- Trait Vars
    GoodTraitCount = 10,
    BadTraitCount = 7,
}

return mod_constants
