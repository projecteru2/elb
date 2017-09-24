local _M = {}

_M.NAME = os.getenv("ELBNAME") or 'ELB'
_M.DOMAIN_KEY = '%s/rules/%s'

_M.ETCD = os.getenv("ETCD") or 'http://127.0.0.1:2379'

return _M