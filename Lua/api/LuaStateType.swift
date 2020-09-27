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

struct LuaInternalError: LocalizedError {

    let err: LuaValue

    var errorDescription: String? {
        switch err.luaType {
        case .string:
            return err.asString
        default:
            return "\(err)"
        }
    }

}

struct LuaSwiftError: LocalizedError {

    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }

}

protocol LuaStateType: class {

    func getTop() -> Int
    func absIndex(idx: Int) -> Int
    func checkStack(n: Int) -> Bool
    func pop(n: Int) throws
    func copy(fromIdx: Int, toIdx: Int) throws
    func pushValue(idx: Int) throws
    func replace(idx: Int) throws
    func insert(idx: Int)
    func remove(idx: Int) throws
    func rotate(idx: Int, n: Int)
    func setTop(idx: Int) throws
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
    func toString(idx: Int) throws -> String
    func toStringX(idx: Int) throws -> (String, Bool)
    func toSwiftFunction(idx: Int) -> SwiftFunction?
    func rawLen(idx: Int) -> UInt
    /* push functions (Go -> stack) */
    func pushNil() throws
    func pushBoolean(_ b: Bool) throws
    func pushInteger(_ n: Int64) throws
    func pushNumber(_ n: Double) throws
    func pushString(_ s: String) throws
    func pushSwiftFunction(f: @escaping SwiftFunction) throws
    func pushGlobalTable() throws
    func pushSwiftClosure(f: @escaping SwiftFunction, n: Int) throws
    /* Comparison and arithmetic functions */
    func arith(op: ArithOp) throws
    func compare(idx1: Int, idx2: Int, op: CompareOp) throws -> Bool
    func rawEqual(idx1: Int, idx2: Int) throws -> Bool
    /* get functions (Lua -> stack) */
    func newTable() throws
    func createTable(nArr: Int, nRec: Int) throws
    func getTable(idx: Int) throws -> LuaType
    func getField(idx: Int, k: String) throws -> LuaType
    func getI(idx: Int, i: Int64) throws -> LuaType
    func getGlobal(name: String) throws -> LuaType
    func rawGet(idx: Int) throws -> LuaType
    func rawGetI(idx: Int, i: Int64) throws -> LuaType
    func getMetatable(idx: Int) throws -> Bool
    /* set functions (stack -> Lua) */
    func setTable(idx: Int) throws
    func setField(idx: Int, k: String) throws
    func setI(idx: Int, i: Int64) throws
    func setGlobal(name: String) throws
    func rawSet(idx: Int) throws
    func rawSetI(idx: Int, i: Int64) throws
    func setMetatable(idx: Int) throws
    func register(name: String, f: @escaping SwiftFunction) throws
    /* 'load' and 'call' functions (load and run Lua code) */
    func load(chunk: Data, chunkName: String, mode: String) throws -> Int
    func call(nArgs: Int, nResults: Int) throws
    /* miscellaneous functions */
    func len(idx: Int) throws
    func concat(n: Int) throws

    func next(idx: Int) throws -> Bool

    func error() throws -> Int
    func pCall(nArgs: Int, nResults: Int, msgh: Int) throws -> LuaThreadStatus

}
