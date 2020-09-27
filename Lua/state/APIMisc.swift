//
//  APIMisc.swift
//  Lua
//
//  Created by Qing on 2020/9/20.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {
    
    // [-0, +1, e]
    // http://www.lua.org/manual/5.3/manual.html#lua_len
    func len(idx: Int) throws {
        let val = self.stack.get(idx: idx)
        if val.luaType == .string {
            try self.stack.push(Int64(val.asString.count))
            return
        }
        
        let (result, ok) = try callMetamethod(a: val, b: val, mmName: "__len", ls: self)
        if ok {
            try self.stack.push(result)
            return
        }
        
        if val.luaType == .table {
            try self.stack.push(Int64(val.asTable.len()))
            return
        }

        throw LuaSwiftError("length error!")
    }
    
    func rawLen(idx: Int) -> UInt {
        let val = self.stack.get(idx: idx)
        switch val.luaType {
        case .string:
            return UInt(val.asString.count)
        case .table:
            return UInt(val.asTable.len())
        default:
            return 0
        }
    }
    
    // [-n, +1, e]
    // http://www.lua.org/manual/5.3/manual.html#lua_concat
    func concat(n: Int) throws {
        if n == 0 {
            try self.stack.push("")
        } else if n >= 2 {
            for _ in (1..<n) {
                if self.isString(idx: -1) && self.isString(idx: -2) {
                    let s2 = try self.toString(idx: -1)
                    let s1 = try self.toString(idx: -2)
                    _ = try self.stack.pop()
                    _ = try self.stack.pop()
                    try self.stack.push(s1 + s2)
                    continue
                }
                
                let b = try self.stack.pop()
                let a = try self.stack.pop()
                let (result, ok) = try callMetamethod(a: a, b: b, mmName: "__concat", ls: self)
                if ok {
                    try self.stack.push(result)
                    continue
                }
                
                throw LuaSwiftError("caoncatenation error!")
            }
        }
        // n == 1, do nothing
    }

    func next(idx: Int) throws -> Bool {
        let val = self.stack.get(idx: idx)
        if val.luaType == .table {
            let t = val.asTable
            let key = try self.stack.pop()
            let nextKey = t.nextKey(key)
            if nextKey.luaType != .nil {
                try self.stack.push(nextKey)
                try self.stack.push(t.get(key: nextKey))
                return true
            }
            return false
        }
        throw LuaSwiftError("table expected!")
    }

    func error() throws -> Int {
        let err = try self.stack.pop()
        throw LuaInternalError(err: err)
    }
    
}
