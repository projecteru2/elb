# -*- coding: utf-8 -*-
import pytest
import requests
import subprocess
import time

import elb as elbpy


TEST_ELB_ADDRESS = '127.0.0.1:18888'


@pytest.fixture(scope='session')
def elb_client(request):
    etcd_cmd = 'docker run --name elb_pytest_etcd --detach --rm elcolio/etcd:latest'
    assert subprocess.call(etcd_cmd.split()) == 0

    elb_cmd = 'docker run --name elb_pytest_instance --link elb_pytest_etcd --detach --rm --publish {}:80 --env ETCD_HOST=elb_pytest_etcd projecteru2/elb:latest'.format(TEST_ELB_ADDRESS)
    assert subprocess.call(elb_cmd.split()) == 0
    # wait until ELB is alive
    elb_url = 'http://{}'.format(TEST_ELB_ADDRESS)
    tries = 3
    while tries:
        try:
            requests.get(elb_url, timeout=0.5)
            break
        except requests.exceptions.RequestException as e:
            print('ELB not alive yet: {}'.format(e))
            time.sleep(1)
            tries -= 1

    def tear_down():
        cmd = 'docker rm -f elb_pytest_instance elb_pytest_etcd'
        assert subprocess.call(cmd.split()) == 0

    request.addfinalizer(tear_down)
    return elbpy.ELB('http://{}'.format(TEST_ELB_ADDRESS))
