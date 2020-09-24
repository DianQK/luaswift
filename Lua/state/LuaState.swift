//
//  LuaState.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class LuaState: LuaStateType {

    var stack: LuaStack

    init(stackSize: Int = LUA_MINSTACK) {
        self.stack = LuaStack(size: stackSize)
        self.stack.state = self
    }

}

extension LuaState {

    func pushLuaStack(stack: LuaStack) {
        stack.prev = self.stack
        self.stack = stack
    }

    func popLuaStack() {
        let stack = self.stack
        self.stack = stack.prev!
        stack.prev = nil
    }

}

extension LuaState {

    func printStack() {
        let top = self.getTop()
        for i in (1...top) {
            let t = self.type(idx: i)
            switch t {
            case .boolean:
                print("[\(self.toBoolean(idx: i))]", terminator: "")
            case .number:
                if self.isInteger(idx: i) {
                    print("[\(self.toInteger(idx: i))]", terminator: "")
                } else {
                    print("[\(self.toNumber(idx: i))]", terminator: "")
                }
            case .string:
                print("[\"\(self.toString(idx: i))\"]", terminator: "")
            default:
                print("[\(self.typeName(t))]", terminator: "")
            }
        }
        print("")
    }

}
