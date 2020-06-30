/**
 *  SplashHaskell
 *  Copyright (c) Moss Prescott 2020
 *  MIT license - see LICENSE
 */

import Foundation
import XCTest
import Splash

final class HaskellTests: SyntaxHighlighterTestCase {
    func testSimpleMain() {
        let components = highlighter.highlight("main = putStrLn \"Hello\"")

        XCTAssertEqual(components, [
            .plainText("main"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .plainText("putStrLn"),
            .whitespace(" "),
            .token("\"Hello\"", .string),
        ])
    }
    
        func testOption() {
            let components = highlighter.highlight("{-# LANGUAGE NoImplicitPrelude #-}")

            XCTAssertEqual(components, [
                .token("{-#", .preprocessing),
                .whitespace(" "),
                .token("LANGUAGE", .preprocessing),
                .whitespace(" "),
                .token("NoImplicitPrelude", .preprocessing),
                .whitespace(" "),
                .token("#-}", .preprocessing),
            ])
        }

    func testRecord() {
        let components = highlighter.highlight("""
data Thing = Thing
  { thingName  :: Text
  , thingStyle :: Maybe Style
  } deriving (Eq, Show)
""")

        XCTAssertEqual(components, [
            .token("data", .keyword),
            .whitespace(" "),
            .token("Thing", .type),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("Thing", .type),
            .whitespace("\n  "),
            .plainText("{"),
            .whitespace(" "),
            .plainText("thingName"),
            .whitespace("  "),
            .plainText("::"),
            .whitespace(" "),
            .token("Text", .type),
            .whitespace("\n  "),
            .plainText(","),
            .whitespace(" "),
            .plainText("thingStyle"),
            .whitespace(" "),
            .plainText("::"),
            .whitespace(" "),
            .token("Maybe", .type),
            .whitespace(" "),
            .token("Style", .type),
            .whitespace("\n  "),
            .plainText("}"),
            .whitespace(" "),
            .token("deriving", .keyword),
            .whitespace(" "),
            .plainText("("),
            .token("Eq", .type),
            .plainText(","),
            .whitespace(" "),
            .token("Show", .type),
            .plainText(")")
        ])
    }

    func testComments() {
        let components = highlighter.highlight("""
x = 1  -- Hey!

{- Wow. -}
""")

        XCTAssertEqual(components, [
            .plainText("x"),
            .whitespace(" "),
            .plainText("="),
            .whitespace(" "),
            .token("1", .number),
            .whitespace("  "),
            .token("--", .comment),
            .whitespace(" "),
            .token("Hey!", .comment),
            .whitespace("\n\n"),
            .token("{-", .comment),
            .whitespace(" "),
            .token("Wow.", .comment),
            .whitespace(" "),
            .token("-}", .comment)
        ])
    }

    func testOperators() {
        let components = highlighter.highlight("""
do
  x <- generate $ arbitrary @Int
""")

        XCTAssertEqual(components, [
            .token("do", .keyword),
            .whitespace("\n  "),
            .plainText("x"),
            .whitespace(" "),
            .plainText("<-"),
            .whitespace(" "),
            .plainText("generate"),
            .whitespace(" "),
            .plainText("$"),
            .whitespace(" "),
            .plainText("arbitrary"),
            .whitespace(" "),
            .plainText("@"),
            .token("Int", .type)
        ])
    }

    func testAllTestsRunOnLinux() {
        XCTAssertTrue(TestCaseVerifier.verifyLinuxTests((type(of: self)).allTests))
    }
}

extension HaskellTests {
    static var allTests: [(String, TestClosure<HaskellTests>)] {
        return [
            ("testSimpleMain", testSimpleMain),
            ("testOption", testOption),
            ("testRecord", testRecord),
            ("testComments", testComments),
            ("testOperators", testOperators),
        ]
    }
}

