//
//  fpb.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

/*
** converts an integer to a "floating point byte", represented as
** (eeeeexxx), where the real value is (1xxx) * 2^(eeeee - 1) if
** eeeee != 0 and (xxx) otherwise.
 */
func int2fb(x: Int) -> Int {
    var e = 0 /* exponent */
    if x < 8 {
        return x
    }
    var x = x
    while x >= (8 << 4) { /* coarse steps */
        x = (x + 0xf) >> 4 /* x = ceil(x / 16) */
        e += 4
    }
    while x >= (8 << 1) { /* fine steps */
        x = (x + 1) >> 1 /* x = ceil(x / 2) */
        e += 1
    }
    return ((e + 1) << 3) | (x - 8)
}

/* converts back */
func fb2int(x: Int) -> Int {
    if x < 8 {
        return x
    } else {
        return ((x & 7) + 8) << UInt((x>>3)-1)
    }
}
