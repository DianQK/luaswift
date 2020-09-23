//
//  InstTable.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let LFIELDS_PER_FLUSH = 50

extension Instruction {

    // R(A) := {} (size = B,C)
    static func newTable(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1

        vm.createTable(nArr: fb2int(x: b), nRec: fb2int(x: c))
        vm.replace(idx: a)
    }

    // R(A) := R(B)[RK(C)]
    static func getTable(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1
        b += 1

        vm.getRK(rk: c)
        _ = vm.getTable(idx: b)
        vm.replace(idx: a)
    }

    // R(A)[RK(B)] := RK(C)
    static func setTable(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1

        vm.getRK(rk: b)
        vm.getRK(rk: c)
        vm.setTable(idx: a)
    }

    // R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
    static func setList(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1

        if c > 0 {
            c = c - 1
        } else {
            c = vm.fetch().Ax
        }

        let bIsZero = b == 0
        if bIsZero {
            b = Int(vm.toInteger(idx: -1)) - a - 1
            vm.pop(n: 1)
        }

        _ = vm.checkStack(n: 1)
        var idx = Int64(c * LFIELDS_PER_FLUSH)
        for j in (1...b) {
            idx += 1
            vm.pushValue(idx: a + j)
            vm.setI(idx: a, i: idx) // TODO: 性能优化点？直接设置值，跳过 vm api 操作
        }

        if bIsZero {
            for j in ((vm.registerCount() + 1)...vm.getTop()) {
                idx += 1
                vm.pushValue(idx: j)
                vm.setI(idx: a, i: idx)
            }

            // clear stack
            vm.setTop(idx: vm.registerCount())
        }
    }

}
