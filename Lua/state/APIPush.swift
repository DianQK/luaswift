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

}
