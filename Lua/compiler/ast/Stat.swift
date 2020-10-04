//
//  Stat.swift
//  Lua
//
//  Created by 呀哈哈 on 2020/10/3.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

protocol Stat {
    
}


struct EmptyStat: Stat { // ;
    
}

struct BreakStat: Stat { // break
    
    let line: Int
    
}

struct LabelStat: Stat { // ::name::
    
    let name: String
    
}

struct GotoStat: Stat { // goto name
    
    let name: String
    
}

struct DoStat: Stat {
    
    let block: Block
    
}

struct WhileStat: Stat {
    let exp: Exp
    let block: Block
}

struct RepeatStat: Stat {
    let block: Block
    let exp: Exp
}

struct ForInStat: Stat {
    let lineOfDo: Int
    let nameList: [String]
    let expList: [Exp]
    let block: Block
}

struct LocalVarDeclStat: Stat {
    let lastLine: Int
    let nameList: [String]
    let expList: [Exp]
}

struct AssignStat: Stat {
    let lastLine: Int
    let varList: [Exp]
    let expList: [Exp]
}

struct LocalFuncDefStat: Stat {
    let name: String
    let exp: FuncDefExp
}

typealias FuncCallStat = FuncCallExp
extension FuncCallStat: Stat {}
