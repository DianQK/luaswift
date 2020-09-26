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
        if !binaryChunk.mainFunc.upvalues.isEmpty {
            let env = self.registry.get(key: LUA_RIDX_GLOBALS)
            c.upvals[0] = Upvalue(val: env)
        }
        self.stack.push(c)
        return 0
    }

    func call(nArgs: Int, nResults: Int) {
        var nArgs = nArgs
        var val = self.stack.get(idx: -(nArgs + 1))
        var isClosure = val.luaType == .function
        
        if !isClosure {
            let mf = getMetafield(val: val, fieldName: "__cal", ls: self)
            if mf.luaType == .function {
                val = mf
                isClosure = true
                self.stack.push(val)
                self.insert(idx: -(nArgs + 2))
                nArgs += 1
            }
        }
        
        if isClosure {
            let c = val.asClosure
            if let proto = c.proto {
                self.callLuaClosure(nArgs: nArgs, nResults: nResults, proto: proto, closure: c)
            } else if let swiftFunc = c.swiftFunc {
                self.callSwiftClosure(nArgs: nArgs, nResults: nResults, swiftFunc: swiftFunc, closure: c)
            } else {
                fatalError("closure has not func")
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
//            print("[\(String(format: "%02d", pc))] \(inst.opName) ", terminator: "")
            inst.execute(vm: self)
//            self.printStack()
            if inst.opcode == .RETURN {
                break
            }
        }
    }

}
