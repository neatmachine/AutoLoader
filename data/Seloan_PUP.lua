local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local autosets = require("autoloader-sets")
require("lists")
autoloader.auto_movement = "on"
autoloader.pet_mode = "default"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /recast Deploy;input /ja Deploy <stnpc>")

    -- R1+Down = ^F8
    autoloader.register_keybind("^F8", "input //gs c cast element maneuver")

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c element cycleback")

    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c element cycle")

    -- R1+L1+Up = !F7
    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast Deactivate;input /ja Deactivate <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input /target <me>;input /recast Retrieve;input /ja Retrieve <stpc>")

    -- R1+L1+Right = !F10
end

function before_self_command(cmd)
    local a1, tail = cmd:match("^(%S+)%s*(.*)$")
    a1 = (a1 or ""):lower()
    local a2 = (tail ~= "" and tail) or nil

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end

    if a1 == "erase" then
        common_job.auto_debuff_removal()
        return true
    end

    if a1 == "element" then
        common_job.handle_element_mode(a2)
        return true
    end

    if a1 == "status" then
        common_job.handle_status_mode(a2)
        return true
    end

    if a1 == "cast" then
        common_job.handle_cast(a2)
        return true
    end

    if a1 == "auto_cure" then
        common_job.toggle_auto_downgrade_cure()
        return true
    end
    
    if a1 == "rpt" then
        common_job.handle_repeat(a2)
    end
end