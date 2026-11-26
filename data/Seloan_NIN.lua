local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local utils = require("autoloader-utils")
local autosets = require("autoloader-sets")
autoloader.auto_movement = "on"

function before_get_sets()
    
    -- R1+Up = ^F7
    if player and player.sub_job and player.sub_job:lower() == "war" then
        autoloader.register_keybind("^F7", "input /ja Provoke <stnpc>")
    end

    -- R1+Down = ^F8
    autoloader.register_keybind("^F8", "input //gs c utsusemi")

    -- R1+Left = ^F9
    -- R1+Right = ^F10

    -- R1+L1+Up = !F7
    -- R1+L1+Down = !F8
    -- R1+L1+Left = !F9
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

    if a1 == "rpt" then
        common_job.handle_repeat(a2)
    end
end