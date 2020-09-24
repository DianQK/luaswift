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
        self._setTable(t: t, k: k, v: v, idx: idx)
    }

    func setField(idx: Int, k: String) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: t, k: k, v: v, idx: idx)
    }

    func setI(idx: Int, i: Int64) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: t, k: i, v: v, idx: idx)
    }

    // t[k]=v
    private func _setTable(t: LuaValue, k: LuaValue, v: LuaValue, idx: Int) {
        if let tbl = t as? LuaTable {
            tbl.put(key: k, val: v)
            return
        }
        fatalError("not a table!")
    }

    func setGlobal(name: String) {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        let v = self.stack.pop()
        if let tbl = t as? LuaTable {
            tbl.put(key: name, val: v)
            return
        }
        fatalError("not a table!")
    }

    func register(name: String, f: @escaping SwiftFunction) {
        self.pushSwiftFunction(f: f)
        self.setGlobal(name: name)
    }

}
