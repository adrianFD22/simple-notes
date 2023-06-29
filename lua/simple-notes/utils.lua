
local M


-----------------------------------------
--           General purpose
-----------------------------------------

local function parse_string (s, sep)
        if sep == nil then
                sep = "%s"
        end

        local t={}

        for str in string.gmatch(s, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local function table_is_empty(t)
    return next(t) == nil
end

local function array_to_pretty_string(t)

    -- Add tabulation
    local function array_to_pretty_string_tab(current_t, num_tabs)
        local tabs_outside = string.rep("\t", num_tabs)
        local tabs_inside = tabs_outside .. "\t"

        local result = tabs_outside .. "{\n"

        for _,v in ipairs(current_t) do
            local current_row = ""

            -- Ignore key

            -- Add value
            if type(v) == "table" then
                current_row = current_row .. array_to_pretty_string_tab(v, num_tabs+1)
            elseif  type(v) == "string" then
                current_row = tabs_inside .. current_row .. [["]] .. v .. [["]]
            elseif type(v) == 'number' then
                current_row = tabs_inside .. current_row .. v
            end

            current_row = current_row .. ",\n"

            result = result .. current_row
        end

        result = result .. tabs_outside .. "}"

        return result
    end

    return array_to_pretty_string_tab(t, 0)
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function read_all(filename)
    local f = io.open(filename, "r")

    if f == nil then return nil end

    local content = f:read("*all")
    f:close()

    return content
end

local function write_all(filename, content)
    local f = io.open(filename, "w")

    if f == nil then return nil end

    f:write(content)
    f:close()

    return true
end

-- https://stackoverflow.com/questions/28550413/compare-dates-in-lua
local function days_from_civil(y, m, d)
    if m <= 2 then
      y = y - 1
      m = m + 9
    else
      m = m - 3
    end
    local era = math.floor(y/400)
    local yoe = y - era * 400                                           -- [0, 399]
    local doy = math.modf((153*m + 2)/5) + d-1                          -- [0, 365]
    local doe = yoe * 365 + math.modf(yoe/4) - math.modf(yoe/100) + doy -- [0, 146096]
    return era * 146097 + doe - 719468
end


-----------------------------------------
--            Main table
-----------------------------------------

M = {
    parse_string = parse_string,
    table_is_empty = table_is_empty,
    array_to_pretty_string = array_to_pretty_string,
    file_exists = file_exists,
    read_all = read_all,
    write_all = write_all,
    days_from_civil = days_from_civil
}

return M
