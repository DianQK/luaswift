//
//  LuaStateType.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol LuaStateType: class {

    func getTop() -> Int
    func absIndex(idx: Int)
    func checkStack(n: Int) -> Bool
    func pop(n: Int)
    func copy(fromIdx: Int, toIdx: Int)
    func pushValue(idx: Int)
    func replace(idx: Int)
    func insert(idx: Int)
    func remove(idx: Int)
    func rotate(idx: Int, n: Int)
    func setTop(idx: Int)
    /* access functions (stack -> Go) */
    func typeName(tp: LuaType) -> String
    func type(idx: Int) -> LuaType
    func isNone(idx: Int) -> Bool
    func isNil(idx: Int) -> Bool
    func isNoneOrNil(idx: Int) -> Bool
    func isBoolean(idx: Int) -> Bool
    func isInteger(idx: Int) -> Bool
    func isNumber(idx: Int) -> Bool
    func isString(idx: Int) -> Bool
    func isTable(idx: Int) -> Bool
    func isThread(idx: Int) -> Bool
    func isFunction(idx: Int) -> Bool
    func toBoolean(idx: Int) -> Bool
    func toInteger(idx: Int) -> Int64
    func toIntegerX(idx: Int) -> (Int64, Bool)
    func toNumber(idx: Int) -> Double
    func toNumberX(idx: Int) -> (Double, Bool)
    func toString(idx: Int) -> String
    func toStringX(idx: Int) -> (String, Bool)
    /* push functions (Go -> stack) */
    func pushNil()
    func pushBoolean(b: Bool)
    func pushInteger(n: Int64)
    func pushNumber(n: Double)
    func pushString(s: String)
}