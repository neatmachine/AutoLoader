-- Seloan_RDM.lua
-- Basic Red Mage (RDM) configuration file with AutoLoader support
local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
autoloader.auto_movement = "on"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "/input /recast \"Dia III\";input /ma \"Dia III\" <stnpc>")

    -- R1+Down = ^F8
    if player and player.sub_job and player.sub_job:lower() == "nin" then
        autoloader.register_keybind("^F8", "input //gs c utsusemi")
    else
        autoloader.register_keybind("^F8", "input /target <me>;input /recast Blink;input /ma Blink <stpc>")
    end

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c element cycleback")

    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c element cycle")

    -- R1+L1+Up = !F7
    if player and player.sub_job and player.sub_job:lower() == "sch" then
        autoloader.register_keybind("!F7", "input /target <me>;input //gs c sch light")
    end

    -- R1+L1+Down = !F8
    if player and player.sub_job and player.sub_job:lower() == "sch" then
        autoloader.register_keybind("!F8", "input /target <me>;input //gs c sch dark")
    end

    -- R1+L1+Left = !F9
    if player and player.sub_job and player.sub_job:lower() then
        autoloader.register_keybind("!F9", "input /target <me>;input //gs c sch speed")
    end

    -- R1+L1+Right = !F10
    if player and player.sub_job and player.sub_job:lower() == "sch" then
        autoloader.register_keybind("!F10", "input /target <me>;input //gs c sch aoe")
    end
end

function before_precast(spell)
    if spell and spell.action_type and spell.action_type:lower() == "magic" and spell.skill then
        -- Magic
        -- Use echos if necessary
        local terminate = common_job.auto_echo_drops(spell)
        if terminate == true then return true end

        terminate = common_job.auto_recast_downgrade(spell)
        if terminate == true then return true end

        terminate = common_job.auto_cure_downgrade(spell)
        if terminate == true then return true end

        if spell.skill:lower() == "enhancing magic" then
            -- Enhancing Magic

            -- If Composure not up and it's ready, use it and then re-cast.
            if not buffactive["Composure"] and codex.get_ability_recast("Composure") == 0 then
                common_job.ja_then_recast("Composure", spell)
                return true -- block original precast
            end

            -- Phalanx II downgrade on self
            local self_cast = (spell.target and (spell.target.type:lower() == "self" or spell.target.name == (windower.ffxi.get_player() or {}).name))
            if self_cast then
                if spell.english == "Phalanx II" then
                    -- Downgrade Phalanx II when casting on self
                    cancel_spell()
                    windower.send_command("input /ma 'Phalanx' " .. spell.target.name)
                    log.info("Phalanx II (Self) => Phalanx (Self)")
                    return true -- block original precast
                end
            end
        end
    end
    return false
end

function after_midcast(spell)
    if spell and spell.action_type and spell.action_type:lower() == "magic" and spell.skill then
        if buffactive["Composure"] then
            if spell.skill == "Enhancing Magic" then
                autoloader.equip_clean(autosets.get("enhancing.composure"))
            elseif spell.skill == "Enfeebling Magic" then
                autoloader.equip_clean(autosets.get("enfeebling.composure"))
            end
        end
        if buffactive["Saboteur"] and spell.skill == "Enfeebling Magic" then
            autoloader.equip_clean(autosets.get("enfeebling.composure"))
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

    if a1 == "erase" then
        common_job.auto_debuff_removal()
        return true
    end

    if a1 == "sch" then
        common_job.handle_strategem(a2)
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
