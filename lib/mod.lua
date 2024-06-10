local fx = require("fx/lib/fx")
local mod = require 'core/mods'
local hook = require 'core/hook'
local tab = require 'tabutil'
-- Begin post-init hack block
if hook.script_post_init == nil and mod.hook.patched == nil then
    mod.hook.patched = true
    local old_register = mod.hook.register
    local post_init_hooks = {}
    mod.hook.register = function(h, name, f)
        if h == "script_post_init" then
            post_init_hooks[name] = f
        else
            old_register(h, name, f)
        end
    end
    mod.hook.register('script_pre_init', '!replace init for fake post init', function()
        local old_init = init
        init = function()
            old_init()
            for i, k in ipairs(tab.sort(post_init_hooks)) do
                local cb = post_init_hooks[k]
                print('calling: ', k)
                local ok, error = pcall(cb)
                if not ok then
                    print('hook: ' .. k .. ' failed, error: ' .. error)
                end
            end
        end
    end)
end
-- end post-init hack block


local FxDelayyyy = fx:new{
    subpath = "/fx_delayyyy"
}

local rate_value = {1/16, 1/12, 3/32, 1/8, 1/6, 3/16, 1/4, 1/3, 3/8, 1/2, 2/3, 3/4, 1}
local rate_option = {"1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4","1/3", "3/8", "1/2", "2/3", "3/4", "1"}

function FxDelayyyy:add_params()
    params:add_group("fx_delayyyy", "fx delayyyy", 8)
    FxDelayyyy:add_slot("fx_delayyyy_slot", "slot")
    params:add_option("fx_delayyyy_rate", "rate", rate_option, 6)
    params:set_action("fx_delayyyy_rate", function(idx) params:set("fx_delayyyy_time", rate_value[idx] * clock.get_beat_sec() * 4) end)
    FxDelayyyy:add_taper("fx_delayyyy_time", "time", "time", 0.01, 4, 0.5, 1, "s")
    FxDelayyyy:add_taper("fx_delayyyy_feedback", "feedback", "feedback", 0, 1, 0.6, 1, "")
    FxDelayyyy:add_taper("fx_delayyyy_lp", "lp", "lp", 20, 16000, 2000, 2, "hz")
    FxDelayyyy:add_taper("fx_delayyyy_hp", "hp", "hp", 20, 16000, 400, 2, "hz")
    FxDelayyyy:add_taper("fx_delayyyy_mod", "mod depth", "mod", 0, 100, 0, 1, "%")
end

mod.hook.register("script_post_init", "fx delayyyy mod post init", function()
    FxDelayyyy:add_params()
end)

mod.hook.register("script_post_cleanup", "delayyyy mod post cleanup", function()
end)

return FxDelayyyy
