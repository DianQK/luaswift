//
//  InstOperators.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    // R(A) := RK(B) op RK(C)
    private static func _binaryArith(i: Instruction, vm: LuaVMType, op: ArithOp) throws {
        var (a, b, c) = i.ABC
        a += 1

        try vm.getRK(rk: b)
        try vm.getRK(rk: c)
        try vm.arith(op: op)
        try vm.replace(idx: a)
    }

    // R(A) := op R(B)
    private static func _unaryArith(i: Instruction, vm: LuaVMType, op: ArithOp) throws {
        var (a, b, _) = i.ABC
        a += 1
        b += 1

        try vm.pushValue(idx: b)
        try vm.arith(op: op)
        try vm.replace(idx: a)
    }

    static func add(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i, vm: vm, op: .add) }  // +
    static func sub(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .sub) }  // -
    static func mul(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .mul) }  // *
    static func mod(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .mod) }  // %
    static func pow(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .pow) }  // ^
    static func div(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .div) }  // /
    static func idiv(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .idiv) } // //
    static func band(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .band) } // &
    static func bor(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .bor) }  // |
    static func bxor(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .bxor) } // ~
    static func shl(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .shl) }  // <<
    static func shr(i: Instruction, vm: LuaVMType) throws { try _binaryArith(i: i,vm: vm, op: .shr) }  // >>
    static func unm(i: Instruction, vm: LuaVMType) throws { try _unaryArith(i: i,vm: vm, op: .unm) }   // -
    static func bnot(i: Instruction, vm: LuaVMType) throws { try _unaryArith(i: i,vm: vm, op: .bnot) }  // ~

    // R(A) := length of R(B)
    static func length(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1
        b += 1

        try vm.len(idx: b)
        try vm.replace(idx: a)
    }

    // R(A) := R(B).. ... ..R(C)
    static func concat(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1
        b += 1
        c += 1

        let n = c - b + 1
        _ = vm.checkStack(n: n)

        for i in (b...c) {
            try vm.pushValue(idx: i)
        }
        try vm.concat(n: n)
        try vm.replace(idx: a)
    }

    // if ((RK(B) op RK(C)) ~= A) then pc++
    private static func _compare(i: Instruction, vm: LuaVMType, op: CompareOp) throws {
        let (a, b, c) = i.ABC

        try vm.getRK(rk: b)
        try vm.getRK(rk: c)

        if try vm.compare(idx1: -2, idx2: -1, op: op) != (a != 0) {
            vm.addPC(n: 1)
        }

        try vm.pop(n: 2)
    }

    static func eq(i: Instruction, vm: LuaVMType) throws { try _compare(i: i, vm: vm, op: .eq) } // ==
    static func lt(i: Instruction, vm: LuaVMType) throws { try _compare(i: i, vm: vm, op: .lt) } // <
    static func le(i: Instruction, vm: LuaVMType) throws { try _compare(i: i, vm: vm, op: .le) } // <=

    // R(A) := not R(B)
    static func not(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1
        b += 1

        try vm.pushBoolean(vm.toBoolean(idx: b))
        try vm.replace(idx: a)
    }

    // if (R(B) <=> C) then R(A) := R(B) else pc++
    static func testSet(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1
        b += 1

        if vm.toBoolean(idx: b) == (c != 0) {
            try vm.copy(fromIdx: b, toIdx: a)
        } else {
            vm.addPC(n: 1)
        }
    }

    // if not (R(A) <=> C) then pc++
    static func test(i: Instruction, vm: LuaVMType) {
        var (a, _, c) = i.ABC
        a += 1

        if vm.toBoolean(idx: a) != (c != 0) {
            vm.addPC(n: 1)
        }
    }

}
