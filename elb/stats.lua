local string = require 'string'
local statsd = require 'resty.statsd'
local config = require 'elb.config'
local utils = require 'resty.utils'

if not config.STATSD then
    return
end

if ngx.var.backend == '' then
    ngx.log(ngx.ERR, 'invalid domain ', ngx.var.host)
    return
end

local cost = 0
if ngx.var.upstream_response_time then
    for token in string.gmatch(ngx.var.upstream_response_time, '[^,]+') do
        local cost_time = tonumber(token)
        if cost_time then
            cost = cost + cost_time
        end
    end
end

local host = ngx.var.host
-- statsd
local statsd_host = string.gsub(host, '%.', '_')
local statsd_cost = string.format(config.STATSD_FORMAT, statsd_host, 'cost')
local statsd_total = string.format(config.STATSD_FORMAT, statsd_host, 'total')
local statsd_status = string.format(config.STATSD_FORMAT, statsd_host, 'status')

statsd.count(statsd_total, 1)
if ngx.var.upstream_status and ngx.var.upstream_status ~= '-' then
    statsd.count(statsd_status..'.'..ngx.var.upstream_status, 1)
end

if cost then
    statsd.time(statsd_cost, cost*1000) -- 毫秒
end

local function statsd_flush(premature)
    local data = utils.split(config.STATSD, ':')
    statsd.flush(ngx.socket.udp, data[1], data[2])
end

local ok, err = ngx.timer.at(0, statsd_flush)
if not ok then
    ngx.log(ngx.ERR, 'failed to create timer: ', err)
end
