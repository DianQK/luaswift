//
//  APIGet.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func newTable() {
        self.createTable(nArr: 0, nRec: 0)
    }

    func createTable(nArr: Int, nRec: Int) {
        let t = LuaTable.new(nArr: nArr, nRec: nRec)
        self.stack.push(t)
    }

    func getTable(idx: Int) -> LuaType {
        let t = self.stack.get(idx: idx)
        let k = self.stack.pop()
        return self._getTable(t: t, k: k, raw: false)
    }

    func getField(idx: Int, k: String) -> LuaType {
        let t = self.stack.get(idx: idx)
        return self._getTable(t: t, k: k, raw: false)
    }

    func getI(idx: Int, i: Int64) -> LuaType {
        let t = self.stack.get(idx: idx)
        return self._getTable(t: t, k: i, raw: false)
    }

    // push(t[k])
    private func _getTable(t: LuaValue, k: LuaValue, raw: Bool) -> LuaType {
        if t.luaType == .table {
            let tbl = t.asTable
            let v = tbl.get(key: k)
            if raw || v.luaType != .nil || !tbl.hasMetafield(fieldName: "__index") {
                self.stack.push(v)
                return v.luaType
            }
        }
        
        if !raw {
            let mf = getMetafield(val: t, fieldName: "__index", ls: self)
            switch mf.luaType {
            case .table:
                let x = mf.asTable
                return self._getTable(t: x, k: k, raw: false)
            case .function:
                self.stack.push(mf)
                self.stack.push(t)
                self.stack.push(k)
                self.call(nArgs: 2, nResults: 1)
                let v = self.stack.get(idx: -1)
                return v.luaType
            default:
                break
            }
        }

        fatalError("index error!")
    }

    func getGlobal(name: String) -> LuaType {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        return self._getTable(t: t, k: name, raw: false)
    }

}
