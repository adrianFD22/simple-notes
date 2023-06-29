
local utils = require('simple-notes.utils')

local M


-----------------------------------------
--            Punctual events
-----------------------------------------

local function get_punctual_events(date, events_path)

    -- Read events
    local content = utils.read_all(events_path)
    if content == nil then return nil end
    local calendar = loadstring(content)()

    -- Iterate events
    local today_events = {}
    local passed_events = {}
    local updated_events = {}

    for _,event in ipairs(calendar) do
        -- Extract fields
        local event_date = event[1]
        local event_string = event[2]

        -- Select today and passed events
        if date == event_date then
            table.insert(today_events, event_string)

        elseif date > event_date then
            local passed_event = event_date .. ": " .. event_string
            table.insert(passed_events, passed_event)

        else
            table.insert(updated_events, event)
        end
    end

    -- Return
    return today_events, passed_events, updated_events
end

local function set_punctual_events(t, events_path)
    local pretty_events = "return " .. utils.array_to_pretty_string(t)

    return utils.write_all(events_path, pretty_events)
end


-----------------------------------------
--            Cyclic events
-----------------------------------------

local function date_coset(date, mod)
    local parsed_date = utils.parse_string(date, "-")
    local year, month, day = tonumber(parsed_date[1]), tonumber(parsed_date[2]), tonumber(parsed_date[3])

    local today_coset = utils.days_from_civil(year, month, day) % mod

    return today_coset
end

local function get_cyclic_events(date, events_path)

    -- Read events
    local content = utils.read_all(events_path)
    if content == nil then return nil end
    local calendar = loadstring(content)()

    -- Iterate events
    local today_events = {}

    for _,event in ipairs(calendar) do
        -- Extract fields
        local event_cycle = event[1]
        local event_coset = event[2]
        local event_string = event[3]

        -- Select today events
        --local year, month, day = date[
        local today_coset = date_coset(date, event_cycle)

        if today_coset == event_coset then
            table.insert(today_events, event_string)
        end
    end

    -- Return
    return today_events
end


-----------------------------------------
--            Main table
-----------------------------------------

M = {
    get_punctual_events = get_punctual_events,
    set_punctual_events = set_punctual_events,

    date_coset = date_coset,
    get_cyclic_events = get_cyclic_events
}

return M
