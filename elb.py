# coding: utf-8

import random
import requests


class ELBError(Exception):
    pass


class ELBRespError(ELBError):
    pass


class ELBRuleError(ELBError):
    pass


class Rule(object):

    def next(self):
        return []

    def dump(self):
        return {}


class UARule(Rule):
    """User-Agent rule checks if user-agent matches `pattern`,
    if success, next rule will be `succ` to process, otherwise `fail` will
    be the next."""

    def __init__(self, name, pattern, succ, fail):
        self.name = name
        self.pattern = pattern
        self.succ = succ
        self.fail = fail

    def next(self):
        return [self.succ, self.fail]

    def dump(self):
        return {
            'type': 'ua',
            'args': {
                'succ': self.succ,
                'fail': self.fail,
                'pattern': self.pattern,
            },
        }


class BackendRule(Rule):
    """Backend rule is the destination of all rules.
    `servername` will be passed to nginx `proxy_pass`.
    `servername` can be either a name of `upstream`,
    or an IP address directly to proxy pass.
    """

    def __init__(self, name, servername):
        self.name = name
        self.servername = servername

    def dump(self):
        return {
            'type': 'backend',
            'args': {
                'servername': self.servername,
            },
        }


class PathRule(Rule):
    """Path rule checks if requested path matches `pattern`, `regex` can be
    set to True to indicate that `pattern` is used as a regex.
    `rewrite` and `rewrite` can be used to set `rewrite` in nginx.
    """

    def __init__(self, name, pattern, regex, rewrite, succ, fail):
        self.name = name
        self.pattern = pattern
        self.regex = bool(regex)
        self.rewrite = bool(rewrite)
        self.succ = succ
        self.fail = fail

    def next(self):
        return [self.succ, self.fail]

    def dump(self):
        return {
            'type': 'path',
            'args': {
                'succ': self.succ,
                'fail': self.fail,
                'pattern': self.pattern,
            },
        }


class RuleSet(object):
    """a set of rules"""

    def __init__(self, init, rules):
        self.init = init
        self.rules = rules

    def check_rules(self):
        """
        1. `init` must be in one of the rules
        2. if any rule has a `succ` or `fail`, must be in one of the rules
        """
        rulenames = set([rule.name for rule in self.rules])
        next_rulenames = set([name for rule in self.rules for name in rule.next()])
        return self.init in rulenames and next_rulenames.issubset(rulenames)

    def dump(self):
        if not self.check_rules():
            raise ELBRuleError('Error in rules')
        rules = {r.name: r.dump() for r in self.rules}
        return {'init': self.init, 'rules': rules}


class UpStream(object):
    """upstream for nginx.
    `servers` is a dict, key in format `IP:port`, value as a string.
    value will be set as additional info for nginx upstream such like `weight=10`.
    """

    def __init__(self, backendname, servers):
        self.backendname = backendname
        self.servers = servers

    def dump(self):
        return {self.backendname: self.servers}


class ELB(object):

    def __init__(self, base):
        if not base.startswith('http://'):
            base = 'http://' + base
        self.base = base
        self.session = requests.Session()

    def req(self, method, url, params=None, json=None):
        resp = self.session.request(method, url=url, params=params, json=json)
        if resp.status_code != 200:
            raise ELBRespError(resp.content)
        return resp.json()

    def get_upstream(self):
        url = self.base + '/__erulb__/upstream'
        return self.req('GET', url)

    def add_upstream(self, upstream):
        url = self.base + '/__erulb__/upstream'
        return self.req('PUT', url, json=upstream.dump())

    def delete_upstream(self, upstreams):
        url = self.base + '/__erulb__/upstream'
        return self.req('DELETE', url, json=upstreams)

    def get_domain_rules(self):
        url = self.base + '/__erulb__/domain'
        return self.req('GET', url)

    def set_domain_rules(self, domain, ruleset):
        url = self.base + '/__erulb__/domain'
        json = {domain: ruleset.dump()}
        return self.req('PUT', url, json=json)

    def delete_domain_rules(self, domains):
        url = self.base + '/__erulb__/domain'
        return self.req('DELETE', url, json=domains)

    def dump_to_etcd(self):
        url = self.base + '/__erulb__/dump'
        return self.req('PUT', url)


class ELBSet(object):
    """a set of ELB instances, they share the same etcd"""

    def __init__(self, bases):
        self.elbs = [ELB(b) for b in bases]

    def __getattr__(self, name):
        """`get_upstream`, `get_domain_rules`, `dump_to_etcd` only need to call one of these instances.
        other methods will need to call every instance of els.
        """
        if name in ('get_upstream', 'get_domain_rules', 'dump_to_etcd'):
            e = random.choice(self.elbs)
            return getattr(e, name)

        elbs = self.elbs
        def method(*args, **kwargs):
            for e in elbs:
                m = getattr(e, name)
                m(*args, **kwargs)
        return method
