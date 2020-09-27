//
//  InstUpvalue.swift
//  Lua
//
//  Created by dianqk on 2020/9/24.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    // R(A) := UpValue[B]
    static func getUpval(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1
        b += 1

        try vm.copy(fromIdx: LuaUpvalueIndex(i: b), toIdx: a)
    }

    // UpValue[B] := R(A)
    static func setUpval(i: Instruction, vm: LuaVMType) throws {
        var (a, b, _) = i.ABC
        a += 1
        b += 1

        try vm.copy(fromIdx: a, toIdx: LuaUpvalueIndex(i: b))
    }

    static func getTabUp(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1
        b += 1

        try vm.getRK(rk: c) // TODO: 这里可以通过直接使用返回值操作，减少栈的操作？毕竟 getTabUp 是个指令
        _ = try vm.getTable(idx: LuaUpvalueIndex(i: b))
        try vm.replace(idx: a)
    }

    // UpValue[A][RK(B)] := RK(C)
    static func setTabUp(i: Instruction, vm: LuaVMType) throws {
        var (a, b, c) = i.ABC
        a += 1

        try vm.getRK(rk: b)
        try vm.getRK(rk: c)
        try vm.setTable(idx: LuaUpvalueIndex(i: a))
    }


}
