-- -------------------------------------------------------------------------- --
--                    Defines and adds traits to the game.                    --
-- -------------------------------------------------------------------------- --

local trait_factory = TraitFactory

local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local trait_manager = {}

function trait_manager.init()
    logger:debug("Creating traits...")

    trait_factory.addTrait("GoldenBrusher",
        getText(string.format("UI_%s_GoldenBrusherTrait", mod_constants.MOD_ID)),
        2,
        getText(string.format("UI_%s_GoldenBrusherTraitDesc", mod_constants.MOD_ID)),
        false)

    trait_factory.addTrait("FoulBrusher",
        getText(string.format("UI_%s_FoulBrusherTrait", mod_constants.MOD_ID)),
        2,
        getText(string.format("UI_%s_FoulBrusherTraitDesc", mod_constants.MOD_ID)),
        false)

    trait_factory.setMutualExclusive("GoldenBrusher", "FoulBrusher")
end

return trait_manager
