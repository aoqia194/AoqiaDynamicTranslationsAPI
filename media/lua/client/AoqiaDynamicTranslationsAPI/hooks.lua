-- -------------------------------------------------------------------------- --
--                             Hook stuff for fun                             --
-- -------------------------------------------------------------------------- --

local mod_constants = require("AoqiaDynamicTranslationsAPI/mod_constants")
local translations  = require("AoqiaDynamicTranslationsAPI/translations")

local logger        = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local hooks         = {}

hooks.o_get_text    = nil

--- @return string
--- @overload fun(text: string): string
--- @overload fun(text: string, arg1: any): string
--- @overload fun(text: string, arg1: any, arg2: any): string
--- @overload fun(text: string, arg1: any, arg2: any, arg3: any): string
--- @overload fun(text: string, arg1: any, arg2: any, arg3: any, arg4: any): string
function hooks.get_text(...)
    -- TODO: Optimise this function LIKE BRICKS. It will run *every frame* in most cases for always-shown text.
    -- This means if-checking func calls for less overhead, min-maxing basically.

    -- logger:debug("Intercepted getText call with text (%s)!", tostring(select(1, ...)))

    local key = tostring(select(1, ...))
    local value = hooks.o_get_text(...)

    -- We can assume that the translation failed to get if the key is the translation.
    if value == key then
        return "nil"
    end

    -- If the translation doesn't exist in the cache, create it and return the value from the original getText
    if not translations.exists(key) then
        logger:debug("Creating translation (%s) with value (%s)", key, value)

        translations.create(key, value)
        return value
    end

    -- Otherwise return the translation in the cache.
    local translation = translations.find(key)
    if translation == nil then
        logger:warn("Translation (%s) was nil.", key)
    end

    return translation or "nil"
end

return hooks
