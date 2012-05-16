#library("dart-redis test suites");

#import('test_helper.dart');
#import('../vendor/dahlia/src/dahlia.dart');

#import('../src/redis.dart');
#import('dart:utf');

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
			it("should allow users to send a command without arguments to the server", () {
				client.cmd("PING");
				expect(client.coder.lastArgs).to(beEquivalent([encodeUtf8("PING")]));
			});
			it("should allow users to send a command with multiple arguments to the server", () {
				client.cmd("SET", ["mykey", "\"hello\""]);
				expect(client.coder.lastArgs).
					to(beEquivalent([encodeUtf8("SET"), encodeUtf8("mykey"), encodeUtf8("\"hello\"")]));
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
		  	expect(coder.decode(encodeUtf8("*1\r\n\$4\r\nPONG\r\n"))).to(beEquivalent([encodeUtf8("PONG")]));
		});
	});
}

List encodeListAsUtf8(List<String> input) => input.map((elem) => encodeUtf8(elem));

class MockSocket {
	void set onConnect(void callback()) {
		// Connect immediately
		callback();
	}
}

class MockCoder {
	List lastArgs;

	List encode(args) {
		lastArgs = args;
	}

}