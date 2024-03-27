-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

local ModData = ModData
local ISTakeWaterAction = ISTakeWaterAction

local sendVisual = sendVisual

require("TimedActions/ISBaseTimedAction")
local ISBaseTimedAction = ISBaseTimedAction

local AQConstants = require("AQConstants")
local AQUtils = require("AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQBrushTeeth = ISBaseTimedAction:derive("AQBrushTeeth")

function AQBrushTeeth:isValid()
    return self.sink:getObjectIndex() ~= -1
end

function AQBrushTeeth:update()
    self.character:faceThisObjectAlt(self.sink)
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function AQBrushTeeth:waitToStart()
    self.character:faceThisObject(self.sink)
    return self.character:shouldBeTurning()
end

function AQBrushTeeth:start()
    --NOTE: Should eventually use custom animation. I am not sure how I would make the sound though.
    self:setActionAnim("RipSheets")
    self:setOverrideHandModels(self.toothbrush:getStaticModel(), nil)
    self.sound = self.character:playSound("WashYourself")
end

function AQBrushTeeth:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function AQBrushTeeth:stop()
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function AQBrushTeeth:perform()
    self:stopSound()

    -- self.toothpastes[0]:Use()
    ISTakeWaterAction.SendTakeWaterCommand(self.character, self.sink, 1)

    -- Update player mod data

    ---@type AQModDataStruct
    local data = ModData.get(AQConstants.MOD_ID)
    data.daysWithoutBrushingTeeth = 0
    data.timesBrushedTeethToday = data.timesBrushedTeethToday + 1

    if data.timesBrushedTeethToday <= 2 then
        -- Decrease the unhappy
        local bodyDamage = self.character:getBodyDamage()
        bodyDamage:setUnhappynessLevel(AQUtils.clamp(bodyDamage:getUnhappynessLevel() - 10, 0, 100))
    end

    ISBaseTimedAction.perform(self)
end

function AQBrushTeeth.getRequiredToothpaste()
    -- NOTE: Maybe have the toothpaste amount be dynamic based on how dirty your teeth are?
    return 1
end

---@param toothpastes table<number, ComboItem>
function AQBrushTeeth.getToothpasteRemaining(toothpastes)
    local total = 0

    for _, toothpaste in ipairs(toothpastes) do
        total = total + toothpaste:getUses()
    end

    return total
end

function AQBrushTeeth.getRequiredWater()
    -- NOTE: See getRequiredToothpaste()
    return 1
end

---@param character IsoPlayer
---@param sink IsoObject
---@param toothbrush ComboItem
---@param time number
function AQBrushTeeth:new(character, sink, toothbrush, toothpastes, time)
    local o = {}

    setmetatable(o, self)
    self.__index       = self
    o.character        = character
    o.sink             = sink
    o.toothbrush       = toothbrush
    o.toothpastes      = toothpastes
    o.stopOnWalk       = true
    o.stopOnRun        = true
    o.forceProgressBar = true
    o.maxTime          = time

    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end

return AQBrushTeeth
