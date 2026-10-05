//
//  StubNetworkMonitor.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import Foundation

@testable import MedalWall

/// Scriptable `NetworkMonitor` so connection changes can be tested without a network.
///
/// A `@MainActor` class for the same reason as `StubAuthService`.
@MainActor
final class StubNetworkMonitor: NetworkMonitor {

  // MARK: - Script
  private var onConnectivityChange: (@MainActor (Bool) async -> Void)?

  // MARK: - Script control
  /// Reports the connection going up or down and waits until the observer has handled it.
  func report(isConnected: Bool) async {
    await onConnectivityChange?(isConnected)
  }

  // MARK: - NetworkMonitor
  func observe(_ onChange: @escaping @MainActor (Bool) async -> Void) {
    onConnectivityChange = onChange
  }
}
