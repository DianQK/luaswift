//
//  consts.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

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
