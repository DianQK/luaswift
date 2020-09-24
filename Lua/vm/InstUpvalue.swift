//
//  InstUpvalue.swift
//  Lua
//
//  Created by dianqk on 2020/9/24.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Instruction {

    static func getTabUp(i: Instruction, vm: LuaVMType) {
        var (a, _, c) = i.ABC
        a += 1

        vm.pushGlobalTable()
        vm.getRK(rk: c)
        _ = vm.getTable(idx: -2)
        vm.replace(idx: a)
        vm.pop(n: 1)
    }

}
