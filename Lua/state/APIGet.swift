//
//  APIGet.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func newTable() throws {
        try self.createTable(nArr: 0, nRec: 0)
    }

    func createTable(nArr: Int, nRec: Int) throws {
        let t = LuaTable.new(nArr: nArr, nRec: nRec)
        try self.stack.push(t)
    }

    func getTable(idx: Int) throws -> LuaType {
        let t = self.stack.get(idx: idx)
        let k = try self.stack.pop()
        return try self._getTable(t: t, k: k, raw: false)
    }
    
    func rawGet(idx: Int) throws -> LuaType {
        let t = self.stack.get(idx: idx)
        let k = try self.stack.pop()
        return try self._getTable(t: t, k: k, raw: true)
    }

    func getField(idx: Int, k: String) throws -> LuaType {
        let t = self.stack.get(idx: idx)
        return try self._getTable(t: t, k: k, raw: false)
    }

    func getI(idx: Int, i: Int64) throws -> LuaType {
        let t = self.stack.get(idx: idx)
        return try self._getTable(t: t, k: i, raw: false)
    }
    
    func rawGetI(idx: Int, i: Int64) throws -> LuaType {
        let t = self.stack.get(idx: idx)
        return try self._getTable(t: t, k: i, raw: true)
    }

    // push(t[k])
    private func _getTable(t: LuaValue, k: LuaValue, raw: Bool) throws -> LuaType {
        if t.luaType == .table {
            let tbl = t.asTable
            let v = tbl.get(key: k)
            if raw || v.luaType != .nil || !tbl.hasMetafield(fieldName: "__index") {
                try self.stack.push(v)
                return v.luaType
            }
        }
        
        if !raw {
            let mf = getMetafield(val: t, fieldName: "__index", ls: self)
            switch mf.luaType {
            case .table:
                let x = mf.asTable
                return try self._getTable(t: x, k: k, raw: false)
            case .function:
                try self.stack.push(mf)
                try self.stack.push(t)
                try self.stack.push(k)
                try self.call(nArgs: 2, nResults: 1)
                let v = self.stack.get(idx: -1)
                return v.luaType
            default:
                break
            }
        }

        throw LuaSwiftError("index error!")
    }

    func getGlobal(name: String) throws -> LuaType {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        return try self._getTable(t: t, k: name, raw: false)
    }
    
    func getMetatable(idx: Int) throws -> Bool {
        let val = self.stack.get(idx: idx)
        if let mt = Lua.getMetatable(val: val, ls: self) {
            try self.stack.push(mt)
            return true
        } else {
            return false
        }
    }

}
