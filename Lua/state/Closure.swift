//
//  Closure.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

typealias SwiftFunction = (LuaState) -> Int

struct Upvalue { // FIXME: 可能需要 class 进行引用
    var val: LuaValue
}

struct Closure {

    var proto: BinaryChunk.Prototype?
    var swiftFunc: SwiftFunction?
    var upvals: [Upvalue] = []

    init(proto: BinaryChunk.Prototype) {
        self.proto = proto
        let nUpvals = proto.upvalues.count
        if nUpvals > 0 {
            self.upvals = [Upvalue].init(repeating: Upvalue(val: LuaNil()), count: nUpvals)
        }
    }

    init(swiftFunc: @escaping SwiftFunction, nUpvals: Int) {
        self.swiftFunc = swiftFunc
        if nUpvals > 0 {
            self.upvals = [Upvalue].init(repeating: Upvalue(val: LuaNil()), count: nUpvals)
        }
    }

}
