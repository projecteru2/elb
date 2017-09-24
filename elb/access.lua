local string = require 'string'
local cjson = require 'cjson'

local config = require 'elb.config'
local processor = require 'elb.processor'

local rules = ngx.shared.rules
local key = string.format(config.DOMAIN_KEY, config.NAME, ngx.var.host)
-- local rule = rules:get(key)
-- if rule == nil then
--     ngx.exit(ngx.HTTP_NOT_FOUND)
-- end
local rule = '{"rules": {"r4": {"args": {"regex": true, "pattern": "^\\\\/blog\\\\/(\\\\S+)$", "succ": "r2", "fail": "r3", "rewrite": true}, "type": "path"}, "r1": {"args": {"fail": "r3", "pattern": "httpie(\\\\S+)$", "succ": "r4"}, "type": "ua"}, "r2": {"args": {"servername": "127.0.0.1:8088"}, "type": "backend"}, "r3": {"args": {"servername": "127.0.0.1:8089"}, "type": "backend"}}, "init": "r1"}'
local rule = cjson.decode(rule)
local backend, err_code = processor.process(rule)
if err_code ~= nil then
    ngx.exit(err_code)
end
--if backend == nil then
--    ngx.exit(ngx.HTTP_NOT_FOUND)
--end
ngx.var.backend = backend