//
//  LuaVMType.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol LuaVMType: LuaStateType {

    /// 返回当前 PC 地址（仅供测试）
    var pc: Int { get }
    /// 修改 PC 地址，用于跳转指令
    func addPC(n: Int)
    /// 取出当前指令，将 PC 指向下一条指令
    func fetch() -> Instruction
    /// 将指定常量推入栈顶
    func getConst(idx: Int)
    /// 将指定常量或栈值推入栈顶
    func getRK(rk: Int)

    func registerCount() -> Int
    func loadVararg(n: Int)
    func loadProto(idx: Int)

}
