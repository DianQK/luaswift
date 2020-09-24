//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

func luaPrint(ls: LuaState) -> Int {
    let nArgs = ls.getTop()
    for i in (1...nArgs) {
        if ls.isBoolean(idx: i) {
            print(ls.toBoolean(idx: i), terminator: "")
        } else if ls.isString(idx: i) {
            print(ls.toString(idx: i), terminator: "")
        } else {
            print(ls.typeName(ls.type(idx: i)), terminator: "")
        }
    }
    print("")
    return 0
}

let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])

benchmark(name: "start")
let data = try Data(contentsOf: fileUrl)
benchmark(name: "read data")

let ls = LuaState()
ls.register(name: "print", f: luaPrint)
_ = try ls.load(chunk: data, chunkName: fileUrl.absoluteString, mode: "b")
benchmark(name: "load chunk")
ls.call(nArgs: 0, nResults: 0)
printBenchmarkResult()
