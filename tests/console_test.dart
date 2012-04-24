#library('run all tests on the console');

#import('../vendor/dahlia/src/dahlia.dart');
#import('test_suites.dart');

main() {
 	testSuites();
 	new Runner([new ConsoleReporter()]).run();
}
