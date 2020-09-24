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
    static func move(i: Instruction, vm: LuaVMType) {
        var (a, b, _) = i.ABC
        a += 1
        b += 1
        vm.copy(fromIdx: b, toIdx: a)
    }

    // pc+=sBx; if (A) close all upvalues >= R(A - 1)
    static func jmp(i: Instruction, vm: LuaVMType) {
        let (a, sBx) = i.AsBx
        vm.addPC(n: sBx)
        if a != 0 {
            vm.closeUpvalues(a: a)
        }
    }

    static func todo(i: Instruction, vm: LuaVMType) {
        fatalError("todo: \(i.opName)!")
    }

}
