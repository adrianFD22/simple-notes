
# simple-notes

This is the script I use for managing my daily note workflow. When I fully transitioned to vim, I stopped using Obsidian. There were some Obsidian features that I love and I missed, so I implemented some of these functionalities that I liked the most.


## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'adrianFD22/simple-notes'
```


## Usage

The workflow is simple: use a file a day that contains your schedule. You have access to the following functions:

| Functions         | Description                                                                         |
|-------------------|-------------------------------------------------------------------------------------|
| `setup`           | Set the options                                                                     |
| `open_daily_note` | Open a buffer corresponing to the daily note file                                   |
| `print_options`   | Print the current options                                                           |
| `date_coset`      | Get the coset (module operation %) corresponding to a given date and a given module |

When you open the daily note via `open_daily_note`, a new markdown is created if required in the directory that is set in the options. Then, this file is filled with a template corresponding to the day of the week that it is storaged in the other directory set in the options. In addition, two files in the first directory are read that contain a unique return statement that returns the table of punctual events and cyclic events, respectively. The events read from these files are added to the daily note.

An example of the `punctual_events.lua` that must be storaged in the daily notes directory
```lua
return {
    {
        "2022-04-20",
        "Important meeting"
    },
    {
        "2022-06-21",
        "Other meeting"
    }
}
```

An example of the `cyclic_events.lua` that must be storaged in the daily notes directory
```lua
-- Usage: each element of the table represents a cyclic event and has the following format:
--      {
--          cycle,
--          coset,
--          string
--      }

return {
    {
        7,
        0,
        "Laundry"
    }
}

```

An example of a configuration file
```lua
local notes = require("simple-notes")

notes.setup({
    daily_dir = "my_daily_notes_dir",
    templates_dir = "my_week_templates_dir"
})

-- Navigate notes
vim.keymap.set("n", "<leader>cn", notes.open_daily_note)	-- Open daily note
```

Feel free to ask any questions via issues.


## TODO

- Add functionalities
    - A function for getting the day of certain day of the week day
- Improve robustness
    - Perform shell expansion in the options string
    - Auto create punctual_events.lua and cyclic_events.lua file
    - Detect whether or not the option directories are correctly set
