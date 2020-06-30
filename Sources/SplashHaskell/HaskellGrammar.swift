//
//  HaskellGrammar.swift
//
//  Copyright © 2020 Moss Prescott.
//

import Foundation
import Splash

/// Splash Grammar for the Haskell programming language, providing basic tokenization for "better
/// than nothing" syntax highlighting.
public struct HaskellGrammar: Grammar {
    public var delimiters: CharacterSet
    public var syntaxRules: [SyntaxRule]

    public init() {
        var delimiters = CharacterSet.alphanumerics.inverted
        delimiters.remove("_")
        delimiters.remove("\"")
//        delimiters.remove("#")
        delimiters.remove("@")
        delimiters.remove("$")
        self.delimiters = delimiters

        syntaxRules = [
            PreprocessingRule(),
            CommentRule(),
            SingleLineStringRule(),
            NumberRule(),
            TypeRule(),
//            CallRule(),
//            PropertyRule(),
//            DotAccessRule(),
            KeywordRule()
        ]
    }

    public func isDelimiter(_ delimiterA: Character,
                            mergableWith delimiterB: Character) -> Bool {
        switch (delimiterA, delimiterB) {
        case ("-", "-"):
            return true
        case ("{", "-"):
            return true
        case ("-", "}"):
            return true

        default:
            return true
        }
    }
}

private extension HaskellGrammar {
    static let keywords: Set<String> = [
        "type", "data", "where", "let", "in", "do", "class", "module",
        "deriving", "instance", "import", "if", "then", "else", "case", "of",
        "infix", "infixl", "infixr", "hiding", "foreign", "forall", "newtype",
        "type", "family", "qualified", "as",
    ]

    struct PreprocessingRule: SyntaxRule {
        var tokenType: TokenType { return .preprocessing }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("{-#") {
                if segment.tokens.current.hasSuffix("#-}") {
                    return true
                }
            }
            
            if segment.tokens.current.isAny(of: "{-#", "#-}") {
                return true
            }

            let multiLineStartCount = segment.tokens.count(of: "{-#")
            return multiLineStartCount != segment.tokens.count(of: "#-}")
        }
    }

    struct CommentRule: SyntaxRule {
        var tokenType: TokenType { return .comment }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("{-") {
                if segment.tokens.current.hasSuffix("-}") {
                    return true
                }
            }
            
            if segment.tokens.current.hasPrefix("--") {
                return true
            }

            if segment.tokens.onSameLine.contains("--") {
                return true
            }

            if segment.tokens.current.isAny(of: "{-", "-}") {
                return true
            }

            let multiLineStartCount = segment.tokens.count(of: "{-")
            return multiLineStartCount != segment.tokens.count(of: "-}")
        }
    }
    
    struct SingleLineStringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("\"") &&
               segment.tokens.current.hasSuffix("\"") {
                return true
            }

            guard segment.isWithinStringLiteral(withStart: "\"", end: "\"") else {
                return false
            }

            return false
        }
    }

    struct NumberRule: SyntaxRule {
        var tokenType: TokenType { return .number }

        func matches(_ segment: Segment) -> Bool {
            // Integers can be separated using "_", so handle that
            if segment.tokens.current.removing("_").isNumber {
                return true
            }
            
            // Double and floating point values that contain a "."
            guard segment.tokens.current == "." else {
                return false
            }

            guard let previous = segment.tokens.previous,
                  let next = segment.tokens.next else {
                    return false
            }

            return previous.isNumber && next.isNumber
        }
    }

    // TODO: use "call" for anything that looks like function application?
//    struct CallRule: SyntaxRule {
//        var tokenType: TokenType { return .call }
//
//        func matches(_ segment: Segment) -> Bool {
//        }
//    }

    struct KeywordRule: SyntaxRule {
        var tokenType: TokenType { return .keyword }

        func matches(_ segment: Segment) -> Bool {
            return keywords.contains(segment.tokens.current)
        }
    }

    struct TypeRule: SyntaxRule {
        var tokenType: TokenType { return .type }

        func matches(_ segment: Segment) -> Bool {
            let token = segment.tokens.current.trimmingCharacters(
                in: CharacterSet(charactersIn: "_")
            )

            guard token.isCapitalized else {
                return false
            }

            return true
        }
    }

    // TODO: any analog?
//    struct DotAccessRule: SyntaxRule {
//        var tokenType: TokenType { return .dotAccess }
//
//        func matches(_ segment: Segment) -> Bool {
//        }
//    }

// TODO: any analog?
//    struct PropertyRule: SyntaxRule {
//        var tokenType: TokenType { return .property }
//
//        func matches(_ segment: Segment) -> Bool {
//        }
//    }
}

private extension Segment {
    func isWithinStringLiteral(withStart start: String, end: String) -> Bool {
        if tokens.current.hasPrefix(start) {
            return true
        }

        if tokens.current.hasSuffix(end) {
            return true
        }

        var markerCounts = (start: 0, end: 0)
        var previousToken: String?

        for token in tokens.onSameLine {
            if token.hasPrefix("(") || token.hasPrefix("#(") || token.hasPrefix("\"") {
                guard previousToken != "\\" else {
                    previousToken = token
                    continue
                }
            }

            if token == start {
                if start != end || markerCounts.start == markerCounts.end {
                    markerCounts.start += 1
                } else {
                    markerCounts.end += 1
                }
            } else if token == end && start != end {
                markerCounts.end += 1
            } else {
                if token.hasPrefix(start) {
                    markerCounts.start += 1
                }

                if token.hasSuffix(end) {
                    markerCounts.end += 1
                }
            }

            previousToken = token
        }

        return markerCounts.start != markerCounts.end
    }

//    var isWithinStringInterpolation: Bool {
//        let delimiter = "\\("
//
//        if tokens.current == delimiter || tokens.previous == delimiter {
//            return true
//        }
//
//        let components = tokens.onSameLine.split(separator: delimiter)
//
//        guard components.count > 1 else {
//            return false
//        }
//
//        let suffix = components.last!
//        var paranthesisCount = 1
//
//        for component in suffix {
//            paranthesisCount += component.numberOfOccurrences(of: "(")
//            paranthesisCount -= component.numberOfOccurrences(of: ")")
//
//            guard paranthesisCount > 0 else {
//                return false
//            }
//        }
//
//        return true
//    }

//    var isWithinRawStringInterpolation: Bool {
//        // Quick fix for supporting single expressions within raw string
//        // interpolation, a proper fix should be developed ASAP.
//        switch tokens.current {
//        case "\\":
//            return tokens.previous != "\\" && tokens.next == "#"
//        case "#":
//            return tokens.previous == "\\" && tokens.next == "("
//        case "(":
//            return tokens.onSameLine.suffix(2) == ["\\", "#"]
//        case ")":
//            let suffix = tokens.onSameLine.suffix(4)
//            return suffix.prefix(3) == ["\\", "#", "("]
//        default:
//            let suffix = tokens.onSameLine.suffix(3)
//            return suffix == ["\\", "#", "("] && tokens.next == ")"
//        }
//    }

//    var prefixedByDotAccess: Bool {
//        return tokens.previous == "(." || prefix.hasSuffix(" .")
//    }

    var isValidSymbol: Bool {
        guard let firstCharacter = tokens.current.first else {
            return false
        }

        return firstCharacter == "_" || firstCharacter.isLetter
    }
}

// HACK: copied from Splash
internal extension String {
    var isCapitalized: Bool {
        guard let firstCharacter = first.map(String.init) else {
            return false
        }

        return firstCharacter != firstCharacter.lowercased()
    }

//    var startsWithLetter: Bool {
//        guard let firstCharacter = first else {
//            return false
//        }
//
//        return CharacterSet.letters.contains(firstCharacter)
//    }

    var isNumber: Bool {
        return Int(self) != nil
    }

    func removing(_ substring: String) -> String {
        return replacingOccurrences(of: substring, with: "")
    }
}

//// HACK: copied from Splash
//internal extension Sequence where Element: Equatable {
//    func numberOfOccurrences(of target: Element) -> Int {
//        return reduce(0) { count, element in
//            return element == target ? count + 1 : count
//        }
//    }
//}

// HACK: copied from Splash
extension Equatable {
    func isAny(of candidates: Self...) -> Bool {
        return candidates.contains(self)
    }

    func isAny<S: Sequence>(of candidates: S) -> Bool where S.Element == Self {
        return candidates.contains(self)
    }
}
