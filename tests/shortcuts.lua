-- Run from the repository root: lua tests/shortcuts.lua
package.path = "./libs/?.lua;" .. package.path

package.preload["Modes"] = function()
    function M(options)
        options.current = options[1]
        function options:set(value) self.current = value end
        function options:contains(value)
            for _, option in ipairs(self) do
                if option == value then return true end
            end
            return false
        end
        return options
    end
    return true
end
package.preload["lists"] = function() return true end
package.preload["resources"] = function() return {} end
package.preload["autoloader-codex"] = function() return {} end
package.preload["common_job"] = function() return {} end
package.preload["autoloader-sets"] = function()
    return { get_weapons = function() return {} end }
end

local chat, commands = {}, {}
windower = {
    add_to_chat = function(color, text)
        chat[#chat + 1] = {
            color = color,
            text = (text:gsub(string.char(0x1F) .. ".", "")),
        }
    end,
    send_command = function(command) commands[#commands + 1] = command end,
    register_event = function() return 1 end,
    unregister_event = function() end,
}
function include(name) require(name) end

local function reset_output()
    chat, commands = {}, {}
end

local function load_job(job, path)
    reset_output()
    player = { main_job = job }
    package.loaded["autoloader"] = nil
    local loader = require("autoloader")
    loader.use_auto_sets = false
    if path then dofile(path) end
    return loader
end

local function expect_lines(expected)
    assert(#chat == #expected, "Unexpected chat line count")
    local log = require("autoloader-logger")
    for i, text in ipairs(expected) do
        assert(chat[i].text == text, ("Line %d: %s"):format(i, chat[i].text))
        assert(chat[i].color == log.options.color, "Incorrect INFO color")
    end
end

local loader = load_job("RDM", "data/Seloan_RDM.lua")
get_sets()
expect_lines({
    "[AutoLoader] Shortcuts (RDM)",
    "!F10: input //ez cycle",
    "^F10: input //ez cycle back",
})
assert(#commands == 4, "Displaying shortcuts sent an extra command")
reset_output()
get_sets()
expect_lines({
    "[AutoLoader] Shortcuts (RDM)",
    "!F10: input //ez cycle",
    "^F10: input //ez cycle back",
})
file_unload()

load_job("BLU", "data/Seloan_BLU.lua")
get_sets()
expect_lines({
    "[AutoLoader] Shortcuts (BLU)",
    '^F7: input /ma "Sudden Lunge" <t>',
    "^F8: input /target <me>;input /recast Diffusion;input /ja Diffusion <stpc>",
})
assert(#commands == 3, "Displaying a command chain executed commands")
file_unload()

load_job("DRK", "data/Seloan_DRK.lua")
get_sets()
expect_lines({})
file_unload()

loader = load_job("SAM")
local chain = 'input /ja "Example" <me>;wait 1;input /echo Display ONLY'
loader.register_keybind("!F10", chain)
loader.register_keybind("!F9", "input /old")
loader.register_keybind("!F9", "input /Updated <t>")
loader.register_keybind("!F02", "input /two")
loader.register_keybind("!F2", "input /two again")
loader.register_keybind("^F10", "input /ten")
loader.register_keybind("^F9", "input /nine")
loader.register_keybind("a", "input /letter")
function after_get_sets()
    assert(#chat == 0, "Shortcuts printed before after_get_sets")
    loader.register_keybind("~numpad2", "input /late")
end
get_sets()
expect_lines({
    "[AutoLoader] Shortcuts (SAM)",
    "!F02: input /two",
    "!F2: input /two again",
    "!F9: input /Updated <t>",
    "!F10: " .. chain,
    "^F9: input /nine",
    "^F10: input /ten",
    "a: input /letter",
    "~numpad2: input /late",
})
assert(#commands == 8, "Shortcut display changed command execution")
file_unload()

loader = load_job("THF")
loader.register_keybind("f9", "input /test")
local log = require("autoloader-logger")
for _, verbosity in ipairs({ "off", "error", "info", "debug" }) do
    reset_output()
    log.mode:set(verbosity)
    get_sets()
    if verbosity == "off" or verbosity == "error" then
        expect_lines({})
    else
        -- DEBUG adds existing diagnostic lines before the shortcut list.
        assert(chat[#chat - 1].text == "[AutoLoader] Shortcuts (THF)")
        assert(chat[#chat].text == "f9: input /test")
        assert(chat[#chat].color == log.options.color)
    end
end

log.mode:set("info")
reset_output()
log.info("Unchanged; informational: message")
expect_lines({ "[AutoLoader] Unchanged; informational: message" })
log.mode:set("off")
reset_output()
log.info("Forced message", true)
expect_lines({ "[AutoLoader] Forced message" })
log.mode:set("info")
reset_output()
log.info_lines({})
expect_lines({})
assert(#commands == 0, "Logger executed commands")

print("Shortcut regression tests passed.")
