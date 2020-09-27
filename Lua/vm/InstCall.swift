//
//  InstCall.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    static func closure(i: Instruction, vm: LuaVMType) {
        var (a, bx) = i.ABx
        a += 1

        vm.loadProto(idx: bx)
        vm.replace(idx: a)
    }

    // R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
    static func call(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1

//         println(":::"+ vm.StackToString())
        let nArgs = _pushFuncAndArgs(a: a, b: b, vm: vm)
        vm.call(nArgs: nArgs, nResults: c - 1)
        _popResults(a: a, c: c, vm: vm)
    }

    private static func _pushFuncAndArgs(a: Int, b: Int, vm: LuaVMType) -> Int {
        if b >= 1 { // b-1 = args
            _ = vm.checkStack(n: b)
            for i in (a..<(a+b)) {
                vm.pushValue(idx: i)
            }
            return b - 1
        } else {
            _fixStack(a: a, vm: vm)
            return vm.getTop() - vm.registerCount() - 1
        }
    }

    private static func _fixStack(a: Int, vm: LuaVMType) {
        let x = Int(vm.toInteger(idx: -1))
        vm.pop(n: 1)

        _ = vm.checkStack(n: x - a)
        for i in (a..<x) {
            vm.pushValue(idx: i)
        }
        vm.rotate(idx: vm.registerCount() + 1, n: x - a)
    }

    private static func _popResults(a: Int, c: Int, vm: LuaVMType) {
        // return value count c-1
        if c == 1 {
            // no results
        } else if c > 1 {
            for i in (a...(a + c - 2)).reversed() {
                vm.replace(idx: i)
            }
        } else {
            // leave results on stack
            _ = vm.checkStack(n: 1)
            vm.pushInteger(Int64(a))
        }
    }

    // return R(A), ... ,R(A+B-2)
    static func _return(i: Instruction, vm: LuaVMType) {
        var (a, b, _) = i.ABC
        a += 1

        if b == 1 {
            // no return values
        } else if b > 1 {
            // b-1 return values
            _ = vm.checkStack(n: b - 1)
            for i in (a...(a+b-2)) {
                vm.pushValue(idx: i)
            }
        } else {
            _fixStack(a: a, vm: vm)
        }
    }

    // R(A), R(A+1), ..., R(A+B-2) = vararg
    static func vararg(i: Instruction, vm: LuaVMType) {
        var (a, b, _) = i.ABC
        a += 1

        if b != 1 { // b==0 or b>1
            vm.loadVararg(n: b - 1)
            _popResults(a: a, c: b, vm: vm)
        }
    }

    // return R(A)(R(A+1), ... ,R(A+B-1))
    static func tailCall(i: Instruction, vm: LuaVMType) {
        var (a, b, _) = i.ABC
        a += 1

        // TODO: optimize tail call!
        let c = 0
        let nArgs = _pushFuncAndArgs(a: a, b: b, vm: vm)
        vm.call(nArgs: nArgs, nResults: c - 1)
        _popResults(a: a, c: c, vm: vm)
    }

    // R(A+1) := R(B); R(A) := R(B)[RK(C)]
    static func _self(i: Instruction, vm: LuaVMType) {
        var (a, b, c) = i.ABC
        a += 1
        b += 1

        vm.copy(fromIdx: b, toIdx: a + 1)
        vm.getRK(rk: c)
        _ = vm.getTable(idx: b)
        vm.replace(idx: a)
    }

    static func tForCall(i: Instruction, vm: LuaVMType) {
        var (a, _, c) = i.ABC
        a += 1

        _ = _pushFuncAndArgs(a: a, b: 3, vm: vm)
        vm.call(nArgs: 2, nResults: c)
        _popResults(a: a + 3, c: c + 1, vm: vm)
    }

}
