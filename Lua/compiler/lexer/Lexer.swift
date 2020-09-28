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

    init(chunk: String, chunkName: String) {
        self.chunk = chunk
        self.chunkName = chunkName
        self.line = 1
    }

//    func nextToken() -> (line: Int, kind: Int, token: String) {
//        
//    }

}
