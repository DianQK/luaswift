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

    let action: (_ i: Instruction, _ vm: LuaVMType) -> ()
}

let opcodes: [Opcode] = [
    /*     T            A            B             C             mode                 name    */
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "MOVE    ", action: Instruction.move), // R(A) := R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .N, opMode: .IABx /* */, name: "LOADK   ", action: Instruction.loadK), // R(A) := Kst(Bx)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .N, argCMode: .N, opMode: .IABx /* */, name: "LOADKX  ", action: Instruction.loadKx), // R(A) := Kst(extra arg)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "LOADBOOL", action: Instruction.loadBool), // R(A) := (bool)B; if (C) pc++
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "LOADNIL ", action: Instruction.loadNil), // R(A), R(A+1), ..., R(A+B) := nil

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "GETUPVAL", action: Instruction.getUpval), // R(A) := UpValue[B]
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .K, opMode: .IABC /* */, name: "GETTABUP", action: Instruction.getTabUp), // R(A) := UpValue[B][RK(C)]

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .K, opMode: .IABC /* */, name: "GETTABLE", action: Instruction.getTable), // R(A) := R(B)[RK(C)]

    Opcode(testFlag: 0, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SETTABUP", action: Instruction.setTabUp), // UpValue[A][RK(B)] := RK(C)
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "SETUPVAL", action: Instruction.setUpval), // UpValue[B] := R(A)

    Opcode(testFlag: 0, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SETTABLE", action: Instruction.setTable), // R(A)[RK(B)] := RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "NEWTABLE", action: Instruction.newTable), // R(A) := {} (size = B,C)

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .K, opMode: .IABC /* */, name: "SELF    ", action: Instruction._self), // R(A+1) := R(B); R(A) := R(B)[RK(C)]

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "ADD     ", action: Instruction.add), // R(A) := RK(B) + RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SUB     ", action: Instruction.sub), // R(A) := RK(B) - RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "MUL     ", action: Instruction.mul), // R(A) := RK(B) * RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "MOD     ", action: Instruction.mod), // R(A) := RK(B) % RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "POW     ", action: Instruction.pow), // R(A) := RK(B) ^ RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "DIV     ", action: Instruction.div), // R(A) := RK(B) / RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "IDIV    ", action: Instruction.idiv), // R(A) := RK(B) // RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BAND    ", action: Instruction.band), // R(A) := RK(B) & RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BOR     ", action: Instruction.bor), // R(A) := RK(B) | RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "BXOR    ", action: Instruction.bxor), // R(A) := RK(B) ~ RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SHL     ", action: Instruction.shl), // R(A) := RK(B) << RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "SHR     ", action: Instruction.shr), // R(A) := RK(B) >> RK(C)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "UNM     ", action: Instruction.unm), // R(A) := -R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "BNOT    ", action: Instruction.bnot), // R(A) := ~R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "NOT     ", action: Instruction.not), // R(A) := not R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IABC /* */, name: "LEN     ", action: Instruction.length), // R(A) := length of R(B)
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .R, opMode: .IABC /* */, name: "CONCAT  ", action: Instruction.concat), // R(A) := R(B).. ... ..R(C)
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "JMP     ", action: Instruction.jmp), // pc+=sBx; if (A) close all upvalues >= R(A - 1)
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "EQ      ", action: Instruction.eq), // if ((RK(B) == RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "LT      ", action: Instruction.lt), // if ((RK(B) <  RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .K, argCMode: .K, opMode: .IABC /* */, name: "LE      ", action: Instruction.le), // if ((RK(B) <= RK(C)) ~= A) then pc++
    Opcode(testFlag: 1, setAFlag: 0, argBMode: .N, argCMode: .U, opMode: .IABC /* */, name: "TEST    ", action: Instruction.test), // if not (R(A) <=> C) then pc++
    Opcode(testFlag: 1, setAFlag: 1, argBMode: .R, argCMode: .U, opMode: .IABC /* */, name: "TESTSET ", action: Instruction.testSet), // if (R(B) <=> C) then R(A) := R(B) else pc++

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "CALL    ", action: Instruction.call), // R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "TAILCALL", action: Instruction.tailCall), // return R(A)(R(A+1), ... ,R(A+B-1))
    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "RETURN  ", action: Instruction._return), // return R(A), ... ,R(A+B-2)

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "FORLOOP ", action: Instruction.forLoop), // R(A)+=R(A+2); if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "FORPREP ", action: Instruction.forPrep), // R(A)-=R(A+2); pc+=sBx

    Opcode(testFlag: 0, setAFlag: 0, argBMode: .N, argCMode: .U, opMode: .IABC /* */, name: "TFORCALL", action: Instruction.todo), // R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .R, argCMode: .N, opMode: .IAsBx /**/, name: "TFORLOOP", action: Instruction.todo), // if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }

    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .U, opMode: .IABC /* */, name: "SETLIST ", action: Instruction.setList), // R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B

    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABx /* */, name: "CLOSURE ", action: Instruction.closure), // R(A) := closure(KPROTO[Bx])
    Opcode(testFlag: 0, setAFlag: 1, argBMode: .U, argCMode: .N, opMode: .IABC /* */, name: "VARARG  ", action: Instruction.vararg), // R(A), R(A+1), ..., R(A+B-2) = vararg

    Opcode(testFlag: 0, setAFlag: 0, argBMode: .U, argCMode: .U, opMode: .IAx /*  */, name: "EXTRAARG", action: Instruction.todo), // extra (larger) argument for previous opcode
]

