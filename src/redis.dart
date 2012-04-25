#library("Dart Redis client");

#import("dart:io");

class Redis {
	static RedisConnection connect(hostname) {
		return new RedisConnection(hostname);
	}
}

class RedisConnection {
	String hostname;
	bool _connected;
	Socket _conn;

	bool get connected()	=> _connected;

	RedisConnection(this.hostname) {
		_connected = true;
		_conn = new Socket(hostname, 6379);
	}
	
	RedisConnection set(String key, String value) {
	  // dummy
	  return this;
	}
	
	Future cmd(List<String> args) {
    Completer completer = new Completer<String>();
    Future future = completer.future;
    completer.complete(["value1"]);
    
    return future;
	}
	
	RedisConnection get(String key, void onComplete(String)) {
	  cmd(["GET", key]).then((results) => onComplete(results[0]));
	  
	  return this;
	}
	
	void _getCallback() {
	  
	}

	close() {
	  _conn.close();
		_connected = false;
	}
}