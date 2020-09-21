//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

//let luaState = LuaState.new()
//luaState.pushInteger(1)
//luaState.pushString("2.0")
//luaState.pushString("3.0")
//luaState.pushNumber(4.0)
//luaState.printStack()
//
//luaState.arith(op: .add); luaState.printStack()
//luaState.arith(op: .bnot); luaState.printStack()
//luaState.len(idx: 2); luaState.printStack()
//luaState.concat(n: 3); luaState.printStack()
//luaState.pushBoolean(luaState.compare(idx1: 1, idx2: 2, op: .eq))
//luaState.printStack()

print(CommandLine.arguments)

let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
let data = try Data(contentsOf: fileUrl)

let reader = Reader(data: data)
let binaryChunk = try reader.undump()

func luaMain(proto: BinaryChunk.Prototype) {
    let nRegs = Int(proto.maxStackSize)
    let ls = LuaState(stackSize: nRegs + 8, proto: proto)
    ls.setTop(idx: nRegs)
    while true {
        let pc = ls.pc
        let inst = ls.fetch()
        if inst.opcode != .RETURN {
            inst.execute(vm: ls)
            print("[\(String(format: "%02d", pc+1))] \(inst.opName) ", terminator: "")
            ls.printStack()
        } else {
            break
        }
    }
}

luaMain(proto: binaryChunk.mainFunc)
