# coding: utf-8

from elb import ELB
from elb import UARule, PathRule, BackendRule, RuleSet
from elb import UpStream


c = ELB('127.0.0.1:8080')

# rules
ua = UARule('ua', 'test$', 'backend1', 'path')
path = PathRule('path', '/path1', False, False, 'backend2', 'backend1')
backend1 = BackendRule('backend1', {'up1': ''})
backend2 = BackendRule('backend2', {'up2': ''})
ruleset = RuleSet('ua', [ua, path, backend1, backend2])

# upstreams
up1 = UpStream('up1', {'127.0.0.1:5000': ''})
up2 = UpStream('up2', {'127.0.0.1:5001': ''})

# set rules
c.set_domain_rules('test.local', ruleset)

# add upstreams
c.add_upstream(up1)
c.add_upstream(up2)
