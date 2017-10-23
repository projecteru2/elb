local _M = {}
local keyPrefix = "/v2/keys"
local cjson = require 'cjson'
local http = require "resty.http"
local string = require 'string'

function _M:new(url)
    local c = {}
    setmetatable(c, self)
    self.__index = self
    c.base_url = url or "http://127.0.0.1:2379"
    return c
end

function _M:_keyURL(key)
    return self.base_url .. keyPrefix .. key
end

function _M:_handleRequest(res)
    if res.status ~= ngx.HTTP_OK and res.status ~= ngx.HTTP_CREATED then
        ngx.log(ngx.ERR, res.body)
        return nil
    end
    return cjson.decode(res.body)
end

function _M:get(key)
    local url = self:_keyURL(key)
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {method = "GET"})
    if not res and err then
        ngx.log(ngx.ERR, err)
        return nil
    end
    return self:_handleRequest(res)
end

function _M:set(key, value)
    local url = self:_keyURL(key)
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {
        method = "PUT",
        body = string.format('value=%s', value),
        headers = {
          ['Content-Type'] = 'application/x-www-form-urlencoded',
        }
    })
    if not res and err then
        ngx.log(ngx.ERR, err)
        return nil
    end
    return self:_handleRequest(res)
end

function _M:delete(key)
    local url = self:_keyURL(key)
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {method = "DELETE"})
    if not res and err then
        ngx.log(ngx.ERR, err)
        return nil
    end
    return self:_handleRequest(res)
end

function _M:recursively_delete(key)
    local url = self:_keyURL(key)
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {method = "DELETE", query='?recursive=true'})
    if not res and err then
        ngx.log(ngx.ERR, err)
        return nil
    end
    return self:_handleRequest(res)
end

return _M
