local _M = {}

local function get_etcd()
    local etcd_url = os.getenv("ETCD_URL") or os.getenv("ETCD")
    if etcd_url == nil then
        local etcd_host = os.getenv("ETCD_HOST") or "127.0.0.1"
        local etcd_port = os.getenv("ETCD_PORT") or "2379"
        return "http://"..etcd_host..":"..etcd_port
    end
    return etcd_url
end

_M.NAME = os.getenv("ELBNAME") or 'ELB'
-- _M.ETCD = os.getenv("ETCD") or 'http://127.0.0.1:2379'
_M.ETCD = get_etcd()
_M.STATSD = os.getenv("STATSD")
_M.STATSD_FORMAT = _M.NAME..'.%s.%s'

_M.RULES_KEY = '/%s/rules'
_M.DOMAIN_KEY = '/%s/rules/%s'
_M.UPSTREAMS_KEY  = '/%s/upstreams?recursive=true'
_M.UPSTREAMS_KEY_R  = '/%s/upstreams'
_M.UPSTREAM_DOMAIN = '/%s/upstreams/%s/%s'
return _M
