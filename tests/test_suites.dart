#library("dart-redis test suites");

#import('test_helper.dart');
#import('../vendor/dahlia/src/dahlia.dart');

#import('../src/redis.dart');
#import('dart:utf');

testSuites() {
	describe("Redis.connect", () {
		Future<RedisConnection> future;
		RedisConnection conn;

		beforeEach(() {
			future = Redis.connect("localhost");
			future.then((connection) => conn = connection );
		});

		it("should return a future", () => expect(future).to(not(beNull())));

		it("should set the hostname on the connection", () => expect(conn.hostname).to(equal("localhost")));
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

		it("should encode a single argument message", () {
			expect(RedisCoder.encode(["PING"])).to(beEquivalent(encodeUtf8("*1\r\n\$4\r\nPING\r\n")));
		});
		it("should encode a multi argment methd", () {
			expect(RedisCoder.encode(["SET", "mykey", "myvalue"])).to(beEquivalent(encodeUtf8("*3\r\n\$3\r\nSET\r\n\$5\r\nmykey\r\n\$7\r\nmyvalue\r\n")));
		});
	});
}