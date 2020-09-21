//
//  APIVM.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState: LuaVMType {

    func addPC(n: Int) {
        self.pc += n
    }

    func fetch() -> Instruction {
        let i = self.proto.code[self.pc]
        self.pc += 1
        return i
    }

    func getConst(idx: Int) {
        let c = self.proto.constants[idx]
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

}
