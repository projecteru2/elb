local args, err = ngx.req.get_headers()
if err ~= nil then
    ngx.log(ngx.ERR, 'get header failed', err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
if args["path"] ~= nil then
    ngx.var.path = args["path"]
end
if args["expires"] ~= nil then
    ngx.var.expires = args["expires"]
end