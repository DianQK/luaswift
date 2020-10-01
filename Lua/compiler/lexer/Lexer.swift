//
//  Lexer.swift
//  Lua
//
//  Created by dianqk on 2020/9/28.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

enum LexerRegex: String {
    
    case newLine = #"\r\n|\n\r|\n|\r"#
    case identifier = #"^[_\d\w]+"#
    case number = #"0[xX][0-9a-fA-F]*(\.[0-9a-fA-F]*)?([pP][+\-]?[0-9]+)?|^[0-9]*(\.[0-9]*)?([eE][+\-]?[0-9]+)?"#
    case shortString = #"(?s)(^'(\\\\|\\'|\\\n|\\z\s*|[^'\n])*')|(^"(\\\\|\\"|\\\n|\\z\s*|[^"\n])*")"#
    case openingLongBracket = #"^\[=*\["#
    case closingLongBracket = #"\]=*\]"#
    
}

struct LexerError: LocalizedError {
    
    let message: String
    
    var errorDescription: String? { message }
    
}

struct TokenInfo {
    
    let line: Int
    let kind: RawTokenKind
    let token: String
    
    init(_ line: Int, _ kind: RawTokenKind, _ token: String) {
        self.line = line
        self.kind = kind
        self.token = token
    }
    
}

class Lexer {

    /// 源代码
    let chunk: String

    /// 源文件名
    let chunkName: String

    /// 当前行号
    var line: Int

    var processChunk: Substring
    
    var nextTokenInfo: TokenInfo?

    init(chunk: String, chunkName: String) {
        self.chunk = chunk
        self.chunkName = chunkName
        self.line = 1
        self.processChunk = Substring(self.chunk)
    }

    var nextChar: Character {
        self.processChunk[self.processChunk.startIndex]
    }

    func next(_ n: Int) {
        self.processChunk = self.processChunk.dropFirst(n)
    }

    func nextToken() throws -> TokenInfo {
        if let nextTokenInfo = self.nextTokenInfo {
            self.nextTokenInfo = nil
            self.line = nextTokenInfo.line
            return nextTokenInfo
        }
        
        self.skipWhiteSpaces()
        if self.processChunk.isEmpty {
            return TokenInfo(self.line, .eof, "EOF")
        }
        
        switch self.processChunk[self.processChunk.startIndex] {
        case ";":
            self.next(1)
            return TokenInfo(self.line, .semicolon, ";")
        case ",":
            self.next(1)
            return TokenInfo(self.line, .comma, ",")
        case "(":
            self.next(1)
            return TokenInfo(self.line, .leftParen, "(")
        case ")":
            self.next(1)
            return TokenInfo(self.line, .rightParen, ")")
        case "]":
            self.next(1)
            return TokenInfo(self.line, .rightSquareBracket, "]")
        case "{":
            self.next(1)
            return TokenInfo(self.line, .leftBrace, "{")
        case "}":
            self.next(1)
            return TokenInfo(self.line, .rightBrace, "}")
        case "+":
            self.next(1)
            return TokenInfo(self.line, .addOperator, "+")
        case "-":
            self.next(1)
            return TokenInfo(self.line, .minusOperator, "-")
        case "*":
            self.next(1)
            return TokenInfo(self.line, .mulOperator, "*")
        case "^":
            self.next(1)
            return TokenInfo(self.line, .powOperator, "^")
        case "%":
            self.next(1)
            return TokenInfo(self.line, .modOperator, "%")
        case "&":
            self.next(1)
            return TokenInfo(self.line, .bandOperator, "&")
        case "|":
            self.next(1)
            return TokenInfo(self.line, .borOperator, "|")
        case "#":
            self.next(1)
            return TokenInfo(self.line, .lenOperator, "#")
        case ":":
            if self.test("::") {
                self.next(2)
                return TokenInfo(self.line, .label, "::")
            } else {
                self.next(1)
                return TokenInfo(self.line, .colon, ":")
            }
        case "/":
            if self.test("//") {
                self.next(2)
                return TokenInfo(self.line, .idivOperator, "//")
            } else {
                self.next(1)
                return TokenInfo(self.line, .divOperator, "/")
            }
        case "~":
            if self.test("~=") {
                self.next(2)
                return TokenInfo(self.line, .neOperator, "~=")
            } else {
                self.next(1)
                return TokenInfo(self.line, .waveOperator, "~")
            }
        case "=":
            if self.test("==") {
                self.next(2)
                return TokenInfo(self.line, .eqOperator, "==")
            } else {
                self.next(1)
                return TokenInfo(self.line, .assign, "=")
            }
        case "<":
            if self.test("<<") {
                self.next(2)
                return TokenInfo(self.line, .shlOperator, "<<")
            } else if self.test("<=") {
                self.next(2)
                return TokenInfo(self.line, .leOperator, "<=")
            } else {
                self.next(1)
                return TokenInfo(self.line, .ltOperator, "<")
            }
        case ">":
            if self.test(">>") {
                self.next(2)
                return TokenInfo(self.line, .shrOperator, ">>")
            } else if self.test(">=") {
                self.next(2)
                return TokenInfo(self.line, .geOperator, ">=")
            } else {
                self.next(1)
                return TokenInfo(self.line, .gtOperator, ">")
            }
        case ".":
            if self.test("...") {
                self.next(3)
                return TokenInfo(self.line, .vararg, "...")
            } else if self.test("..") {
                self.next(2)
                return TokenInfo(self.line, .concatOperator, "..")
            } else if self.processChunk.count == 1 || !self.processChunk[self.processChunk.index(after: self.processChunk.startIndex)].isNumber {
                self.next(1)
                return TokenInfo(self.line, .dot, ".")
            }
        case "[":
            if self.test("[[") || self.test("[=") {
                return TokenInfo(self.line, .string, try self.scanLongString())
            } else {
                self.next(1)
                return TokenInfo(self.line, .leftSquareBracket, "[")
            }
        case "'", "\"":
            return TokenInfo(self.line, .string, try self.scanShortString())
        default:
            break
        }
        
        let char = self.processChunk[self.processChunk.startIndex]
        if char == "." || char.isNumber {
            let token = try self.scanNumber()
            return TokenInfo(self.line, .number, token)
        }
        if char == "_" || char.isLetter {
            let token = try self.scanIdentifier()
            if let kind = RawTokenKind.keywords[token] {
                return TokenInfo(self.line, kind, token)
            } else {
                return TokenInfo(self.line, .identifier, token)
            }
        }

        throw LexerError(message: "unexpected symbol near \(char)")
    }

    func skipWhiteSpaces() {
        while !self.processChunk.isEmpty {
            if self.test("--") {

            } else if self.test("\r\n") || self.test("\n\r") {
                self.next(2)
                self.line += 1
            } else if self.nextChar.isNewline {
                self.next(1)
                self.line += 1
            } else if self.nextChar.isWhitespace {
                self.next(1)
            } else {
                break
            }
        }
    }

    func skipComment() throws {
        self.next(2) // skip --

        // long comment
        if self.test("[") {
            if self.range(regex: .openingLongBracket) != nil {
                try self.scanLongString()
                return
            }
        }

        // short comment
        while !self.nextChar.isNewline {
            self.next(1)
        }
    }

    func test(_ s: String) -> Bool {
        self.processChunk.hasPrefix(s)
    }
    
    func range(regex: LexerRegex) -> Range<Substring.Index>? {
        self.processChunk.range(of: regex.rawValue, options: .regularExpression)
    }
    
    @discardableResult func scanLongString() throws -> String {
        guard let openingLongBracketRange = self.range(regex: .openingLongBracket) else {
            throw LexerError(message: "invalid long string delimiter near \(self.processChunk[self.processChunk.startIndex])")
        }
        guard let closingLongBracketRange = self.range(regex: .closingLongBracket) else {
            throw LexerError(message: "unfinished long string or comment")
        }
        let content = self.processChunk[openingLongBracketRange.upperBound..<closingLongBracketRange.lowerBound]
        let nextStep = self.processChunk.distance(from: self.processChunk.startIndex, to: closingLongBracketRange.upperBound)
        self.next(nextStep)
        return String(content)
    }
    
    func scanShortString() throws -> String {
        guard let shortStringRange = self.range(regex: .shortString) else {
            throw LexerError(message: "unfinished string")
        }
        // TODO: 增加 escape
        let content = self.processChunk[shortStringRange].dropFirst().dropLast()
        self.next(self.processChunk.distance(from: self.processChunk.startIndex, to: shortStringRange.upperBound))
        return String(content)
    }
    
    func scan(regex: LexerRegex) throws -> String {
        guard let range = self.range(regex: regex) else {
            throw LexerError(message: "unreachable!")
        }
        let token = String(self.processChunk[range])
        self.next(token.count)
        return token
    }
    
    func scanIdentifier() throws -> String {
        return try self.scan(regex: .identifier)
    }

    func scanNumber() throws -> String {
        return try self.scan(regex: .number)
    }

}
