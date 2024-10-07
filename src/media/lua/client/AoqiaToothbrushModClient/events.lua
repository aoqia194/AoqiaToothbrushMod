-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

-- My Mod Modules
local context_menu = require("AoqiaToothbrushModClient/ui/context_menu")

local aoqia_math = require("AoqiaZomboidUtilsShared/math")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")
local moodle_manager = require("AoqiaToothbrushModClient/moodle_manager")
local aoqia_table = require("AoqiaZomboidUtilsShared/table")
local types = require("AoqiaToothbrushModShared/types")

-- Vanilla Global Tables/Variables
local Events = Events
local ModData = ModData
local SandboxVars = SandboxVars
-- Vanilla Global Functions
local getGameTime = getGameTime
local getPlayer = getPlayer

-- Dependency Global Tables/Variables
require("MF_ISMoodle")

local moodle_factory = MF

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local events = {}

function events.every_ten_minutes()
    local player = getPlayer()

    --- @type ModDataDummy
    local mdata = player:getModData()[mod_constants.MOD_ID]

    mdata.time_lastbrush_mins = mdata.time_lastbrush_mins + 10
end

function events.every_hours()
    -- Only execute every 6 hours (1/4 of a day)
    local time = getGameTime()
    local hour = time:getHour()
    if hour % 6 ~= 0 then return end

    local player = getPlayer()

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]

    --- @type ModDataDummy
    local mdata = player:getModData()[mod_constants.MOD_ID]

    -- Update moodle if we have not brushed.
    if mdata.today_brush_count < sbvars.BrushTeethMaxValue then
        local moodle = moodle_factory.getMoodle("DirtyTeeth", player:getPlayerNum())
        if moodle == nil then return end

        moodle:setValue(aoqia_math.clamp((mdata.today_brush_count / sbvars.BrushTeethMaxValue) / 2,
            0.0,
            0.5))
    end
end

function events.every_days()
    local player = getPlayer()
    local traits = player:getTraits()
    local stats = player:getStats()
    local bd = player:getBodyDamage()

    --- @type ModDataDummy
    local mdata = player:getModData()[mod_constants.MOD_ID]

    -- Daily mod data update logic
    if mdata.today_brush_count == 0 then
        mdata.days_notbrushed = mdata.days_notbrushed + 1
        mdata.days_brushed_max = 0
        mdata.days_brushed = 0
    else
        mdata.days_brushed = mdata.days_brushed + 1
        mdata.days_notbrushed = 0
    end

    -- Trait stuff is below.
    -- Trait logic is calculated daily because it closely relies on the amount of days not brushed.

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]
    if not sbvars or sbvars.DoTransferItemsOnUse == nil then
        logger:error("No sandbox variables found. " ..
            "This should never happen so please make an issue on github or comment on the mod workshop page.")

        return
    end

    -- Assign trait depending on mod data.
    -- Remove trait if needed too.
    if mdata.days_notbrushed >= sbvars.BadTraitCount and player:HasTrait("FoulBrusher") == false then
        if player:HasTrait("GoldenBrusher") then
            traits:remove("GoldenBrusher")
        end

        traits:add("FoulBrusher")
    elseif mdata.days_brushed_max >= sbvars.GoodTraitCount and player:HasTrait("GoldenBrusher") == false then
        if player:HasTrait("FoulBrusher") then
            traits:remove("FoulBrusher")
        end

        traits:add("GoldenBrusher")
    elseif mdata.days_brushed_max == 0 and player:HasTrait("GoldenBrusher") then
        traits:remove("GoldenBrusher")
    elseif mdata.days_notbrushed == 0 and mdata.days_brushed and player:HasTrait("FoulBrusher") then
        traits:remove("FoulBrusher")
    end

    -- Calc new brush count influenced by the trait
    local newmax = moodle_manager.calc_newmax(sbvars, player)
    mdata.brush_newmax = newmax

    -- Reset moodle
    local moodle = moodle_factory.getMoodle("DirtyTeeth", player:getPlayerNum())
    if moodle then
        moodle:setValue(0.5)
    end

    -- Using trait logic to update mod data
    if mdata.today_brush_count ~= 0 then
        if mdata.today_brush_count >= newmax then
            mdata.days_brushed_max = mdata.days_brushed_max + 1
        end

        mdata.today_brush_count = 0
    end

    -- Is the daily effect active?
    local do_effect = sbvars.DoDailyEffect
    if mdata.days_notbrushed <= 0 or do_effect == false then return end

    local grace_period = sbvars.DailyEffectGracePeriod
    local unhappy_rate = sbvars.DailyEffectExponent
    local stress_rate = sbvars.DailyEffectAlternateExponent
    local unhappy_max = sbvars.DailyEffectMaxValue
    local stress_max = sbvars.DailyEffectAlternateMaxValue

    -- NOTE: For visualisation purposes, see https://www.desmos.com/calculator/awdp9rmxs8
    local unhappy_calc = math.min(
        math.max(
            math.exp(
                unhappy_rate * (mdata.days_notbrushed - grace_period) /
                (types.tonumber(mdata.days_notbrushed >= (newmax / 2)) + 1)),
            0),
        unhappy_max)
    local stress_calc = math.min(
        math.max(
            math.exp(
                stress_rate * (mdata.days_notbrushed - grace_period) /
                (types.tonumber(mdata.days_notbrushed >= (newmax / 2)) + 1)),
            0),
        stress_max)

    -- Set the daily effect using the formula above.
    local type = sbvars.DailyEffectType
    if type == 1 then
        bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappy_calc)
    elseif type == 2 then
        bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappy_calc)

        stats:setStress(stats:getStress() + stress_calc)
    elseif type == 3 then
        stats:setStress(stats:getStress() + stress_calc)
    else
        logger:error("Invalid DailyEffectType enum value")
    end
end

--- @param player_idx integer The player number of the newly-spawned character.
--- @param player IsoPlayer The new player object.
function events.create_player(player_idx, player)
    -- Maybe do modData[AQConstants.MOD_ID] = AQPlayerModDataStructDummy?
    -- local modData = player:getModData()

    --- @type ModDataDummy
    local mdata = player:getModData()[mod_constants.MOD_ID]

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]

    -- Has user created a new character or enabled the mod on an existing character?
    local newchar = (mdata == nil)
    if newchar then
        player:getModData()[mod_constants.MOD_ID]
        = aoqia_table.shallow_copy(mod_constants.ModDataDummy)
        return
    end

    -- Outdated mod data check and merge.
    -- This keeps the old data values and merges them with the new table.
    --- @diagnostic disable: undefined-field
    if mdata._modVersion then
        logger:warn("Mod data version mismatch."
            .. " Expected version ("
            .. mod_constants.MOD_VERSION
            .. ") but got version ("
            .. mdata._modVersion
            .. "); Dropping old mod data table.")

        player:getModData()[mod_constants.MOD_ID]
        = aoqia_table.shallow_copy(mod_constants.ModDataDummy)
        return
    elseif mdata._MOD_VERSION ~= mod_constants.MOD_VERSION then
        logger:warn("Mod data version mismatch."
            .. " Expected version ("
            .. mod_constants.MOD_VERSION
            .. ") but got version("
            .. mdata._MOD_VERSION
            .. "); Merging old mod data with dummy mod data.")

        local dummy = aoqia_table.shallow_copy(mod_constants.ModDataDummy)
        for k, _ in pairs(dummy) do
            if k ~= "modVersion" and mdata[k] ~= nil then
                dummy[k] = mdata[k]
            end
        end

        player:getModData()[mod_constants.MOD_ID] = dummy
        return
    end
    --- @diagnostic enable: undefined-field

    -- This compares with the dummy struct for new data keys not in the table.
    for k, v in pairs(mod_constants.ModDataDummy) do
        if mdata[k] == nil then
            logger:info("Found nil value in mod data. Setting to default...")
            mdata[k] = v
        end
    end

    if mdata.brush_newmax == 0 then
        -- Do some mod data stuff for cases where newmax is 0 (default).
        local newMax = moodle_manager.calc_newmax(sbvars, player)
        mdata.brush_newmax = newMax
    end
end

--- @param new_game boolean
function events.init_global_moddata(new_game)
    -- Remove the accidental addition to the global mod data that I did from 1.0.0 to 1.0.1.
    if ModData.exists(mod_constants.MOD_ID) then
        logger:info("Found old global mod data. Removing...")
        ModData.remove(mod_constants.MOD_ID)
    end
end

function events.on_game_boot()
    moodle_manager.init()
end

function events.register()
    logger:debug("Registering events...")

    Events.EveryTenMinutes.Add(events.every_ten_minutes)
    Events.EveryHours.Add(events.every_hours)
    Events.EveryDays.Add(events.every_days)
    Events.OnFillInventoryObjectContextMenu.Add(context_menu.create_inventory_menu)
    Events.OnFillWorldObjectContextMenu.Add(context_menu.create_world_menu)
    Events.OnCreatePlayer.Add(events.create_player)
    Events.OnInitGlobalModData.Add(events.init_global_moddata)
    Events.OnGameBoot.Add(events.on_game_boot)
end

return events
