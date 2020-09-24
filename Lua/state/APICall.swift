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
        let c = Closure.prototype(proto: binaryChunk.mainFunc)
        self.stack.push(c)
        return 0
    }

    func call(nArgs: Int, nResults: Int) {
        let val = self.stack.get(idx: -(nArgs + 1))
        if let c = val as? Closure {
            switch c {
            case let .prototype(proto):
                print("call \(proto.source)<\(proto.lineDefined),\(proto.lastLineDefined)>")
                self.callLuaClosure(nArgs: nArgs, nResults: nResults, proto: proto, closure: c)
            case let .swiftFunc(swiftFunc):
                self.callSwiftClosure(nArgs: nArgs, nResults: nResults, swiftFunc: swiftFunc, closure: c)
            }
        } else {
            fatalError("not function!")
        }
    }

    func callSwiftClosure(nArgs: Int, nResults: Int, swiftFunc: SwiftFunction, closure: Closure) {
        // create new lua stack
        let newStack = LuaStack(size: nArgs + LUA_MINSTACK, state: self)
        newStack.closure = closure

        // pass args, pop func
        if nArgs > 0 {
            let args = self.stack.pop(n: nArgs)
            newStack.push(vals: args, n: nArgs)
        }
        _ = self.stack.pop()

        // run closure
        self.pushLuaStack(stack: newStack)
        let r = swiftFunc(self)
        self.popLuaStack()

        // return results
        if nResults != 0 {
            let results = newStack.pop(n: r)
            self.stack.check(n: results.count)
            self.stack.push(vals: results, n: nResults)
        }
    }

    func callLuaClosure(nArgs: Int, nResults: Int, proto: BinaryChunk.Prototype, closure: Closure) {
        let nRegs = Int(proto.maxStackSize)
        let nParams = Int(proto.numParams)
        let isVararg = proto.isVararg == 1

        // create new lua stack
        let newStack = LuaStack(size: nRegs + LUA_MINSTACK, state: self)
        newStack.closure = closure

        // pass args, pop func
        let funcAndArgs = self.stack.pop(n: nArgs + 1)
        newStack.push(vals: Array(funcAndArgs[1..<funcAndArgs.endIndex]), n: nParams)
        newStack.top = nRegs
        if nArgs > nParams && isVararg {
            
            newStack.varargs = Array(funcAndArgs[(nParams + 1)...(nArgs)])
            
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
//            print("[\(String(format: "%02d", pc))] \(inst.opName) ", terminator: "")
//            self.printStack()
            if inst.opcode == .RETURN {
                break
            }
        }
    }

}
