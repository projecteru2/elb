local string = require 'string'
local etcd = require 'resty.etcd'
local lock = require 'resty.lock'
local utils = require 'resty.utils'
local config = require 'elb.config'

local etcd_client = etcd:new(config.ETCD)
local rules = ngx.shared.rules

local function dump_data()
    local mutex = lock:new('locks', {timeout = 0})
    local es, err = mutex:lock('load_data')
    if not es then
        ngx.log(ngx.NOTICE, 'load data in another worker')
        return
    elseif err then
        ngx.log(ngx.ERR, err)
        return
    end

    -- dump value from shared.DICT `rules` to etcd
    etcd_client:recursively_delete(string.format(config.RULES_KEY, config.NAME))
    local rule_keys = rules:get_keys(0)
    for _, rule_key in ipairs(rule_keys) do
        local rule = rules:get(rule_key)
        if rule ~= nil then
            etcd_client:set(rule_key, ngx.escape_uri(rule))
        end
    end

    -- dump value from `upstream` to etcd
    etcd_client:recursively_delete(string.format(config.UPSTREAMS_KEY_R, config.NAME))
    local upstream = require 'ngx.upstream'
    local upstreams = upstream.get_upstreams()
    for _, up in ipairs(upstreams) do
        local servers, err = upstream.get_servers(up)
        if servers ~= nil and err == nil then
            for _, server in ipairs(servers) do
                local addr = server['addr']
                local additions = {}
                for k, v in pairs(server) do
                    if k ~= 'addr' and k~= 'name' then
                        local r = string.format('%s=%s', k, v)
                        table.insert(additions, r)
                    end
                end
                local addition = table.concat(additions, ' ')
                local key = string.format(config.UPSTREAM_DOMAIN, config.NAME, up, addr)
                etcd_client:set(key, ngx.escape_uri(addition))
            end
        end
    end
    mutex:unlock()
end

return {
    dump = dump_data
}
