//
//  consts.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let LUA_MINSTACK = 20
let LUAI_MAXSTACK = 1000000
let LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1000
let LUA_RIDX_GLOBALS: Int64 = 2

/* basic types */
enum LuaType: Int {

    case none = -1
    case `nil`
    case boolean
    case lightuserdata
    case number
    case string
    case table
    case function
    case userdata
    case thread

    var name: String {
        switch self {
        case .none:
            return "no value"
        case .nil:
            return "nil"
        case .boolean:
            return "boolean"
        case .number:
            return "number"
        case .string:
            return "string"
        case .table:
            return "table"
        case .function:
            return "function"
        case .thread:
            return "thread"
        case .userdata, .lightuserdata:
            return "userdata"
        }
    }
}

/* arithmetic functions */
enum ArithOp: Int {
    case add = 0     // +
    case sub         // -
    case mul         // *
    case mod         // %
    case pow         // ^
    case div         // /
    case idiv        // //
    case band        // &
    case bor         // |
    case bxor        // ~
    case shl         // <<
    case shr         // >>
    case unm         // -
    case bnot        // ~
}

/* comparison functions */
enum CompareOp: Int {
    case eq = 0    // ==
    case lt        // <
    case le        // <=
}
