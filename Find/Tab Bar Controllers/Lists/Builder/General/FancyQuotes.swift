//
//  FancyQuotes.swift
//  Find
//
//  Created by Zheng on 2/22/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

extension String {
    public func typographized(language: String, isHTML: Bool = false, debug: Bool = false, measurePerformance: Bool = false) -> String {
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
            self.refreshLanguage()
        }
    }

    var text = "" {
        didSet {
            self.refreshTextIterator()
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
        self.isDebugModeEnabled = debug
        self.isMeasurePerformanceEnabled = measurePerformance

        self.refreshLanguage()
        self.refreshTextIterator()
    }

    private mutating func refreshLanguage() {
        switch self.language {
        case "he":
            // TODO: Insert proper replacements.
            // Fixing dumb quotation marks in Hebrew is tricky,
            // because a dumb double quotation mark may also be used for gershayim.
            // See https://en.wikipedia.org/wiki/Gershayim
            self.openingDoubleQuote = "\""
            self.closingDoubleQuote = "\""
            self.openingSingleQuote = "\'"
            self.closingSingleQuote = "\'"
        case "cs",
             "da",
             "de",
             "et",
             "is",
             "lt",
             "lv",
             "sk",
             "sl":
            self.openingDoubleQuote = "„"
            self.closingDoubleQuote = "“"
            self.openingSingleQuote = "\u{201A}"
            self.closingSingleQuote = "‘"
        case "de_CH",
             "de_LI":
            self.openingDoubleQuote = "«"
            self.closingDoubleQuote = "»"
            self.openingSingleQuote = "‹"
            self.closingSingleQuote = "›"
        case "bs",
             "fi",
             "sv":
            self.openingDoubleQuote = "”"
            self.closingDoubleQuote = "”"
            self.openingSingleQuote = "’"
            self.closingSingleQuote = "’"
        case "fr":
            self.openingDoubleQuote = "«\u{00A0}"
            self.closingDoubleQuote = "\u{00A0}»"
            self.openingSingleQuote = "‹\u{00A0}"
            self.closingSingleQuote = "\u{00A0}›"
        case "hu",
             "pl",
             "ro":
            self.openingDoubleQuote = "„"
            self.closingDoubleQuote = "”"
            self.openingSingleQuote = "’"
            self.closingSingleQuote = "’"
        case "ja":
            self.openingDoubleQuote = "「"
            self.closingDoubleQuote = "」"
            self.openingSingleQuote = "『"
            self.closingSingleQuote = "』"
        case "ru",
             "no",
             "nn":
            self.openingDoubleQuote = "«"
            self.closingDoubleQuote = "»"
            self.openingSingleQuote = "’"
            self.closingSingleQuote = "’"
        case "en",
             "nl": // contemporary Dutch style
            fallthrough
        default:
            self.openingDoubleQuote = "“"
            self.closingDoubleQuote = "”"
            self.openingSingleQuote = "‘"
            self.closingSingleQuote = "’"
        }
    }

    mutating func refreshTextIterator() {
        self.textIterator = self.text.unicodeScalars.makeIterator()
    }

    mutating func typographize() -> String {
        #if DEBUG
            var startTime: Date?
            if self.isMeasurePerformanceEnabled {
                startTime = Date()
            }
        #endif

        var tokens = [Token]()
        do {
            while let token = try self.nextToken() {
                tokens.append(token)
            }
        } catch {
                if self.isDebugModeEnabled {
                    #if DEBUG
                        print("Typographizer iterator triggered an error.")
                        abort()
                    #endif
                } else {
                    return self.text // return unchanged text
                }
        }

        let s = tokens.compactMap({$0.text}).joined()

        #if DEBUG
            if let startTime = startTime {
                let endTime = Date().timeIntervalSince(startTime)
                print("Typographizing took \(NSString(format:"%.8f", endTime)) seconds")
            }
        #endif

        return s
    }

    private mutating func nextToken() throws -> Token? {
        while let ch = self.nextScalar() {
            switch ch {
            case "´",
                 "`":
                // FIXME: Replacing a combining accent only works for the very first scalar in a string
                return Token(.apostrophe, self.apostrophe)
            case "\"",
                 "'",
                 "-":
                return try self.fixableToken(ch)
            case "<" where self.isHTML:
                return try self.htmlToken()
            default:
                return try self.unchangedToken(ch)
            }
        }
        return nil
    }

    private mutating func nextScalar() -> UnicodeScalar? {
        if let next = self.bufferedScalar {
            self.bufferedScalar = nil
            return next
        }
        return self.textIterator?.next()
    }

    // MARK: Tag Token
    private mutating func htmlToken() throws -> Token {
        var tokenText = "<"
        var tagName = ""
        loop: while let ch = nextScalar() {
            switch ch {
            case " " where self.tagsToSkip.contains(tagName),
                 ">" where self.tagsToSkip.contains(tagName):
                tokenText.unicodeScalars.append(ch)
                tokenText.append(self.fastForwardToClosingTag(tagName))
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
                        let (bufferedString, isMatchingTag) = self.checkForMatchingTag(tag)
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
        self.previousScalar = first

        loop: while let ch = nextScalar() {
            switch ch {
            case "\"", "'", "<", "-":
                self.bufferedScalar = ch
                break loop
            default:
                self.previousScalar = ch
                tokenText.unicodeScalars.append(ch)
            }
        }
        return Token(.unchanged, tokenText)
    }

    // MARK: Fixable Token (quote, apostrophe, hyphen)
    private mutating func fixableToken(_ first: UnicodeScalar) throws -> Token {
        var tokenText = String(first)

        let nextScalar = self.nextScalar()
        self.bufferedScalar = nextScalar

        var fixingResult: Result = .ignored

        switch first {
        case "\"":
            if let previousScalar = self.previousScalar,
                let nextScalar = nextScalar {
                if CharacterSet.whitespacesAndNewlines.contains(previousScalar) || self.openingBracketsSet.contains(previousScalar) {
                    tokenText = self.openingDoubleQuote
                    fixingResult = .openingDouble
                } else if CharacterSet.whitespacesAndNewlines.contains(nextScalar) || CharacterSet.punctuationCharacters.contains(nextScalar) {
                    tokenText = self.closingDoubleQuote
                    fixingResult = .closingDouble
                } else {
                    tokenText = self.closingDoubleQuote
                    fixingResult = .closingDouble
                }
            } else {
                if self.previousScalar == nil {
                    // The last character of a string:
                    tokenText = self.openingDoubleQuote
                    fixingResult = .openingDouble
                } else {
                    // The first character of a string:
                    tokenText = self.closingDoubleQuote
                    fixingResult = .closingDouble
                }
            }

        case "'":
            if let previousScalar = self.previousScalar,
                let nextScalar = nextScalar {

                if CharacterSet.whitespacesAndNewlines.contains(previousScalar)
                    || CharacterSet.punctuationCharacters.contains(previousScalar) && !CharacterSet.whitespacesAndNewlines.contains(nextScalar) {
                    tokenText = self.openingSingleQuote
                    fixingResult = .openingSingle
                } else if CharacterSet.whitespacesAndNewlines.contains(nextScalar) || CharacterSet.punctuationCharacters.contains(nextScalar) {
                    tokenText = self.closingSingleQuote
                    fixingResult = .closingSingle
                } else {
                    tokenText = self.apostrophe
                    fixingResult = .apostrophe
                }
            } else {
                if self.previousScalar == nil {
                    // The first character of a string:
                    tokenText = self.openingSingleQuote
                    fixingResult = .openingSingle
                } else {
                    // The last character of a string:
                    tokenText = self.closingSingleQuote
                    fixingResult = .closingSingle
                }
            }
        case "-":
            if let previousScalar = self.previousScalar,
                let nextScalar = nextScalar,
                CharacterSet.whitespacesAndNewlines.contains(previousScalar)
                && CharacterSet.whitespacesAndNewlines.contains(nextScalar) {
                tokenText = self.enDash
                fixingResult = .enDash
            }
        default: ()
        }

        self.previousScalar = tokenText.unicodeScalars.last

        #if DEBUG
            if self.isDebugModeEnabled && self.isHTML {
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
