//
//  InstMisc.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    // R(A) := R(B)
    func move(vm: LuaVMType) {
        var (a, b, _) = self.ABC
        a += 1
        b += 1
        vm.copy(fromIdx: b, toIdx: a)
    }

    // pc+=sBx; if (A) close all upvalues >= R(A - 1)
    func jmp(vm: LuaVMType) {
        let (a, sBx) = self.AsBx
        vm.addPC(n: sBx)
        if a != 0 {
            fatalError("todo: jmp!")
        }
    }

}
