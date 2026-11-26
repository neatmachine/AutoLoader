local autoloader = require("autoloader")
local common_job = require("common_job")
local codex = require("autoloader-codex")
local log = require("autoloader-logger")
local autosets = require("autoloader-sets")
local utils = require("autoloader-utils")
require("lists")
autoloader.auto_movement = "on"
autoloader.pet_mode = "default"
autoloader.melee_mode = "off"

function before_get_sets()
    -- R1+Up = ^F7
    autoloader.register_keybind("^F7", "input /recast Assault;input /ja Assault <stnpc>")

    -- R1+Down = ^F8

    -- R1+Left = ^F9
    autoloader.register_keybind("^F9", "input //gs c element cycleback")
    -- R1+Right = ^F10
    autoloader.register_keybind("^F10", "input //gs c element cycle")

    -- R1+L1+Up = !F7
    if player and player.sub_job then
        if player.sub_job:lower() == "whm" then
            autoloader.register_keybind("!F7", "input /target <me>;input /recast \"Divine Seal\";input /ja \"Divine Seal\" <stpc>")
        elseif player.sub_job:lower() == "rdm" then
            autoloader.register_keybind("!F7", "input /target <me>;input /recast Convert;input /ja Convert <stpc>")
        end
    end
    -- R1+L1+Down = !F8
    autoloader.register_keybind("!F8", "input /target <me>;input /recast Release;input /ja Release <stpc>")

    -- R1+L1+Left = !F9
    autoloader.register_keybind("!F9", "input /target <me>;input /recast Retreat;input /ja Retreat <stpc>")

    -- R1+L1+Right = !F10
    --autoloader.register_keybind("!F10", "input //gs c status cycle")
end

local function pet_macro_update()
    local _avatar_macro_set_commands = {
        ["Carbuncle"] = "input /macro book 21;wait .1;input /macro set 1",
        ["Fenrir"] = "input /macro book 21;wait .1;input /macro set 2",
        ["Diabolos"] = "input /macro book 21;wait .1;input /macro set 3",
        ["Cait Sith"] = "input /macro book 21;wait .1;input /macro set 4",
        ["Siren"] = "input /macro book 21;wait .1;input /macro set 5",

        ["Ifrit"] = "input /macro book 22;wait .1;input /macro set 1",
        ["Titan"] = "input /macro book 22;wait .1;input /macro set 2",
        ["Leviathan"] = "input /macro book 22;wait .1;input /macro set 3",
        ["Garuda"] = "input /macro book 22;wait .1;input /macro set 4",
        ["Shiva"] = "input /macro book 22;wait .1;input /macro set 5",
        ["Ramuh"] = "input /macro book 22;wait .1;input /macro set 6",
    }

    local avatar = pet and pet.name
    if avatar then
        local macro_command = _avatar_macro_set_commands[avatar]
        if macro_command then
            windower.send_command(macro_command)
            log.info("Macro: " .. avatar)
            return
        end
    end

    windower.send_command(_avatar_macro_set_commands["Carbuncle"])
    log.info("Macro: Carbuncle")
end

local function get_best_spirit()
    local day_elem     = world.day_element
    local weather_elem = world.weather_element
    local weather_int  = world.weather_intensity or 0 -- 0,1,2

    -- Normalize helper
    local function norm(elem)
        if type(elem) ~= "string" then return nil end
        elem = elem:lower()
        return elem:gsub("^%l", string.upper) -- fire -> Fire
    end

    day_elem       = norm(day_elem)
    weather_elem   = norm(weather_elem)

    -- Opposing element map: who this element is weak to
    -- opposing[elem] = element that BEATS elem
    local opposing = {
        Fire      = "Water",
        Ice       = "Fire",
        Wind      = "Ice",
        Earth     = "Wind",
        Lightning = "Earth",
        Water     = "Lightning",
        Light     = "Dark",
        Dark      = "Light",
    }

    -- Relationship of spell element to environment element:
    --  +1 = matching (bonus)
    --  -1 = env is element that beats this element (penalty)
    --   0 = irrelevant
    local function relation(spell_elem, env_elem)
        if not spell_elem or not env_elem then
            return 0
        end
        if spell_elem == env_elem then
            -- Matching day/weather
            return 1
        end
        -- If env element is what beats this element → penalty
        if opposing[spell_elem] == env_elem then
            return -1
        end
        -- No bonus for "I'm strong vs env"; just neutral
        return 0
    end

    -- Compute total day/weather score for a given element
    local function score_element(elem)
        local score = 0

        -- Day: +/-10% when relevant
        local r_day = relation(elem, day_elem)
        if r_day ~= 0 then
            score = score + 0.10 * r_day
        end

        -- Weather: +/-10% (single) or +/-15% (double) when relevant
        if weather_elem and weather_int > 0 then
            local mag = (weather_int >= 2) and 0.15 or 0.10
            local r_weather = relation(elem, weather_elem)
            if r_weather ~= 0 then
                score = score + mag * r_weather
            end
        end

        return score
    end

    local candidates = {
        { elem = "Fire",      name = "Fire Spirit" },
        { elem = "Ice",       name = "Ice Spirit" },
        { elem = "Wind",      name = "Air Spirit" },
        { elem = "Earth",     name = "Earth Spirit" },
        { elem = "Lightning", name = "Thunder Spirit" },
        { elem = "Water",     name = "Water Spirit" },
        { elem = "Light",     name = "Light Spirit" },
        { elem = "Dark",      name = "Dark Spirit" },
    }

    local best_name  = nil
    local best_score = -math.huge

    for _, entry in ipairs(candidates) do
        local s = score_element(entry.elem)
        if s > best_score then
            best_score = s
            best_name  = entry.name
        end
    end

    -- If everything is neutral or worse, default to Light Spirit
    if not best_name or best_score <= 0 then
        best_name = "Light Spirit"
    end

    return best_name
end

local last_release = nil
function before_precast(spell)
    if spell.english == "Release" then
        last_release = utils.now()
        return false
    end

    local terminate = common_job.auto_echo_drops(spell)
    if terminate == true then return true end

    terminate = common_job.auto_recast_downgrade(spell)
    if terminate == true then return true end

    terminate = common_job.auto_cure_downgrade(spell)
    if terminate == true then return true end

    if (pet.isvalid and pet_midaction() and not spell.type == "SummonerPact") or spell.type == "Item" then
        return true
    end

    if spell.type == "SummonerPact" then
        -- Summoning
        if pet and pet.isvalid and (last_release == nil or (utils.now() - last_release > 2)) then
            common_job.ja_then_recast("Release", spell)
            return true
        end
        -- if spell.english:lower() == "odin" or spell.english:lower() == "alexander" then
        --     if not buffactive["Astral Flow"] and codex.get_ability_recast("Astral Flow") == 0 and codex.player_can_cast(spell.english) then
        --         common_job.ja_then_recast("Astral Flow", spell)
        --         return true
        --     end
        -- end
    -- elseif spell.english == "Elemental Siphon" and (not pet or not pet.isvalid or not utils.ends_with(pet.name, "Spirit")) then
    --     cancel_spell()
    --     local spirit = get_best_spirit()
    --     windower.send_command(("input /ma \"%s\" <me>;wait 1.5;input /ja \"Elemental Siphon\" <me>"):format(spirit))
    --     log.info(("Elemental Siphon => %s => Elemental Siphon"):format(spirit))
    end
end

function after_precast(spell)
    if spell and spell.type == "SummonerPact" then
        autoloader.equip_clean(autosets.get("precast.summoning"))
    end
end

function before_midcast(spell)
    if (pet.isvalid and pet_midaction()) or spell.type == "Item" then
        return true
    end
end

function after_midcast(spell)
    if spell.type == "BloodPactWard" or spell.type == "BloodPactRage" and not buffactive["Astral Conduit"] then
        autoloader.equip_clean(autosets.get("bp.delay"))
    end
end

function after_pet_midcast(spell)
    if spell.english == "Shock Squall" then return true end

    local combined = L {}
    combined:append(codex.get_blood_pact_set(spell.english))
    combined:append("bp." .. utils.sanitize(spell.english))

    if autoloader.get_current_magic_mode() == "acc" then
        combined:append(codex.CASTING_SETS.bp.acc)
    end

    autoloader.equip_clean(autosets.build_set(combined))

    return true
end

function before_aftercast(spell)
    if pet_midaction() or spell.type == "Item" then
        return true
    end
end

function after_aftercast(spell)
    if spell.english == "Odin" then
        autoloader.equip_clean(autosets.get("zantetsuken"))
        return
    end

    if spell.english == "Alexander" then
        autoloader.equip_clean(autosets.get("perfect_defense"))
        return
    end

    if spell.english == "Atomos" then
        autoloader.equip_clean(autosets.get("chronoshift"))
        return
    end

    if spell.english == "Release" or spell.type == "SummonerPact" then
        windower.send_command("wait 1;input //gs c a status_refresh")
        return
    end
end

function before_status_change(new, old)
    if pet_midaction() then
        autoloader.status_refresh()
        return true
    end
end

local function handle_spirit_summon()
    local spirit = get_best_spirit()
    windower.send_command(("input /recast \"%s\";input /ma \"%s\" <stpc>"):format(spirit, spirit))
end

function before_self_command(cmd)
    local a1, tail = cmd:match("^(%S+)%s*(.*)$")
    a1 = (a1 or ""):lower()
    local a2 = (tail ~= "" and tail) or nil

    if a1 == "rpt" then
        common_job.handle_repeat(a2)
    end

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end

    if a1 == "erase" then
        common_job.auto_debuff_removal()
        return true
    end

    if a1 == "pet_auto_attack" then
        _pet_auto_attack = not _pet_auto_attack
        utils.echo("Pet Auto Attack: " .. tostring(_pet_auto_attack))
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
        a2 = a2 and a2:lower()
        if a2 == "spirit" then
            handle_spirit_summon()
            return true
        else
            common_job.handle_cast(a2)
            return true
        end
    end

    if a1 == "auto_cure" then
        common_job.toggle_auto_downgrade_cure()
        return true
    end
end
