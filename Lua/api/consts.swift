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
}


