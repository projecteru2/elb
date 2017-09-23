local _M = {}

function _M.split(str, separator, max, regex)
    assert(separator ~= '')
    assert(max == nil or max >= 1)

    local record = {}

    if str:len() > 0 then
        local plain = not regex
        max = max or -1

        local field=1 start=1
        local first, last = str:find(separator, start, plain)
        while first and max ~= 0 do
            record[field] = str:sub(start, first - 1)
            field = field + 1
            start = last + 1
            first, last = str:find(separator, start, plain)
            max = max - 1
        end
        record[field] = str:sub(start)
    end

    return record
end

-- 拿第一级path
function _M.get_first_path(uri)
    local first_path = '/'
    if uri ~= '/' then
        first_path = _M.split(uri, '/', 2)[2]
    end
    return first_path
end

function _M.read_data()
    ngx.req.read_body()
    local data = _M.cjson.decode(ngx.req.get_body_data())
    if not data then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    return data
end

function _M.say_msg_and_exit(status, message)
    if type(message) == 'table' then
        ngx.say(_M.cjson.encode(message))
    else
        ngx.say(_M.cjson.encode({msg=message}))
    end
    ngx.exit(ngx.status)
end

return _M
