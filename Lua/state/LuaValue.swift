//
//  LuaValue.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol LuaValue {

    var luaType: LuaType { get }

    var toStringX: (value: String, ok: Bool) { get }
    var toFloat: (value: Double, ok: Bool) { get }
    var toInteger: (value: Int64, ok: Bool) { get }
    
    var isNil: Bool { get }

    var asString: String { get }
    var asInteger: Int64 { get }
    var asBoolean: Bool { get }
    var asFloat: Double { get }
    var asTable: LuaTable { get }
    var asClosure: Closure { get }

    var isFloat: Bool { get } // TODO: 也应当考虑使用 switch case
    var isInteger: Bool { get }

}

let _none = LuaType.none
let _nil = LuaType.nil
let _boolean = LuaType.boolean
let _lightuserdata = LuaType.lightuserdata
let _number = LuaType.number
let _string = LuaType.string
let  _table = LuaType.table
let _function = LuaType.function

extension LuaValue {

    var toBoolean: Bool {
        switch self.luaType {
        case .nil:
            return false
        case .boolean:
            return self.asBoolean
        default:
            return true
        }
    }

    var toStringX: (value: String, ok: Bool) {
        return ("", false)
    }

    var toFloat: (value: Double, ok: Bool) {
        return (0, false)
    }

    var toInteger: (value: Int64, ok: Bool) {
        return (0, false)
    }
    
    var isNil: Bool { false }

    var asString: String { fatalError("can not as string") }
    var asInteger: Int64 { fatalError("can not as integer") }
    var asBoolean: Bool { fatalError("can not as boolean") }
    var asFloat: Double { fatalError("can not as float") }
    var asTable: LuaTable { fatalError("can not as table") }
    var asClosure: Closure { fatalError("can not as closure") }

    var isFloat: Bool { false }
    var isInteger: Bool { false }

}

protocol LuaNumberValue: LuaValue {

    var description: String { get }

}

extension LuaNumberValue {

    var luaType: LuaType {
        _number
    }

    var toStringX: (value: String, ok: Bool) {
        return (self.description, true)
    }

}

private struct _LuaNil: LuaValue {

    var luaType: LuaType {
        _nil
    }
    
    var isNil: Bool { true }

}

let LuaNil: LuaValue = _LuaNil()

extension Bool: LuaValue {

    var luaType: LuaType {
        _boolean
    }

    var asBoolean: Bool { self }

}

extension Int64: LuaNumberValue {

    var toFloat: (value: Double, ok: Bool) {
        return (Double(self), true)
    }

    var toInteger: (value: Int64, ok: Bool) {
        return (self, true)
    }

    var asInteger: Int64 { self }

    var isInteger: Bool { true }

}

extension Double: LuaNumberValue {

    var toFloat: (value: Double, ok: Bool) {
        return (self, true)
    }

    var toInteger: (value: Int64, ok: Bool) {
        return Math.floatToInteger(self)
    }

    var isFloat: Bool { true }

    var asFloat: Double { self }

}


extension String: LuaValue {

    var luaType: LuaType {
        _string
    }

    var toStringX: (value: String, ok: Bool) {
        (self, true)
    }

    var toFloat: (value: Double, ok: Bool) {
        if let f = Double(self) {
            return (f, true)
        } else {
            return (0, false)
        }
    }

    var toInteger: (value: Int64, ok: Bool) {
        if let i = Int64(self) {
            return (i, true)
        } else {
            return (0, false)
        }
    }

    var asString: String { self }

}

extension LuaTable: LuaValue {

    var luaType: LuaType {
        _table
    }

    var asTable: LuaTable { self }

}

extension Closure: LuaValue {

    var luaType: LuaType {
        _function
    }

    var asClosure: Closure { self }

}

func setMetatable(val: LuaValue, mt: LuaTable?, ls: LuaState) throws {
    if val.luaType == .table {
        val.asTable.metatable = mt
        return
    }
    let key = String(format: "_MT%d", val.luaType.rawValue)
    try ls.registry.put(key: key, val: mt ?? LuaNil)
}

func getMetatable(val: LuaValue, ls: LuaState) -> LuaTable? {
    if val.luaType == .table {
        return val.asTable.metatable
    }
        
    let key = String(format: "_MT%d", val.luaType.rawValue)
    let mt = ls.registry.get(key: key)
    if mt.luaType == .table {
        return mt.asTable
    }
    
    return nil
}

func getMetafield(val: LuaValue, fieldName: String, ls: LuaState) -> LuaValue {
    if let mt = getMetatable(val: val, ls: ls) {
        return mt.get(key: fieldName)
    }
    return LuaNil
}

func callMetamethod(a: LuaValue, b: LuaValue, mmName: String, ls: LuaState) throws -> (LuaValue, Bool) {
    var mm = getMetafield(val: a, fieldName: mmName, ls: ls)
    if mm.luaType == .nil {
        mm = getMetafield(val: b, fieldName: mmName, ls: ls)
        if mm.luaType == .nil {
            return (LuaNil, false)
        }
    }

    ls.stack.check(n: 4)
    try ls.stack.push(mm)
    try ls.stack.push(a)
    try ls.stack.push(b)
    try ls.call(nArgs: 2, nResults: 1)
    return (try ls.stack.pop(), true)
}
