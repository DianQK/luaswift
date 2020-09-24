//
//  APIPush.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func pushNil() {
        self.stack.push(LuaNil())
    }

    func pushBoolean(_ b: Bool) {
        self.stack.push(b)
    }

    func pushInteger(_ n: Int64) {
        self.stack.push(n)
    }

    func pushNumber(_ n: Double) {
        self.stack.push(n)
    }

    func pushString(_ s: String) {
        self.stack.push(s)
    }

    func pushSwiftFunction(f: @escaping SwiftFunction) {
        self.stack.push(Closure.swiftFunc(swiftFunc: f))
    }

    func pushGlobalTable() {
        let global = self.registry.get(key: LUA_RIDX_GLOBALS)
        // FIXME: Global 多个 stack 读写出现拷贝读的内容不一样？
        self.stack.push(global)
    }

}
