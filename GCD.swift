//
//  GCD.swift
//  GCD
//
//  Created by Lam Le V. on 11/28/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import Foundation

func mainThread(_ f: @escaping () -> Void) {
    if Thread.isMainThread {
        f()
    } else {
        GCD.run(.async(queue: .main)) { f() }
    }
}

func subThread(_ f: @escaping () -> Void) {
    if !Thread.isMainThread {
        f()
    } else {
        GCD.run(.async(queue: .global(priority: .userInitiated))) { f() }
    }
}

func delay(_ second: Double, _ f: @escaping () -> Void) {
    GCD.run(.after(second: second, queue: .main), f)
}

struct GCD {

    fileprivate init() {}

    enum `Type` {
        case async(queue: GCD.Queue)
        case sync(queue: GCD.Queue)
        case after(second: Double, queue: GCD.Queue)
        case barrierAsync(queue: GCD.Queue)
        case barrierSync(queue: GCD.Queue)
        case group(taskQueue: GCD.Queue, tasks: [(() -> Void)], timeout: Double)
        case groupNotify(tasks: [((() -> Void) -> Void)], completionQueue: GCD.Queue)
    }

    enum QOS {
        case main
        case background
        case userInteractive
        case userInitiated
        case utility
        case `default`
    }

    enum Queue {
        case main
        case global(priority: GCD.QOS)
        case serial

        var value: DispatchQueue {
            switch self {
            case .main:
                return DispatchQueue.main
            case .global(let qos):
                switch qos {
                case .main:
                    return DispatchQueue.main
                case .background:
                    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                case .userInteractive:
                    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
                case .userInitiated:
                    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
                case .utility:
                    return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
                case .default:
                    return Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                }
            case .serial:
                let uuid = "gcd.serial_queue_" + UUID().uuidString
                return DispatchQueue(label: uuid, attributes: [])
            }
        }
    }

    static func run(_ type :Type, _ block: @escaping () -> Void) {
        switch type {
        case .async(let queue):
            queue.value.async { block() }
        case .sync(let queue):
            queue.value.sync { block() }
        case .after(let second, let queue):
            queue.value.asyncAfter(deadline: self.dispatchTime(second)) { block() }
        case .barrierAsync(let queue):
            queue.value.async(flags: .barrier, execute: { block() })
        case .barrierSync(let queue):
            queue.value.sync(flags: .barrier, execute: { block() })
        case .group(let taskQueue, let tasks, let timeout):
            let group = DispatchGroup()

            tasks.forEach() { task in
                taskQueue.value.async(group: group) { task() }
            }

            _ = group.wait(timeout: self.dispatchTime(timeout))
        case .groupNotify(let tasks, let completionQueue):
            let group = DispatchGroup()

            tasks.forEach() {
                group.enter()
                $0() { group.leave() }
            }

            group.notify(queue: completionQueue.value) { block() }
        }
    }

    fileprivate static func dispatchTime(_ second: Double) -> DispatchTime {
        return DispatchTime.now() + second
    }
}
