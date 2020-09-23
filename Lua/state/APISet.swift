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
        self._setTable(t: &t, k: k, v: v)
    }

    func setField(idx: Int, k: String) {
        var t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: &t, k: k, v: v)
    }

    func setI(idx: Int, i: Int64) {
        var t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self._setTable(t: &t, k: i, v: v)
    }

    // t[k]=v
    private func _setTable(t: inout LuaValue, k: LuaValue, v: LuaValue) {
        if var tbl = t as? LuaTable {
            // TODO: 不确定能否设置成功
            tbl.put(key: k, val: v)
            return
        }

        fatalError("not a table!")
    }

}
