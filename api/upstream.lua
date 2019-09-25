local utils = require 'resty.utils'
local dyups = require 'ngx.dyups'
local string = require 'string'

local function detail()
    local upstream = require 'ngx.upstream'
    local get_servers = upstream.get_servers
    local get_upstreams = upstream.get_upstreams
    local upstreams = get_upstreams()
    local result = {}
    for i = 1, #upstreams do
        local upstream = upstreams[i]
        local servers, err = get_servers(upstream)
        if not servers then
            ngx.log(ngx.ERR, 'failed to get servers in upstream ', upstream)
        elseif err then
            ngx.log(ngx.ERR, err)
        else
            result[upstream] = servers
        end
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, result)
end

local function put()
    local data = utils.read_data()
    local upstreams = cjson.decode(data)
    local server_pattern = "server %s %s;"
    for backend_name, servers in pairs(upstreams) do
        local parts = {}
        for ip_port, addition in pairs(servers) do
            table.insert(parts, string.format(server_pattern, ip_port, addition))
        end
        local servers_str = table.concat(parts, '\n')
        if not utils.set_upstream(backend_name, servers_str) then
            ngx.log(ngx.ERR, 'update upstream failed ', upstream)
        end
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, 'OK')
end

local function delete()
    local data = utils.read_data()
    local upstreams = cjson.decode(data)
    local result = {}
    for i = 1, #upstreams do
        local upstream = upstreams[i]
        local status, err = dyups.delete(upstream)
        if status ~= ngx.HTTP_OK then
            ngx.log(ngx.ERR, 'delete upstream failed ', upstream, err)
            result[upstream] = status
        else
            result[upstream] = true
        end
    end
    utils.say_msg_and_exit(ngx.HTTP_OK, result)
end

if ngx.var.request_method == 'GET' then
    detail()
elseif ngx.var.request_method == 'PUT' then
    put()
elseif ngx.var.request_method == 'DELETE' then
    delete()
else
    utils.say_msg_and_exit(ngx.HTTP_FORBIDDEN, '')
end
