//
//  LuaState.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class LuaState: LuaStateType {

    let stack: LuaStack

    init(stack: LuaStack) {
        self.stack = stack
    }

    static func new() -> LuaState {
        LuaState(stack: LuaStack(size: 20))
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
