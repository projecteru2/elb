local _M = {}
local string = require 'string'

function _M.process(params)
    local ua, pattern = ngx.var.http_user_agent, params['pattern']
    if not ua then
        return false, nil
    end
    local ua = string.lower(ua)
    ngx.log(ngx.ERR, ua..' '..pattern)
    local captured, err = ngx.re.match(ua, pattern)
    if err or not captured then
        return false, err
    end
    return true, nil
end

return _M