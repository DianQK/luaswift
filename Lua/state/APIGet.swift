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
        return self._getTable(t: t, k: k)
    }

    func getField(idx: Int, k: String) -> LuaType {
        let t = self.stack.get(idx: idx)
        return self._getTable(t: t, k: k)
    }

    func getI(idx: Int, i: Int64) -> LuaType {
        let t = self.stack.get(idx: idx)
        return self._getTable(t: t, k: i)
    }

    // push(t[k])
    private func _getTable(t: LuaValue, k: LuaValue) -> LuaType {
        if t.luaType == .table {
            let v = t.asTable.get(key: k)
            self.stack.push(v)
            return v.luaType
        }

        fatalError("not a table!") // todo
    }

    func getGlobal(name: String) -> LuaType {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        return self._getTable(t: t, k: name)
    }

}
