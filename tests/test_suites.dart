#library("dart-redis test suites");

#import('../vendor/dahlia/src/dahlia.dart');
#import('../src/redis.dart');

testSuites() {
	describe("Redis.connect", () {
		it("should return a connection", () => expect(Redis.connect("localhost")).to(not(beNull())));
	});
}