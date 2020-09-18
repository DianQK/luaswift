//
//  Parser.swift
//  Lua
//
//  Created by dianqk on 2020/9/18.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

struct Parser {

    static func parseInteger(str: String) -> (Int64, Bool) {
        guard let i = Int64(str) else {
            return (0, false)
        }
        return (i, true)
    }

    static func parseFloat(str: String) -> (Double, Bool) {
        guard let f = Double(str) else {
            return (0, false)
        }
        return (f, true)
    }

}
