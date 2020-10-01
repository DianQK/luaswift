//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

//let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
//let code = String(contentsOf: fileUrl)

let code = """
print("hello world!")
"""

let lexer = Lexer(chunk: code, chunkName: "demo")

while true {
    let tokenInfo = try lexer.nextToken()
    let category = tokenInfo.kind.category.rawValue.padding(toLength: 10, withPad: " ", startingAt: 0)
    print("[\(String(format: "%2d", tokenInfo.line))] [\(category)] \(tokenInfo.token)")
    if tokenInfo.kind == .eof {
        break
    }
}
