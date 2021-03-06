//
//  LuaState.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class LuaState: LuaStateType {

    var registry: LuaTable
    var stack: LuaStack

    init() throws {
        self.registry = LuaTable.new(nArr: 0, nRec: 0)
        try self.registry.put(key: LUA_RIDX_GLOBALS, val: LuaTable.new(nArr: 0, nRec: 0))
        self.stack = LuaStack(size: LUA_MINSTACK)
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

    func printStack() throws {
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
                print("[\"\(try self.toString(idx: i))\"]", terminator: "")
            default:
                print("[\(self.typeName(t))]", terminator: "")
            }
        }
        print("")
    }

}
