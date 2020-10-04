//
//  ParseBlock.swift
//  Lua
//
//  Created by 呀哈哈 on 2020/10/4.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class Parse {
    
//    let lexer: Lexer
//
//    init(lexer: Lexer) {
//        self.lexer = lexer
//    }
    
    func parseBlock(_ lexer: Lexer) -> Block {
        return Block(stats: parseStats(lexer),
                     retExps: parseRetExps(lexer),
                     lastLine: lexer.line)
    }
    
    func parseStats(_ lexer: Lexer) -> [Stat] {
        fatalError()
    }
    
    func parseRetExps(_ lexer: Lexer) -> [Exp] {
        fatalError()
    }
    
}
