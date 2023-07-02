
local utils = require("simple-notes.utils")
local notes = require("simple-notes.notes")

local M


-----------------------------------------
--               Utils
-----------------------------------------

local function valid_options()
    return M.templates_dir and M.daily_dir
end


-----------------------------------------
--          Builtin functions
-----------------------------------------

local function open_daily_note()
    -- Check that options are set
    if not valid_options() then
        print("Options are not set")
        return
    end

    -- Insert template if file does not exist
    local today_date = os.date('%Y-%m-%d')
    local file = M.daily_dir .. today_date .. ".md"

    if not utils.file_exists(file) then
        local daily_events = ""

        local punctual_events_path = M.daily_dir .. "punctual_events.lua"
        local cyclic_events_path = M.daily_dir .. "cyclic_events.lua"

        local today_punctual_events, passed_events, updated_events = notes.get_punctual_events(today_date, punctual_events_path)
        local today_cyclic_events = notes.get_cyclic_events(today_date, cyclic_events_path)

        local exist_events = not (utils.table_is_empty(today_punctual_events) and utils.table_is_empty(passed_events) and utils.table_is_empty(today_cyclic_events))

        if exist_events then
            daily_events = "# Events\n\n"

            -- punctual today events
            if not utils.table_is_empty(today_punctual_events) then
                for _,event in ipairs(today_punctual_events) do
                    local current_event_line = "- [ ] " .. event .. "\n"
                    daily_events = daily_events .. current_event_line
                end
            end

            -- cyclic events
            if not utils.table_is_empty(today_cyclic_events) then
                for _,event in ipairs(today_cyclic_events) do
                    local current_event_line = "- [ ] " .. event .. "\n"
                    daily_events = daily_events .. current_event_line
                end
            end

            -- punctual passed events
            if not utils.table_is_empty(passed_events) then
                for _,event in ipairs(passed_events) do
                    local current_event_line = "- [ ] " .. event .. "\n"
                    daily_events = daily_events .. current_event_line
                end
            end

            daily_events = daily_events .. "\n\n"

            -- Update punctual events file
            notes.set_punctual_events(updated_events, punctual_events_path)
        end

        -- Daily schedule
        local day_of_the_week = os.date("%A")
        local schedule_header = "# Schedule\n\n"
        local daily_schedule = schedule_header .. utils.read_all(M.templates_dir .. day_of_the_week .. ".md")
        daily_schedule = daily_schedule .. "\n\n"

        -- Day notes
        local day_notes = "# Day notes\n- "

        -- Write file
        local f = io.open(file, "w")
        f:write("\n")
        f:write(daily_events)
        f:write(daily_schedule)
        f:write(day_notes)
        f:close()
    end

    -- Open file
	local command = "e " .. file
	vim.cmd(command)
end

local function get_calendar(date, num_days)
    -- Check parameters
    if num_days == nil then
        num_days = date
        date = os.date("%Y-%m-%d")
    end

    local calendar = {}
    local year, month, day = date:match("(%d%d%d%d)-(%d%d)-(%d%d)")

    local punctual_events_path = M.daily_dir .. "punctual_events.lua"
    local cyclic_events_path = M.daily_dir .. "cyclic_events.lua"

    for i=0,num_days do
        local curr_date = os.date("%Y-%m-%d", os.time({year = year, month = month, day = day + i}))

        local punctual_events = notes.get_punctual_events(curr_date, punctual_events_path)
        local cyclic_events = notes.get_cyclic_events(curr_date, cyclic_events_path)

        local curr_events = {}

        for _,v in ipairs(punctual_events) do
            table.insert(curr_events, v)
        end

        for _,v in ipairs(cyclic_events) do
            table.insert(curr_events, v)
        end

        calendar[curr_date] = curr_events
    end

    return calendar
end

local function print_calendar(num_days)
    local calendar = get_calendar(num_days)

    local today_date = os.date('%Y-%m-%d')
    local year, month, day = today_date:match("(%d%d%d%d)-(%d%d)-(%d%d)")

    local log = ""

    for i=0,num_days do
        local curr_date = os.date("%Y-%m-%d", os.time({year = year, month = month, day = day + i}))
        log = log .. curr_date .. "\n"

        for _,event in ipairs(calendar[curr_date]) do
            log = log .. "\t" .. event
        end

        log = log .. "\n"
    end

    vim.print(log)
end


-----------------------------------------
--            Main table
-----------------------------------------

local function setup(opts)
    if opts.daily_dir then
        M.daily_dir = opts.daily_dir
    end

    if opts.templates_dir then
        M.templates_dir = opts.templates_dir
    end
end

local function print_options()
    print("daily_dir =", M.daily_dir, ", templates_dir =", M.templates_dir)
end


M = {
    setup = setup,
    print_options = print_options,

    date_coset = notes.date_coset,
    open_daily_note = open_daily_note,
    get_calendar = get_calendar,
    print_calendar = print_calendar
}

return M
