//
//  main.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

print(CommandLine.arguments)

let fileUrl = URL(fileURLWithPath: CommandLine.arguments[1])
let data = try Data(contentsOf: fileUrl)

let ls = LuaState()
try ls.load(chunk: data, chunkName: fileUrl.absoluteString, mode: "b")
ls.call(nArgs: 0, nResults: 0)
