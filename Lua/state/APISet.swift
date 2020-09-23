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

}
