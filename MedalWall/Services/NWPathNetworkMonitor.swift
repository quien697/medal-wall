//
//  NWPathNetworkMonitor.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation
import Network

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
  func isConnected() async -> Bool {
    await withCheckedContinuation { continuation in
      let oneOffMonitor = NWPathMonitor()
      oneOffMonitor.pathUpdateHandler = { path in
        oneOffMonitor.cancel()
        continuation.resume(returning: path.status == .satisfied)
      }
      oneOffMonitor.start(queue: .global())
    }
  }
}
