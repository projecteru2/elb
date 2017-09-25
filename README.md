rule: {
    "init":name,
    "rules": {
        name1: {"type": ua, args:{"pattern": xxx, "succ": name2, "fail": name3}},
        name2: {"type": path, args:{"pattern": xxx, "regex": true|false, rewrite: true|false, succ: name2, "fail": name3}},
        name3: {"type": backend, args:{"servername": xx}},
    }
}

{
    "up1":{"xx": "someting", "xxx": "someting"},
    "up2":{"aaa":"", "bbb":""}
}
