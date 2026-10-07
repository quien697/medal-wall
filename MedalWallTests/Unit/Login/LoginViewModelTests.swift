//
//  LoginViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-07.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct LoginViewModelTests {

  private let email = "runner@example.com"

  // MARK: - Support
  /// A private defaults suite with no email saved.
  private func makeDefaults(function: String = #function) throws -> UserDefaults {
    let suiteName = "LoginViewModelTests.\(function).\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
  }

  // MARK: - Sending the email link
  @Test("sending offline shows no connection on the sheet and sends nothing")
  func testSendOfflineIsRefused() async throws {
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: networkMonitor, defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    #expect(viewModel.emailSheetError == .noInternetConnection)
    #expect(viewModel.error == nil)
    #expect(authService.sentLinkEmails.isEmpty)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
    #expect(!viewModel.isEmailLinkSent)
  }

  @Test("a send that fails shows the error on the sheet, not the login screen")
  func testSendFailureShowsOnSheet() async throws {
    let authService = StubAuthService(sendLinkOutcome: .failure(.unknown))
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    let sheetError = viewModel.emailSheetError
    guard case .sendEmailSignInLinkFailed = sheetError else {
      Issue.record("expected sendEmailSignInLinkFailed, got \(String(describing: sheetError))")
      return
    }
    #expect(viewModel.error == nil)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
    #expect(!viewModel.isEmailLinkSent)
  }

  @Test("a send that works saves the email and shows the confirmation")
  func testSendSuccessSavesEmail() async throws {
    let authService = StubAuthService()
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    #expect(authService.sentLinkEmails == [email])
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == email)
    #expect(viewModel.isEmailLinkSent)
    #expect(viewModel.emailSheetError == nil)
  }

  @Test("closing the email sheet forgets an error it was still showing")
  func testClosingSheetClearsItsError() async throws {
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: networkMonitor,
      defaults: try makeDefaults())
    viewModel.email = email
    await viewModel.sendEmailLink()

    viewModel.resetEmailFlow()

    #expect(viewModel.emailSheetError == nil)
  }
}
