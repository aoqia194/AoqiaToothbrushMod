-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

-- Dependancies.
require("MF_ISMoodle")
-- My modules.
local aoqia_math = require("AoqiaZomboidUtilsShared/math")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")
local moodle_manager = require("AoqiaToothbrushModClient/moodle_manager")

-- TIS globals cache.
local ISBaseTimedAction = ISBaseTimedAction
local ISTakeWaterAction = ISTakeWaterAction
local Metabolics = Metabolics
local SandboxVars = SandboxVars
-- Dependancy globals cache.
local MoodleFactory = MF

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

--- @class (exact) BrushTeethAction: ISBaseTimedAction
--- @field __index self
--- @field private sound integer?
--- @field character IsoPlayer
--- @field water_obj IsoObject | InventoryItem
--- @field toothbrush InventoryItem
--- @field toothpaste InventoryItem?
--- @field stop_on_walk boolean
local brush_teeth = ISBaseTimedAction:derive("brush_teeth")

function brush_teeth:isValid()
    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]
    if self.toothpaste == nil and sbvars.BrushTeethRequiredToothpaste == 0 then return end

    local water_obj = self.water_obj

    if instanceof(water_obj, "IsoObject") then
        --- @cast water_obj IsoObject
        return water_obj:getObjectIndex() ~= -1
    else
        --- @cast water_obj InventoryItem
        return water_obj:getCurrentUses() > 0
    end
end

function brush_teeth:update()
    if instanceof(self.water_obj, "IsoObject") == false then
        return
    end

    self.character:faceThisObjectAlt(self.water_obj)
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function brush_teeth:waitToStart()
    if instanceof(self.water_obj, "IsoObject") == false then
        return false
    end

    -- Alt version makes character walk there I believe.
    self.character:faceThisObjectAlt(self.water_obj)
    return self.character:shouldBeTurning()
end

function brush_teeth:start()
    self:setActionAnim("BrushTeeth")
    self:setOverrideHandModels("Base.Toothbrush", nil)

    self.sound = self.character:playSound("BrushTeeth") --[[@as integer]]
end

function brush_teeth:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function brush_teeth:stop()
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function brush_teeth:perform()
    self:stopSound()

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]

    --- @type ModDataDummy
    local mdata = self.character:getModData()[mod_constants.MOD_ID]

    local water_obj = self.water_obj
    if instanceof(self.water_obj, "IsoObject") then
        --- @cast water_obj IsoObject
        ISTakeWaterAction.SendTakeWaterCommand(self.character, water_obj, 1)
    else
        --- @cast water_obj InventoryItem
        water_obj:Use()
    end

    -- Calculate the toothpaste units and take away uses from the toothpaste if needed.

    local units = sbvars.BrushTeethRequiredToothpaste
    if self.toothpaste and units > 0 then
        local new_uses = self.toothpaste:getUses() - units

        -- Take unit(s) from the toothpaste item.
        self.toothpaste:setUses(new_uses)
    end

    -- Damage toothbrush

    -- self.toothbrush:setCondition(self.toothbrush:getCondition() - 1)

    -- Brush teeth mod data update

    mdata.today_brush_count = mdata.today_brush_count + 1
    mdata.total_brush_count = mdata.total_brush_count + 1
    mdata.days_notbrushed = 0
    mdata.time_lastbrush_mins = 0

    local new_max = moodle_manager.calc_newmax(sbvars, self.character)
    mdata.brush_newmax = new_max

    -- Update moodle

    local moodle = MoodleFactory.getMoodle("DirtyTeeth", self.character:getPlayerNum())
    if moodle == nil then
        logger:debug("Found nil moodle when trying to get DirtyTeeth moodle.")
        return
    end
    
    moodle:setValue(aoqia_math.clamp(mdata.today_brush_count, 0, new_max) / new_max)

    -- Brush Teeth Effect

    if sbvars.DoBrushTeethEffect and mdata.today_brush_count <= new_max then
        local effectType = sbvars.BrushTeethEffectType
        local unhappyAmount = sbvars.BrushTeethEffectAmount
        local stressAmount = sbvars.BrushTeethEffectAlternateAmount

        --- @type Stats
        local stats = self.character:getStats()
        --- @type BodyDamage
        local bd = self.character:getBodyDamage()
        local unhappy = bd:getUnhappynessLevel()
        local stress = stats:getStress()

        if effectType == 1 then
            bd:setUnhappynessLevel(unhappy - unhappyAmount)
        elseif effectType == 2 then
            bd:setUnhappynessLevel(unhappy - unhappyAmount)

            stats:setStress(stress - stressAmount)
        elseif effectType == 3 then
            stats:setStress(stress - stressAmount)
        else
            logger:error("Invalid BrushTeethEffectType enum value")
        end
    end

    ISBaseTimedAction.perform(self)
end

--- @param character IsoPlayer
--- @param water_obj IsoObject | InventoryItem
--- @param toothbrush InventoryItem
--- @param toothpaste? InventoryItem
--- @param time float
--- @param stop_on_walk boolean
--- @return BrushTeethAction
function brush_teeth:new(character, water_obj, toothbrush, toothpaste, time, stop_on_walk)
    --- @type BrushTeethAction
    --- @diagnostic disable-next-line: missing-fields
    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.character = character
    o.water_obj = water_obj
    o.toothbrush = toothbrush
    o.toothpaste = toothpaste

    o.stopOnWalk = stop_on_walk
    o.stopOnRun = true
    o.forceProgressBar = true
    o.maxTime = character:isTimedActionInstant() and 1 or time

    return o
end

return brush_teeth
