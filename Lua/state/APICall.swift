//
//  APICall.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {

    func load(chunk: Data, chunkName: String, mode: String) throws -> Int {
        let reader = Reader(data: data)
        let binaryChunk = try reader.undump()
        let c = Closure(proto: binaryChunk.mainFunc)
        self.stack.push(c)
        return 0
    }

    func call(nArgs: Int, nResults: Int) {
        let val = self.stack.get(idx: -(nArgs + 1))
        if let c = val as? Closure {
            print("call \(c.proto.source)<\(c.proto.lineDefined),\(c.proto.lastLineDefined)>")
            self.callLuaClosure(nArgs: nArgs, nResults: nResults, c: c)
        } else {
            fatalError("not function!")
        }
    }


    func callLuaClosure(nArgs: Int, nResults: Int, c: Closure) {
        let nRegs = Int(c.proto.maxStackSize)
        let nParams = Int(c.proto.numParams)
        let isVararg = c.proto.isVararg == 1

        // create new lua stack
        let newStack = LuaStack(size: nRegs + 20)
        newStack.closure = c

        // pass args, pop func
        let funcAndArgs = self.stack.pop(n: nArgs + 1)
        newStack.push(vals: Array(funcAndArgs[1..<funcAndArgs.endIndex]), n: nParams)
        newStack.top = nRegs
        if nArgs > nParams && isVararg {
            newStack.varargs = Array(funcAndArgs[(nParams + 1)..<funcAndArgs.endIndex])
        }

        // run closure
        self.pushLuaStack(stack: newStack)
        self.runLuaClosure()
        self.popLuaStack()

        // return results
        if nResults != 0 {
            let result = newStack.pop(n: newStack.top - nRegs)
            self.stack.check(n: result.count)
            self.stack.push(vals: result, n: nResults)
        }
    }

    func runLuaClosure() {
        while true {
            let inst = self.fetch()
            inst.execute(vm: self)
//            print("[\(String(format: "%02d", pc+1))] \(inst.opName) ", terminator: "")
//            self.printStack()
            if inst.opcode == .RETURN {
                break
            }
        }
    }

}
