//
//  APISet.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func setTable(idx: Int) throws {
        let t = self.stack.get(idx: idx)
        let v = try self.stack.pop()
        let k = try self.stack.pop()
        try self._setTable(t: t, k: k, v: v, raw: false)
    }
    
    func rawSet(idx: Int) throws {
        let t = self.stack.get(idx: idx)
        let v = try self.stack.pop()
        let k = try self.stack.pop()
        try self._setTable(t: t, k: k, v: v, raw: true)
    }

    func setField(idx: Int, k: String) throws {
        let t = self.stack.get(idx: idx)
        let v = try self.stack.pop()
        try self._setTable(t: t, k: k, v: v, raw: false)
    }

    func setI(idx: Int, i: Int64) throws {
        let t = self.stack.get(idx: idx)
        let v = try self.stack.pop()
        try self._setTable(t: t, k: i, v: v, raw: false)
    }
    
    func rawSetI(idx: Int, i: Int64) throws {
        let t = self.stack.get(idx: idx)
        let v = try self.stack.pop()
        try self._setTable(t: t, k: i, v: v, raw: true)
    }

    // t[k]=v
    private func _setTable(t: LuaValue, k: LuaValue, v: LuaValue, raw: Bool) throws {
        if t.luaType == .table {
            let tbl = t.asTable
            if raw || tbl.get(key: k).luaType != .nil || !tbl.hasMetafield(fieldName: "__newindex") {
                try tbl.put(key: k, val: v)
            }
            return
        }
        
        if !raw {
            let mf = getMetafield(val: t, fieldName: "__newindex", ls: self)
            switch mf.luaType {
            case .table:
                try self._setTable(t: mf.asTable, k: k, v: v, raw: false)
                return
            case .function:
                try self.stack.push(mf)
                try self.stack.push(t)
                try self.stack.push(k)
                try self.stack.push(v)
                try self.call(nArgs: 3, nResults: 0)
                return
            default:
                break
            }
        }
        
        throw LuaSwiftError("index error!")
    }

    func setGlobal(name: String) throws {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        let v = try self.stack.pop()
        if t.luaType == .table {
            try t.asTable.put(key: name, val: v)
            return
        }
        throw LuaSwiftError("not a table!")
    }

    func register(name: String, f: @escaping SwiftFunction) throws {
        try self.pushSwiftFunction(f: f)
        try self.setGlobal(name: name)
    }
    
    func setMetatable(idx: Int) throws {
        let val = self.stack.get(idx: idx)
        let mtVal = try self.stack.pop()
        
        switch mtVal.luaType {
        case .nil:
            try Lua.setMetatable(val: val, mt: nil, ls: self)
        case .table:
            try Lua.setMetatable(val: val, mt: mtVal.asTable, ls: self)
        default:
            throw LuaSwiftError("table expected!") // TODO: 
        }
    }

}
