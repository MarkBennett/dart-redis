# dart-redis

This library provides a redis client for Dart.

# How to use it

You start by opening a client which connects to the redis server

    RedisClient client = new RedisClient("localhost");

The client has a connect event which is triggered after the client has
connected to the server.

    client.connect.then((client) {
    	// We're guarenteed to be connected at this point
    	// ...
    });

You can then issue commands against the client. Each command returns a Future
that can be used to trigger a callback and respond to errors.

    conn.cmd("get", ["my-key"]).then((reply) -> print "#{reply[0]}");

Some commands also have shortcuts to make them easier to use.

    conn.set("my-key", "Hello, World");
    conn.get("my-key", (val) -> print "#val");	// "Hello, World!"
