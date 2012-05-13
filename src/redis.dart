#library("Dart Redis client");

#import("dart:io");
#import("dart:utf");

#source("redis-connection.dart");
#source("redis-coder.dart");

class Redis {
	static var connectionFactory;

	static RedisConnection connect(hostname) {
		if (!connectionFactory) {
			connectionFactory = new RedisConnectionFactory();
		}
		return connectionFactory.build(hostname);
	}
}

class RedisConnectionFactory {
	RedisConnection build(String hostname) {
		return new RedisConnection(hostname);
	}
}