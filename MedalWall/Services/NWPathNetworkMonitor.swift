//
//  NWPathNetworkMonitor.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation
import Network
import os

/// Whether the device can reach the network, behind a protocol so callers can be tested
/// against a stub.
///
/// `UserManager` takes this as `(any NetworkMonitor)? = nil` and resolves it with
/// `?? NWPathNetworkMonitor()` inside `init`, for the same reason the repositories do.
protocol NetworkMonitor {
  /// Calls `onChange` with whether the device has a usable network path, now and on every
  /// change.
  func observe(_ onChange: @escaping @MainActor (Bool) async -> Void)

  /// Whether the device has a usable network path right now.
  func isConnected() async -> Bool
}

final class NWPathNetworkMonitor: NetworkMonitor {
  private let monitor = NWPathMonitor()

  /// Starts watching the device's network path and reports each change to `onChange`.
  func observe(_ onChange: @escaping @MainActor (Bool) async -> Void) {
    monitor.pathUpdateHandler = { path in
      let isConnected = path.status == .satisfied
      Task {
        await onChange(isConnected)
      }
    }
    monitor.start(queue: DispatchQueue(label: "NWPathNetworkMonitor"))
  }

  /// Reads the device's network path once, with a monitor of its own so `observe` is untouched.
  /// Only the first path answers: the handler runs on a concurrent queue, so a second update
  /// can arrive before `cancel()` takes effect, and resuming twice would crash.
  func isConnected() async -> Bool {
    await withCheckedContinuation { continuation in
      let oneOffMonitor = NWPathMonitor()
      let isAnswered = OSAllocatedUnfairLock(initialState: false)
      oneOffMonitor.pathUpdateHandler = { path in
        let isFirstPath = isAnswered.withLock { answered in
          defer { answered = true }
          return !answered
        }
        guard isFirstPath else { return }

        oneOffMonitor.cancel()
        continuation.resume(returning: path.status == .satisfied)
      }
      oneOffMonitor.start(queue: .global())
    }
  }
}
