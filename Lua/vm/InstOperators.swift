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
    private func _binaryArith(vm: LuaVMType, op: ArithOp) {
        var (a, b, c) = self.ABC
        a += 1

        vm.getRK(rk: b)
        vm.getRK(rk: c)
        vm.arith(op: op)
        vm.replace(idx: a)
    }

    // R(A) := op R(B)
    private func _unaryArith(vm: LuaVMType, op: ArithOp) {
        var (a, b, _) = self.ABC
        a += 1
        b += 1

        vm.pushValue(idx: b)
        vm.arith(op: op)
        vm.replace(idx: a)
    }

    func add(vm: LuaVMType)  { _binaryArith(vm: vm, op: .add) }  // +
    func sub(vm: LuaVMType)  { _binaryArith(vm: vm, op: .sub) }  // -
    func mul(vm: LuaVMType)  { _binaryArith(vm: vm, op: .mul) }  // *
    func mod(vm: LuaVMType)  { _binaryArith(vm: vm, op: .mod) }  // %
    func pow(vm: LuaVMType)  { _binaryArith(vm: vm, op: .pow) }  // ^
    func div(vm: LuaVMType)  { _binaryArith(vm: vm, op: .div) }  // /
    func idiv(vm: LuaVMType) { _binaryArith(vm: vm, op: .idiv) } // //
    func band(vm: LuaVMType) { _binaryArith(vm: vm, op: .band) } // &
    func bor(vm: LuaVMType)  { _binaryArith(vm: vm, op: .bor) }  // |
    func bxor(vm: LuaVMType) { _binaryArith(vm: vm, op: .bxor) } // ~
    func shl(vm: LuaVMType)  { _binaryArith(vm: vm, op: .shl) }  // <<
    func shr(vm: LuaVMType)  { _binaryArith(vm: vm, op: .shr) }  // >>
    func unm(vm: LuaVMType)  { _unaryArith(vm: vm, op: .unm) }   // -
    func bnot(vm: LuaVMType) { _unaryArith(vm: vm, op: .bnot) }  // ~

    // R(A) := length of R(B)
    func length(vm: LuaVMType) {
        var (a, b, _) = self.ABC
        a += 1
        b += 1

        vm.len(idx: b)
        vm.replace(idx: a)
    }

    // R(A) := R(B).. ... ..R(C)
    func concat(vm: LuaVMType) {
        var (a, b, c) = self.ABC
        a += 1
        b += 1
        c += 1

        let n = c - b + 1
        _ = vm.checkStack(n: n)

        for i in (b...c) {
            vm.pushValue(idx: i)
        }
        vm.concat(n: n)
        vm.replace(idx: a)
    }

    // if ((RK(B) op RK(C)) ~= A) then pc++
    private func _compare(vm: LuaVMType, op: CompareOp) {
        let (a, b, c) = self.ABC

        vm.getRK(rk: b)
        vm.getRK(rk: c)

        if vm.compare(idx1: -2, idx2: -1, op: op) != (a != 0) {
            vm.addPC(n: 1)
        }

        vm.pop(n: 2)
    }

    func eq(vm: LuaVMType) { _compare(vm: vm, op: .eq) } // ==
    func lt(vm: LuaVMType) { _compare(vm: vm, op: .lt) } // <
    func le(vm: LuaVMType) { _compare(vm: vm, op: .le) } // <=

    // R(A) := not R(B)
    func not(vm: LuaVMType) {
        var (a, b, _) = self.ABC
        a += 1
        b += 1

        vm.pushBoolean(vm.toBoolean(idx: b))
        vm.replace(idx: a)
    }

    // if (R(B) <=> C) then R(A) := R(B) else pc++
    func testSet(vm: LuaVMType) {
        var (a, b, c) = self.ABC
        a += 1
        b += 1

        if vm.toBoolean(idx: b) == (c != 0) {
            vm.copy(fromIdx: b, toIdx: a)
        } else {
            vm.addPC(n: 1)
        }
    }

    // if not (R(A) <=> C) then pc++
    func test(vm: LuaVMType) {
        var (a, _, c) = self.ABC
        a += 1

        if vm.toBoolean(idx: a) != (c != 0) {
            vm.addPC(n: 1)
        }
    }

}
