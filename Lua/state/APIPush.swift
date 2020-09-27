//
//  APIPush.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func pushNil() throws {
        try self.stack.push(LuaNil)
    }

    func pushBoolean(_ b: Bool) throws {
        try self.stack.push(b)
    }

    func pushInteger(_ n: Int64) throws {
        try self.stack.push(n)
    }

    func pushNumber(_ n: Double) throws {
        try self.stack.push(n)
    }

    func pushString(_ s: String) throws {
        try self.stack.push(s)
    }

    func pushSwiftFunction(f: @escaping SwiftFunction) throws {
        try self.stack.push(Closure(swiftFunc: f, nUpvals: 0))
    }

    func pushGlobalTable() throws {
        let global = self.registry.get(key: LUA_RIDX_GLOBALS)
        // FIXME: Global 多个 stack 读写出现拷贝读的内容不一样？
        try self.stack.push(global)
    }

    func pushSwiftClosure(f: @escaping SwiftFunction, n: Int) throws {
        let closure = Closure(swiftFunc: f, nUpvals: n)
        if n > 0 {
            for i in (1...n).reversed() {
                let val = try self.stack.pop()
                closure.upvals[i - 1] = Upvalue(val: val)
            }
        }
        try self.stack.push(closure)
    }

}
