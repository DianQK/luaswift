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

extension Int64: LuaValue {

    var luaType: LuaType {
        .number
    }

}

extension Double: LuaValue {

    var luaType: LuaType {
        .number
    }

}


extension String: LuaValue {

    var luaType: LuaType {
        .string
    }

}

