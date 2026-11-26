local autoloader = require("autoloader")
local codex = require("autoloader-codex")
local common_job = require("common_job")
local log = require("autoloader-logger")
local auto_sets = require("autoloader-sets")
local utils = require("autoloader-utils")
include("Modes")

autoloader.auto_movement = "on"
local _learning_mode = M { "off", "on" }

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ma \"Sudden Lunge\" <t>")
    -- R1+Down = ^F8
    if player and player.sub_job and player.sub_job:lower() == "nin" then
        autoloader.register_keybind("^F8", "input //gs c utsusemi")
    else
        autoloader.register_keybind("^F8", "input /target <me>;input /recast Occultation;input /ma Occultation <stpc>")
    end

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input /target <me>;input /recast \"Chain Affinity\";input /ja \"Chain Affinity\" <stpc>")

    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input /target <me>;input /recast \"Burst Affinity\";input /ja \"Burst Affinity\" <stpc>")
    
    -- R1+L1+Up = !F7
    autoloader.register_keybind("!F7", "input /target <me>;input /recast Fantod;input /ma Fantod <stpc>")

    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast Cocoon;input /ma Cocoon <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input /target <me>;input /recast \"Erratic Flutter\";input /ma \"Erratic Flutter\" <stpc>")

    -- R1+L1+Right = !F10
    autoloader.register_keybind("!F10", "input /target <me>;input /recast \"Battery Charge\";input /ma \"Battery Charge\" <stpc>")

end

local function is_blue_magic(spell)
    return spell and spell.action_type and spell.action_type:lower() == "magic" and spell.skill and
           spell.skill:lower() == "blue magic"
end

function before_precast(spell)
    if spell and spell.action_type and spell.action_type:lower() == "magic" then
        local terminate = common_job.auto_echo_drops(spell)
        if terminate == true then return true end
    end

    if is_blue_magic(spell) then
        if codex.BLUE_MAGIC.UNBRIDLED_SPELLS:contains(spell.english) and not buffactive["Unbridled Learning"] and codex.get_ability_recast("Unbridled Learning") == 0 and not buffactive["Unbridled Wisdom"] then
            common_job.ja_then_recast("Unbridled Learning", spell)
            return true
        end
    end

    return false
end

function after_status_change(new, old)
    if _learning_mode.current == "on" then
        autoloader.equip_clean(auto_sets.get("learning"))
    end
end

function after_midcast(spell)
    if is_blue_magic(spell) then
        -- Blue Magic
        local self_cast = (spell.target and (spell.target.type:lower() == "self" or spell.target.name == (windower.ffxi.get_player() or {}).name))
        -- Buff => Self cast and not healing
        local is_buff = self_cast == true and not codex.BLUE_MAGIC.MAGICAL.HEALING_SPELLS:contains(spell.english)
        if buffactive["Diffusion"] and is_buff then
            -- Equip diffusion enhanced set over other resolved sets
            autoloader.equip_clean(auto_sets.get("blue.magical_buff_diffusion"))
        end
    end
end

function before_self_command(cmd)
    if cmd == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    elseif cmd == "learning" then
        _learning_mode:cycle()
        utils.echo("Spell Learning: " .. utils.pretty_mode_value(_learning_mode.current))
        return true
    end
end