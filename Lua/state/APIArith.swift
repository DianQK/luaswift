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
    let integerFunc: IArithOpFunc?
    let floatFunc: FArithOpFunc?
    
    init(_ integerFunc: IArithOpFunc?, _ floatFunc: FArithOpFunc?) {
        self.integerFunc = integerFunc
        self.floatFunc = floatFunc
    }
}

let operators: [Operator] = [
    Operator(iadd, fadd),
    Operator(isub, fsub),
    Operator(imul, fmul),
    Operator(imod, fmod),
    Operator(nil, pow),
    Operator(nil, div),
    Operator(iidiv, fidiv),
    Operator(band, nil),
    Operator(bor, nil),
    Operator(bxor, nil),
    Operator(shl, nil),
    Operator(shr, nil),
    Operator(iunm, funm),
    Operator(bnot, nil)
]



extension LuaState {

    // [-(2|1), +1, e]
    // http://www.lua.org/manual/5.3/manual.html#lua_arith
    func arith(op: ArithOp) {
        let a: LuaValue
        let b: LuaValue
        b = self.stack.pop()
        if op != .unm && op != .bnot {
            a = self.stack.pop()
        } else {
            a = b
        }

        let result = _arith(a: a, b: b, op: operators[op.rawValue])
        if result.isNil {
            fatalError("arithmetic error!")
        }
        self.stack.push(result)
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
        return LuaNil()
    }
    
}
