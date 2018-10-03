local _M = {}
local string = require 'string'

-- regex disable in default
function _M.process(params)
    local path, pattern = ngx.var.uri, params['pattern'] 
    local regex, rewrite = params['regex'] or false, params['rewrite'] or false
    local ret, sub_path
    if not regex then
        ret = _M.no_regex(path, pattern)
    else
        ret, sub_path = _M.regex(path, pattern)
    end
    if not ret then
        return false, nil
    end
    if ret and regex and rewrite then
        ngx.req.set_uri(sub_path)
    end
    return true, nil
end

function _M.no_regex(path, pattern)
    -- prefix check
    return string.sub(path, 1, string.len(pattern)) == pattern
end

function _M.regex(path, pattern)
    -- regex check
    ngx.log(ngx.ERR, path..' '..pattern)
    local captured, err = ngx.re.match(path, pattern)
    if err then
        return false, nil
    end
    if captured ~= nil and captured[1] then
        return true, captured[1]
    end
    return true, '/'
end

return _M