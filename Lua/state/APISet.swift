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
        var t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        let k = self.stack.pop()
        self._setTable(t: &t, k: k, v: v, idx: idx)
    }

    func setField(idx: Int, k: String) {
        var t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: &t, k: k, v: v, idx: idx)
    }

    func setI(idx: Int, i: Int64) {
        var t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: &t, k: i, v: v, idx: idx)
    }

    // t[k]=v
    private func _setTable(t: inout LuaValue, k: LuaValue, v: LuaValue, idx: Int) {
        if var tbl = t as? LuaTable {
            tbl.put(key: k, val: v) // TODO: 产生了额外的拷贝
            self.stack.set(idx: idx, val: tbl)
            return
        }

        fatalError("not a table!")
    }

    func setGlobal(name: String) {
        let t = self.registry.get(key: LUA_RIDX_GLOBALS)
        let v = self.stack.pop()
        if var tbl = t as? LuaTable {
            tbl.put(key: name, val: v) // FIXME: 产生了额外的拷贝，全局变量是共享的，可能在各种场景下凉凉
            self.registry.put(key: LUA_RIDX_GLOBALS, val: tbl)
            return
        }
        fatalError("not a table!")
    }

    func register(name: String, f: @escaping SwiftFunction) {
        self.pushSwiftFunction(f: f)
        self.setGlobal(name: name)
    }

}
