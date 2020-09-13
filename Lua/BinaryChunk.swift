//
//  BinaryChunk.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

typealias Byte = UInt8

struct BinaryChunk {
    
    struct Header {
        let signature: [Byte] // 4
        let version: Byte
        let format: Byte
        let luacData: [Byte] // 6
        let cintSize: Byte
        let sizetSize: Byte
        let instructionSize: Byte
        let luaIntegerSize: Byte
        let luaNumberSize: Byte
        let luacInt: Byte
        let luacNum: Double
        
        enum CheckError: Error {
            case desc(String)
        }
    }
    
    struct Prototype {
        
        struct Upvalue {
            let instack: Byte
            let idx: Byte
        }
        
        struct LocVar {
            let varName: String
            let startPC: UInt32
            let endPC: UInt32
        }
        
        let source: String
        let lineDefined: UInt32
        let lastLineDefined: UInt32
        let numParams: Byte
        let isVararg: Byte
        let maxStackSize: Byte
        let code: [UInt32]
//        let constants:
        let upvalues: [Upvalue]
        let protos: [Prototype]
        let lineInfo: [UInt32]
        let locVars: [LocVar]
        let upvalueNames: [String]
    }
    
    let header: Header
    let sizeUpvalues: Byte
//    let mainFunc
    
}
