local utils = require 'resty.utils'
local config = require 'elb.config'
local string = require 'string'
local rules = ngx.shared.rules

local function detail()
    local rules = ngx.shared.rules
    local keys = rules:get_keys()
    local result = {}
    for i = 1, #keys do
        local key = keys[i]
        local domain = utils.real_key(key)
        result[domain] = cjson.decode(rules:get(key))
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, result)
end

local function put()
    local data = utils.read_data()
    local domains = cjson.decode(data) 
    for domain, rule in pairs(domains) do
        local key = string.format(config.DOMAIN_KEY, config.NAME, domain)
        rules:set(key, cjson.encode(rule))
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, "OK")
end

if ngx.var.request_method == 'GET' then 
    detail()
elseif ngx.var.request_method == 'PUT' then
    put()
else
    utils.say_msg_and_exit(ngx.HTTP_FORBIDDEN, "")
end