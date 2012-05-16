#library("dart-redis test suites");

#import('../vendor/dahlia/src/dahlia.dart');

BeEquivalentMatcher beEquivalent(expected) => new BeEquivalentMatcher(expected);

class BeEquivalentMatcher implements Matcher {
	final expected;
	const BeEquivalentMatcher(this.expected);

	bool equivalent(expected, actual) {
		if (expected.length == actual.length) {
			for (var i = 0; i < expected.length; i++) {
				if (expected[i] != actual[i]) {
					try {
						if (!equivalent(expected[i], actual[i])) {
							return false;	
						}
					} catch (NoSuchMethodException e) {
						return false;
					}
				}
			}
			return true;
		}
		return false;
	}

	bool matches(var actual) {
		return equivalent(expected, actual);
	}
	String describeExpectation(var actual) => 'actual "$actual" to be equivalent to "$expected"';
}