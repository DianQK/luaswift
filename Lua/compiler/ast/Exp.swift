//
//  Exp.swift
//  Lua
//
//  Created by 呀哈哈 on 2020/10/4.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol Exp {

}

struct NilExp: Exp {
    let line: Int
}

struct TrueExp: Exp {
    let line: Int
}

struct FalseExp: Exp {
    let line: Int
}

struct VarargExp: Exp {
    let line: Int
}

struct IntegerExp: Exp {
    let line: Int
    let val: Int64
}

struct FloatExp: Exp {
    let line: Int
    let val: Double
}

struct StringExp: Exp {
    let line: Int
    let str: String
}

struct NameExp: Exp {
    let line: Int
    let name: String
}

struct UnopExp: Exp {
    let line: Int
    let op: Int
    let exp: Exp
}

struct BinopExp: Exp {
    let line: Int
    let op: Int
    let exp1: Exp
    let exp2: Exp
}

struct Concat: Exp {
    let line: Int
    let exps: [Exp]
}

struct TableConstructorExp: Exp {
    let line: Int
    let lastLine: Int
    let keyExps: [Exp]
    let valExps: [Exp]
}

struct FuncDefExp: Exp {
    let line: Int
    let lastLine: Int
    let parList: [String]
    let isVararg: Bool
    let block: Block
}

struct ParensExp: Exp {
    let exp: Exp
}

struct TableAccessExp: Exp {
    let lastLine: Int
    let prefixExp: Exp
    let keyExp: Exp
}

struct FuncCallExp: Exp {
    let line: Int
    let lastLine: Int
    let prefixExp: Exp
    let nameExp: StringExp
    let args: [Exp]
}
