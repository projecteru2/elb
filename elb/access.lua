local string = require 'string'
local cjson = require 'cjson'

local config = require 'elb.config'
local processor = require 'elb.processor'

local rules = ngx.shared.rules
local key = string.format(config.DOMAIN_KEY, config.NAME, ngx.var.http_host)
local rule = rules:get(key)
if rule == nil then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
--[[
rule: {
    "init": "r1",
    "rules": {
        "r5": {
            "args": {
                "path": "/tmp/statics",
                "expires": "30d",
                "servername": "127.0.0.1:7070"
            },
            "type": "backend"
        },
        "r1": {
            "args": {
                "fail": "r3",
                "pattern": "httpie(\\\\S+)$",
                "succ": "r4"
            },
            "type": "ua"
        },
        "r2": {
            "args": {
                "servername": "127.0.0.1:8088"
            },
            "type": "backend"
        },
        "r3": {
            "args": {
                "servername": "127.0.0.1:8089"
            },
            "type": "backend"
        },
        "r4": {
            "args": {
                "regex": true,
                "pattern": "^\\\\/blog\\\\/(\\\\S+)$",
                "succ": "r2",
                "fail": "r3",
                "rewrite": true
            },
            "type": "path"
        }
    }
}
-- ]]
rule = cjson.decode(rule)
local args, err_code = processor.process(rule)
if err_code ~= nil then
    ngx.exit(err_code)
end

if args["servername"] ~= nil then
    ngx.var.backend = args["servername"]
    args["servername"] = nil
    for k, v in pairs(args) do
        ngx.req.set_header(k, v)
    end
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end