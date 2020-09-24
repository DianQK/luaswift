//
//  Closure.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

typealias SwiftFunction = (LuaState) -> Int

struct Closure {

    var proto: BinaryChunk.Prototype?
    var swiftFunc: SwiftFunction?

    init(proto: BinaryChunk.Prototype) {
        self.proto = proto
    }

    init(swiftFunc: @escaping SwiftFunction) {
        self.swiftFunc = swiftFunc
    }

}
