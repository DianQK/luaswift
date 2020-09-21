//
//  InstLoad.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    // R(A), R(A+1), ..., R(A+B) := nil
    static func loadNil(i: Instruction, vm: LuaVMType) {
        var (a, b, _) = i.ABC
        a += 1

        vm.pushNil()
        for i in (a...a+b) {
            vm.copy(fromIdx: -1, toIdx: i)
        }
        vm.pop(n: 1)
    }

    // R(A) := (bool)B; if (C) pc++
    static func loadBool(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1

        vm.pushBoolean(b != 0)
        vm.replace(idx: a)

        if c != 0 {
            vm.addPC(n: 1)
        }
    }

    // R(A) := Kst(Bx)
    static func loadK(i: Instruction, vm: LuaVMType) {
        var (a, bx) = i.ABx
        a += 1

        vm.getConst(idx: bx)
        vm.replace(idx: a)
    }

    // R(A) := Kst(extra arg)
    static func loadKx(i: Instruction, vm: LuaVMType) {
        var (a, _) = i.ABx
        a += 1
        let ax = vm.fetch().Ax

//        vm.checkStack(n: 1)
        vm.getConst(idx: ax)
        vm.replace(idx: a)
    }

}
