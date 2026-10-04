local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local utils = require("autoloader-utils")
local autosets = require("autoloader-sets")

autoloader.auto_movement = "on"
common_job.init_element("light")

local _auto_dbl_mode = M {"off", "on"}
local _luzaf_mode = M {"off", "on"}
local _th_mode = M { "off", "on" }

--_auto_dbl_mode:set("on")

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ra <stnpc>")
    -- R1+Down = ^F8
    if player and player.sub_job and player.sub_job:lower() == "nin" then
        autoloader.register_keybind("^F8", "input //gs c utsusemi")
    end
    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c element cycleback")
    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c element cycle")

    -- R1+L1+Up = !F7
    autoloader.register_keybind("!F7", "input //gs c cast element qd")

    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast 'Double-Up';input /ja 'Double-Up' <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input //gs c luzaf")

    -- R1+L1+Right = !F10
end

function after_precast(spell)
    if spell and spell.type and spell.type == 'CorsairRoll' then
        autoloader.equip_clean(autosets.get("phantom_roll"))
    end
end

function after_aftercast(spell)
    if spell and spell.type and spell.type == 'CorsairRoll' then
        local roll = codex.COR_ROLLS[spell.english]
        if roll then
            log.info(("(%s) Lucky: %s | Unlucky: %s"):format(spell.english, roll.lucky, roll.unlucky))
            if _auto_dbl_mode.current == "on" then
                windower.send_command("input /target <me>;input /recast 'Double-Up';input /ja 'Double-Up' <stpc>")
            end
            return
        end

    if _auto_dbl_mode.current == "on" and spell.english == "Double-Up" and buffactive["Double-Up Chance"] then
            windower.send_command("input /target <me>;input /recast 'Double-Up';input /ja 'Double-Up' <stpc>")
        end
    end
end

local function toggle_auto_dbl()
    _auto_dbl_mode.cycle()
    local current = _auto_dbl_mode.current
    utils.echo("Auto Double-Up: " .. utils.pretty_mode_value(current))
end

local luzaf_set = {
  left_ring = "Luzaf's Ring",
}
local function toggle_luzaf()
    _luzaf_mode:cycle()
    local current = _luzaf_mode.current
    utils.echo("Luzaf's Ring: " .. utils.pretty_mode_value(current))

    if current == "on" then
        autoloader.equip_lock(luzaf_set)
    else
        autoloader.unlock(luzaf_set)
        autoloader.status_refresh()
    end
end

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

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end

    if a1 == "luzaf" then
        toggle_luzaf()
        return true
    end

    if a1 == "th" then
        toggle_th()
        return true
    end

    if a1== "auto_dbl" then
        toggle_auto_dbl()
        return true
    end

    if a1 == "element" then
        common_job.handle_element_mode(a2)
        return true
    end

    if a1 == "cast" then
        common_job.handle_cast(a2)
        return true
    end
end
