//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

let hwLuacUrl = URL(fileURLWithPath: "/Users/qing/Documents/GitHub/luago-book/code/lua/ch02/hw.luac")

print(hwLuacUrl)

let luacBin = try Data(contentsOf: hwLuacUrl)

let reader = Reader(data: luacBin)

try reader.checkHeader()

print("DONE")
