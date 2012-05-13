#library("dart-redis test suites");

#import('test_helper.dart');
#import('../vendor/dahlia/src/dahlia.dart');

#import('../src/redis.dart');
#import('dart:utf');

class MockRedisConnection {
	String hostname;
	MockRedisConnection(this.hostname);
}
class MockRedisConnectionFactory {
	MockRedisConnection build(hostname) {
		return new MockRedisConnection(hostname);
	}
}

testSuites() {
	describe("Redis.connect", () {

		RedisConnection conn;

		beforeEach(() {
			Redis.connectionFactory = new MockRedisConnectionFactory();
			conn = Redis.connect("localhost");
		});

		it("should return a connection", () => expect(conn).to(not(beNull())));

		it("should be connecting to the right hostname", () => expect(conn.hostname).to(equal("localhost")));
	});

	describe("RedisConnection", () {
		RedisConnection conn;

		beforeEach(() => conn = new RedisConnection("localhost"));

		it('should be connected', () => expect(conn.connected).to(beTrue()));

		describe("after disconnecting", () {
			beforeEach(() => conn.close());

			it('should not be connected', () => expect(conn.connected).to(beFalse()));
		});
		
		describe("setting a key", () {
			beforeEach(() => conn.set("test", "value1"));

			it("should set the key in redis", () {
			  var ret_val;
			  
			  conn.get("test", (val) => ret_val = val);
	      expect(ret_val).to(equal("value1"));			  
			});
		});
	});

	describe("RedisCoder", () {

		it("should encode a message", () {
			expect(RedisCoder.encode(["PING"])).to(beEquivalent(encodeUtf8("*1\r\n\$4\r\nPING\r\n")));
		});
	});
}