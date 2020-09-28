//
//  Lexer.swift
//  Lua
//
//  Created by dianqk on 2020/9/28.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class Lexer {

    /// 源代码
    let chunk: String

    /// 源文件名
    let chunkName: String

    /// 当前行号
    var line: Int

    var processChunk: Substring

    init(chunk: String, chunkName: String) {
        self.chunk = chunk
        self.chunkName = chunkName
        self.line = 1
        self.processChunk = Substring(self.chunk)
    }


    func next(_ n: Int) {
        self.processChunk = self.processChunk.dropFirst(n)
    }

//    func nextToken() -> (line: Int, kind: Int, token: String) {
//        
//    }

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

    func skipComment() {
        self.next(2) // skip --

        // long comment ?
        if self.test("[") {
//            if reOpeningLongBracket.FindString(self.chunk) != "" {
//                self.scanLongString()
//                return
//            }
        }

        // short comment
        while !self.nextChar.isNewline {
            self.next(1)
        }
    }

    var nextChar: Character {
        self.processChunk[self.processChunk.startIndex]
    }

    func test(_ s: String) -> Bool {
        self.processChunk.hasPrefix(s)
    }

}
