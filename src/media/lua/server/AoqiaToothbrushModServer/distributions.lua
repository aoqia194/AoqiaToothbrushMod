-- -------------------------------------------------------------------------- --
--             Handles the procedural distributions (loot tables)             --
-- -------------------------------------------------------------------------- --

local table = table

require("Items/ProceduralDistributions")
local ProceduralDistributions = ProceduralDistributions

local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local distributions = {}

distributions.toothbrush = {}
distributions.toothbrush.containers = {
    "BathroomCabinet",
    "BathroomCounter",
    "BathroomShelf",
    "PharmacyCosmetics",
    "PrisonCellRandom",
}

distributions.toothbrush.items = {
    { name = "ToothbrushRed",             chance = 10 },
    { name = "ToothbrushOrange",          chance = 10 },
    { name = "ToothbrushYellow",          chance = 10 },
    { name = "ToothbrushGreen",           chance = 10 },
    { name = "ToothbrushLightBlue",       chance = 10 },
    { name = "ToothbrushDarkBlue",        chance = 10 },
    { name = "ToothbrushPurple",          chance = 10 },
    { name = "ToothbrushMagenta",         chance = 10 },
    { name = "ToothbrushPink",            chance = 10 },
    { name = "ToothbrushRosePink",        chance = 10 },
    { name = "ToothbrushTollgateGreen",   chance = 10 },
    { name = "ToothbrushTollgateBlue",    chance = 10 },
    { name = "ToothbrushTollgatePurple",  chance = 10 },
    { name = "ToothbrushTollgateMagenta", chance = 10 },
}

function distributions.init()
    logger:debug_server("Adding custom items to loot table...")

    local conts = distributions.toothbrush.containers
    local items = distributions.toothbrush.items
    for i = 1, #conts do
        local cont = conts[i]

        for j = 1, #items do
            local item = items[j]
            local list = ProceduralDistributions.list[cont].items

            list[#list + 1] = item.name
            --- @diagnostic disable-next-line: assign-type-mismatch
            list[#list + 1] = item.chance
        end
    end
end

return distributions
