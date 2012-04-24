#library("Dart Redis client");

class Redis {
	static RedisConnection connect(hostname) {
		return new RedisConnection(hostname);
	}
}

class RedisConnection {
	String hostname;
	RedisConnection(this.hostname);
}