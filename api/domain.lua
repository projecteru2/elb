local utils = require 'resty.utils'
local config = require 'elb.config'

local rules = ngx.shared.rules
local keys = rules:get_keys()
local result = {}
for i = 1, #keys do
    local key = keys[i]
    local domain = utils.real_key(key)
    result[domain] = cjson.decode(rules:get(key))
end
utils.say_msg_and_exit(ngx.HTTP_OK, result)