local autoloader = require("autoloader")
local common_job = require("common_job")
local utils = require("autoloader-utils")
local auto_sets = require("autoloader-sets")

autoloader.auto_movement = "on"

local _absorb_mode = M {
        "Absorb-STR",
        "Absorb-DEX",
        "Absorb-VIT",
        "Absorb-AGI",
        "Absorb-INT",
        "Absorb-MND",
        "Absorb-CHR",
        "Absorb-ACC",
}

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /ja \"Weapon Bash\" <t>")
    -- R1+Down = ^F8
    autoloader.register_keybind("^F8", "input /ma Stun <t>")
    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c absorb cycleback")
    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c absorb cycle")

    -- R1+L1+Up = !F7
    if player and player.sub_job and player.sub_job:lower() == "sam" then
        autoloader.register_keybind("!F7", "input /ja \"Third Eye\" <me>")
    end
    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast \"Dread Spikes\";input /ma \"Dread Spikes\" <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input //gs c element cycleback")
    -- R1+L1+Right = !F10
    autoloader.register_keybind("!F10", "input //gs c element cycle")
end

function before_precast(spell)
    if spell and spell.action_type and spell.action_type:lower() == "magic" then
        local terminate = common_job.auto_echo_drops(spell)
        if terminate == true then return true end

        terminate = common_job.auto_recast_downgrade(spell)
        if terminate == true then return true end

        if spell.english and spell.english == "Drain III" or spell.english == "Drain II" then
            if not buffactive["Nether Void"] and codex.get_ability_recast("Nether Void") == 0 then
                common_job.ja_then_recast("Nether Void", spell)
                return true
            end
            if not buffactive["Dark Seal"] and codex.get_ability_recast("Dark Seal") == 0 then
                common_job.ja_then_recast("Dark Seal", spell)
                return true
            end
        end
    end
end

function after_midcast(spell)
       if buffactive["Nether Void"] and spell.skill and spell.skill:lower() == "dark" then
            autoloader.equip_clean(auto_sets.get("dark.nether_void"))
        end
end

local function handle_absorb_cast()
    windower.send_command(("input /recast \"%s\";input /ma \"%s\" <stnpc>"):format(_absorb_mode.current, _absorb_mode.current))
end

local function handle_absorb_mode(cmd)
   if not cmd then return false end

    cmd = cmd:lower()

    if cmd == "cycle" then
        _absorb_mode:cycle()
        utils.echo(_absorb_mode.current:gsub("-", ": "))
        return true
    elseif cmd == "cycle back" or cmd == "cycleback" then
        _absorb_mode:cycleback()
        utils.echo(_absorb_mode.current:gsub("-", ": "))
        return true
    else
        _absorb_mode:set(cmd)
        utils.echo(_absorb_mode.current:gsub("-", ": "))
        return true
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

    if a1 == "absorb" then
        handle_absorb_mode(a2)
        return true
    end

    if a1 == "element" then
        common_job.handle_element_mode(a2)
        return true
    end

    if a1 == "cast" then
        a2 = a2 and a2:lower()
        if a2 == "absorb" then
            handle_absorb_cast()
            return true
        else
            common_job.handle_cast(a2)
            return true
        end
    end


    if a1 == "rpt" then
        common_job.handle_repeat(a2)
        end
end
