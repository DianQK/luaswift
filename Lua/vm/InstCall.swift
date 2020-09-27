//
//  InstCall.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    static func closure(i: Instruction, vm: LuaVMType) throws {
        var (a, bx) = i.ABx
        a += 1

        try vm.loadProto(idx: bx)
        try vm.replace(idx: a)
    }

    // R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
    static func call(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1

//         println(":::"+ vm.StackToString())
        let nArgs = try _pushFuncAndArgs(a: a, b: b, vm: vm)
        try vm.call(nArgs: nArgs, nResults: c - 1)
        try _popResults(a: a, c: c, vm: vm)
    }

    private static func _pushFuncAndArgs(a: Int, b: Int, vm: LuaVMType) throws -> Int {
        if b >= 1 { // b-1 = args
            _ = vm.checkStack(n: b)
            for i in (a..<(a+b)) {
                try vm.pushValue(idx: i)
            }
            return b - 1
        } else {
            try _fixStack(a: a, vm: vm)
            return vm.getTop() - vm.registerCount() - 1
        }
    }

    private static func _fixStack(a: Int, vm: LuaVMType) throws {
        let x = Int(vm.toInteger(idx: -1))
        try vm.pop(n: 1)

        _ = vm.checkStack(n: x - a)
        for i in (a..<x) {
            try vm.pushValue(idx: i)
        }
        vm.rotate(idx: vm.registerCount() + 1, n: x - a)
    }

    private static func _popResults(a: Int, c: Int, vm: LuaVMType) throws {
        // return value count c-1
        if c == 1 {
            // no results
        } else if c > 1 {
            for i in (a...(a + c - 2)).reversed() {
                try vm.replace(idx: i)
            }
        } else {
            // leave results on stack
            _ = vm.checkStack(n: 1)
            try vm.pushInteger(Int64(a))
        }
    }

    // return R(A), ... ,R(A+B-2)
    static func _return(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1

        if b == 1 {
            // no return values
        } else if b > 1 {
            // b-1 return values
            _ = vm.checkStack(n: b - 1)
            for i in (a...(a+b-2)) {
                try vm.pushValue(idx: i)
            }
        } else {
            try _fixStack(a: a, vm: vm)
        }
    }

    // R(A), R(A+1), ..., R(A+B-2) = vararg
    static func vararg(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1

        if b != 1 { // b==0 or b>1
            try vm.loadVararg(n: b - 1)
            try _popResults(a: a, c: b, vm: vm)
        }
    }

    // return R(A)(R(A+1), ... ,R(A+B-1))
    static func tailCall(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1

        // TODO: optimize tail call!
        let c = 0
        let nArgs = try _pushFuncAndArgs(a: a, b: b, vm: vm)
        try vm.call(nArgs: nArgs, nResults: c - 1)
        try _popResults(a: a, c: c, vm: vm)
    }

    // R(A+1) := R(B); R(A) := R(B)[RK(C)]
    static func _self(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1
        b += 1

        try vm.copy(fromIdx: b, toIdx: a + 1)
        try vm.getRK(rk: c)
        _ = try vm.getTable(idx: b)
        try vm.replace(idx: a)
    }

    static func tForCall(i: Instruction, vm: LuaVMType) throws {
        var (a, _, c) = i.ABC
        a += 1

        _ = try _pushFuncAndArgs(a: a, b: 3, vm: vm)
        try vm.call(nArgs: 2, nResults: c)
        try _popResults(a: a + 3, c: c + 1, vm: vm)
    }

}
