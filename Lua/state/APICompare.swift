//
//  APICompare.swift
//  Lua
//
//  Created by Qing on 2020/9/20.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {
    
    func rawEqual(idx1: Int, idx2: Int) throws -> Bool {
        if !self.stack.isValid(idx: idx1) || !self.stack.isValid(idx: idx2) {
            return false
        }

        let a = self.stack.get(idx: idx1)
        let b = self.stack.get(idx: idx2)
        return try _eq(a: a, b: b, ls: nil)
    }
    
    func compare(idx1: Int, idx2: Int, op: CompareOp) throws -> Bool {
        let a = self.stack.get(idx: idx1)
        let b = self.stack.get(idx: idx2)
        switch op {
        case .eq:
            return try _eq(a: a, b: b, ls: self)
        case .lt:
            return try _lt(a: a, b: b)
        case .le:
            return try _le(a: a, b: b)
        }
    }
    
    private func _eq(a: LuaValue, b: LuaValue, ls: LuaState?) throws -> Bool {
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
            let x = a.asTable
            let y = b.asTable
            if let ls = ls, x !== y {
                let (result, ok) = try callMetamethod(a: x, b: y, mmName: "__eq", ls: ls)
                if ok {
                    return result.toBoolean
                }
            }
            return x === y
        case (.nil, _), (_, .nil):
            return false
        default:
            // FIXME: 其他类型判断不当
            let aPointer = unsafeBitCast(a, to: Int.self)
            let bPointer = unsafeBitCast(b, to: Int.self)
            return aPointer == bPointer
        }
    }
    
    private func _lt(a: LuaValue, b: LuaValue) throws -> Bool {
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
            let (result, ok) = try callMetamethod(a: a, b: b, mmName: "__lt", ls: self)
            if ok {
                return result.toBoolean
            }
            throw LuaSwiftError("comparison error!")
        }
    }
    
    private func _le(a: LuaValue, b: LuaValue) throws -> Bool {
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
            do {
                let (result, ok) = try callMetamethod(a: a, b: b, mmName: "__le", ls: self)
                if ok {
                    return result.toBoolean
                }
            }
            do {
                let (result, ok) = try callMetamethod(a: b, b: a, mmName: "__lt", ls: self)
                if ok {
                    return result.toBoolean
                }
            }
            throw LuaSwiftError("comparison error!")
        }
    }
    
}
