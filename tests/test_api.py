# -*- coding: utf-8 -*-

import pytest
from elb import UpStream, ELBRuleError
from elb import UARule, PathRule, BackendRule, RuleSet


def test_rule():
    ua = UARule('ua', 'test$', 'backend1', 'path')
    path = PathRule('path', '/path1', False, False, 'backend2', 'backend1')
    rs1 = RuleSet('ua', [ua, path])
    assert not rs1.check_rules()
    with pytest.raises(ELBRuleError):
        rs1.dump()

    backend1 = BackendRule('backend1', {'up1': ''})
    backend2 = BackendRule('backend2', {'up2': ''})
    rs2 = RuleSet('ua', [ua, path, backend1, backend2])
    assert rs2.check_rules()
    assert rs2.dump()


def test_upstream_api(elb_client):
    assert elb_client.get_upstream() == {}
    up1 = UpStream('up1', {'127.0.0.1:5000': ''})
    up2 = UpStream('up2', {'127.0.0.1:5001': ''})
    assert elb_client.set_upstream(up1)['msg'] == 'OK'
    assert elb_client.set_upstream(up2)['msg'] == 'OK'
    ups = elb_client.get_upstream()
    assert len(ups) == 2
    assert len(ups['up1']) == 1
    assert len(ups['up2']) == 1
