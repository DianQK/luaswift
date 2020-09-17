//
//  APIStack.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func getTop() -> Int {
        self.stack.top
    }

    func absIndex(idx: Int) -> Int {
        self.stack.absIndex(idx: idx)
    }

    func checkStack(n: Int) -> Bool {
        self.stack.check(n: n)
        return true // never fails
    }

    func pop(n: Int) {
        self.setTop(idx: -n - 1)
    }

    func copy(fromIdx: Int, toIdx: Int) {
        let val = self.stack.get(idx: fromIdx)
        self.stack.set(idx: toIdx, val: val)
    }

    func pushValue(idx: Int) {
        let val = self.stack.get(idx: idx)
        self.stack.push(val)
    }

    func replace(idx: Int) {
        let val = self.stack.pop()
        self.stack.set(idx: idx, val: val)
    }

    func insert(idx: Int) {
        self.rotate(idx: idx, n: 1)
    }

    func remove(idx: Int) {
        self.rotate(idx: idx, n: -1)
        self.pop(n: 1)
    }

    func rotate(idx: Int, n: Int) {
        let t = self.stack.top - 1
        let p = self.stack.absIndex(idx: idx) - 1
        var m: Int
        if n >= 0 {
            m = t - n
        } else {
            m = p - n - 1
        }
        self.stack.reverse(from: p, to: m)
        self.stack.reverse(from: m + 1, to: t)
        self.stack.reverse(from: p, to: t)
    }

    func setTop(idx: Int) {
        let newTop = self.stack.absIndex(idx: idx)
        guard newTop >= 0 else {
            fatalError("stack underflow!")
        }

        let n = self.stack.top - newTop
        if n > 0 {
            for _ in 0..<n {
                _ = self.stack.pop()
            }
        } else if n < 0 {
            for _ in 0..<n {
                self.stack.push(LuaNil())
            }
        }
    }

}
