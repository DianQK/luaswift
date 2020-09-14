//
//  opcodes.swift
//  Lua
//
//  Created by Qing on 2020/9/14.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

/* OpMode */
/* basic instruction format */
enum OpMode: Int {
    case IABC = 0 // [  B:9  ][  C:9  ][ A:8  ][OP:6]
    case IABx     // [      Bx:18     ][ A:8  ][OP:6]
    case IAsBx    // [     sBx:18     ][ A:8  ][OP:6]
    case IAx      // [           Ax:26        ][OP:6]
}

/* OpArgMask */
enum OpArgMask: Int {
    case N = 0    // argument is not used
    case U        // argument is used
    case R        // argument is a register or a jump offset
    case K        // argument is a constant or register/constant
}

/* Opcode */
enum OpcodeTag: Int {
    case MOVE = 0
    case LOADK
    case LOADKX
    case LOADBOOL
    case LOADNIL
    case GETUPVAL
    case GETTABUP
    case GETTABLE
    case SETTABUP
    case SETUPVAL
    case SETTABLE
    case NEWTABLE
    case SELF
    case ADD
    case SUB
    case MUL
    case MOD
    case POW
    case DIV
    case IDIV
    case BAND
    case BOR
    case BXOR
    case SHL
    case SHR
    case UNM
    case BNOT
    case NOT
    case LEN
    case CONCAT
    case JMP
    case EQ
    case LT
    case LE
    case TEST
    case TESTSET
    case CALL
    case TAILCALL
    case RETURN
    case FORLOOP
    case FORPREP
    case TFORCALL
    case TFORLOOP
    case SETLIST
    case CLOSURE
    case VARARG
    case EXTRAARG
}

struct Opcode {
    // operator is a test (next instruction must be a jump)
    let testFlag: Byte
    // instruction set register A
    let setAFlag: Byte
    // B arg mode
    let argBMode: OpArgMask
    // C arg mode
    let argCMode: OpArgMask
    // op mode
    let opMode: OpMode
    let name: String
}

let opcodes: [Opcode] = [
    /*     T            A            B             C             mode                 name    */
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "MOVE    "), // R(A) := R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .N, opMode: .IABx /* */, name: "LOADK   "), // R(A) := Kst(Bx)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .N, argCMode: .N, opMode: .IABx /* */, name: "LOADKX  "), // R(A) := Kst(extra arg)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "LOADBOOL"), // R(A) := (bool)B; if (C) pc++
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "LOADNIL "), // R(A), R(A+1), ..., R(A+B) := nil
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "GETUPVAL"), // R(A) := UpValue[B]
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .K, opMode: .IABC /* */, name: "GETTABUP"), // R(A) := UpValue[B][RK(C)]
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .K, opMode: .IABC /* */, name: "GETTABLE"), // R(A) := R(B)[RK(C)]
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SETTABUP"), // UpValue[A][RK(B)] := RK(C)
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "SETUPVAL"), // UpValue[B] := R(A)
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SETTABLE"), // R(A)[RK(B)] := RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "NEWTABLE"), // R(A) := {} (size = B,C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .K, opMode: .IABC /* */, name: "SELF    "), // R(A+1) := R(B); R(A) := R(B)[RK(C)]
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "ADD     "), // R(A) := RK(B) + RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SUB     "), // R(A) := RK(B) - RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "MUL     "), // R(A) := RK(B) * RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "MOD     "), // R(A) := RK(B) % RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "POW     "), // R(A) := RK(B) ^ RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "DIV     "), // R(A) := RK(B) / RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "IDIV    "), // R(A) := RK(B) // RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BAND    "), // R(A) := RK(B) & RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BOR     "), // R(A) := RK(B) | RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BXOR    "), // R(A) := RK(B) ~ RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SHL     "), // R(A) := RK(B) << RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SHR     "), // R(A) := RK(B) >> RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "UNM     "), // R(A) := -R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "BNOT    "), // R(A) := ~R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "NOT     "), // R(A) := not R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "LEN     "), // R(A) := length of R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .R, opMode: .IABC /* */, name: "CONCAT  "), // R(A) := R(B).. ... ..R(C)
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "JMP     "), // pc+=sBx; if (A) close all upvalues >= R(A - 1)
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "EQ      "), // if ((RK(B) == RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "LT      "), // if ((RK(B) <  RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "LE      "), // if ((RK(B) <= RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .N, argCMode: .U, opMode: .IABC /* */, name: "TEST    "), // if not (R(A) <=> C) then pc++
    Opcode(testFlag: 1, setAFlag: 1, argBMode: .R, argCMode: .U, opMode: .IABC /* */, name: "TESTSET "), // if (R(B) <=> C) then R(A) := R(B) else pc++
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "CALL    "), // R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "TAILCALL"), // return R(A)(R(A+1), ... ,R(A+B-1))
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "RETURN  "), // return R(A), ... ,R(A+B-2)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "FORLOOP "), // R(A)+=R(A+2); if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "FORPREP "), // R(A)-=R(A+2); pc+=sBx
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .N, argCMode: .U, opMode: .IABC /* */, name: "TFORCALL"), // R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "TFORLOOP"), // if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "SETLIST "), // R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABx /* */, name: "CLOSURE "), // R(A) := closure(KPROTO[Bx])
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "VARARG  "), // R(A), R(A+1), ..., R(A+B-2) = vararg
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .U, opMode: .IAx /*  */, name: "EXTRAARG"), // extra (larger) argument for previous opcode
]

let MAXARG_Bx = 1 << 18 - 1
let MAXARG_sBX = MAXARG_Bx >> 1

struct Instruction {
    
    let value: UInt32
    
    var opcode: Int {
        Int(value & 0x3F)
    }
    
    var ABC: (a: Int, b: Int, c: Int) {
        let a = Int(value >> 6 & 0xFF)
        let c = Int(value >> 14 & 0x1FF)
        let b = Int(value >> 23 & 0x1FF)
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
        opcodes[self.opcode].name
    }
    
    var opMode: OpMode {
        opcodes[self.opcode].opMode
    }
    
    var BMode: OpArgMask {
        opcodes[self.opcode].argBMode
    }
    
    var CMode: OpArgMask {
        opcodes[self.opcode].argCMode
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
