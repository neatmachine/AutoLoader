local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local autosets = require("autoloader-sets")
require("lists")
autoloader.auto_movement = "on"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("!F7", "input /target <me>;input /recast \"Divine Seal\";input /ja \"Divine Seal\" <stpc>")

    -- R1+Down = ^F8

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c element cycleback")
    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c element cycle")

    -- R1+L1+Up = !F7
    autoloader.register_keybind("!F7", "input /target <me>;input //gs c sch light")

    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input //gs c sch dark")

    -- R1+L1+Left = !F9
    --autoloader.register_keybind("!F9", "input //gs c status cycleback")
    -- R1+L1+Right = !F10
    --autoloader.register_keybind("!F10", "input //gs c status cycle")
end

function before_precast(spell)
    local terminate = common_job.auto_echo_drops(spell)
    if terminate == true then return true end

    terminate = common_job.auto_recast_downgrade(spell)
    if terminate == true then return true end

    terminate = common_job.auto_cure_downgrade(spell)
    if terminate == true then return true end
end

function after_get_sets()
    --autoloader.poll.ensure_registration("auto_pet_check", 1, auto_pet_check)
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

    if a1 == "auto_cure" then
        common_job.toggle_auto_downgrade_cure()
        return true
    end

    if a1 == "cast" then
        a2 = a2 and a2:lower()
        common_job.handle_cast(a2)
        return true
    end

    if a1 == "rpt" then
        common_job.handle_repeat(a2)
    end
end
