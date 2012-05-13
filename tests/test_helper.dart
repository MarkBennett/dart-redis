#library("dart-redis test suites");

#import('../vendor/dahlia/src/dahlia.dart');

BeEquivalentMatcher beEquivalent(expected) => new BeEquivalentMatcher(expected);

class BeEquivalentMatcher implements Matcher {
	final expected;
	const BeEquivalentMatcher(this.expected);

	bool matches(var actual) {
		if (expected.length == actual.length) {
			for (var i = 0; i < expected.length; i++) {
				if (expected[i] != actual[i]) {
					return false;
				}
			}
			return true;
		}
		return false;
	}
	String describeExpectation(var actual) => 'actual "$actual" to be equivalent to "$expected"';
}