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
			client = new RedisClient("localhost", new MockSocket());
			future = client.connect;
			future.then((client) => callback_client = client );
		});

		it("should return a future", () => expect(future).to(not(beNull())));

		it("should invoke the future with the client after connecting", () => expect(callback_client).to(equal(client)));
	});

	describe("RedisCoder", () {

		it("should encode a single argument message", () {
			expect(RedisCoder.encode(["PING"])).to(beEquivalent(encodeUtf8("*1\r\n\$4\r\nPING\r\n")));
		});
		it("should encode a multi argument message", () {
			expect(RedisCoder.encode(["SET", "mykey", "myvalue"])).to(beEquivalent(encodeUtf8("*3\r\n\$3\r\nSET\r\n\$5\r\nmykey\r\n\$7\r\nmyvalue\r\n")));
		});
		
		it("should decode a multi argument message", () {
		  expect(RedisCoder.decode(encodeUtf8("*3\r\n\$3\r\nSET\r\n\$5\r\nmykey\r\n\$7\r\nmyvalue\r\n"))).
		 	to(beEquivalent([encodeUtf8("SET"), encodeUtf8("mykey"), encodeUtf8("myvalue")]));
		});
		it("should decode a single argument message", () {
		  expect(RedisCoder.decode(encodeUtf8("*1\r\n\$4\r\nPONG\r\n"))).to(beEquivalent([encodeUtf8("PONG")]));
		});
	});
}

class MockSocket {
	void set onConnect(void callback()) {
		// Connect immediately
		callback();
	}
}