//
//  APIVM.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState: LuaVMType {

    var pc: Int {
        self.stack.pc
    }

    func addPC(n: Int) {
        self.stack.pc += n
    }

    func fetch() -> Instruction {
        let i = self.stack.closure!.proto!.code[self.stack.pc]
        self.stack.pc += 1
        return i
    }

    func getConst(idx: Int) throws {
        let c = self.stack.closure!.proto!.constants[idx]
        try self.stack.push(c.luaValue)
    }

    func getRK(rk: Int) throws {
        if rk > 0xFF { // constant
            try self.getConst(idx: rk & 0xFF)
        } else { // register
            // Lua 虚拟机指令操作数里携带的寄存器索引是从 0 开始的，而 Lua API 里的栈索引是从1开始的，所以当需要把寄存器索引当成栈索引使用时，要对寄存器索引加 1。
            try self.pushValue(idx: rk + 1)
        }
    }

    func registerCount() -> Int {
        return Int(self.stack.closure!.proto!.maxStackSize)
    }

    func loadVararg(n: Int) throws {
        var n = n
        if n < 0 {
            n = self.stack.varargs!.count
        }

        self.stack.check(n: n)
        try self.stack.push(vals: self.stack.varargs!, n: n)
    }

    func loadProto(idx: Int) throws {
        let subProto = self.stack.closure!.proto!.protos[idx]
        let closure = Closure(proto: subProto)
        try self.stack.push(closure)

        for (i, uvInfo) in subProto.upvalues.enumerated() {
            let uvIdx = Int(uvInfo.idx)
            if uvInfo.instack == 1 { // 捕获当前函数中的局部变量
//                if stack.openuvs == nil {
//                    stack.openuvs = [:]
//                }
                if let openuv = stack.openuvs[uvIdx] {
                    closure.upvals[i] = openuv
                } else {
                    closure.upvals[i] = Upvalue(val: stack.slots[uvIdx])
                    stack.openuvs[uvIdx] = closure.upvals[i]
                }
            } else { // 捕获更外围的函数中的局部变量
                closure.upvals[i] = stack.closure!.upvals[uvIdx]
            }
        }

    }

    func closeUpvalues(a: Int) {
        for (i, _) in self.stack.openuvs.enumerated() {
            if i >= a - 1 {
                // FIXME: 修复以下空缺功能
//                let val = openuv.value // 引用改复制一个值
//                openuv.value = val // 复制的值重新设置
                self.stack.openuvs.removeValue(forKey: i)
            }
        }
    }

}
