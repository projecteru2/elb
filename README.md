Eru load balance
================
ELB (Eru load balance) is based on [openresty](https://openresty.org/en/). In Eru architecture, we use multiple filters to determine which upstream to forward. And by using [ngx_http_dyups_module](https://github.com/yzprofile/ngx_http_dyups_module), [citadel](https://github.com/citadel) can update upstream dynamically.

### Features

* update upstream dynamically
* run by eru
* custom strategies of network flow

### Storage

ELB will load data from [etcd](https://github.com/coreos/etcd) when starting.

### Rule

In this version, we provide two types of filter. One is for user-agent, another for path. So we design a simple protocol for describing it.

This data will store in etcd with key `/$ELBNAME/rules/$domain`.

For example:

```json
{
    "init": "r1",
    "rules": {
        "r1": {"type": "ua", "args": {"fail": "r3", "pattern": "httpie(\\S+)$", "succ": "r4"}},
        "r2": {"type": "backend", "args": {"servername": "upstrimg1"}},
        "r3": {"type": "backend", "args": {"servername": "upstream2"}},
        "r4": {"type": "path", "args": {"regex": true, "pattern": "^\\/blog\\/(\\S+)$", "succ": "r2", "fail": "r3", "rewrite": false}}
    },
}
```

You can build a complex filter by multiple rules.

### Upstream

Upstream data also store in etcd with key `/$ELBNAME/upstreams/$name`.

For example

```json
{
    "127.0.0.1:8089": "max_fails=2 weight=10",
    "127.0.0.1:8088": ""
}
```

### API

ELB have two APIs for managing.

1. Domain API `/__erulb__/domain`

Only support `GET` method, it will response a json which contains domain and it's rules.

For example:

```
GET /__erulb__/domain HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: 127.0.0.1:8080
User-Agent: HTTPie/0.9.9



HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: application/json
Date: Mon, 25 Sep 2017 09:06:32 GMT
Server: openresty/1.11.2.5
Transfer-Encoding: chunked

{
    "127.0.0.1": {
        "init": "r1",
        "rules": {
            "r1": {
                "args": {
                    "fail": "r3",
                    "pattern": "httpie(\\S+)$",
                    "succ": "r4"
                },
                "type": "ua"
            },
            "r2": {
                "args": {
                    "servername": "up1"
                },
                "type": "backend"
            },
            "r3": {
                "args": {
                    "servername": "up2"
                },
                "type": "backend"
            },
            "r4": {
                "args": {
                    "fail": "r3",
                    "pattern": "^\\/blog\\/(\\S+)$",
                    "regex": true,
                    "rewrite": false,
                    "succ": "r2"
                },
                "type": "path"
            }
        }
    }
}
```

2. Upstream API `/__erulb__/upstream`

If you `GET` this url, elb will response a json which contains upstreams and it's backends like this:

```
GET /__erulb__/upstream HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: 127.0.0.1:8080
User-Agent: HTTPie/0.9.9



HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: application/json
Date: Mon, 25 Sep 2017 09:08:59 GMT
Server: openresty/1.11.2.5
Transfer-Encoding: chunked

{
    "upstream1": [
        {
            "addr": "127.0.0.1:8089",
            "fail_timeout": 10,
            "max_fails": 1,
            "name": "127.0.0.1:8089",
            "weight": 1
        },
        {
            "addr": "127.0.0.1:8088",
            "fail_timeout": 10,
            "max_fails": 1,
            "name": "127.0.0.1:8088",
            "weight": 1
        }
    ],
    "upstream2": [
        {
            "addr": "127.0.0.1:8089",
            "fail_timeout": 10,
            "max_fails": 2,
            "name": "127.0.0.1:8089",
            "weight": 10
        }
    ]
}
```

If you use `PUT` method, you can upload a json with upstreams and it's backends, then ELB will update itself with those upstreams like this:

```
PUT /__erulb__/upstream HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 115
Content-Type: application/json
Host: localhost:8080
User-Agent: HTTPie/0.9.9

{
    "up1": {
        "127.0.0.1:8088": "",
        "127.0.0.1:8089": ""
    },
    "up2": {
        "localhost:8088": "",
        "localhost:8089": ""
    }
}

HTTP/1.1 200 OK
Connection: keep-alive
Content-Type: application/json
Date: Mon, 25 Sep 2017 09:10:58 GMT
Server: openresty/1.11.2.5
Transfer-Encoding: chunked

{
    "msg": "OK"
}
```

### Env

ELB will read `ETCD`, `ELBNAME` and `STATSD` from environment.

If etcd and elbname not set, elb will use `127.0.0.1:2379` and `ELB` as default.

But if `STATSD` not set, elb will not calcuate domain status.

### Dockerized ELB

We suggest you to run elb by ERU, however this [image](https://hub.docker.com/r/projecteru2/elb/) can standalone running.

```shell
docker run -d --privileged \
  --name eru_elb_$HOSTNAME \
  --net host \
  --restart always \
  -e "ETCD=<IP:PORT>" \
  -e "ELBNAME=<ELBNAME>" \
  -e "STATSD=<IP:PORT>" \
  projecteru2/elb
```