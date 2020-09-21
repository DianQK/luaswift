//
//  InstFor.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    // R(A)-=R(A+2); pc+=sBx
    static func forPrep(i: Instruction, vm: LuaVMType) {
        var (a, sBx) = i.AsBx
        a += 1

        if vm.type(idx: a) == .string {
            vm.pushNumber(vm.toNumber(idx: a))
            vm.replace(idx: a)
        }
        if vm.type(idx: a + 1) == .string {
            vm.pushNumber(vm.toNumber(idx: a + 1))
            vm.replace(idx: a + 1)
        }
        if vm.type(idx: a + 2) == .string {
            vm.pushNumber(vm.toNumber(idx: a + 2))
            vm.replace(idx: a + 1)
        }

        vm.pushValue(idx: a)
        vm.pushValue(idx: a + 2)
        vm.arith(op: .sub)
        vm.replace(idx: a)
        vm.addPC(n: sBx)
    }

    // R(A)+=R(A+2);
    // if R(A) <?= R(A+1) then {
    //   pc+=sBx; R(A+3)=R(A)
    // }
    static func forLoop(i: Instruction, vm: LuaVMType) {
        var (a, sBx) = i.AsBx
        a += 1

        // R(A)+=R(A+2);
        vm.pushValue(idx: a + 2)
        vm.pushValue(idx: a)
        vm.arith(op: .add)
        vm.replace(idx: a)

        let isPositiveStep = vm.toNumber(idx: a + 2) >= 0
        if (isPositiveStep && vm.compare(idx1: a, idx2: a + 1, op: .le))
            || (!isPositiveStep && vm.compare(idx1: a + 1, idx2: a, op: .le)) {
            // pc+=sBx; R(A+3)=R(A)
            vm.addPC(n: sBx)
            vm.copy(fromIdx: a, toIdx: a + 3)
        }
    }

}
