local utils = require 'resty.utils'
local dump = require 'elb.dump'

if ngx.var.request_method == 'PUT' then
    dump.dump()
    utils.say_msg_and_exit(ngx.HTTP_OK, 'OK')
else
    utils.say_msg_and_exit(ngx.HTTP_FORBIDDEN, '')
end
