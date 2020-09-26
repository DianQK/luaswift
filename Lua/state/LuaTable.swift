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
        switch (lhs.value.luaType, rhs.value.luaType) {
        case (.string, .string):
            return lhs.value.asString == rhs.value.asString
        case (.number, .number):
            switch (lhs.value.isInteger, rhs.value.isInteger) {
            case (true, true):
                return lhs.value.asInteger == rhs.value.asInteger
            default: // TODO: 应当考虑 Double 场景
                return false
            }
        default: // TODO: 这里的判断可能有遗漏
            return false
        }
    }

}

class LuaTable {
    
    var metatable: LuaTable?

    var arr: [LuaValue]
    var map: [LuaMapKey: LuaValue] // TODO: 需要创建一个专门的 struct 处理

    init(arr: [LuaValue], map: [LuaMapKey: LuaValue]) {
        self.arr = arr
        self.map = map
    }

    static func new(nArr: Int, nRec: Int) -> LuaTable {
        let arr: [LuaValue] = [LuaValue].init(repeating: LuaNil, count: nArr)
        let map = [LuaMapKey: LuaValue].init(minimumCapacity: nRec)
        return LuaTable(arr: arr, map: map)
    }

    private func _floatToInteger(key: LuaValue) -> LuaValue {
        if key.isFloat {
            return Int64(key.asFloat)
        }
        return key
    }

    func get(key: LuaValue) -> LuaValue { // TODO: 可以使用方法重载提升性能
        let key = _floatToInteger(key: key)
        if key.isInteger {
            let idx = key.asInteger
            if idx >= 0 && idx <= self.arr.count {
                return self.arr[Int(idx) - 1]
            }
        }
        return self.map[LuaMapKey(value: key)] ?? LuaNil
    }

    func put(key: LuaValue, val: LuaValue) {
        if key.isNil {
            fatalError("table index is nil!")
        }
        if key.isFloat && key.asFloat.isNaN {
            fatalError("table index is NaN!")
        }
        let key = _floatToInteger(key: key)

        if key.isInteger {
            let idx = key.asInteger
            if idx >= 1 {
                let arrLen = Int64(self.arr.count)
                if idx <= arrLen {
                    self.arr[Int(idx - 1)] = val
                    if idx == arrLen && val.isNil {
                        self._shrinkArray()
                    }
                    return
                }
                if idx == arrLen + 1 {
                    self.map.removeValue(forKey: LuaMapKey(value: key))
                    if !val.isNil {
                        self.arr.append(val)
                        self._expandArray()
                    }
                    return
                }
            }
        }

        if val.isNil {
            self.map.removeValue(forKey: LuaMapKey(value: key))
        } else {
            self.map[LuaMapKey(value: key)] = val
        }
    }

    private func _shrinkArray() {
        while let last = self.arr.last, last.isNil {
            self.arr.removeLast()
        }
    }

    private func _expandArray() {
        var idx = Int64(self.arr.count + 1)
        while let val = self.map[LuaMapKey(value: idx)] {
            self.map.removeValue(forKey: LuaMapKey(value: idx))
            self.arr.append(val)
            idx += 1
        }
    }

    func len() -> Int {
        self.arr.count
    }

}
