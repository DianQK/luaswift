//
//  APICompare.swift
//  Lua
//
//  Created by Qing on 2020/9/20.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {
    
    func compare(idx1: Int, idx2: Int, op: CompareOp) -> Bool {
        let a = self.stack.get(idx: idx1)
        let b = self.stack.get(idx: idx2)
        switch op {
        case .eq:
            return _eq(a: a, b: b)
        case .lt:
            return _lt(a: a, b: b)
        case .le:
            return _le(a: a, b: b)
        }
    }
    
    private func _eq(a: LuaValue, b: LuaValue) -> Bool {
        switch (a.luaType, b.luaType) {
        case (.nil, .nil):
            return true
        case (.boolean, .boolean):
            return a.asBoolean == b.asBoolean
        case (.string, .string):
            return a.asString == b.asString
        case (.number, .number):
            switch (a.isInteger, b.isInteger) {
            case (true, false):
                return Double(a.asInteger) == b.asFloat
            case (true, true):
                return a.asInteger == b.asInteger
            case (false, false):
                return a.asFloat == b.asFloat
            case (false, true):
                return a.asFloat == Double(b.asInteger)
            }
        case (.table, .table):
            return a.asTable === a.asTable
        default:
            // FIXME: 其他类型判断不当
            let aPointer = unsafeBitCast(a, to: Int.self)
            let bPointer = unsafeBitCast(b, to: Int.self)
            return aPointer == bPointer
        }
    }
    
    private func _lt(a: LuaValue, b: LuaValue) -> Bool {
        switch (a.luaType, b.luaType) {
        case (.string, .string):
            return a.asString < b.asString
        case (.number, .number):
            switch (a.isInteger, b.isInteger) {
            case (true, false):
                return Double(a.asInteger) < b.asFloat
            case (true, true):
                return a.asInteger < b.asInteger
            case (false, false):
                return a.asFloat < b.asFloat
            case (false, true):
                return a.asFloat < Double(b.asInteger)
            }
        default:
            fatalError("comparison error!")
        }
    }
    
    private func _le(a: LuaValue, b: LuaValue) -> Bool {
        switch (a.luaType, b.luaType) {
        case (.string, .string):
            return a.asString <= b.asString
        case (.number, .number):
            switch (a.isInteger, b.isInteger) {
            case (true, false):
                return Double(a.asInteger) <= b.asFloat
            case (true, true):
                return a.asInteger <= b.asInteger
            case (false, false):
                return a.asFloat <= b.asFloat
            case (false, true):
                return a.asFloat <= Double(b.asInteger)
            }
        default:
            fatalError("comparison error!")
        }
    }
    
}
