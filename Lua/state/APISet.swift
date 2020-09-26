//
//  APISet.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func setTable(idx: Int) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        let k = self.stack.pop()
        self._setTable(t: t, k: k, v: v, raw: false)
    }

    func setField(idx: Int, k: String) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: t, k: k, v: v, raw: false)
    }

    func setI(idx: Int, i: Int64) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: t, k: i, v: v, raw: false)
    }

    // t[k]=v
    private func _setTable(t: LuaValue, k: LuaValue, v: LuaValue, raw: Bool) {
        if t.luaType == .table {
            let tbl = t.asTable
            if raw || tbl.get(key: k).luaType != .nil || !tbl.hasMetafield(fieldName: "__newindex") {
                tbl.put(key: k, val: v)
            }
            return
        }
        
        if !raw {
            let mf = getMetafield(val: t, fieldName: "__newindex", ls: self)
            switch mf.luaType {
            case .table:
                self._setTable(t: mf.asTable, k: k, v: v, raw: false)
                return
            case .function:
                self.stack.push(mf)
                self.stack.push(t)
                self.stack.push(k)
                self.stack.push(v)
                self.call(nArgs: 3, nResults: 0)
                return
            default:
                break
            }
        }
        
        fatalError("index error!")
    }

    func setGlobal(name: String) {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        let v = self.stack.pop()
        if t.luaType == .table {
            t.asTable.put(key: name, val: v)
            return
        }
        fatalError("not a table!")
    }

    func register(name: String, f: @escaping SwiftFunction) {
        self.pushSwiftFunction(f: f)
        self.setGlobal(name: name)
    }

}
