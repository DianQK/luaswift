//
//  LuaValue.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol LuaValue {

    var luaType: LuaType { get }

    var toStringX: (String, Bool) { get }

}

extension LuaValue {

    var toBoolean: Bool {
        switch self.luaType {
        case .nil:
            return false
        case .boolean:
            return self as! Bool
        default:
            return true
        }
    }

    var toStringX: (String, Bool) {
        return ("", false)
    }

}

protocol LuaNumberValue: LuaValue {

    var description: String { get }

}

extension LuaNumberValue {

    var luaType: LuaType {
        .number
    }

    var toStringX: (String, Bool) {
        return (self.description, true)
    }

}

struct LuaNil: LuaValue {

    var luaType: LuaType {
        .nil
    }

}

extension Bool: LuaValue {

    var luaType: LuaType {
        .boolean
    }

}

extension Int64: LuaNumberValue {

}

extension Double: LuaNumberValue {

}


extension String: LuaValue {

    var luaType: LuaType {
        .string
    }

    var toStringX: (String, Bool) {
        (self, true)
    }

}
