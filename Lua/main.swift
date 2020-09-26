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

func luaGetMetatable(ls: LuaState) -> Int {
    if !ls.getMetatable(idx: 1) { // TODO: 专为测试代码适配，读 index 1 了
        ls.pushNil()
    }
    return 1
}

func luaSetMetatable(ls: LuaState) -> Int {
    ls.setMetatable(idx: 1)
    return 1
}

func main() throws {
    let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
    let data = try Data(contentsOf: fileUrl)

    let ls = LuaState()
    ls.register(name: "print", f: luaPrint)
    ls.register(name: "getmetatable", f: luaGetMetatable(ls:))
    ls.register(name: "setmetatable", f: luaSetMetatable(ls:))
    _ = try ls.load(chunk: data, chunkName: fileUrl.absoluteString, mode: "b")
    ls.call(nArgs: 0, nResults: 0)
}

try main()
