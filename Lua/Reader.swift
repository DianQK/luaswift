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

extension BinaryChunk.Header {
    
    static let LUA_SIGNATURE    = "\u{1b}Lua"
    static let LUAC_VERSION     = 0x53
    static let LUAC_FORMAT      = 0
    static let LUAC_DATA        = "\u{19}\r\n\u{1A}\n"
    static let CINT_SIZE        = 4
    static let CSIZET_SIZE      = 8
    static let INSTRUCTION_SIZE = 4
    static let LUA_INTEGER_SIZE = 8
    static let LUA_NUMBER_SIZE  = 8
    static let LUAC_INT         = 0x5678
    static let LUAC_NUM         = 370.5
    
}

// 1B 4C 75 61
// 53
// 00
// 19 93 0D 0A 1A 0A
// 04 08 04 08

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
        return String(data: self.readBytes(count: size), encoding: String.Encoding.utf8)!
    }
    
    func checkHeader() throws {
        guard let signature = String(data: self.readBytes(count: 4), encoding: String.Encoding.ascii), signature == BinaryChunk.Header.LUA_SIGNATURE else {
            throw BinaryChunk.Header.CheckError.desc("not a precompiled chunk!")
        }
        guard self.readByte() == BinaryChunk.Header.LUAC_VERSION else {
            throw BinaryChunk.Header.CheckError.desc("version mismatch!")
        }
        guard self.readByte() == BinaryChunk.Header.LUAC_FORMAT else {
            throw BinaryChunk.Header.CheckError.desc("format mismatch!")
        }
        guard let data = String(data: self.readBytes(count: 6), encoding: String.Encoding.ascii), data == BinaryChunk.Header.LUAC_DATA else {
            throw BinaryChunk.Header.CheckError.desc("corrupted!")
        }
        guard self.readByte() == BinaryChunk.Header.CINT_SIZE else {
            throw BinaryChunk.Header.CheckError.desc("int size mismatch!")
        }
        guard self.readByte() == BinaryChunk.Header.CSIZET_SIZE else {
            throw BinaryChunk.Header.CheckError.desc("size_t size mismatch!")
        }
        guard self.readByte() == BinaryChunk.Header.INSTRUCTION_SIZE else {
            throw BinaryChunk.Header.CheckError.desc("instruction size mismatch!")
        }
        guard self.readByte() == BinaryChunk.Header.LUA_INTEGER_SIZE else {
            throw BinaryChunk.Header.CheckError.desc("lua_Integer size mismatch!")
        }
        guard self.readByte() == BinaryChunk.Header.LUA_NUMBER_SIZE else {
            throw BinaryChunk.Header.CheckError.desc("lua_Number size mismatch!")
        }
        guard self.readLuaInteger() == BinaryChunk.Header.LUAC_INT else {
            throw BinaryChunk.Header.CheckError.desc("endianness mismatch!")
        }
        guard self.readLuaNumber() == BinaryChunk.Header.LUAC_NUM else {
            throw BinaryChunk.Header.CheckError.desc("float format mismatch!")
        }
    }
    
}
