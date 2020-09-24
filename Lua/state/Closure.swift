//
//  Closure.swift
//  Lua
//
//  Created by dianqk on 2020/9/23.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

typealias SwiftFunction = (LuaState) -> Int

enum Closure {

    case prototype(proto: BinaryChunk.Prototype)
    case swiftFunc(swiftFunc: SwiftFunction)

    var proto: BinaryChunk.Prototype? {
        switch self {
        case let .prototype(proto):
            return proto
        default:
            return nil
        }
    }

}
