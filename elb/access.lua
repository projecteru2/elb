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
        "r0": {
            "args": {
                "path": "/tmp/statics",
                "expires": "30d"
            },
            "type": "statics"
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
elseif args["path"] ~= nil then
    local params, err = ngx.req.get_uri_args()
    if err ~= nil then
        ngx.log(ngx.ERR, 'get args failed ', err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    params["path"] = args["path"]
    if args["expires"] ~= nil then
        params["expires"] = args["expires"]
    end
    ngx.req.set_uri_args(params)
    ngx.var.backend = "127.0.0.1:7070"
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end