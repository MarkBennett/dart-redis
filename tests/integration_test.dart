#library("Run dart-redis integration tests");

#import('../src/redis.dart');

main() {
	print("Connecting to Redis...");
	new RedisClient("localhost").connect.then(on_connect);
}

on_connect(client) {
	print("Connected!");

	// Set then get a key
	String key = "mykey";
	print("Setting key value of, \"$key\" to, \"hello\".");
	client.cmd("set", [key, "hello"]);
	print("Retrieving key...");
	String retrieved = client.cmd("get", [key])[0];
	print("the value of \"$key\" was, \"$retrieved\"");

	exit(0);
}