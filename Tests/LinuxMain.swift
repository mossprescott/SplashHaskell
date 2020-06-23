import XCTest

import SplashHaskellTests

var tests = [XCTestCaseEntry]()
tests += HaskellTests.allTests()
XCTMain(tests)
