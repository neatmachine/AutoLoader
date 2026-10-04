local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local utils = require("autoloader-utils")
local autosets = require("autoloader-sets")
autoloader.auto_movement = "on"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ra <stnpc>")

    -- R1+Down = ^F8
    if player and player.sub_job then
        if player.sub_job:lower() == "nin" then
            autoloader.register_keybind("^F8", "input //gs c utsusemi")
        elseif player.sub_job:lower() == "dnc" then
            autoloader.register_keybind("^F8", "input /ja \"Reverse Flourish\" <t>")
        end
    end

    -- R1+Left = ^F9
    -- R1+Right = ^F10

    -- R1+L1+Up = !F7
    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast Flee;input /ja Flee <stpc>")
    -- R1+L1+Left = !F9
    -- R1+L1+Right = !F10

    --autoloader.register_melee_mode("th", "Treasure Hunter")
end

local _th_mode = M { "off", "on" }

local function toggle_th()
    _th_mode:cycle()
    local current = _th_mode.current
    utils.echo("Treasure Hunter: " .. utils.pretty_mode_value(current))
    local th_set = autosets.get("th")
    if th_set then
        if current == "on" then
            autoloader.equip_lock(th_set)
        else
            autoloader.unlock(th_set)
            autoloader.status_refresh()
        end
    end
end

function before_self_command(cmd)
    local a1, tail = cmd:match("^(%S+)%s*(.*)$")
    a1 = (a1 or ""):lower()
    local a2 = (tail ~= "" and tail) or nil

    if a1 == "th" then
        toggle_th()
        return true
    end

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end

    if a1 == "rpt" then
        common_job.handle_repeat(a2)
    end
end