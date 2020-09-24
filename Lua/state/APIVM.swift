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

    func getConst(idx: Int) {
        let c = self.stack.closure!.proto!.constants[idx]
        self.stack.push(c.luaValue)
    }

    func getRK(rk: Int) {
        if rk > 0xFF { // constant
            self.getConst(idx: rk & 0xFF)
        } else { // register
            // Lua 虚拟机指令操作数里携带的寄存器索引是从 0 开始的，而 Lua API 里的栈索引是从1开始的，所以当需要把寄存器索引当成栈索引使用时，要对寄存器索引加 1。
            self.pushValue(idx: rk + 1)
        }
    }

    func registerCount() -> Int {
        return Int(self.stack.closure!.proto!.maxStackSize)
    }

    func loadVararg(n: Int) {
        var n = n
        if n < 0 {
            n = self.stack.varargs!.count
        }

        self.stack.check(n: n)
        self.stack.push(vals: self.stack.varargs!, n: n)
    }

    func loadProto(idx: Int) {
        let proto = self.stack.closure!.proto!.protos[idx]
        let closure = Closure.prototype(proto: proto)
        self.stack.push(closure)
    }

}
