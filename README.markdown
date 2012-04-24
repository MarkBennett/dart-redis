# dart-redis

This library provides a redis client for Dart.

# How to use it

You start by opening a connection to the redis server

    RedisConnection conn = Redis.connect("localhost");

You can then issue commands against the connect. Each command returns a Future
that can be used to trigger a callback and respond to errors.

    conn.cmd("get", ["my-key"]).then((reply) -> print "#{reply[0]}");

Some commands also have shortcuts to make them easier to use.

    conn.put("my-key", "Hello, World");
    conn.get("my-key", (val) -> print "#val");	// "Hello, World!"
