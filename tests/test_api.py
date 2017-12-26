# -*- coding: utf-8 -*-


def test_upstream_api(elb_client):
    assert elb_client.get_upstream() == {}
