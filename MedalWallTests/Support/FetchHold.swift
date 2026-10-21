//
//  FetchHold.swift
//  MedalWall
//
//  Created by Quien on 2026-10-19.
//

import Foundation

/// Holds a stub's next fetch in flight until the test releases it, so a test can look at a
/// load while it runs instead of guessing with a sleep. The same pattern as
/// `StubUserRepository`'s held create, shared by every stub that fetches.
actor FetchHold {

  // MARK: - State
  private var isArmed = false
  private var hasStarted = false
  private var isReleased = false
  private var startWaiter: CheckedContinuation<Void, Never>?
  private var heldFetch: CheckedContinuation<Void, Never>?

  // MARK: - Test control
  /// Holds the next fetch once it starts.
  func holdNext() {
    isArmed = true
    hasStarted = false
    isReleased = false
  }

  /// Waits until the held fetch has started.
  func waitForStart() async {
    guard !hasStarted else { return }
    await withCheckedContinuation { startWaiter = $0 }
  }

  /// Lets the held fetch finish.
  func release() {
    isReleased = true
    heldFetch?.resume()
    heldFetch = nil
  }

  // MARK: - Stub side
  /// Called by a stub as a fetch starts; suspends it when a hold is armed.
  func enter() async {
    guard isArmed else { return }
    isArmed = false
    hasStarted = true
    startWaiter?.resume()
    startWaiter = nil
    if !isReleased {
      await withCheckedContinuation { heldFetch = $0 }
    }
  }
}
