/**
 *  SplashHaskell
 *  Copyright (c) Moss Prescott 2020
 *  MIT license - see LICENSE.md
 */

import XCTest

#if os(Linux)

public func makeLinuxTests() -> [XCTestCaseEntry] {
    return [
        testCase(HaskellTests.allTests),
    ]
}

#endif
