//
//  CommandTests.swift
//  MonyoTests
//
//  Created by Daniel Haight on 23/05/2019.
//  Copyright © 2019 Daniel Haight. All rights reserved.
//

import Foundation
import XCTest
@testable import Monyo

class CommandTests: XCTestCase {
    
    let n = 100000
    
    func testCombine() {
        
        let expectedSorted = Array(0..<n)
        let commands = expectedSorted.map(Command<Int>.pure)
        
        let combined = Command<Int>.combine(commands)
        
        let returnedSorted = combined.runSynchronously().sorted()
        
        XCTAssertEqual(returnedSorted, expectedSorted)
        
    }
    
    func testCombineWithRandomDelaysAndQueues() {
        
        let expectedSorted = Array(0..<n)
        let commands = expectedSorted.map { i in
            return Command<Int> { cont in
                let queue = DispatchQueue(label: "test")
                queue.asyncAfter(deadline: .now() + Double(arc4random_uniform(1000))/1000){
                    cont(i)
                }
            }
        }
        let combined = Command<Int>.combine(commands)
        
        
        let returnedSorted = combined.runSynchronously().sorted()
        
        
        XCTAssertEqual(returnedSorted, expectedSorted)
    }


    func testCombineWorksAcrossMultipleConcurrentQueues() {
        var continuations = [(Int,(Int)->Void)]()
        let expectedSorted = Array(0..<n)
        let commands = expectedSorted.map { i in
            return Command<Int>{ cont in
                continuations.append((i,cont))
            }
        }
        
        let combined = Command<Int>.combine(commands)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var returnedSorted = [Int]()
        
        combined.run { results in
            returnedSorted = results.sorted()
            semaphore.signal()
        }
        
        DispatchQueue.concurrentPerform(iterations: continuations.count) { i in
            let (value, f) =  continuations[i]
            f(value)
        }
        semaphore.wait()
        
        XCTAssertEqual(returnedSorted, expectedSorted)
        
    }
    
    
}
