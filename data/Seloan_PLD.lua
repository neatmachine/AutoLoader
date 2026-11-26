local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
autoloader.auto_movement = "on"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ja \"Shield Bash\" <t>")
    -- R1+Down = ^F8
    -- R1+Left = ^F9
    -- R1+Right = ^F10

    -- R1+L1+Up = !F7
    -- R1+L1+Down = !F8
    -- R1+L1+Left = !F9
    -- R1+L1+Right = !F10
end