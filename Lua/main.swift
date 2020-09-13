//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let hwLuacUrl = URL(fileURLWithPath: "/Users/qing/Documents/GitHub/luago-book/code/lua/ch02/luac.out")
let luacBin = try Data(contentsOf: hwLuacUrl)
let reader = Reader(data: luacBin)
let binaryChunk = try reader.undump()

binaryChunk.mainFunc.list()
