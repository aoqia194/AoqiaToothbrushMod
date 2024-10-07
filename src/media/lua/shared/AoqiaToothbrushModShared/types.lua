-- -------------------------------------------------------------------------- --
--            Everything to do with types such as type conversions            --
-- -------------------------------------------------------------------------- --

-- ------------------------------ Module Start ------------------------------ --

local types = {}

---@param value number
--- This function converts numbers/strings to booleans.
function types.toboolean(value)
    if type(value) == "number" then
        return value == 1 and true or value == 0 and false
    elseif type(value) == "string" then
        return value == "true" and true or value == "false" and false
    end
end

---@param value boolean
--- This function converts booleans to numbers.
function types.tonumber(value)
    return value == true and 1 or value == false and 0
end

return types
