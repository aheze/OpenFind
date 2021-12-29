//
//  FancyQuotes.swift
//  Find
//
//  Created by Zheng on 2/22/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

public extension String {
    func typographized(language: String, isHTML: Bool = false, debug: Bool = false, measurePerformance: Bool = false) -> String {
        var t = Typographizer(language: language, text: self)
        t.isHTML = isHTML
        t.isDebugModeEnabled = debug
        t.isMeasurePerformanceEnabled = measurePerformance

        return t.typographize()
    }
}

struct Typographizer {
    var language: String {
        didSet {
            refreshLanguage()
        }
    }

    var text = "" {
        didSet {
            refreshTextIterator()
        }
    }

    private var textIterator: String.UnicodeScalarView.Iterator?
    private var bufferedScalar: UnicodeScalar?
    private var previousScalar: UnicodeScalar?

    var isDebugModeEnabled = false
    var isMeasurePerformanceEnabled = false
    var isHTML = false

    private var openingDoubleQuote: String = "·"
    private var closingDoubleQuote: String = "·"
    private var openingSingleQuote: String = "·"
    private var closingSingleQuote: String = "·"

    private let apostrophe: String = "’"
    private let enDash: String = "–"
    private let tagsToSkip: Set<String> = ["pre", "code", "var", "samp", "kbd", "math", "script", "style"]
    private let openingBracketsSet: Set<UnicodeScalar> = ["(", "["]

    init(language: String, text: String, isHTML: Bool = false, debug: Bool = false, measurePerformance: Bool = false) {
        self.text = text
        self.isHTML = isHTML
        self.language = language
        isDebugModeEnabled = debug
        isMeasurePerformanceEnabled = measurePerformance

        refreshLanguage()
        refreshTextIterator()
    }

    private mutating func refreshLanguage() {
        switch language {
        case "he":
            // TODO: Insert proper replacements.
            // Fixing dumb quotation marks in Hebrew is tricky,
            // because a dumb double quotation mark may also be used for gershayim.
            // See https://en.wikipedia.org/wiki/Gershayim
            openingDoubleQuote = "\""
            closingDoubleQuote = "\""
            openingSingleQuote = "\'"
            closingSingleQuote = "\'"
        case "cs",
             "da",
             "de",
             "et",
             "is",
             "lt",
             "lv",
             "sk",
             "sl":
            openingDoubleQuote = "„"
            closingDoubleQuote = "“"
            openingSingleQuote = "\u{201A}"
            closingSingleQuote = "‘"
        case "de_CH",
             "de_LI":
            openingDoubleQuote = "«"
            closingDoubleQuote = "»"
            openingSingleQuote = "‹"
            closingSingleQuote = "›"
        case "bs",
             "fi",
             "sv":
            openingDoubleQuote = "”"
            closingDoubleQuote = "”"
            openingSingleQuote = "’"
            closingSingleQuote = "’"
        case "fr":
            openingDoubleQuote = "«\u{00A0}"
            closingDoubleQuote = "\u{00A0}»"
            openingSingleQuote = "‹\u{00A0}"
            closingSingleQuote = "\u{00A0}›"
        case "hu",
             "pl",
             "ro":
            openingDoubleQuote = "„"
            closingDoubleQuote = "”"
            openingSingleQuote = "’"
            closingSingleQuote = "’"
        case "ja":
            openingDoubleQuote = "「"
            closingDoubleQuote = "」"
            openingSingleQuote = "『"
            closingSingleQuote = "』"
        case "ru",
             "no",
             "nn":
            openingDoubleQuote = "«"
            closingDoubleQuote = "»"
            openingSingleQuote = "’"
            closingSingleQuote = "’"
        case "en",
             "nl": // contemporary Dutch style
            fallthrough
        default:
            openingDoubleQuote = "“"
            closingDoubleQuote = "”"
            openingSingleQuote = "‘"
            closingSingleQuote = "’"
        }
    }

    mutating func refreshTextIterator() {
        textIterator = text.unicodeScalars.makeIterator()
    }

    mutating func typographize() -> String {
#if DEBUG
        var startTime: Date?
        if isMeasurePerformanceEnabled {
            startTime = Date()
        }
#endif

        var tokens = [Token]()
        do {
            while let token = try nextToken() {
                tokens.append(token)
            }
        } catch {
            if isDebugModeEnabled {
#if DEBUG

                abort()
#endif
            } else {
                return text // return unchanged text
            }
        }

        let s = tokens.compactMap { $0.text }.joined()

#if DEBUG
        if let startTime = startTime {
            let endTime = Date().timeIntervalSince(startTime)
        }
#endif

        return s
    }

    private mutating func nextToken() throws -> Token? {
        while let ch = nextScalar() {
            switch ch {
            case "´",
                 "`":
                // FIXME: Replacing a combining accent only works for the very first scalar in a string
                return Token(.apostrophe, apostrophe)
            case "\"",
                 "'",
                 "-":
                return try fixableToken(ch)
            case "<" where isHTML:
                return try htmlToken()
            default:
                return try unchangedToken(ch)
            }
        }
        return nil
    }

    private mutating func nextScalar() -> UnicodeScalar? {
        if let next = bufferedScalar {
            bufferedScalar = nil
            return next
        }
        return textIterator?.next()
    }

    // MARK: Tag Token

    private mutating func htmlToken() throws -> Token {
        var tokenText = "<"
        var tagName = ""
        loop: while let ch = nextScalar() {
            switch ch {
            case " " where tagsToSkip.contains(tagName),
                 ">" where tagsToSkip.contains(tagName):
                tokenText.unicodeScalars.append(ch)
                tokenText.append(fastForwardToClosingTag(tagName))
                break loop
            case ">":
                tokenText.unicodeScalars.append(ch)
                break loop
            default:
                tagName.unicodeScalars.append(ch)
                tokenText.unicodeScalars.append(ch)
            }
        }
        return Token(.skipped, tokenText)
    }

    private mutating func fastForwardToClosingTag(_ tag: String) -> String {
        var buffer = ""

        loop: while let ch = nextScalar() {
            buffer.unicodeScalars.append(ch)
            if ch == "<" {
                if let ch = nextScalar() {
                    buffer.unicodeScalars.append(ch)
                    if ch == "/" {
                        let (bufferedString, isMatchingTag) = checkForMatchingTag(tag)
                        buffer.append(bufferedString)
                        if isMatchingTag {
                            break loop
                        }
                    }
                }
            }
        }
        return buffer
    }

    private mutating func checkForMatchingTag(_ tag: String) -> (bufferedString: String, isMatchingTag: Bool) {
        var buffer = ""
        loop: while let ch = nextScalar() {
            buffer.unicodeScalars.append(ch)
            if ch == ">" {
                break loop
            }
        }
        return (buffer, buffer.hasPrefix(tag))
    }

    // MARK: Unchanged Token

    private mutating func unchangedToken(_ first: UnicodeScalar) throws -> Token {
        var tokenText = String(first)
        previousScalar = first

        loop: while let ch = nextScalar() {
            switch ch {
            case "\"", "'", "<", "-":
                bufferedScalar = ch
                break loop
            default:
                previousScalar = ch
                tokenText.unicodeScalars.append(ch)
            }
        }
        return Token(.unchanged, tokenText)
    }

    // MARK: Fixable Token (quote, apostrophe, hyphen)

    private mutating func fixableToken(_ first: UnicodeScalar) throws -> Token {
        var tokenText = String(first)

        let nextScalar = self.nextScalar()
        bufferedScalar = nextScalar

        var fixingResult: Result = .ignored

        switch first {
        case "\"":
            if let previousScalar = previousScalar,
               let nextScalar = nextScalar
            {
                if CharacterSet.whitespacesAndNewlines.contains(previousScalar) || openingBracketsSet.contains(previousScalar) {
                    tokenText = openingDoubleQuote
                    fixingResult = .openingDouble
                } else if CharacterSet.whitespacesAndNewlines.contains(nextScalar) || CharacterSet.punctuationCharacters.contains(nextScalar) {
                    tokenText = closingDoubleQuote
                    fixingResult = .closingDouble
                } else {
                    tokenText = closingDoubleQuote
                    fixingResult = .closingDouble
                }
            } else {
                if previousScalar == nil {
                    // The last character of a string:
                    tokenText = openingDoubleQuote
                    fixingResult = .openingDouble
                } else {
                    // The first character of a string:
                    tokenText = closingDoubleQuote
                    fixingResult = .closingDouble
                }
            }

        case "'":
            if let previousScalar = previousScalar,
               let nextScalar = nextScalar
            {
                if CharacterSet.whitespacesAndNewlines.contains(previousScalar)
                    || CharacterSet.punctuationCharacters.contains(previousScalar) && !CharacterSet.whitespacesAndNewlines.contains(nextScalar)
                {
                    tokenText = openingSingleQuote
                    fixingResult = .openingSingle
                } else if CharacterSet.whitespacesAndNewlines.contains(nextScalar) || CharacterSet.punctuationCharacters.contains(nextScalar) {
                    tokenText = closingSingleQuote
                    fixingResult = .closingSingle
                } else {
                    tokenText = apostrophe
                    fixingResult = .apostrophe
                }
            } else {
                if previousScalar == nil {
                    // The first character of a string:
                    tokenText = openingSingleQuote
                    fixingResult = .openingSingle
                } else {
                    // The last character of a string:
                    tokenText = closingSingleQuote
                    fixingResult = .closingSingle
                }
            }
        case "-":
            if let previousScalar = previousScalar,
               let nextScalar = nextScalar,
               CharacterSet.whitespacesAndNewlines.contains(previousScalar),
               CharacterSet.whitespacesAndNewlines.contains(nextScalar)
            {
                tokenText = enDash
                fixingResult = .enDash
            }
        default: ()
        }

        previousScalar = tokenText.unicodeScalars.last

#if DEBUG
        if isDebugModeEnabled, isHTML {
            tokenText = "<span class=\"typographizer-debug typographizer-debug--\(fixingResult.rawValue)\">\(tokenText)</span>"
        }
#endif
        return Token(fixingResult, tokenText)
    }
}

extension Typographizer {
    enum Result: String {
        case openingSingle = "opening-single"
        case closingSingle = "closing-single"
        case openingDouble = "opening-double"
        case closingDouble = "closing-double"
        case apostrophe
        case enDash = "en-dash"
        // Unchanged text because it doesn’t contain the trigger characters:
        case unchanged
        // It’s one of the trigger characters but didn’t need changing:
        case ignored
        // Was skipped because it was either an HTML tag, or a pair of tags with protected text in between:
        case skipped
    }
    
    struct Token {
        let result: Result
        let text: String
        
        init(_ result: Result, _ text: String) {
            self.result = result
            self.text = text
        }
    }
}
