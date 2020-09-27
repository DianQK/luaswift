//
//  LuaStateType.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

func LuaUpvalueIndex(i: Int) -> Int {
    return LUA_REGISTRYINDEX - i
}

protocol LuaStateType: class {

    func getTop() -> Int
    func absIndex(idx: Int) -> Int
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
    func typeName(_ tp: LuaType) -> String
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
    func isSwiftFunction(idx: Int) -> Bool
    func toBoolean(idx: Int) -> Bool
    func toInteger(idx: Int) -> Int64
    func toIntegerX(idx: Int) -> (Int64, Bool)
    func toNumber(idx: Int) -> Double
    func toNumberX(idx: Int) -> (Double, Bool)
    func toString(idx: Int) -> String
    func toStringX(idx: Int) -> (String, Bool)
    func toSwiftFunction(idx: Int) -> SwiftFunction?
    func rawLen(idx: Int) -> UInt
    /* push functions (Go -> stack) */
    func pushNil()
    func pushBoolean(_ b: Bool)
    func pushInteger(_ n: Int64)
    func pushNumber(_ n: Double)
    func pushString(_ s: String)
    func pushSwiftFunction(f: @escaping SwiftFunction)
    func pushGlobalTable()
    func pushSwiftClosure(f: @escaping SwiftFunction, n: Int)
    /* Comparison and arithmetic functions */
    func arith(op: ArithOp)
    func compare(idx1: Int, idx2: Int, op: CompareOp) -> Bool
    func rawEqual(idx1: Int, idx2: Int) -> Bool
    /* get functions (Lua -> stack) */
    func newTable()
    func createTable(nArr: Int, nRec: Int)
    func getTable(idx: Int) -> LuaType
    func getField(idx: Int, k: String) -> LuaType
    func getI(idx: Int, i: Int64) -> LuaType
    func getGlobal(name: String) -> LuaType
    func rawGet(idx: Int) -> LuaType
    func rawGetI(idx: Int, i: Int64) -> LuaType
    func getMetatable(idx: Int) -> Bool
    /* set functions (stack -> Lua) */
    func setTable(idx: Int)
    func setField(idx: Int, k: String)
    func setI(idx: Int, i: Int64)
    func setGlobal(name: String)
    func rawSet(idx: Int)
    func rawSetI(idx: Int, i: Int64)
    func setMetatable(idx: Int)
    func register(name: String, f: @escaping SwiftFunction)
    /* 'load' and 'call' functions (load and run Lua code) */
    func load(chunk: Data, chunkName: String, mode: String) throws -> Int
    func call(nArgs: Int, nResults: Int)
    /* miscellaneous functions */
    func len(idx: Int)
    func concat(n: Int)

    func next(idx: Int) -> Bool

}
