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
    static func forPrep(i: Instruction, vm: LuaVMType) throws {
        var (a, sBx) = i.AsBx
        a += 1

        if vm.type(idx: a) == .string {
            try vm.pushNumber(vm.toNumber(idx: a))
            try vm.replace(idx: a)
        }
        if vm.type(idx: a + 1) == .string {
            try vm.pushNumber(vm.toNumber(idx: a + 1))
            try vm.replace(idx: a + 1)
        }
        if vm.type(idx: a + 2) == .string {
            try vm.pushNumber(vm.toNumber(idx: a + 2))
            try vm.replace(idx: a + 1)
        }

        try vm.pushValue(idx: a)
        try vm.pushValue(idx: a + 2)
        try vm.arith(op: .sub)
        try vm.replace(idx: a)
        vm.addPC(n: sBx)
    }

    // R(A)+=R(A+2);
    // if R(A) <?= R(A+1) then {
    //   pc+=sBx; R(A+3)=R(A)
    // }
    static func forLoop(i: Instruction, vm: LuaVMType) throws {
        var (a, sBx) = i.AsBx
        a += 1

        // R(A)+=R(A+2);
        try vm.pushValue(idx: a + 2)
        try vm.pushValue(idx: a)
        try vm.arith(op: .add)
        try vm.replace(idx: a)

        let isPositiveStep = vm.toNumber(idx: a + 2) >= 0

        func jump() throws {
            // pc+=sBx; R(A+3)=R(A)
            vm.addPC(n: sBx)
            try vm.copy(fromIdx: a, toIdx: a + 3)
        }

        if isPositiveStep {
            if try vm.compare(idx1: a, idx2: a + 1, op: .le) {
                try jump()
            }
        } else {
            if try vm.compare(idx1: a + 1, idx2: a, op: .le) {
                try jump()
            }
        }
    }

    static func tForLoop(i: Instruction, vm: LuaVMType) throws {
        var (a, sBx) = i.AsBx
        a += 1

        if !vm.isNil(idx: a + 1) {
            try vm.copy(fromIdx: a + 1, toIdx: a)
            vm.addPC(n: sBx)
        }
    }

}
