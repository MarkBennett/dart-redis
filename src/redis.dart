#library("Dart Redis client");

#import("dart:io");
#import("dart:utf");

#source("redis-coder.dart");

class RedisClient {
	Completer<RedisClient> _connectCompleter;
	Future<RedisClient> get connect() => _connectCompleter.future;

	Socket socket;
	RedisCoder coder;

	RedisClient(host, [Socket socket, RedisCoder coder]) {
		if (null == socket) {
			socket = new Socket(host, 3000);
		}
		this.socket = socket;

		if (null == coder) {
			coder = new RedisCoder();
		}
		this.coder = coder;

		_connectCompleter = new Completer<RedisClient>();
		socket.onConnect = () => _connectCompleter.complete(this);
	}

	Future<List> cmd(String cmd, [List<String> args]) {
		if (null == args) {
			args = new List();
		}

		List new_args = new List();
		new_args.add(cmd);
		new_args.addAll(args); 
		List arg_bytes = new_args.map((arg) => encodeUtf8(arg));

		List<int> message_bytes = coder.encode(arg_bytes);

		socket.outputStream.write(message_bytes);
	}
}