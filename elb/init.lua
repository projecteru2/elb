statsd = require 'resty.statsd'
cjson = require 'cjson'
string = require 'string'
etcd = require 'resty.etcd'
config = require 'elb.config'
etcd_client = etcd:new(config.ETCD)