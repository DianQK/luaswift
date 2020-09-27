//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

func luaPrint(ls: LuaState) throws -> Int {
    let nArgs = ls.getTop()
    for i in (1...nArgs) {
        if ls.isBoolean(idx: i) {
            print(ls.toBoolean(idx: i), terminator: " ")
        } else if ls.isString(idx: i) {
            print(try ls.toString(idx: i), terminator: " ")
        } else {
            print(ls.typeName(ls.type(idx: i)), terminator: " ")
        }
    }
    print("")
    return 0
}

func luaGetMetatable(ls: LuaState) throws -> Int {
    if try !ls.getMetatable(idx: 1) { // TODO: 专为测试代码适配，读 index 1 了
        try ls.pushNil()
    }
    return 1
}

func luaSetMetatable(ls: LuaState) throws -> Int {
    try ls.setMetatable(idx: 1)
    return 1
}

func luaNext(ls: LuaState) throws -> Int {
    try ls.setTop(idx: 2) // 简化版
    if try ls.next(idx: 1) {
        return 2
    } else {
        try ls.pushNil()
        return 1
    }
}

func luaPairs(ls: LuaState) throws -> Int {
    try ls.pushSwiftFunction(f: luaNext) // will return generator
    // ✨调用新的方法时，创建了新的 LuaStack，此时 stack 还是干净的，所以这个 push idx 1 是把栈底的第一个参数拷贝到栈顶一份
    try ls.pushValue(idx: 1) // state,
    try ls.pushNil()
    return 3
}

func _LuaIPairsAux(ls: LuaState) throws -> Int {
    let i = ls.toInteger(idx: 2) + 1
    try ls.pushInteger(i)
    if try ls.getI(idx: 1, i: i) == .nil {
        return 1
    } else {
        return 2
    }
}

func luaIPairs(ls: LuaState) throws -> Int {
    try ls.pushSwiftFunction(f: _LuaIPairsAux(ls:)) /* iteration function */
    try ls.pushValue(idx: 1)               /* state */
    try ls.pushInteger(0)             /* initial value */
    return 3
}

func luaError(ls: LuaState) throws -> Int {
    try ls.error()
}

func luaPCall(ls: LuaState) throws -> Int {
    let nArgs = ls.getTop() - 1
    let status = try ls.pCall(nArgs: nArgs, nResults: -1, msgh: 0)
    try ls.pushBoolean(status == .ok)
    ls.insert(idx: 1)
    return ls.getTop()
}

func main() throws {
    let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
    let data = try Data(contentsOf: fileUrl)

    let ls = try LuaState()
    try ls.register(name: "print", f: luaPrint)
    try ls.register(name: "getmetatable", f: luaGetMetatable(ls:))
    try ls.register(name: "setmetatable", f: luaSetMetatable(ls:))
    try ls.register(name: "next", f: luaNext(ls:))
    try ls.register(name: "pairs", f: luaPairs(ls:))
    try ls.register(name: "ipairs", f: luaIPairs(ls:))
    try ls.register(name: "error", f: luaError(ls:))
    try ls.register(name: "pcall", f: luaPCall(ls:))
    _ = try ls.load(chunk: data, chunkName: fileUrl.absoluteString, mode: "b")
    try ls.call(nArgs: 0, nResults: 0)
}

try main()
