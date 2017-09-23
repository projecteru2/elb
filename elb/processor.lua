local _M = {}
local cjson = require 'cjson'
local filter = {
    ua = require 'filter.ua'
--    path = require 'path'
}

function _M.process(rule)
    local init = rule['init']
    if not init then
        return nil, ngx.HTTP_BAD_REQUEST
    end
    local rules = rule['rules']
    if not rules then
        return nil, ngx.HTTP_BAD_REQUEST
    end
    local typ, args = _M.get_rule(rules, init)
    if not typ or not args then
        ngx.log(ngx.ERR, cjson.encode(rule))
        return nil, ngx.HTTP_BAD_REQUEST
    end
    while typ ~= 'backend' do
        local f = filter[typ]
        if not f then
            return nil, ngx.HTTP_INTERNAL_SERVER_ERROR
        end
        local ret, err = f.process(args)
        if err then
            return nil, ngx.HTTP_INTERNAL_SERVER_ERROR
        end
        local succ, fail = args['succ'], args['fail']
        if ret and succ ~= nil then
            typ, args = _M.get_rule(rules, succ)
        elseif not ret and fail ~= nil then
            typ, args = _M.get_rule(rules, fail)
        end
    end
    -- I hate golang, not check anymore
    return args['servername'], nil
end

function _M.get_rule(rules, name)
    local rule = rules[name]
    local typ, args = rule['type'], rule['args']
    return typ, args
end

return _M