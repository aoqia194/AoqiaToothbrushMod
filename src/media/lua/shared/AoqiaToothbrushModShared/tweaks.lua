-- -------------------------------------------------------------------------- --
--                 Registers tweaks using the ItemTweakerAPI.                 --
-- -------------------------------------------------------------------------- --

local getScriptManager = getScriptManager

local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local tweaks = {}

function tweaks.init()
    logger:debug_shared("Applying tweaks...")

    local script_manager = getScriptManager()
    local tweak_table = {
        ["Base.Toothbrush"] = {
            ["DisplayCategory"] = "FirstAid",
            ["Tags"] = "Toothbrush",
            ["Tooltip"] = ("Tooltip_%s_Toothbrush"):format(mod_constants.MOD_ID),
            ["Weight"] = 0.05,
        },
        ["Base.Toothpaste"] = {
            ["DisplayCategory"] = "FirstAid",
            ["Tags"] = "Toothpaste",
            ["Tooltip"] = ("Tooltip_%s_Toothpaste"):format(mod_constants.MOD_ID),
            ["Weight"] = 0.05,
        }
    }

    for tweak_item, data in pairs(tweak_table) do
        for prop, val in pairs(data) do
            local item = script_manager:getItem(tweak_item)
            if item then
                item:DoParam(prop .. " = " .. val)
            end
        end
    end
end

return tweaks
