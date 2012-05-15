#library("Dart Redis client");

#import("dart:io");
#import("dart:utf");

#source("redis-connection.dart");
#source("redis-coder.dart");

class Redis {
	static Future<RedisConnection> connect(hostname) {
		Completer completer = new Completer();
		completer.complete(new RedisConnection(hostname));
		return completer.future;
	}
}