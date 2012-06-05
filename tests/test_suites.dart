#library("dart-redis test suites");

#import('test_helper.dart');
#import('../vendor/dahlia/src/dahlia.dart');

#import('../src/redis.dart');
#import('dart:utf');
#import('dart:io');

// A typical session using the Redis client goes like this
//
// new RedisClient("localhost").connect.then((client) => client.ping());
testSuites() {
	describe("RedisClient", () {
		Future<RedisClient> future;
		RedisClient client;
		var callback_client;

		beforeEach(() {
			client = new RedisClient("localhost", socket: new MockSocket(), coder: new MockCoder());
			future = client.connect;
			future.then((client) => callback_client = client );
		});

		it("should return a future", () => expect(future).to(not(beNull())));

		it("should invoke the future with the client after connecting", () => expect(callback_client).to(equal(client)));

		describe(".cmd()", () {

			beforeEach(() {
				client = new RedisClient("localhost", socket: new MockSocket(), coder: new MockCoder());
				future = client.connect;
				future.then((client) => callback_client = client );
			});

			it("should allow users to send a command without arguments to the server", () {
				client.cmd("PING");
				expect(client.coder.lastArgsToEncode).to(beEquivalent([encodeUtf8("PING")]));
			});
			it("should allow users to send a command with multiple arguments to the server", () {
				client.cmd("SET", ["mykey", "\"hello\""]);
				expect(client.coder.lastArgsToEncode).
					to(beEquivalent([encodeUtf8("SET"), encodeUtf8("mykey"), encodeUtf8("\"hello\"")]));
			});
			it("should write the encoded arguments to the redis socket", () {
				client.coder.encodeOutput = [1,2,3];

				client.cmd("SET", ["arg1", "arg2", "arg3"]);

				expect(client.socket.receivedBytes).to(beEquivalent([1, 2, 3]));
			});
			it("should return the decoded results", () {
				client.coder.decoded_output = [encodeUtf8("hello")];

				List results;
        client.cmd("GET", ["mykey"]).then((res) => results = res);

				expect(results).to(beEquivalent(["hello"]));
			});
		});
	});

	describe("RedisCoder", () {
		RedisCoder coder;

		beforeEach(() {
			coder = new RedisCoder();
		});

		it("should encode a single argument message", () {
			expect(coder.encode([encodeUtf8("PING")])).
				to(beEquivalent(encodeUtf8("*1\r\n\$4\r\nPING\r\n")));
		});
		it("should encode a multi argument message", () {
			expect(coder.encode([encodeUtf8("SET"), encodeUtf8("mykey"), encodeUtf8("myvalue")])).
				to(beEquivalent(encodeUtf8("*3\r\n\$3\r\nSET\r\n\$5\r\nmykey\r\n\$7\r\nmyvalue\r\n")));
		});
		
		it("should decode a multi argument message", () {
		  	expect(coder.decode(encodeUtf8("*3\r\n\$3\r\nSET\r\n\$5\r\nmykey\r\n\$7\r\nmyvalue\r\n"))).
		 		to(beEquivalent([encodeUtf8("SET"), encodeUtf8("mykey"), encodeUtf8("myvalue")]));
		});
		it("should decode a single argument message", () {
		  	expect(coder.decode(encodeUtf8("*1\r\n\$4\r\nPONG\r\n"))).
		  		to(beEquivalent([encodeUtf8("PONG")]));
		});
		it("should decode a standard get response", () {
			// This response was taken from Wireshark
			// The original response bytes were 24:35:0d:0a:68:65:6c:6c:6f:0d:0a
			expect(coder.decode(encodeUtf8("\$5\r\nhello\r\n"))).
				to(beEquivalent([encodeUtf8("hello")]));
		});
	});
}

List encodeListAsUtf8(List<String> input) => input.map((elem) => encodeUtf8(elem));

class MockSocket {
	List<int> get receivedBytes() => _output.contents();

	OutputStream _output;
	OutputStream get outputStream() => _output;

	InputStream _input;
	InputStream get inputStream() => _input;
	List<int> _bytesToSend;
	List<int> set bytesToSend(List<int> bytes) {
		_bytesToSend = bytes;
		_input = new ListInputStream();
		_input.write(bytes);
		_input.markEndOfStream();
	}
	List<int> get bytesToSend() => _bytesToSend;

	MockSocket() {
		_output = new ListOutputStream();
		bytesToSend = [43];
	}
	void set onConnect(void callback()) {
		// Connect immediately
		callback();
	}
  void set onData(void callback()) {
		// Connect immediately
		callback();
  }
	int available() {
		return 1;
	}
}

class MockCoder {
	List<int> encodeOutput;
	List decoded_output;

	List lastArgsToEncode;
	List<int> lastBytesToDecode;

	MockCoder() {
		encodeOutput = new List<int>();
		decoded_output = new List();
	}

	List encode(args) {
		lastArgsToEncode = args;
		return encodeOutput;
	}
	List decode(bytes) {
		lastBytesToDecode = bytes;
		return decoded_output;
	}
  Future<List> readMessage(InputStream stream) {
    Completer on_message = new Completer();

    on_message.complete(decoded_output);

    return on_message.future;
  } 
}
