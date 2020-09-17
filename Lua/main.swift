//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let luaState = LuaState.new()
luaState.pushBoolean(true); luaState.printStack()
luaState.pushInteger(10); luaState.printStack()
luaState.pushNil(); luaState.printStack()
luaState.pushString("hello"); luaState.printStack()
luaState.pushValue(idx: -4); luaState.printStack()
luaState.replace(idx: 3); luaState.printStack()
luaState.setTop(idx: 6); luaState.printStack()
luaState.remove(idx: -3); luaState.printStack()
luaState.setTop(idx: -5); luaState.printStack()
