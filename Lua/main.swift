//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let luaState = LuaState.new()
luaState.pushInteger(1)
luaState.pushString("2.0")
luaState.pushString("3.0")
luaState.pushNumber(4.0)
luaState.printStack()

luaState.arith(op: .add); luaState.printStack()
luaState.arith(op: .bnot); luaState.printStack()
luaState.len(idx: 2); luaState.printStack()
luaState.concat(n: 3); luaState.printStack()
luaState.pushBoolean(luaState.compare(idx1: 1, idx2: 2, op: .eq))
luaState.printStack()
