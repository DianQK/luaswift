//
//  LuaTable.swift
//  Lua
//
//  Created by dianqk on 2020/9/22.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol LuaHashValue: LuaValue {

    func hash(into hasher: inout Hasher)

}

extension String: LuaHashValue {}
extension Int64: LuaHashValue {}
extension Bool: LuaHashValue {}
extension Double: LuaHashValue {}

struct LuaMapKey: Hashable {

    let value: LuaValue

    func hash(into hasher: inout Hasher) {
        // TODO: 不同类型的 hash 冲突的处理
        if let value = self.value as? LuaHashValue {
            value.hash(into: &hasher)
        } else {
            fatalError("table index is nil/NaN")
        }
    }

    static func == (lhs: LuaMapKey, rhs: LuaMapKey) -> Bool {
        if let lhs = lhs.value as? String, let rhs = rhs.value as? String {
            return lhs == rhs
        } else if let lhs = lhs.value as? Int64, let rhs = rhs.value as? Int64 {
            return lhs == rhs
        } else if let lhs = lhs.value as? Double, let rhs = rhs.value as? Double {
            return lhs == rhs
        }
        // TODO: 这里的判断可能有遗漏
        return false
    }

}

struct LuaTable {

    var arr: [LuaValue]
    var map: [LuaMapKey: LuaValue]

}
