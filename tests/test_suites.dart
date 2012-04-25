#library("dart-redis test suites");

#import('../vendor/dahlia/src/dahlia.dart');
#import('../src/redis.dart');

testSuites() {
	describe("Redis.connect", () {
		RedisConnection conn;

		beforeEach(() => conn = Redis.connect("localhost"));

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
}