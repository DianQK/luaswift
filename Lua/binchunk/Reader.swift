//
//  Reader.swift
//  Lua
//
//  Created by Qing on 2020/9/13.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

extension Data {

    mutating func read<T>(from startIndex: Int = 0) -> T {
        let endIndex = startIndex.advanced(by: MemoryLayout<T>.size)
        let bytes = [UInt8](self[startIndex..<endIndex])
        // Fatal error: load from misaligned raw pointer
        // Swift 是内存对齐的，无法直接读内存不对齐的 data，也就是说不能用 self
        let value = bytes.withUnsafeBytes { $0.load(as: T.self) }
        return value
    }
    
}

class Reader {
    
    var data: Data
    
    private var readingIndex: Data.Index = 0
    
    init(data: Data) {
        self.data = data
    }
    
    func readByte() -> Byte {
        let value: UInt8 = self.data[self.readingIndex]
        self.readingIndex += 1;
        return value
    }
    
    func readBytes(count: Int) -> Data {
        let endIndex = self.readingIndex + count
        let value = self.data[self.readingIndex..<endIndex]
        self.readingIndex = endIndex
        return value
    }
    
    private func read<T>() -> T {
        let value: T = self.data.read(from: self.readingIndex)
        self.readingIndex += MemoryLayout<T>.size
        return value
    }
    
    func readUInt32() -> UInt32 {
        return self.read()
    }
    
    func readUInt64() -> UInt64 {
        return self.read()
    }
    
    func readLuaInteger() -> Int64 {
        return self.read()
    }
    
    func readLuaNumber() -> Double {
        return self.read()
    }
    
    func readString() -> String {
        var size = Int(self.readByte())
        if size == 0 {
            return ""
        }
        if size == 0xFF {
            size = Int(self.readUInt64())
        }
        return String(data: self.readBytes(count: size - 1), encoding: String.Encoding.utf8)!
    }
    
    func checkHeader() throws -> BinaryChunk.Header {
        let header = BinaryChunk.Header()
        guard let signature = String(data: self.readBytes(count: 4), encoding: String.Encoding.ascii), signature == header.signature else {
            throw BinaryChunk.Header.CheckError.desc("not a precompiled chunk!")
        }
        guard self.readByte() == header.version else {
            throw BinaryChunk.Header.CheckError.desc("version mismatch!")
        }
        guard self.readByte() == header.format else {
            throw BinaryChunk.Header.CheckError.desc("format mismatch!")
        }
        guard let data = String(data: self.readBytes(count: 6), encoding: String.Encoding.ascii), data == header.luacData else {
            throw BinaryChunk.Header.CheckError.desc("corrupted!")
        }
        guard self.readByte() == header.cintSize else {
            throw BinaryChunk.Header.CheckError.desc("int size mismatch!")
        }
        guard self.readByte() == header.sizetSize else {
            throw BinaryChunk.Header.CheckError.desc("size_t size mismatch!")
        }
        guard self.readByte() == header.instructionSize else {
            throw BinaryChunk.Header.CheckError.desc("instruction size mismatch!")
        }
        guard self.readByte() == header.luaIntegerSize else {
            throw BinaryChunk.Header.CheckError.desc("lua_Integer size mismatch!")
        }
        guard self.readByte() == header.luaNumberSize else {
            throw BinaryChunk.Header.CheckError.desc("lua_Number size mismatch!")
        }
        guard self.readLuaInteger() == header.luacInt else {
            throw BinaryChunk.Header.CheckError.desc("endianness mismatch!")
        }
        guard self.readLuaNumber() == header.luacNum else {
            throw BinaryChunk.Header.CheckError.desc("float format mismatch!")
        }
        return header
    }
    
    func readContents<Content>(readBlock: (Reader) -> Content) -> [Content] {
        let count = self.readUInt32()
        var contents: [Content] = []
        for _ in (0..<count) {
            contents.append(readBlock(self))
        }
        return contents
    }
    
    func readCode() -> [Instruction] {
        self.readContents { Instruction(value: $0.readUInt32()) }
    }
    
    func readConstant() -> [BinaryChunk.Prototype.Constant] {
        self.readContents { (reader) -> BinaryChunk.Prototype.Constant in
            guard let constantTag = BinaryChunk.Prototype.Constant.Tag(rawValue: self.readByte()) else {
                fatalError("corrupted!")
            }
            let constant: BinaryChunk.Prototype.Constant
            switch constantTag {
            case .nil:
                constant = .nil
            case .boolean:
                constant = .boolean(self.readByte() != 0)
            case .integer:
                constant = .integer(self.readLuaInteger())
            case .number:
                constant = .number(self.readLuaNumber())
            case .shortStr:
                constant = .shortStr(self.readString())
            case .longStr:
                constant = .longStr(self.readString())
            }
            return constant
        }
    }
    
    func readUpvalues() -> [BinaryChunk.Prototype.Upvalue] {
        self.readContents { BinaryChunk.Prototype.Upvalue(instack: $0.readByte(), idx: $0.readByte()) }
    }
    
    func readProtos(parentSource: String) -> [BinaryChunk.Prototype] {
        self.readContents { $0.readProto(parentSource: parentSource) }
    }
    
    func readLineInfo() -> [UInt32] {
        self.readContents { $0.readUInt32() }
    }
    
    func readLocVars() -> [BinaryChunk.Prototype.LocVar] {
        self.readContents { BinaryChunk.Prototype.LocVar(varName: $0.readString(), startPC: $0.readUInt32(), endPC: $0.readUInt32()) }
    }
    
    func readUpvalueNames() -> [String] {
        self.readContents { $0.readString() }
    }
    
    func readProto(parentSource: String) -> BinaryChunk.Prototype {
        var source = self.readString()
        if (source.isEmpty) {
            source = parentSource
        }
        let lineDefined = self.readUInt32()
        let lastLineDefined = self.readUInt32()
        let numParams = self.readByte()
        let isVararg = self.readByte()
        let maxStackSize = self.readByte()
        let code = self.readCode()
        let constants = self.readConstant()
        let upvalues = self.readUpvalues()
        let protos = self.readProtos(parentSource: source)
        let lineInfo = self.readLineInfo()
        let locVars = self.readLocVars()
        let upvalueNames = self.readUpvalueNames()
        return BinaryChunk.Prototype(source: source,
                                     lineDefined: lineDefined,
                                     lastLineDefined: lastLineDefined,
                                     numParams: numParams,
                                     isVararg: isVararg,
                                     maxStackSize: maxStackSize,
                                     code: code,
                                     constants: constants,
                                     upvalues: upvalues,
                                     protos: protos,
                                     lineInfo: lineInfo,
                                     locVars: locVars,
                                     upvalueNames: upvalueNames)
    }
    
    func undump() throws -> BinaryChunk {
        return BinaryChunk(header: try self.checkHeader(),
                           sizeUpvalues: self.readByte(),
                           mainFunc: self.readProto(parentSource: ""))
    }
    
}
