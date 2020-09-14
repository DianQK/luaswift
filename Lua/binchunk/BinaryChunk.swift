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
        let signature = "\u{1b}Lua" // 4 Byte 0x1B4C7561
        let version: Byte = 0x53
        let format: Byte = 0
        let luacData = "\u{19}\r\n\u{1A}\n" // 6 Byte 0x19930D0A1A0A
        let cintSize: Byte = 4
        let sizetSize: Byte = 8
        let instructionSize: Byte = 4
        let luaIntegerSize: Byte = 8
        let luaNumberSize: Byte = 8
        let luacInt: Int64 = 0x5678
        let luacNum: Double = 370.5
        
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
        
        enum Constant {
            
            enum Tag: UInt8 {
                case `nil` = 0x00
                case boolean = 0x01
                case integer = 0x03
                case number = 0x13
                case shortStr = 0x04
                case longStr = 0x14
            }
            
            case `nil`
            case boolean(Bool)
            case integer(Int64)
            case number(Double)
            case shortStr(String)
            case longStr(String)
            
            var string: String {
                switch self {
                case .nil:
                    return "nil"
                case let .boolean(value):
                    return value.description
                case let .integer(value):
                    return value.description
                case let .number(value):
                    return value.description
                case let .shortStr(value):
                    return "\"\(value)\""
                case let .longStr(value):
                    return "\"\(value)\""
                }
            }
        }
        
        let source: String
        let lineDefined: UInt32
        let lastLineDefined: UInt32
        let numParams: Byte
        let isVararg: Byte
        let maxStackSize: Byte
        let code: [UInt32]
        let constants: [Constant]
        let upvalues: [Upvalue]
        let protos: [Prototype]
        let lineInfo: [UInt32]
        let locVars: [LocVar]
        let upvalueNames: [String]
    }
    
    let header: Header
    let sizeUpvalues: Byte
    let mainFunc: Prototype
    
}

extension BinaryChunk.Prototype {
    
    func list() {
        printHeader()
        printCode()
        printDetail()
        for proto in protos {
            proto.list()
        }
    }
    
    func printHeader() {
        let funcType = lineDefined > 0 ? "function" : "main"
        let varargFlag = isVararg > 0 ? "+" : ""
        print("\(funcType) <\(source):\(lineDefined),\(lastLineDefined)> (\(code.count)) instructions")
        print("\(numParams)\(varargFlag) params, \(maxStackSize) slots, \(upvalues.count) upvalues, \(locVars.count) locals, \(constants.count) constants, \(protos.count) functions")
    }
    
    func printCode() {
        for (pc, c) in code.enumerated() {
            let line = lineInfo.isEmpty ? "-" : "\(lineInfo[pc])"
//            print("\t\(pc+1)\t[\(line)]\t0x\(String(format: "0x%08x", c))")
            let instruction = Instruction(value: c)
            print("\t\(pc+1)\t[\(line)]\t\(instruction.opName) \t", terminator: "")
            instruction.printOperands()
        }
    }
    
    func printDetail() {
        print("constants (\(constants.count)):")
        for (index, constant) in constants.enumerated() {
            print("\t\(index+1)\t\(constant.string)")
        }
        
        print("locals (\(locVars.count)):")
        for (index, locVar) in locVars.enumerated() {
            print("\t\(index)\t\(locVar.varName)\t\(locVar.startPC+1)\t\(locVar.endPC+1)")
        }
        
        print("upvalues (\(upvalues.count)):")
        for (index, upval) in upvalues.enumerated() {
            print("\t\(index)\t\(upvalueNames[index])\t\(upval.instack)\t\(upval.idx)")
        }
    }
    
    
}
