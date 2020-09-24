//
//  benchmark.swift
//  Lua
//
//  Created by dianqk on 2020/9/24.
//  Copyright © 2020 Indigo. All rights reserved.
//

import Foundation

var times: [(DispatchTime, String)] = []

func benchmark(name: String) {
    times.append((DispatchTime.now(), name))
}

func printBenchmarkResult() {
    let start = times.first!.0
    let end = times.last!.0
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000
    let avg = timeInterval / Double(times.count)
    zip(times, times.dropFirst()).forEach { (a) in
        let ((start, _), (end, endName)) = a
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000
        if timeInterval > avg {
            print("\(endName): \(timeInterval)ms")
        }
    }

    print("total: \(timeInterval)ms, count: \(times.count), avg: \(avg)ms")
}
