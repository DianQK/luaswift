//
//  Math.swift
//  Lua
//
//  Created by dianqk on 2020/9/18.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

struct Math {

    /// 整除
    static func ifloorDiv(_ a: Int64, _ b: Int64) -> Int64 {
        if (a > 0 && b > 0) || (a < 0 && b < 0) || a % b == 0 {
            return a / b
        } else {
            return a / b - 1
        }
    }

    /// 整除
    static func ffloorDiv(_ a: Double, _ b: Double) -> Double {
        return floor(a / b)
    }

    /// 取模
    static func iMod(_ a: Int64, _ b: Int64) -> Int64 {
        return a - ifloorDiv(a, b) * b
    }

    /// 取模
    static func fMod(_ a: Double, _ b: Double) -> Double {
        return a - floor(a / b) * b
    }

    static func shiftLeft(_ a: Int64, n: Int64) -> Int64 {
        if n >= 0 {
            return a << UInt64(n)
        } else {
            return shiftRight(a, n: -n)
        }
    }

    static func shiftRight(_ a: Int64, n: Int64) -> Int64 {
        if n >= 0 {
            return Int64(UInt64(a) >> UInt64(n))
        } else {
            return shiftLeft(a, n: -n)
        }
    }

    static func floatToInteger(_ f: Double) -> (Int64, Bool) {
        let i = Int64(f)
        return (i, Double(i) == f)
    }

}
