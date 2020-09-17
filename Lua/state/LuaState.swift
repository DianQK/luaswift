//
//  LuaState.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class LuaState {

    let stack: LuaStack

    init(stack: LuaStack) {
        self.stack = stack
    }

    static func new() -> LuaState {
        LuaState(stack: LuaStack(size: 20))
    }

}
