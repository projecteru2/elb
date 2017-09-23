local _M = {}

_M.NAME = os.getenv("ELBNAME") or 'ELB'
_M.DOMAIN_KEY = '/%s/%s'

return _M