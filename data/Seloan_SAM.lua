local autoloader = require("autoloader")
local common_job = require("common_job")
local utils = require("autoloader-utils")
local auto_sets = require("autoloader-sets")

autoloader.auto_movement = "on"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ja \"Third Eye\" <me>")

    -- R1+Down = ^F8
    autoloader.register_keybind("^F8", "input /ja \"Blade Bash\" <t>")

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input /target <me>;input /recast Sekkanoki;input /ja Sekkanoki <stpc>")

    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input /target <me>;input /recast Hagakure;input /ja Hagakure <stpc>")

    -- R1+L1+Up = !F7
    autoloader.register_keybind("!F7", "input /target <me>;input /recast Sengikori;input /ja Sengikori <stpc>")

    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast Meditate;input /ja Meditate <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input /target <me>;input /recast Seigan;input /ja Seigan <stpc>")
    -- R1+L1+Right = !F10
    autoloader.register_keybind("!F10", "input /target <me>;input /recast Hasso;input /ja Hasso <stpc>")
end

function before_self_command(cmd)
    local a1, tail = cmd:match("^(%S+)%s*(.*)$")
    a1 = (a1 or ""):lower()
    local a2 = (tail ~= "" and tail) or nil

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end
end