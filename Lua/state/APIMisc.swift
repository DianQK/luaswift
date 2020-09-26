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
    func len(idx: Int) {
        let val = self.stack.get(idx: idx)
        if val.luaType == .string {
            self.stack.push(Int64(val.asString.count))
            return
        }
        
        let (result, ok) = callMetamethod(a: val, b: val, mmName: "__len", ls: self)
        if ok {
            self.stack.push(result)
            return
        }
        
        if val.luaType == .table {
            self.stack.push(Int64(val.asTable.len()))
            return
        }

        fatalError("length error!")
    }
    
    // [-n, +1, e]
    // http://www.lua.org/manual/5.3/manual.html#lua_concat
    func concat(n: Int) {
        if n == 0 {
            self.stack.push("")
        } else if n >= 2 {
            for _ in (1..<n) {
                if self.isString(idx: -1) && self.isString(idx: -2) {
                    let s2 = self.toString(idx: -1)
                    let s1 = self.toString(idx: -2)
                    _ = self.stack.pop()
                    _ = self.stack.pop()
                    self.stack.push(s1 + s2)
                    continue
                }
                
                let b = self.stack.pop()
                let a = self.stack.pop()
                let (result, ok) = callMetamethod(a: a, b: b, mmName: "__concat", ls: self)
                if ok {
                    self.stack.push(result)
                    continue
                }
                
                fatalError("caoncatenation error!")
            }
        }
        // n == 1, do nothing
    }
    
}
