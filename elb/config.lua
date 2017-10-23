local _M = {}

_M.NAME = os.getenv("ELBNAME") or 'ELB'
_M.ETCD = os.getenv("ETCD") or 'http://127.0.0.1:2379'
_M.STATSD = os.getenv("STATSD")
_M.STATSD_FORMAT = _M.NAME..'.%s.%s'

_M.RULES_KEY = '/%s/rules'
_M.DOMAIN_KEY = '/%s/rules/%s'
_M.UPSTREAMS_KEY  = '/%s/upstreams?recursive=true'
_M.UPSTREAMS_KEY_R  = '/%s/upstreams'
_M.UPSTREAM_DOMAIN = '/%s/upstreams/%s/%s'
return _M
