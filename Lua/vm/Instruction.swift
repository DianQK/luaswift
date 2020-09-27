//
//  Instruction.swift
//  Lua
//
//  Created by dianqk on 2020/9/21.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

/*
 * 见书中 P44
 */
let MAXARG_Bx = 1 << 18 - 1
let MAXARG_sBX = MAXARG_Bx >> 1

/*
 31       22       13       5    0
  +-------+^------+-^-----+-^-----
  |b=9bits |c=9bits |a=8bits|op=6|
  +-------+^------+-^-----+-^-----
  |    bx=18bits    |a=8bits|op=6|
  +-------+^------+-^-----+-^-----
  |   sbx=18bits    |a=8bits|op=6|
  +-------+^------+-^-----+-^-----
  |    ax=26bits            |op=6|
  +-------+^------+-^-----+-^-----
 31      23      15       7      0
*/
/*
 * 0xFF: 11111111 提取 8 bit
 * 0x1FF: 111111111 提取 9 bit
 */
struct Instruction {

    let value: UInt32

    var opcode: OpcodeTag {
        OpcodeTag(rawValue: Int(value & 0x3F))!
    }

    var ABC: (a: Int, b: Int, c: Int) {
        let a = Int(value >> 6 & 0xFF)
        let c = Int(value >> 14 & 0x1FF) // >> 6 + 8
        let b = Int(value >> 23 & 0x1FF) // >> 6 + 8 + 9
        return (a, b, c)
    }

    var ABx: (a: Int, bx: Int) {
        let a = Int(value >> 6 & 0xFF)
        let bx = Int(value >> 14)
        return (a, bx)
    }

    var AsBx: (a: Int, sbx: Int) {
        let (a, bx) = self.ABx
        return (a, bx - MAXARG_sBX)
    }

    var Ax: Int {
        Int(value >> 6)
    }

    var opName: String {
        opcodes[self.opcode.rawValue].name
    }

    var opMode: OpMode {
        opcodes[self.opcode.rawValue].opMode
    }

    var BMode: OpArgMask {
        opcodes[self.opcode.rawValue].argBMode
    }

    var CMode: OpArgMask {
        opcodes[self.opcode.rawValue].argCMode
    }

    func execute(vm: LuaVMType) throws {
        let action = opcodes[self.opcode.rawValue].action
        try action(self, vm)
    }

    func printOperands() {
        switch self.opMode {
        case .IABC:
            let (a, b, c) = self.ABC

            print("\(a)", terminator: "")
            if self.BMode != .N {
                if b > 0xFF {
                    print(" \(-1-b&0xFF)", terminator: "")
                } else {
                    print(" \(b)", terminator: "")
                }
            }
            if self.CMode != .N {
                if c > 0xFF {
                    print(" \(-1-c&0xFF)", terminator: "")
                } else {
                    print(" \(c)", terminator: "")
                }
            }
        case .IABx:
            let (a, bx) = self.ABx

            print("\(a)", terminator: "")
            if self.BMode == .K {
                print(" \(-1-bx)", terminator: "")
            } else if self.BMode == .U {
                print(" \(bx)", terminator: "")
            }
        case .IAsBx:
            let (a, sbx) = self.AsBx
            print("\(a) \(sbx)", terminator: "")
        case .IAx:
            let ax = self.Ax
            print("\(-1-ax)", terminator: "")
        }
        print("")
    }

}
