#library("dart-redis test suites");

#import('../vendor/dahlia/src/dahlia.dart');

BeEquivalentMatcher beEquivalent(expected) => new BeEquivalentMatcher(expected);

class BeEquivalentMatcher implements Matcher {
	final expected;
	const BeEquivalentMatcher(this.expected);

	bool equivalent(expected, actual) {
		if (expected == actual) {
			return true;
		} else {
			try {
				if (expected.length == actual.length) {
					for (var i = 0; i < expected.length; i++) {
						if (expected[i] != actual[i]) {
							if (!equivalent(expected[i], actual[i])) {
								return false;	
							}
						}
					}
					return true;
				}

			} catch (NoSuchMethodException e) {
				return false;
			}
		}
		return false;
	}

	bool matches(var actual) {
		return equivalent(expected, actual);
	}
	String describeExpectation(var actual) => 'actual "$actual" to be equivalent to "$expected"';
}