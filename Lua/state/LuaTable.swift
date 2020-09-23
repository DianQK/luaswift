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
    var map: [LuaMapKey: LuaValue] // TODO: 需要创建一个专门的 struct 处理

    static func new(nArr: Int, nRec: Int) -> LuaTable {
        let arr: [LuaValue] = [LuaValue].init(repeating: LuaNil(), count: nArr)
        let map = [LuaMapKey: LuaValue].init(minimumCapacity: nRec)
        return LuaTable(arr: arr, map: map)
    }

    private func _floatToInteger(key: LuaValue) -> LuaValue {
        if let key = key as? Double {
            return Int64(key)
        }
        return key
    }

    func get(key: LuaValue) -> LuaValue { // TODO: 可以使用方法重载提升性能
        let key = _floatToInteger(key: key)
        if let idx = key as? Int64, idx >= 0 && idx <= self.arr.count {
            return self.arr[Int(idx) - 1]
        } else {
            return self.map[LuaMapKey(value: key)] ?? LuaNil()
        }
    }

    mutating func put(key: LuaValue, val: LuaValue) {
        if key.isNil {
            fatalError("table index is nil!")
        }
        if let f = key as? Double, f.isNaN {
            fatalError("table index is NaN!")
        }
        let key = _floatToInteger(key: key)

        if let idx = key as? Int64, idx >= 1 {
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

        if val.isNil {
            self.map.removeValue(forKey: LuaMapKey(value: key))
        } else {
            self.map[LuaMapKey(value: key)] = val
        }
    }

    private mutating func _shrinkArray() {
        while let last = self.arr.last, last.isNil {
            self.arr.removeLast()
        }
    }

    private mutating func _expandArray() {
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
