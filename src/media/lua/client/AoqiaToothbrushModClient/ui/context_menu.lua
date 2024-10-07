-- -------------------------------------------------------------------------- --
--                 Handles the context menu for world objects.                --
-- -------------------------------------------------------------------------- --

-- Global requires.
require("luautils")
-- My requires.
local brush_teeth = require("AoqiaToothbrushModClient/actions/brush_teeth")
local mod_constants = require("AoqiaToothbrushModShared/mod_constants")

-- The stdlib caching.
local string = string
-- TIS module caching.
local ISTimedActionQueue = ISTimedActionQueue
local ISInventoryTransferAction = ISInventoryTransferAction
local ISWorldObjectContextMenu = ISWorldObjectContextMenu
local luautils = luautils
local SandboxVars = SandboxVars
-- TIS function caching.
local instanceof = instanceof
local getSpecificPlayer = getSpecificPlayer

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local context_menu = {}

--- @param water_obj IsoObject | InventoryItem
--- @param player_idx integer
--- @param toothbrush InventoryItem
--- @param toothpaste? InventoryItem
--- @param stop_on_walk boolean
function context_menu.on_brush_teeth(water_obj, player_idx, toothbrush, toothpaste, stop_on_walk)
    local player = getSpecificPlayer(player_idx)
    local player_inv = player:getInventory()

    if instanceof(water_obj, "IsoObject") then
        --- @cast water_obj IsoObject

        local sq = water_obj:getSquare()
        if not sq or not luautils.walkAdj(player, sq, true) then return end
    end

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]

    local time = sbvars.BrushTeethTime
    if toothpaste == nil
    or toothpaste:getCurrentUses() < sbvars.BrushTeethRequiredToothpaste then
        time = time * 2
    end

    -- Original item containers for restoring later
    local oBrushCon = toothbrush:getContainer()
    local oPasteCon = toothpaste and toothpaste:getContainer() or nil

    -- Add items to transfer queue
    if sbvars.DoTransferItemsOnUse then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, toothbrush, oBrushCon,
            player_inv))

        if toothpaste ~= nil and oPasteCon ~= nil then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, toothpaste, oPasteCon,
                player_inv))
        end
    end

    ISTimedActionQueue.add(brush_teeth:new(
        player,
        water_obj,
        toothbrush,
        toothpaste,
        time,
        stop_on_walk))

    -- Add items back to transfer queue to transfer back
    if sbvars.DoTransferItemsOnUse then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, toothbrush, player_inv,
            oBrushCon))

        if toothpaste ~= nil and oPasteCon ~= nil then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, toothpaste, player_inv,
                oPasteCon))
        end
    end
end

--- @param water_obj IsoObject | InventoryItem
--- @param player_idx integer
--- @param context ISContextMenu
function context_menu.do_context_menu(water_obj, player_idx, context)
    local player = getSpecificPlayer(player_idx)
    local inventory = player:getInventory()

    --- @type ModDataDummy
    local mdata = player:getModData()[mod_constants.MOD_ID]

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line assign-type-mismatch
    local sbvars = SandboxVars[mod_constants.MOD_ID]

    local water_uses = nil
    local stop_on_walk = true
    if instanceof(water_obj, "IsoObject") then
        --- @cast water_obj IsoObject

        -- NOTE: Could possibly bug something out??
        if water_obj:getSquare():getBuilding() ~= player:getBuilding() then return end

        if instanceof(water_obj, "IsoClothingDryer") then return end
        if instanceof(water_obj, "IsoClothingWasher") then return end
        if instanceof(water_obj, "IsoCombinationWasherDryer") then return end

        --- @cast water_obj IsoObject
        water_uses = water_obj:getWaterAmount()
    else
        --- @cast water_obj InventoryItem

        water_uses = water_obj:getCurrentUses()
        stop_on_walk = false
    end

    local toothbrush = inventory:getFirstTagRecurse("Toothbrush")
    local toothpaste = inventory:getFirstTagRecurse("Toothpaste")
    if toothbrush == nil then
        return
    end

    -- Context menu shtuff

    local option = context:addOption(
        getText(string.format("ContextMenu_%s_BrushTeeth", mod_constants.MOD_ID)),
        water_obj, context_menu.on_brush_teeth, player_idx, toothbrush, toothpaste, stop_on_walk)
    local tooltip = ISWorldObjectContextMenu.addToolTip()
    local text = ""

    local water_needed = sbvars.BrushTeethRequiredWater
    local toothpaste_needed = sbvars.BrushTeethRequiredToothpaste

    -- Depressed check.
    local unhappiness = player:getBodyDamage():getUnhappynessLevel()
    if unhappiness > 80 then
        text = text
            .. " <RGB:1,0,0> "
            .. getText(string.format("IGUI_%s_TooDepressed", mod_constants.MOD_ID))
        option.notAvailable = true
    end

    -- Time check.
    local min_time = (1440 / mdata.brush_newmax)
    local too_recent = mdata.time_lastbrush_mins < min_time and mdata.today_brush_count ~= 0
    if too_recent then
        text = text
            .. (option.notAvailable and " <LINE> " or "")
            .. " <RGB:1,0,0> "
            .. getText(string.format("IGUI_%s_TooRecent", mod_constants.MOD_ID))
        option.notAvailable = true
    end

    -- If the player has no toothpaste and it is required.
    -- If player has toothpaste but it has no contents and is required.
    -- Else the player has toothpaste and it has contents or is not required.
    if toothpaste == nil and toothpaste_needed > 0 then
        text = text
            .. (option.notAvailable and " <LINE> " or "")
            .. " <RGB:1,0,0> "
            .. getText(("IGUI_%s_NoToothpaste"):format(mod_constants.MOD_ID))
            .. " [0/"
            .. toothpaste_needed
            .. "]"

        option.notAvailable = true
    elseif toothpaste and toothpaste_needed > 0 and toothpaste:getUses() <= 0 then
        text = text
            .. (option.notAvailable and " <LINE> " or "")
            .. " <RGB:1,0,0> "
            .. getText(("IGUI_%s_NotEnoughToothpaste"):format(mod_constants.MOD_ID))
            .. ": ["
            .. toothpaste:getCurrentUses()
            .. "/"
            .. toothpaste_needed
            .. "]"

        option.notAvailable = true
    elseif toothpaste then
        text = text
            .. (option.notAvailable and " <LINE> " or "")
            .. getText(("IGUI_%s_Toothpaste"):format(mod_constants.MOD_ID))
            .. ": "
            .. toothpaste:getCurrentUses()
            .. "/"
            .. toothpaste_needed
    end

    -- Display water object name and amount.
    text = text
        .. " <LINE> "
        .. getText("ContextMenu_WaterName")
        .. ": "
        .. water_uses
        .. "/"
        .. water_needed

    local is_tainted = water_obj:isTaintedWater()
    if is_tainted then
        text = text
            .. " <LINE> "
            .. getText("ContextMenu_TaintedWater")
        option.notAvailable = true
    end

    -- Water amount check.
    if water_uses <= 0 then
        option.notAvailable = true
    end
    tooltip.description = text
    option.toolTip = tooltip
end

--- @param player_idx integer
--- @param context ISContextMenu
--- @param items InventoryItem[] | ContextMenuItemStack[]
function context_menu.create_inventory_menu(player_idx, context, items)
    local player = getSpecificPlayer(player_idx)
    local inventory = player:getInventory()

    local toothbrush = inventory:getFirstTagRecurse("Toothbrush")
    if toothbrush == nil then
        return
    end

    --- @type SandboxVarsDummy
    --- @diagnostic disable-next-line: assign-type-mismatch
    local sandbox_vars = SandboxVars[mod_constants.MOD_ID]

    --- @type InventoryItem
    local water_item = nil
    for i = 1, #items do
        local item = items[i]

        if instanceof(item, "InventoryItem") then
            --- @cast item InventoryItem

            if  item:isWaterSource()
            and item:isTaintedWater() == false
            and item:getCurrentUses() >= sandbox_vars.BrushTeethRequiredWater then
                water_item = item
                break
            end
        else
            --- @cast item ContextMenuItemStack

            for j = 1, #item.items do
                local real_item = item.items[j]

                if  real_item:isWaterSource()
                and real_item:isTaintedWater() == false
                and real_item:getCurrentUses() >= sandbox_vars.BrushTeethRequiredWater then
                    water_item = real_item
                    break
                end
            end
        end
    end

    if water_item == nil then return end
    context_menu.do_context_menu(water_item, player_idx, context)
end

--- @param player_idx integer
--- @param context ISContextMenu
--- @param worldobjects IsoObject[]
--- @param test boolean
--- @return boolean?
function context_menu.create_world_menu(player_idx, context, worldobjects, test)
    local player = getSpecificPlayer(player_idx)
    local inventory = player:getInventory()

    local toothbrush = inventory:getFirstTagRecurse("Toothbrush")
    if toothbrush == nil then
        return
    end

    -- If no world objects, don't create menu.
    if worldobjects == nil or #worldobjects == 0 then
        logger:debug("No world objects.")
        return
    end

    --- @type IsoObject
    local water_obj = nil

    -- Loop through square's objects because worldobjects arg is weird.
    local sq = worldobjects[1]:getSquare()
    local objs = sq:getObjects()
    for i = 1, objs:size() do
        local obj = objs:get(i - 1) --[[@as IsoObject]]
        if obj:hasWater() then
            water_obj = obj
            break
        end
    end

    if water_obj == nil then return end
    if test then return true end

    context_menu.do_context_menu(water_obj, player_idx, context)
end

return context_menu
