local string = require 'string'
local etcd = require 'resty.etcd'
local lock = require 'resty.lock'
local config = require 'elb.config'

local etcd_client = etcd:new(config.ETCD)
local rules = ngx.shared.rules

function load_data()
    local mutex = lock:new('locks', {timeout = 0})
    local es, err = mutex:lock('load_data')
    if not es then
        ngx.log(ngx.NOTICE, 'load data in another worker ')
        return
    elseif err then
        ngx.log(ngx.ERR, err)
        return
    end

    local rules_key = string.format(config.RULES_KEY, config.NAME)
    local data = etcd_client:get(rules_key)
    if not data or not data['node'] or not data['node']['nodes'] then
        ngx.log(ngx.ERR, 'no data')
        return
    end
    data = data['node']['nodes']
    for i = 1, #data do
        local value = data[i]['value']
        local key = data[i]['key']
        rules:set(key, value)
    end
    mutex:unlock()
end

ngx.timer.at(0, load_data)