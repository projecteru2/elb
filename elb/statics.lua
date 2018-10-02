local args, err = ngx.req.get_uri_args()
if err ~= nil then
    ngx.log(ngx.ERR, 'get args failed', err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
ngx.var.path = args["path"]
if args["expires"] ~= nil then
    ngx.var.expires = args["expires"]
end