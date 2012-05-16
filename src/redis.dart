#library("Dart Redis client");

#import("dart:io");
#import("dart:utf");

#source("redis-coder.dart");

class RedisClient {
	Completer<RedisClient> _connectCompleter;
	Future<RedisClient> get connect() => _connectCompleter.future;

	Socket _socket;

	RedisClient(host, [Socket socket]) {
		if (null == socket) {
			socket = new Socket(host, 3000);
		}
		_socket = socket;

		_connectCompleter = new Completer<RedisClient>();
		_socket.onConnect = () => _connectCompleter.complete(this);
	}
}