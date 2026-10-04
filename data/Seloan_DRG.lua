local autoloader = require("autoloader")
local common_job = require("common_job")
local utils = require("autoloader-utils")
local auto_sets = require("autoloader-sets")

autoloader.auto_movement = "on"

function before_get_sets()

end

function before_self_command(cmd)
    local a1, tail = cmd:match("^(%S+)%s*(.*)$")
    a1 = (a1 or ""):lower()
    local a2 = (tail ~= "" and tail) or nil

    if a1 == "utsusemi" then
        common_job.auto_utsusemi()
        return true
    end
end