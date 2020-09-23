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

}

extension LuaValue {

    var toBoolean: Bool {
        switch self.luaType {
        case .nil:
            return false
        case .boolean:
            return self as! Bool
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

}

protocol LuaNumberValue: LuaValue {

    var description: String { get }

}

extension LuaNumberValue {

    var luaType: LuaType {
        .number
    }

    var toStringX: (value: String, ok: Bool) {
        return (self.description, true)
    }

}

struct LuaNil: LuaValue {

    var luaType: LuaType {
        .nil
    }
    
    var isNil: Bool { true }

}

extension Bool: LuaValue {

    var luaType: LuaType {
        .boolean
    }

}

extension Int64: LuaNumberValue {

    var toFloat: (value: Double, ok: Bool) {
        return (Double(self), true)
    }

    var toInteger: (value: Int64, ok: Bool) {
        return (self, true)
    }

}

extension Double: LuaNumberValue {

    var toFloat: (value: Double, ok: Bool) {
        return (self, true)
    }

    var toInteger: (value: Int64, ok: Bool) {
        return Math.floatToInteger(self)
    }

}


extension String: LuaValue {

    var luaType: LuaType {
        .string
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

}

extension LuaTable: LuaValue {

    var luaType: LuaType {
        .table
    }

}
