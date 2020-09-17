//
//  LuaStack.swift
//  Lua
//
//  Created by dianqk on 2020/9/17.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

class LuaStack {

    var slots: [LuaValue]
    var top: Int = 0

    init(size: Int) {
//        self.slots.reserveCapacity(size)
        self.slots = [LuaValue].init(repeating: LuaNil(), count: size)
        self.top = 0
    }

    /// 检查栈空间是否还可以容纳至少 n 个值，否则进行扩容
    /// - Parameter n: 期望容纳个数
    func check(n: Int) {
        guard n > self.slots.count else {
            return
        }
        let free = self.slots.count - self.top
        self.slots.append(contentsOf: [LuaValue].init(repeating: LuaNil(), count: n - free))
    }

    /// 将值推入栈顶
    /// - Parameter val: 推入的值
    func push(val: LuaValue) {
        guard self.top < self.slots.count else {
            fatalError("stack overflow!")
        }
        self.slots[self.top] = val
        self.top += 1
    }

    /// 从栈顶弹出一个值
    /// - Returns: 弹出的值
    func pop() -> LuaValue {
        guard self.top >= 1 else {
            fatalError("stack underflow!")
        }
        self.top -= 1
        let val = self.slots[self.top]
        self.slots[self.top] = LuaNil()
        return val
    }

    /// 把索引转换成绝对索引，为了便于用户使用，索引可以为负数，正数为绝对索引（从栈底计算距离），负数相对索引（从栈顶计算距离）
    /// - Parameter idx: 被转换的索引
    /// - Returns: 转换后的索引
    func absIndex(idx: Int) -> Int {
        if idx >= 0 {
            return idx
        }
        return idx + self.top + 1
    }

    /// 判断索引是否有效
    /// - Parameter idx: 要判断的索引
    /// - Returns: 是否有效的结果
    func isVaild(idx: Int) -> Bool {
        let absIdx = self.absIndex(idx: idx)
        return absIdx > 0 && absIdx <= self.top
    }

    /// 根据索引从栈里取值
    /// - Parameter idx: 索引
    /// - Returns: 返回的值，索引无效返回 nil
    func get(idx: Int) -> LuaValue {
        let absIdx = self.absIndex(idx: idx)
        guard absIdx > 0 && absIdx <= self.top else {
            return LuaNil()
        }
        return self.slots[absIdx - 1]
    }

    /// 根据索引往栈里写入值
    /// - Parameters:
    ///   - idx: 待写入索引
    ///   - val: 待写入值
    func set(idx: Int, val: LuaValue) {
        let absIdx = self.absIndex(idx: idx)
        guard absIdx > 0 && absIdx <= self.top else {
            fatalError("invalid index!")
        }
        self.slots[absIdx - 1] = val
    }

}
