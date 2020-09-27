//
//  APIArith.swift
//  Lua
//
//  Created by Qing on 2020/9/20.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

typealias IArithOpFunc = (Int64, Int64) -> Int64
typealias FArithOpFunc = (Double, Double) -> Double

let iadd: IArithOpFunc = { $0 + $1 }
let fadd: FArithOpFunc = { $0 + $1 }
let isub: IArithOpFunc = { $0 - $1 }
let fsub: FArithOpFunc = { $0 - $1 }
let imul: IArithOpFunc = { $0 * $1 }
let fmul: FArithOpFunc = { $0 * $1 }
let imod: IArithOpFunc = Math.iMod
let fmod: FArithOpFunc = Math.fMod
let pow: FArithOpFunc = Foundation.pow
let div: FArithOpFunc = { $0 / $1 }
let iidiv: IArithOpFunc = Math.ifloorDiv
let fidiv: FArithOpFunc = Math.ffloorDiv
let band: IArithOpFunc = { $0 & $1 }
let bor: IArithOpFunc = { $0 | $1 }
let bxor: IArithOpFunc = { $0 ^ $1 }
let shl: IArithOpFunc = Math.shiftLeft
let shr: IArithOpFunc = Math.shiftRight
let iunm: IArithOpFunc = { (a, _) in -a }
let funm: FArithOpFunc = { (a, _) in -a }
let bnot: IArithOpFunc = { (a, _) in ~a }

struct Operator {
    let metamethod: String
    let integerFunc: IArithOpFunc?
    let floatFunc: FArithOpFunc?
    
    init(_ metamethod: String, _ integerFunc: IArithOpFunc?, _ floatFunc: FArithOpFunc?) {
        self.metamethod = metamethod
        self.integerFunc = integerFunc
        self.floatFunc = floatFunc
    }
}

let operators: [Operator] = [
    Operator("__add", iadd, fadd),
    Operator("__sub", isub, fsub),
    Operator("__mul", imul, fmul),
    Operator("__mod", imod, fmod),
    Operator("__pow", nil, pow),
    Operator("__div", nil, div),
    Operator("__idiv", iidiv, fidiv),
    Operator("__band", band, nil),
    Operator("__bor", bor, nil),
    Operator("__bxor", bxor, nil),
    Operator("__shl", shl, nil),
    Operator("__shr", shr, nil),
    Operator("__unm", iunm, funm),
    Operator("__bnot", bnot, nil)
]



extension LuaState {

    // [-(2|1), +1, e]
    // http://www.lua.org/manual/5.3/manual.html#lua_arith
    func arith(op: ArithOp) throws {
        let a: LuaValue
        let b: LuaValue
        b = try self.stack.pop()
        if op != .unm && op != .bnot {
            a = try self.stack.pop()
        } else {
            a = b
        }
        
        let _operator = operators[op.rawValue]

        let result = _arith(a: a, b: b, op: _operator)
        if result.luaType != .nil {
            try self.stack.push(result)
            return
        }
        
        let mm = _operator.metamethod
        let (_result, ok) = try callMetamethod(a: a, b: b, mmName: mm, ls: self)
        if ok {
            try self.stack.push(_result)
            return
        }
        
        throw LuaSwiftError("arithmetic error!")
    }
    
    private func _arith(a: LuaValue, b: LuaValue, op: Operator) -> LuaValue {
        if let integerFunc = op.integerFunc, op.floatFunc == nil {
            let x = a.toInteger
            let y = b.toInteger
            if x.ok && y.ok {
                return integerFunc(x.value, y.value)
            }
        } else {
            if let integerFunc = op.integerFunc {
                let x = a.toInteger
                let y = b.toInteger
                if x.ok && y.ok {
                    return integerFunc(x.value, y.value)
                }
            }
            if let floatFunc = op.floatFunc {
                let x = a.toFloat
                let y = b.toFloat
                if x.ok && y.ok {
                    return floatFunc(x.value, y.value)
                }
            }
        }
        return LuaNil
    }
    
}
