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
        let reader = Reader(data: chunk)
        let binaryChunk = try reader.undump()
        let c = Closure(proto: binaryChunk.mainFunc)
        if !binaryChunk.mainFunc.upvalues.isEmpty {
            let env = self.registry.get(key: LUA_RIDX_GLOBALS)
            c.upvals[0] = Upvalue(val: env)
        }
        try self.stack.push(c)
        return 0
    }

    func call(nArgs: Int, nResults: Int) throws {
        var nArgs = nArgs
        var val = self.stack.get(idx: -(nArgs + 1))
        var isClosure = val.luaType == .function
        
        if !isClosure {
            let mf = getMetafield(val: val, fieldName: "__call", ls: self)
            if mf.luaType == .function {
                val = mf
                isClosure = true
                try self.stack.push(val)
                self.insert(idx: -(nArgs + 2))
                nArgs += 1
            }
        }
        
        if isClosure {
            let c = val.asClosure
            if let proto = c.proto {
                try self.callLuaClosure(nArgs: nArgs, nResults: nResults, proto: proto, closure: c)
            } else if let swiftFunc = c.swiftFunc {
                try self.callSwiftClosure(nArgs: nArgs, nResults: nResults, swiftFunc: swiftFunc, closure: c)
            } else {
                throw LuaSwiftError("closure has not func")
            }
        } else {
            throw LuaSwiftError("not function!")
        }
    }

    func callSwiftClosure(nArgs: Int, nResults: Int, swiftFunc: SwiftFunction, closure: Closure) throws {
        // create new lua stack
        let newStack = LuaStack(size: nArgs + LUA_MINSTACK, state: self)
        newStack.closure = closure

        // pass args, pop func
        if nArgs > 0 {
            let args = try self.stack.pop(n: nArgs)
            try newStack.push(vals: args, n: nArgs)
        }
        _ = try self.stack.pop()

        // run closure
        self.pushLuaStack(stack: newStack)
        let r = try swiftFunc(self)
        self.popLuaStack()

        // return results
        if nResults != 0 {
            let results = try newStack.pop(n: r)
            self.stack.check(n: results.count)
            try self.stack.push(vals: results, n: nResults)
        }
    }

    func callLuaClosure(nArgs: Int, nResults: Int, proto: BinaryChunk.Prototype, closure: Closure) throws {
        let nRegs = Int(proto.maxStackSize)
        let nParams = Int(proto.numParams)
        let isVararg = proto.isVararg == 1

        // create new lua stack
        let newStack = LuaStack(size: nRegs + LUA_MINSTACK, state: self)
        newStack.closure = closure

        // pass args, pop func
        let funcAndArgs = try self.stack.pop(n: nArgs + 1)
        try newStack.push(vals: Array(funcAndArgs[1..<funcAndArgs.endIndex]), n: nParams)
        newStack.top = nRegs
        if nArgs > nParams && isVararg {
            
            newStack.varargs = Array(funcAndArgs[(nParams + 1)...(nArgs)])
            
        }

        // run closure
        self.pushLuaStack(stack: newStack)
        try self.runLuaClosure()
        self.popLuaStack()

        // return results
        if nResults != 0 {
            let result = try newStack.pop(n: newStack.top - nRegs)
            self.stack.check(n: result.count)
            try self.stack.push(vals: result, n: nResults)
        }
    }

    func runLuaClosure() throws {
        while true {
            let inst = self.fetch()
//            print("[\(String(format: "%02d", pc))] \(inst.opName) ", terminator: "")
            try inst.execute(vm: self)
//            self.printStack()
            if inst.opcode == .RETURN {
                break
            }
        }
    }

    func pCall(nArgs: Int, nResults: Int, msgh: Int) throws -> Int {
        let caller = self.stack
        var status = LuaThreadStatus.errrun
        do {
            try self.call(nArgs: nArgs, nResults: nResults)
            status = .ok
        } catch let error {
            if msgh != 0 {
                throw error
            }
            while self.stack !== caller {
                self.popLuaStack()
            }
            try self.stack.push(error.localizedDescription) // TODO: 完善 error 信息
        }
        return status.rawValue
    }

}
