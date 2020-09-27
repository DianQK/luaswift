//
//  APIAccess.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func typeName(_ tp: LuaType) -> String {
        return tp.name
    }

    func type(idx: Int) -> LuaType {
        guard self.stack.isValid(idx: idx) else {
            return .none
        }
        return self.stack.get(idx: idx).luaType
    }

    func isNone(idx: Int) -> Bool {
        return self.type(idx: idx) == .none
    }

    func isNil(idx: Int) -> Bool {
        return self.type(idx: idx) == .nil
    }

    func isNoneOrNil(idx: Int) -> Bool {
        let t = self.type(idx: idx)
        return t == .none || t == .nil
    }

    func isBoolean(idx: Int) -> Bool {
        return self.type(idx: idx) == .boolean
    }

    func isString(idx: Int) -> Bool {
        let t = self.type(idx: idx)
        return t == .string || t == .number
    }

    func isNumber(idx: Int) -> Bool {
        let (_, ok) = self.toNumberX(idx: idx)
        return ok
    }

    func isInteger(idx: Int) -> Bool {
        let val = self.stack.get(idx: idx)
        return val.isInteger
    }

    func toBoolean(idx: Int) -> Bool {
        let val = self.stack.get(idx: idx)
        return val.toBoolean
    }

    func toNumber(idx: Int) -> Double {
        let (n, _) = self.toNumberX(idx: idx)
        return n
    }

    func toNumberX(idx: Int) -> (Double, Bool) {
        let val = self.stack.get(idx: idx)
        return val.toFloat
    }

    func toInteger(idx: Int) -> Int64 {
        let (i, _) = self.toIntegerX(idx: idx)
        return i
    }

    func toIntegerX(idx: Int) -> (Int64, Bool) {
        let val = self.stack.get(idx: idx)
        return val.toInteger
    }

    func toString(idx: Int) throws -> String {
        let (s, _) = try self.toStringX(idx: idx)
        return s
    }

    func toStringX(idx: Int) throws -> (String, Bool) {
        let val = self.stack.get(idx: idx)
        switch val.luaType {
        case .number:
            let (s, _) = val.toStringX
            try self.stack.set(idx: idx, val: s)
            return (s, true)
        default:
            return val.toStringX
        }
    }

    func toSwiftFunction(idx: Int) -> SwiftFunction? {
        let val = self.stack.get(idx: idx)
        if val.luaType == .function {
            return val.asClosure.swiftFunc
        } else {
            return nil
        }
    }

    func isTable(idx: Int) -> Bool {
        self.type(idx: idx) == .table
    }

    func isThread(idx: Int) -> Bool {
        self.type(idx: idx) == .thread
    }

    func isFunction(idx: Int) -> Bool {
        self.type(idx: idx) == .function
    }

    func isSwiftFunction(idx: Int) -> Bool {
        let val = self.stack.get(idx: idx)
        if val.luaType == .function {
            return val.asClosure.swiftFunc != nil
        } else {
            return false
        }
    }

}
