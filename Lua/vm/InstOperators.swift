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

}
