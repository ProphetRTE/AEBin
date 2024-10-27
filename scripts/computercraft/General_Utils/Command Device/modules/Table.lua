--- This module offers utilities for working with tables
return {

    inTable = function(value, tbl)
        if tbl == nil then return false end

        for key, val in pairs(tbl) do
            if val == value then
                return true
            end
        end

        return false
    end,

    has = function(val, tbl)
        if tbl == nil then return false end

        for _, v in pairs(tbl) do
            if v == val then
                return true
            end
        end

        return false
    end,

    hasKey = function(key, tbl)
        if tbl == nil then return false end

        for k, v in pairs(tbl) do
            if k == key then
                return true
            end
        end

        return false
    end,

    print = function(tbl)
        for k, v in pairs(tbl) do
            print(k, v)
        end
    end,

    --- Remove key/value pairs by key
    -- @param id    ID to remove
    -- @param keys  The table to remove
    removeByKey = function(id, keys)
        local newKeys = {}

        for k, v in pairs(keys) do
            if v ~= id then
                newKeys[k] = v
            end
        end

        return newKeys
    end,

    --- Determine if a table contains specific keys
    -- @param tbl       The table to check for keys
    -- @param keys      A table of keys to look for
    hasKeys = function(keys, tbl)
        if tbl == nil then return false end

        for _, v in pairs(keys) do
            if tbl[v] == nil then return false end
        end

        return true
    end,

    size = function(tbl)
        local count = 0;

        if (tbl ~= nil) then
            for key, val in pairs(tbl) do
                count = count + 1;
            end
        end

        return count;
    end,

    --- Return the position of an element in the table
    position = function(val, tbl)
        for pos, v in ipairs(tbl) do
            if v == val then 
                return pos 
            end
        end
    end
}