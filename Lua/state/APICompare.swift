//
//  APICompare.swift
//  Lua
//
//  Created by Qing on 2020/9/20.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension LuaState {
    
    func compare(idx1: Int, idx2: Int, op: CompareOp) -> Bool {
        let a = self.stack.get(idx: idx1)
        let b = self.stack.get(idx: idx2)
        switch op {
        case .eq:
            return _eq(a: a, b: b)
        case .lt:
            return _lt(a: a, b: b)
        case .le:
            return _le(a: a, b: b)
        }
    }
    
    private func _eq(a: LuaValue, b: LuaValue) -> Bool {
        if a.isNil {
            return b.isNil
        } else if let x = a as? Bool {
            if let y = b as? Bool {
                return x == y
            } else {
                return false
            }
        } else if let x = a as? String {
            if let y = b as? String {
                return x == y
            } else {
                return false
            }
        } else if let x = a as? Int64 {
            if let y = b as? Int64 {
                return x == y
            } else if let y = b as? Double {
                return Double(x) == y
            } else {
                return false
            }
        } else if let x = a as? Double {
            if let y = b as? Double {
                return x == y
            } else if let y = b as? Int64 {
                return x == Double(y)
            } else {
                return false
            }
        } else if let x = a as? LuaTable {
            if let y = b as? LuaTable {
                return x === y
            } else {
                return false
            }
        }
        let aPointer = unsafeBitCast(a, to: Int.self)
        let bPointer = unsafeBitCast(b, to: Int.self)
        return aPointer == bPointer
    }
    
    private func _lt(a: LuaValue, b: LuaValue) -> Bool {
        if let x = a as? String {
            if let y = b as? String {
                return x < y
            }
        } else if let x = a as? Int64 {
            if let y = b as? Int64 {
                return x < y
            } else if let y = b as? Double {
                return Double(x) < y
            }
        } else if let x = a as? Double {
            if let y = b as? Double {
                return x < y
            } else if let y = b as? Int64 {
                return x < Double(y)
            }
        }
        fatalError("comparison error!")
    }
    
    private func _le(a: LuaValue, b: LuaValue) -> Bool {
        if let x = a as? String {
            if let y = b as? String {
                return x <= y
            }
        } else if let x = a as? Int64 {
            if let y = b as? Int64 {
                return x <= y
            } else if let y = b as? Double {
                return Double(x) <= y
            }
        } else if let x = a as? Double {
            if let y = b as? Double {
                return x <= y
            } else if let y = b as? Int64 {
                return x <= Double(y)
            }
        }
        fatalError("comparison error!")
    }
    
}
